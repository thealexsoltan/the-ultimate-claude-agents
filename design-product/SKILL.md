---
name: design-product
description: "Use when someone asks to design a product homepage, create browse sections, set up filtered views for a product, publish a Notion product, add icons to product pages, or make a product look professional and navigable."
---

## Context

Before doing anything, read these references:
- [reference.md](reference.md) — Homepage layout templates, browse section patterns, filtered
  view creation, icon scripts, shareable link setup
- [notion-api-reference.md](../shared/notion-api-reference.md) — API patterns for all
  generated scripts

This skill is **Phase 8 of the Rewyse AI pipeline** — it turns a populated database into a
polished, shareable product. It creates a homepage with organized browse sections, sets up
filtered views, adds icons, and publishes the product as a shareable Notion link.

This skill uses Notion MCP tools for page creation/content and Node.js scripts (via the
Notion REST API) for operations MCP cannot handle (setting icons, enabling public sharing).

**State directory:** `rewyse-ai/output/{project-slug}/`
- **Reads:** `database-config.json` (database_id, properties, parent_page_id),
  `product-idea.md` (product type, niche, ICP, variables)
- **Writes:** `design-config.json` (homepage_id, shareable_link, browse_sections, icon_count)

If running standalone, ask the user for database ID, parent page, and product context directly.

---

## Step 1: Load Product Context

**If orchestrated:** Read from the state directory:
- `product-idea.md` — Product name, type, niche, ICP, variables (select/multi_select properties)
- `database-config.json` — database_id, parent_page_id, property definitions

Extract the information needed for homepage design:
- **Product name** — Used for homepage title
- **Product type** — Determines the homepage layout template (see reference.md)
- **Browse-worthy properties** — All `select` and `multi_select` properties from the database
  (these become browse sections)
- **Database ID** — For linked database embed and filtered views
- **Parent page ID** — Where the homepage will be created
- **Delivery mode** — From `state.json → delivery_mode` (may be `"page"`, `"database"`, or `null`)

**If standalone:** Ask the user for:
1. Database URL/ID
2. Parent page URL/ID (where to create the homepage)
3. Product name
4. Product type (or describe what it is)

Fetch the database with `notion-fetch` to discover its properties.

---

## Step 1b: Verify Delivery Mode

Regardless of what Phase 1 recommended, verify the mode against actual database
distribution now that all entries exist.

### Query category distribution

Generate and run a Node.js script (template in reference.md: `rewyse-distribution-{slug}.js`)
to count published entries per option value for all browse-worthy `select`/`multi_select`
properties.

### Decision logic

1. For each browse-worthy property, compute: `entries_per_option = total_published / option_count`
2. If ALL properties have avg >= 10 entries per option → recommend `database`
3. If ANY primary category property has avg < 10 → recommend `page`

### Present verification result

If the verified mode matches `state.json → delivery_mode`:
> **Delivery mode confirmed:** `{mode}` — {reasoning with actual numbers}.

If the verified mode DIFFERS from the recommendation:
> **Delivery mode update:** Phase 1 recommended `{old_mode}`, but with {N} entries
> across {M} categories (avg {avg}/category), `{new_mode}` will look better.
>
> Switch to `{new_mode}`? Or keep `{old_mode}`?

Wait for user confirmation. Record the final mode choice.

### Page mode: select primary browse property

If mode is `page`, the homepage organizes by ONE primary browse property. Present
the browse-worthy properties ranked by customer relevance (see reference.md) and ask:

> **Primary browse property for page layout:**
> 1. {Property A} — {N} options, {avg} entries each
> 2. {Property B} — {N} options, {avg} entries each
>
> Which property should organize the homepage?

---

## Step 2: Plan Homepage Structure

### If delivery mode is `database`:

Analyze the database properties to determine which become browse sections. Use the
selection rules from reference.md.

**For each select/multi_select property with 3+ options:**
- **Section heading** — e.g., "Browse by Category", "Browse by Difficulty"
- **Sub-pages** — One per option value (each sub-page will get a filtered view)
- **Icon** — Assign a relevant emoji per sub-page
- **Sort order** — Alphabetical for categories/tags, ascending for ranges/tiers

**Skip properties that are:**
- Title (not browseable)
- Rich text, URL, checkbox (not categorical)
- Select/multi_select with fewer than 3 options (not worth a section)
- Status properties (internal, not customer-facing)

Present the browse section plan:

```
## Homepage Structure: {Product Name}

Homepage icon: {emoji}
Callout: "{One-sentence product description for the customer}"

### Browse Sections:
1. Browse by {Property 1} — {N} sub-pages
   {list of sub-page names with icons}
2. Browse by {Property 2} — {N} sub-pages
   {list of sub-page names with icons}
...

### Database Embed:
Full database view at the bottom (all entries)

### Totals:
- Sections: {N}
- Sub-pages: {N}
- Database embeds: 1
```

