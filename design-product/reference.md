# Design Product Reference

## Homepage Layout Templates

Every product homepage follows the same core structure, adapted for the product type.
The layout mirrors the home-page skill pattern: callout intro, browse sections with
2-column sub-page grids, and a full database embed at the bottom.

### Core Layout (all product types)

```
1. Callout intro (bold product name + one-sentence value prop)
2. Browse sections (repeating):
   a. ## Browse by {Property}
   b. Description text explaining the section
   c. <columns> block with sub-pages split 50/50
3. Linked database embed (full database, no filter)
```

### Layout Variations by Product Type

**Knowledge products (Ebook, Guide/Playbook, SOP):**
- Callout emphasizes depth: "X chapters covering..."
- Browse sections: by Topic/Category, by Difficulty, by Module
- Optional toggle: "What's Inside" listing chapters or modules

**Template/Tool products (Template, Checklist, Prompt Pack, Swipe File):**
- Callout emphasizes quantity: "X ready-to-use templates for..."
- Browse sections: by Category, by Use Case, by Industry/Niche
- Optional toggle: "How to Use" with customization instructions

**Skill products (Workbook, Scripts, Online Course):**
- Callout emphasizes transformation: "Master X through Y exercises..."
- Browse sections: by Skill Area, by Difficulty, by Module/Phase
- Optional toggle: "What You'll Learn" listing outcomes

---

## Page-Based Layout (Alternative Delivery Mode)

For products where categories average fewer than ~10 entries each, use page-based
delivery instead of database views. The homepage uses category headings with individual
entry sub-pages containing the actual content — no database embed, no filtered views.

### Database mode vs Page mode

| Aspect | Database Mode | Page Mode |
|--------|--------------|-----------|
| Sub-pages contain | Linked database view (filtered) | Actual content blocks (copied from DB entry) |
| Browse sections | Multiple properties, each a section | ONE primary browse property |
| Database embed | Full DB at bottom of homepage | None (DB is internal-only) |
| Filtered views | Created on each sub-page | Not needed |
| View cleanup scripts | May be needed | Not needed |
| Content-copy script | Not needed | Required (copies blocks from DB entries) |
| Best for | 10+ entries per category | <10 entries per category |

### Page-based homepage structure

```
1. Callout intro (bold product name + entry count + value prop)
2. Content sections (repeating per category option):
   a. ## {icon} {Category Name}
   b. <columns> block with entry sub-pages split 50/50
3. No database embed (database is internal-only)
```

### Page-based callout

```markdown
<callout icon="rocket">
	**{Product Name}.** {N} {product_type_plural} covering {list of category names}.
</callout>
```

### Page-based content sections

```markdown
## {icon} {Category Name}

<columns>
	<column>
		<page url="https://www.notion.so/{entry_id_1}">{Entry Title 1}</page>
		<page url="https://www.notion.so/{entry_id_2}">{Entry Title 2}</page>
	</column>
	<column>
		<page url="https://www.notion.so/{entry_id_3}">{Entry Title 3}</page>
	</column>
</columns>
```

Same column split math as database mode: left = ceil(N/2), right = floor(N/2).
Same indentation rules: tabs, not spaces.

### Primary browse property selection

