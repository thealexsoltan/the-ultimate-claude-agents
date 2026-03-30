---
name: home-page
description: "Use when someone asks to create a home page, build a navigation page, edit home page layout, restructure a home page, set up sub-pages with icons, or organize sub-pages into sections with columns."
---

## Context

Before doing anything, read the full template and rules in [reference.md](reference.md).
All home page content must follow the structure, block syntax, and known workarounds
documented there. Do not guess Notion-flavored markdown syntax — use the reference.

This skill uses Notion MCP tools to create/update page content and a Node.js script
(via the Notion REST API) to set emoji icons on sub-pages, since MCP cannot set page icons.

**Two modes:**
- **Create** — Build a brand-new home page from scratch
- **Edit** — Restructure an existing page to follow the home page pattern

---

## Step 1: Gather Context

Ask the user for:

1. **Mode:** Create new or Edit existing?
2. **Page ID/URL:** (Edit mode) The existing page to restructure. (Create mode) The parent page or workspace location.
3. **Page title and icon emoji** for the home page itself.
4. **Callout intro text** — The bold summary that appears in the callout block at the top.
5. **Callout icon** — Emoji for the callout (default: rocket).

**For Edit mode:** Fetch the existing page using `notion-fetch` to understand its current
structure, existing sub-pages, databases, and content. Present a summary to the user so
they can decide what to keep, reorganize, or remove.

---

## Step 2: Define Navigation Sections

Ask the user to define the navigation sections. Each section needs:

- **Section heading** (e.g., "Browse by Niche / Audience")
- **Section description** (e.g., "Grouped by the type of customer each business serves.")
- **Sub-pages:** A list of sub-page names, each with an emoji icon:
  - e.g., `Agency owners` with icon `agency owners`
  - The user can provide these as a list, a table, or describe the pattern

For each section, confirm:
- The order of sub-pages (alphabetical, ascending value, custom)
- The emoji for each sub-page

**For Edit mode:** Detect existing sub-pages from the fetched content. Present them grouped
by section and ask the user which sections to keep, rename, reorder, or add.

---

## Step 3: Define Supplementary Content

Ask the user about optional content blocks:

1. **Collapsible toggle sections** — Info sections that collapse to save space.
   - Each needs: title + content (bullets, descriptions, or nested toggles)
   - Examples: "What's Inside", "What's in Every Deep Dive", "How It Works"

2. **"How to Navigate" intro text** — Optional paragraph above the navigation sections
   explaining how to use them.

3. **Inline database references** — Any databases to embed on the page.
   - Need: database URL/ID + display title + icon + whether it's inline or sub-page style
   - **Critical:** Always include the `data-source-url` attribute to avoid deletion.

4. **"Also Included" / additional mentions** — Any other pages to mention at the bottom.
   - Need: page URL/ID for each

5. **Dividers** — Whether to add `---` dividers between navigation sections (default: no).

---

## Step 4: Preview & Approve Structure

Present the full page structure as a visual outline. Example:

```
Page Title (icon)
├── Callout: "intro text..."
├── Toggle: What's Inside (4 bullets)
├── Toggle: What's in Every Deep Dive (10 items)
├── How to Navigate
├── ## Browse by Niche / Audience
│   description text
│   ├── Col 1: Agency owners, Bloggers, ... (21 items)
│   └── Col 2: Musicians, Notion users, ... (21 items)
├── ## Browse by Monthly Revenue
│   description text
│   ├── Col 1: Under $1K, ... (4 items)
│   └── Col 2: $25K–$50K, ... (3 items)
├── ## All Case Studies (database embed)
└── ## Also Included (page mention)
```

**Include a count summary:**
- Total sections: X
- Total sub-pages: Y
- Toggle sections: Z
- Databases: N

Wait for user approval. If they request changes, go back to the relevant step.

---

## Step 5: Build Page Content

Generate the full Notion-flavored markdown content following the canonical order
from reference.md. Use these rules:

**Content generation order:**
1. Callout block
2. Collapsible toggle sections
3. "How to Navigate" text (if provided)
4. Navigation sections — for each:
   - `## Section Heading`
   - Description text
   - `<columns>` block with sub-pages split ~50/50 (left = ceil(N/2), right = floor(N/2))
5. Database embed(s)
6. "Also Included" section with `<mention-page>` tags