Wait for user approval. If they want to add/remove sections, reorder, change icons,
or adjust the callout text, make changes and re-present.

### If delivery mode is `page`:

Query the database for all published entries, grouped by the primary browse property.

Present the page-based homepage plan:

> ## Homepage Structure: {Product Name} (page mode)
>
> Homepage icon: {emoji}
> Callout: "{Count} {product_type} entries covering {categories}..."
>
> ### Content Sections:
> 1. {icon} {Category 1} — {N} entries
>    - {Entry 1 title}, {Entry 2 title}, ...
> 2. {icon} {Category 2} — {N} entries
>    - {Entry 3 title}, ...
>
> ### Totals:
> - Categories: {N}
> - Entry sub-pages: {N}
> - No database embed (content lives in sub-pages)

Wait for user approval.

---

## Step 3: Build the Homepage

### Query Published Entry Count

Before assembling the homepage, generate and run a Node.js script to count published entries:

```javascript
// rewyse-ai/scripts/rewyse-count-published-{slug}.js
const databaseId = '{database_id}';
const token = process.env.NOTION_TOKEN;

async function countPublished() {
  let count = 0;
  let cursor = undefined;
  do {
    const res = await fetch(`https://api.notion.com/v1/databases/${databaseId}/query`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Notion-Version': '2022-06-28',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        filter: { property: 'Status', status: { equals: 'Published' } },
        page_size: 100,
        ...(cursor ? { start_cursor: cursor } : {})
      })
    });
    const data = await res.json();
    count += data.results.length;
    cursor = data.has_more ? data.next_cursor : undefined;
  } while (cursor);
  console.log(count);
}
countPublished();
```

Use this count for the homepage callout: "{count} {product_type} entries covering..."

### Build the Homepage

Create the homepage following the home-page skill pattern (callout intro, sections
with 2-column sub-page layouts).

**3a. Create the homepage:**
- Use `notion-create-pages` to create the homepage under the parent page
- Set the title to the product name
- Set the icon emoji

**3b. Create sub-pages:**
- Create all sub-pages as children of the homepage using `notion-create-pages`
- Group by section (batch all sub-pages for one section together)

**3c. Build homepage content:**
Use `notion-update-page` with `replace_content` to set the full content.

**Content order:**
1. Callout block with product intro
2. `## Browse by {Property}` heading for each section
3. Description text under each heading
4. `<columns>` block with sub-pages split 50/50 (left = ceil(N/2), right = floor(N/2))
5. Linked database embed at the bottom (full database, no filter)

**Column formatting rules:**
- Tab indentation inside `<columns>` and `<column>` blocks
- Sub-pages inside columns indented with two tabs
- Escape dollar signs as `\$` in titles
- Natural ordering (price ranges, tiers) keeps ascending order
- Non-natural ordering (categories, tags) sorted alphabetically

**Critical:** Set `allow_deleting_content: true` when using `replace_content` — MCP
cannot detect `<page>` tags inside `<column>` blocks (known false-positive bug).

### Step 3 — Page Mode Alternative

If delivery mode is `page`, the homepage build works differently:

**3a. Create the homepage** (same as database mode — `notion-create-pages` under parent page)

**3b. Create entry sub-pages:**
For each published entry, create a sub-page under the homepage using the REST API
(`POST /v1/pages` with `parent: { page_id: homepage_id }`). Use batches of 5 with
350ms delay. Title each sub-page with the entry title.

**3c. Build homepage content:**
Use `notion-update-page` with `replace_content`. Content order:
1. Callout block with product intro + count
2. For each category in the primary browse property:
   - `## {icon} {Category Name}` heading
   - `<columns>` block with entry sub-pages split 50/50
3. No database embed at the bottom

Use the page-based layout template from reference.md. Same column formatting rules
and `allow_deleting_content: true`.

**3d. Copy content from database entries to sub-pages:**
Generate and run the content-copy script (template in reference.md:
`rewyse-copy-content-{slug}.js`). The script reads blocks from each database entry
page, cleans them (strips IDs), and appends them to the corresponding sub-page.
Build the PAGE_MAP by matching sub-page titles to database entry titles.

---

## Step 4: Create Filtered Views on Sub-Pages (database mode only)

**Skip this step entirely if delivery mode is `page`.** Page-based products have actual
content in sub-pages — no filtered database views needed.

Each sub-page gets a linked database view filtered to show only matching entries.

**4a. Pilot test (2 sub-pages):**
Pick one sub-page from each section. For each:
1. Fetch the sub-page with `notion-fetch` to get the linked database's `database_id`
2. Use `notion-create-view` with the filter DSL:

```
FILTER "{Property Name}" {OPERATOR} "{sub-page title}";
SORT BY "{Title Property}" ASC;
SHOW "{Title Property}"
```

Operators by property type:
- `select` properties: use `=`
- `multi_select` properties: use `CONTAINS`

Ask the user to verify the pilot pages look correct before continuing.

**4b. Bulk view creation:**
Deploy parallel agents (up to 8) to create views on all remaining sub-pages.
Group by section so each agent uses the same filter property.

**4c. Delete default table views (optional):**
If sub-pages were created with a default table view that should be removed, generate
a cleanup script following the subpage-views pattern (see reference.md). This requires
the user's `token_v2` for the internal API.

**4d. Hide database titles (optional):**
Generate a hide-titles script to remove the linked database title from sub-pages.
Both block-level and view-level titles must be hidden (see reference.md).

---

## Step 5: Set Sub-Page Icons

Notion MCP cannot set page icons. Use the Notion REST API via a Node.js script.

1. **Generate the script** at `scripts/notion/set-icons-{slug}.js`:

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

2. **Get page IDs** by fetching the homepage with `notion-fetch` to extract sub-page
   IDs from the `<page url="...">` tags.

3. **Run the script:**
   ```bash
   NOTION_TOKEN="$NOTION_TOKEN" node scripts/notion/set-icons-{slug}.js
   ```

4. Report results: X updated, Y failed. If any failed, offer to retry.

---

## Step 6: Enable Public Sharing

Make the homepage shareable via a public Notion link.

The Notion API does not support enabling public sharing programmatically.
Guide the user through the manual steps:

1. Open the homepage in Notion
2. Click "Share" in the top-right
3. Toggle "Share to web" ON
4. Optionally enable "Allow editing" if the product is a template
5. Copy the public link and share it back

Record the shareable link in `design-config.json`.

---

## Step 7: Save State & Verify

**7a. Write `design-config.json`:**

Use the schema from reference.md — **database mode** or **page mode** depending on the
delivery mode chosen in Step 1b. Include `delivery_mode` in the config.

**7b. Verify the homepage:**
Fetch the final page with `notion-fetch` to confirm:
- All sub-pages present under correct section headers
- Column layout intact
- Callout renders correctly
- Database mode: database embed preserved (check `data-source-url`)
- Page mode: entry sub-pages have content (spot-check 2-3)

**7c. Spot-check icons:**
Fetch 2-3 random sub-pages to confirm their icons are set correctly.

**7d. Present final summary:**

```
## Product Design Complete

**Homepage:** {title}
**URL:** {notion_url}
**Delivery mode:** {page|database}
**Shareable link:** {public_link or "pending -- user needs to enable Share to web"}

Database mode:
  **Browse sections:** {N}
  **Total sub-pages:** {N} (with icons and filtered views)
  **Database embed:** Full database at bottom

Page mode:
  **Content sections:** {N} categories
  **Total entry pages:** {N} (with icons and content)
  **Primary browse property:** {property_name}

**Scripts generated:**
- scripts/notion/set-icons-{slug}.js
- {page mode: rewyse-ai/scripts/rewyse-copy-content-{slug}.js}

**State saved:** rewyse-ai/output/{project-slug}/design-config.json
```

**If orchestrated:** Update `state.json`: set phase `8_design_product` to `status: "approved"`.

---

## Notes

- **Browse section selection is the key design decision.** Not every property needs a section.
  Focus on properties customers would naturally browse by (category, difficulty, topic) and
  skip internal properties (status, date created).
- **Dollar signs in titles:** Always escape as `\$` in Notion content. Revenue ranges like
  "\$1K-\$5K" must be escaped or Notion renders them as LaTeX.
- **En-dashes vs hyphens:** Range values in Notion often use en-dashes. Match exactly what
  the database options use.
- **MCP false-positive warnings:** When replacing content with pages inside columns, set
  `allow_deleting_content: true`. The pages ARE preserved -- MCP just cannot detect them.
- **Icon assignment:** Choose icons that are intuitive for the content. Use consistent icon
  families within a section (e.g., all food emojis for recipe categories).
- **Public sharing limitations:** The Notion API cannot toggle "Share to web." This is a
  manual step the user must complete in the Notion UI.
- **Filtered views require the sub-page to already contain a linked database embed.**
  If sub-pages are empty, add the database embed first, then create the filtered view.
- **If running standalone** (no state directory), write `design-config.json` to
  `output/design-product/{slug}/design-config.json` instead.
- **Delivery mode is verified, not assumed.** Even if Phase 1 recommended a mode,
  Step 1b verifies against actual entry distribution. Real data overrides estimates.
- **Page mode copies content, not moves it.** Database entries keep their content for
  QA (Phase 9). Sub-pages get copies. If QA triggers re-generation, re-run the
  content-copy script for affected entries.