Page mode organizes by ONE property. Pick the most customer-meaningful one:
1. Primary category (what the product IS) — "Category", "Topic", "Type"
2. Audience/ICP (WHO it's for) — if that's the main differentiator
3. Difficulty/Level — for skill-based products

Other select/multi_select properties remain visible on individual entry pages
as useful context, but don't get their own homepage sections.

---

## Browse Section Selection Rules

### Which properties become browse sections?

**Include if:**
- Property type is `select` or `multi_select`
- Has 3 or more option values
- Represents a customer-facing category (something a buyer would browse by)
- Values are meaningful to the end customer (not internal metadata)

**Exclude if:**
- Property type is `title`, `rich_text`, `url`, `checkbox`, `number`, `date`
- Property type is `status` (internal workflow, not customer-facing)
- Has fewer than 3 option values (not worth a dedicated section)
- Values are internal codes or IDs the customer would not understand
- Property name contains "Internal", "Draft", "Notes", or similar

### Section ordering

Order browse sections by usefulness to the customer:
1. **Primary category** (what the product IS about) — e.g., "Category", "Topic", "Type"
2. **Audience/ICP** (WHO it's for) — e.g., "Industry", "Role", "Niche"
3. **Difficulty/Level** (skill requirement) — e.g., "Difficulty", "Experience Level"
4. **Secondary tags** (nice-to-have filters) — e.g., "Tags", "Format", "Duration"

### Sub-page sort order within sections

- **Categories, tags, niches:** Alphabetical A-Z across both columns
- **Ranges/tiers (price, revenue, difficulty):** Ascending order across both columns
- **Numbered items (chapters, modules):** Numeric order across both columns

---

## Notion-Flavored Markdown for Homepage Content

### Callout block

```markdown
<callout icon="rocket">
	**{Product Name}.** {One-sentence description for the customer.}
</callout>
```

### Section heading + description

```markdown
## Browse by {Property Name}

{1-2 sentence description explaining what this section contains and how to use it.}
```

### Columns with sub-pages

```markdown
<columns>
	<column>
		<page url="https://www.notion.so/{id1}">Sub-page Title 1</page>
		<page url="https://www.notion.so/{id2}">Sub-page Title 2</page>
	</column>
	<column>
		<page url="https://www.notion.so/{id3}">Sub-page Title 3</page>
		<page url="https://www.notion.so/{id4}">Sub-page Title 4</page>
	</column>
</columns>
```

**Indentation rules:**
- `<column>` indented 1 tab inside `<columns>`
- `<page>` tags indented 2 tabs inside `<column>`
- Use tab characters, not spaces

### Column split math

For N sub-pages:
- **Left column:** ceil(N / 2) items
- **Right column:** floor(N / 2) items

Examples: 12 items = 6/6, 15 items = 8/7, 7 items = 4/3, 3 items = 2/1

### Collapsible toggle (optional)

```markdown
<details>
<summary>What's Inside</summary>
	- **{Item 1}** — Description
	- **{Item 2}** — Description
</details>
```

### Database embed

```markdown
<database url="https://www.notion.so/{db-id}" inline="false" icon="emoji" data-source-url="collection://{data-source-id}">Database Title</database>
```

**Critical:** Always include the `data-source-url` attribute to prevent deletion.

### Text escaping

- Dollar signs: `\$1K`, `\$25\$-\$50`
- Standard markdown: `\*`, `\[`, `\]`, `\<`, `\>`

---

## Filtered View Creation Patterns

### How sub-pages get their filtered views

Each sub-page represents one option value from a database property. The sub-page
contains a linked database view filtered to show only entries matching that value.

### Filter DSL by property type

**select property:**
```
FILTER "{Property Name}" = "{option value}";
SORT BY "{Title Property}" ASC;
SHOW "{Title Property}"
```

**multi_select property:**
```
FILTER "{Property Name}" CONTAINS "{option value}";
SORT BY "{Title Property}" ASC;
SHOW "{Title Property}"
```

### Filter value matching

The filter value must **exactly match** the database option value. Common pitfalls:
- En-dashes (`–`) vs hyphens (`-`) in ranges: "\$1K–\$5K" not "\$1K-\$5K"
- Trailing spaces in option names
- Case sensitivity: "Agency Owners" vs "Agency owners"
- Ampersands: "Health & Fitness" not "Health and Fitness"

Always verify by querying the database to list actual option values before building filters.

### Bulk view creation with parallel agents

For efficiency, deploy up to 8 parallel agents. Each agent handles a batch of sub-pages
from the same section (same filter property).

**Agent prompt template:**
```
For each page below, fetch it with notion-fetch to get the database_id from
the linked database embed, then create a list view with notion-create-view.

Pages: [{id, title} list]

For each page use this DSL:
FILTER "{property}" {OPERATOR} "{page_title}";
SORT BY "{title_property}" ASC;
SHOW "{title_property}"

Report which pages succeeded and which failed.
```

---

## Icon Assignment Script Template

Notion MCP cannot set page icons. Use the REST API pattern from the home-page skill.

### Script location
`scripts/set-icons-{slug}.js`

### Script structure

```javascript
const NOTION_TOKEN = process.env.NOTION_TOKEN;

const PAGES = [
  // Section: Browse by Category
  { id: "{32-char-hex-no-dashes}", emoji: "{emoji}", title: "{title}" },
  // Section: Browse by Difficulty
  { id: "{32-char-hex-no-dashes}", emoji: "{emoji}", title: "{title}" },
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

### Icon selection guidelines

- Use icons that visually represent the sub-page content
- Keep icons consistent within a section (e.g., all industry icons for "Browse by Niche")
- For range/tier sections, use progressive icons (e.g., small to large)
- The homepage icon should represent the product as a whole

### Running the script

```bash
NOTION_TOKEN="$NOTION_TOKEN" node scripts/set-icons-{slug}.js
```

The NOTION_TOKEN can be found in `.claude/settings.local.json` or provided by the user.

### Getting page IDs

After creating sub-pages, fetch the homepage with `notion-fetch`. The content contains
`<page url="https://www.notion.so/{id}">` tags — extract the 32-character hex ID from
each URL. Page IDs in the PAGES array use the no-dashes format.

---

## Shareable Link Setup

### Why this is manual

The Notion API (as of 2022-06-28 version) does not support enabling public sharing
programmatically. The "Share to web" toggle can only be set through the Notion UI.

### Instructions for the user

1. Open the homepage in Notion
2. Click **Share** in the top-right corner
3. Click **Publish** tab (or "Share to web" toggle)
4. Toggle **Share to web** ON
5. Configure options:
   - **Allow editing** — ON if the product is a template customers should duplicate
   - **Allow comments** — Usually OFF for products
   - **Allow duplicate as template** — ON for template products
6. Copy the public link
7. Share the link back so it can be saved in `design-config.json`

### Shareable link format

Public Notion links follow this pattern:
```
https://{workspace}.notion.site/{page-title}-{page-id}
```

Or with a custom domain if the user has one configured.

---

## Homepage Creation via API

### Creating the parent homepage

Use `notion-create-pages` MCP tool to create the homepage under the parent page.
Include the title and icon in the creation call.

Alternatively, use the REST API:

```javascript
async function createHomepage(parentPageId, title, emoji) {
  const res = await fetch("https://api.notion.com/v1/pages", {
    method: "POST",
    headers: HEADERS,
    body: JSON.stringify({
      parent: { type: "page_id", page_id: parentPageId },
      icon: { type: "emoji", emoji: emoji },
      properties: {
        title: [{ type: "text", text: { content: title } }],
      },
    }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Failed to create homepage: ${res.status} ${body}`);
  }
  return res.json();
}
```

### Creating sub-pages

Sub-pages are children of the homepage. Create them in batches using the MCP tool
or the REST API. Each sub-page title matches a database option value.

```javascript
async function createSubPage(homepageId, title) {
  const res = await fetch("https://api.notion.com/v1/pages", {
    method: "POST",
    headers: HEADERS,
    body: JSON.stringify({
      parent: { type: "page_id", page_id: homepageId },
      properties: {
        title: [{ type: "text", text: { content: title } }],
      },
    }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Failed to create sub-page "${title}": ${res.status} ${body}`);
  }
  return res.json();
}
```

### Adding a linked database embed to sub-pages

After creating sub-pages, each needs a linked database embed so filtered views can
be created on it. Append a linked database block:

```javascript
async function addLinkedDatabase(pageId, databaseId) {
  // Note: Linked database embeds are best created via MCP tools
  // (notion-update-page with database embed syntax) rather than
  // the REST API, which has limited support for collection_view blocks.
  // Use MCP: notion-update-page with content containing:
  // <database url="https://www.notion.so/{db-id}" inline="false" data-source-url="collection://{data-source-id}">Title</database>
}
```

---

## View Cleanup Patterns (Optional)

If sub-pages end up with unwanted default views, use the subpage-views skill patterns.

### Delete old views

Requires `token_v2` (browser cookie) for the internal API. Follow the template in
the subpage-views reference.md:
- Script location: `scripts/cleanup-views-{slug}.js`
- Uses `loadPageChunk` to find `collection_view` blocks
- Uses `submitTransaction` to remove unwanted view IDs and set `alive: false`

### Hide database titles

Both block-level and view-level titles must be hidden:
- Block-level: `collection_pointer_title_hidden: true` on the block record
- View-level: `hide_linked_collection_name: true` on each collection_view record
- Script location: `scripts/hide-titles-{slug}.js`

See the subpage-views skill reference.md for complete script templates.

---

## Rate Limits

| Operation | Batch Size | Delay | Notes |
|-----------|-----------|-------|-------|
| REST API (set icons) | 5 concurrent | 350ms between batches | Official API limit |
| MCP (create views) | 8 parallel agents | N/A | MCP handles rate limiting |
| Internal API (delete views, hide titles) | 5 concurrent | 500ms between batches | Conservative |
| REST API (create sub-pages) | 5 concurrent | 350ms between batches | Official API limit |

---

## Category Distribution Query Script

Used in Step 1b to verify delivery mode against actual database data.

### Script: `scripts/rewyse-distribution-{slug}.js`

```javascript
const NOTION_TOKEN = process.env.NOTION_TOKEN;
const DATABASE_ID = '{database_id}';
const BROWSE_PROPERTIES = {browse_properties_json}; // e.g., ["Category", "Phase"]

const HEADERS = {
  "Authorization": `Bearer ${NOTION_TOKEN}`,
  "Notion-Version": "2022-06-28",
  "Content-Type": "application/json",
};

async function queryAll() {
  let all = [];
  let cursor = undefined;
  do {
    const res = await fetch(`https://api.notion.com/v1/databases/${DATABASE_ID}/query`, {
      method: 'POST',
      headers: HEADERS,
      body: JSON.stringify({
        filter: { property: 'Status', status: { equals: 'Published' } },
        page_size: 100,
        ...(cursor ? { start_cursor: cursor } : {})
      })
    });
    const data = await res.json();
    all = all.concat(data.results);
    cursor = data.has_more ? data.next_cursor : undefined;
  } while (cursor);
  return all;
}

async function main() {
  if (!NOTION_TOKEN) { console.error("Set NOTION_TOKEN"); process.exit(1); }
  const entries = await queryAll();
  console.log(`Total published: ${entries.length}\n`);

  for (const prop of BROWSE_PROPERTIES) {
    const counts = {};
    for (const entry of entries) {
      const val = entry.properties[prop];
      let key = '(empty)';
      if (val?.select?.name) key = val.select.name;
      else if (val?.multi_select) key = val.multi_select.map(o => o.name).join(', ') || '(empty)';
      counts[key] = (counts[key] || 0) + 1;
    }
    const options = Object.keys(counts).filter(k => k !== '(empty)');
    const avg = options.length > 0 ? (entries.length / options.length).toFixed(1) : 0;
    console.log(`${prop}: ${options.length} options, avg ${avg} entries/option`);
    for (const [k, v] of Object.entries(counts).sort((a, b) => b[1] - a[1])) {
      console.log(`  ${k}: ${v}`);
    }
    console.log('');
  }
}

main().catch(console.error);
```

---

## Content-Copy Script Template (Page Mode)

When using page delivery mode, content from database entry pages must be copied to
the customer-facing sub-pages. The database remains the internal source of truth.

### Script: `scripts/rewyse-copy-content-{slug}.js`

```javascript
const NOTION_TOKEN = process.env.NOTION_TOKEN;

const HEADERS = {
  "Authorization": `Bearer ${NOTION_TOKEN}`,
  "Notion-Version": "2022-06-28",
  "Content-Type": "application/json",
};

// Map: sub-page ID -> source database entry page ID
const PAGE_MAP = [
  // { subPageId: "{sub-page-id}", sourcePageId: "{db-entry-page-id}", title: "{title}" },
];

async function getBlocks(pageId) {
  let all = [];
  let cursor = undefined;
  do {
    const url = new URL(`https://api.notion.com/v1/blocks/${pageId}/children`);
    if (cursor) url.searchParams.set("start_cursor", cursor);
    const res = await fetch(url.toString(), { method: "GET", headers: HEADERS });
    if (!res.ok) throw new Error(`Failed to get blocks: ${res.status}`);
    const data = await res.json();
    all = all.concat(data.results);
    cursor = data.has_more ? data.next_cursor : undefined;
  } while (cursor);
  return all;
}

function cleanBlock(block) {
  const { id, created_time, last_edited_time, created_by, last_edited_by,
          has_children, archived, in_trash, parent, request_id, ...rest } = block;
  const type = rest.type;
  if (rest[type]?.children) {
    rest[type].children = rest[type].children.map(cleanBlock);
  }
  return { object: "block", ...rest };
}

async function appendBlocks(pageId, blocks) {
  for (let i = 0; i < blocks.length; i += 100) {
    const chunk = blocks.slice(i, i + 100);
    const res = await fetch(`https://api.notion.com/v1/blocks/${pageId}/children`, {
      method: "PATCH",
      headers: HEADERS,
      body: JSON.stringify({ children: chunk }),
    });
    if (!res.ok) {
      const body = await res.text();
      throw new Error(`Failed to append blocks: ${res.status} ${body}`);
    }
    if (i + 100 < blocks.length) await new Promise(r => setTimeout(r, 350));
  }
}

async function copyContent(subPageId, sourcePageId, title) {
  const sourceBlocks = await getBlocks(sourcePageId);
  if (sourceBlocks.length === 0) {
    console.log(`SKIP ${title} — source page is empty`);
    return;
  }

  // Fetch child blocks for containers (toggles, callouts with children)
  for (const block of sourceBlocks) {
    if (block.has_children && block.type !== 'child_page' && block.type !== 'child_database') {
      const children = await getBlocks(block.id);
      block[block.type].children = children;
      await new Promise(r => setTimeout(r, 100));
    }
  }

  const cleaned = sourceBlocks
    .filter(b => b.type !== 'child_page' && b.type !== 'child_database')
    .map(cleanBlock);

  await appendBlocks(subPageId, cleaned);
  console.log(`OK ${title} — ${cleaned.length} blocks copied`);
}

async function main() {
  if (!NOTION_TOKEN) { console.error("Set NOTION_TOKEN"); process.exit(1); }
  console.log(`Copying content for ${PAGE_MAP.length} entries...\n`);

  let success = 0, failed = 0;
  for (const { subPageId, sourcePageId, title } of PAGE_MAP) {
    try {
      await copyContent(subPageId, sourcePageId, title);
      success++;
    } catch (err) {
      console.log(`FAIL ${title}: ${err.message}`);
      failed++;
    }
    await new Promise(r => setTimeout(r, 350));
  }
  console.log(`\nDone! ${success} copied, ${failed} failed.`);
}

main().catch(console.error);
```

### Content-copy notes

- **Child blocks:** Blocks with `has_children: true` (toggles, callouts) need children
  fetched separately. The script handles one level of nesting.
- **Unsupported blocks:** `child_page` and `child_database` blocks cannot be copied via
  the API. The script filters these out.
- **Block limit:** Max 100 blocks per append call. The script chunks automatically.
- **Rate limits:** Sequential processing with 350ms delay between entries.
- **Idempotency:** The script does NOT clear existing sub-page content before copying.
  Sub-pages are freshly created and empty during Phase 8, so this is not an issue.
- **Building the PAGE_MAP:** After creating sub-pages (Step 3b) and querying database
  entries, match each sub-page to its source DB entry by title.

---

## design-config.json Schema

### Database mode

```json
{
  "homepage_id": "321e268a-566b-8143-aa25-ffa93c372b5e",
  "homepage_url": "https://www.notion.so/321e268a566b8143aa25ffa93c372b5e",
  "shareable_link": "https://workspace.notion.site/Product-Name-321e268a566b8143aa25ffa93c372b5e",
  "delivery_mode": "database",
  "browse_sections": [
    {
      "heading": "Browse by Category",
      "property": "Category",
      "property_type": "select",
      "sub_page_count": 8,
      "sub_pages": [
        { "title": "Automation", "icon": "gear", "page_id": "abc123..." },
        { "title": "Marketing", "icon": "megaphone", "page_id": "def456..." }
      ]
    }
  ],
  "total_sub_pages": 24,
  "icons_set": 24,
  "database_embed": {
    "database_id": "789abc...",
    "data_source_url": "collection://..."
  },
  "scripts_generated": [
    "scripts/set-icons-{slug}.js"
  ]
}
```

### Page mode

```json
{
  "homepage_id": "321e268a-...",
  "homepage_url": "https://www.notion.so/321e268a...",
  "shareable_link": null,
  "delivery_mode": "page",
  "primary_browse_property": "Category",
  "content_sections": [
    {
      "heading": "Shiny Coat",
      "property": "Category",
      "icon": "emoji",
      "entry_count": 4,
      "entries": [
        {
          "title": "Entry Title",
          "icon": "emoji",
          "page_id": "abc123...",
          "source_db_page_id": "def456..."
        }
      ]
    }
  ],
  "total_entry_pages": 12,
  "icons_set": 12,
  "database_id": "789abc...",
  "scripts_generated": [
    "scripts/set-icons-{slug}.js",
    "scripts/rewyse-copy-content-{slug}.js"
  ]
}
```