**For Create mode:**
- Create the home page using `notion-create-pages`
- Then use `notion-update-page` with `replace_content` to set the full content
- Create sub-pages as children of the home page

**For Edit mode:**
- Use `notion-update-page` with `replace_content` to replace the page content
- Reference existing sub-pages by their URLs in `<page url="...">` tags
- **Critical:** Set `allow_deleting_content: true` — the MCP parser has a known
  false-positive bug where it cannot detect `<page>` tags inside `<column>` blocks
  and will incorrectly warn about page deletion. The pages ARE preserved since they
  are referenced in the new content.

**Column formatting rules:**
- Use tab indentation inside `<columns>` and `<column>` blocks
- Sub-pages inside columns must be indented with two tabs
- Escape dollar signs as `\$` in page titles
- Items with natural ordering (price ranges, revenue tiers) keep their order
- Items without natural ordering are alphabetically sorted

**Page icon:** Set the home page icon using `notion-update-page` with `update_properties`
if it's a standalone page, or include it in the create call.

---

## Step 6: Set Sub-Page Icons

Notion MCP cannot set page icons. Use the Notion REST API via a Node.js script.

1. **Generate the script** at `scripts/notion/set-icons-{slug}.js` following this pattern:

```javascript
const NOTION_TOKEN = process.env.NOTION_TOKEN;

const PAGES = [
  // Section: {section name}
  { id: "{page-id-no-dashes}", emoji: "{emoji}", title: "{page title}" },
  // ... all sub-pages
];

async function updatePageIcon(pageId, emoji) {
  const res = await fetch(`https://api.notion.com/v1/pages/${pageId}`, {
    method: "PATCH",
    headers: {
      "Authorization": `Bearer ${NOTION_TOKEN}`,
      "Notion-Version": "2022-06-28",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      icon: { type: "emoji", emoji },
    }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Failed to update ${pageId}: ${res.status} ${body}`);
  }
  return res.json();
}

async function main() {
  if (!NOTION_TOKEN) {
    console.error("ERROR: Set NOTION_TOKEN environment variable first.");
    process.exit(1);
  }
  console.log(`Setting icons for ${PAGES.length} sub-pages...\n`);
  let success = 0;
  let failed = 0;
  for (let i = 0; i < PAGES.length; i += 5) {
    const batch = PAGES.slice(i, i + 5);
    const results = await Promise.allSettled(
      batch.map((page) => updatePageIcon(page.id, page.emoji))
    );
    for (let j = 0; j < results.length; j++) {
      const page = batch[j];
      if (results[j].status === "fulfilled") {
        success++;
        console.log(`OK ${page.emoji} ${page.title}`);
      } else {
        failed++;
        console.log(`FAIL ${page.title}: ${results[j].reason.message}`);
      }
    }
    if (i + 5 < PAGES.length) {
      await new Promise((r) => setTimeout(r, 350));
    }
  }
  console.log(`\nDone! ${success} updated, ${failed} failed.`);
}

main().catch(console.error);
```

2. **Get the page IDs.** For Edit mode, extract IDs from the fetched page content
   (the `<page url="...">` tags contain the ID in the URL). For Create mode, fetch
   the newly created sub-pages to get their IDs.

3. **Run the script:**
   ```bash
   NOTION_TOKEN="$NOTION_TOKEN" node scripts/notion/set-icons-{slug}.js
   ```
   The NOTION_TOKEN value can be found in `.claude/settings.local.json` or the user
   can provide it.

4. Report results: X updated, Y failed. If any failed, offer to retry.

---

## Step 7: Verify & Clean Up

1. **Fetch the final page** using `notion-fetch` to confirm:
   - All sub-pages are present under correct section headers
   - Column layout is intact (pages in `<column>` blocks)
   - Database references are preserved (check `data-source-url`)
   - Toggle sections render correctly

2. **Spot-check icons** — Fetch 2-3 random sub-pages to confirm their `icon=` attribute
   is set correctly.

3. **Present final summary:**
   - Page title and URL
   - Number of sections
   - Number of sub-pages with icons
   - Any warnings or issues

4. **Clean up:** If the icon script was a one-time use, let the user know they can
   delete it from `scripts/`. If it may be reused (e.g., new sub-pages added later),
   suggest keeping it.
