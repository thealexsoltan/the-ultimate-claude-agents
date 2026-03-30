# Subpage Views — Reference

## Notion Internal API

The official Notion API and MCP tools cannot delete views or hide the linked database
title inside views. These operations require Notion's internal API (`/api/v3/`).

### Authentication

Internal API calls require three pieces of authentication:

| Header/Cookie | Value | How to Get |
|--------------|-------|------------|
| `Cookie: token_v2=...` | Browser session token | DevTools → Application → Cookies → notion.so → `token_v2` |
| `x-notion-active-user-header` | User UUID | Discovered via `getSpaces` endpoint |
| `x-notion-space-id` | Space/workspace UUID | Discovered via `getSpaces` endpoint |

### Discovering USER_ID and SPACE_ID

Call `getSpaces` with the token_v2 to enumerate all users and spaces:

```javascript
const res = await fetch("https://www.notion.so/api/v3/getSpaces", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "Cookie": `token_v2=${TOKEN_V2}`,
  },
  body: "{}",
});
const data = await res.json();
// data contains user IDs as top-level keys, each with space_view entries
// containing space IDs
```

Then verify which user+space combination has edit access by calling `syncRecordValues`:

```javascript
const res = await fetch("https://www.notion.so/api/v3/syncRecordValues", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "Cookie": `token_v2=${TOKEN_V2}`,
    "x-notion-active-user-header": userId,
    "x-notion-space-id": spaceId,
  },
  body: JSON.stringify({
    requests: [{
      pointer: { table: "space", id: spaceId },
      version: -1,
    }],
  }),
});
// Check that the returned space record has role: "editor" (not "none" or "read_only")
```

---

## Internal API Endpoints

### loadPageChunk
Loads a page's block tree, including collection_view blocks and their view_ids.

```javascript
async function loadPageChunk(pageId) {
  return apiPost("loadPageChunk", {
    pageId: toUUID(pageId),
    limit: 100,
    cursor: { stack: [] },
    chunkNumber: 0,
    verticalColumns: false,
  });
}
```

**Returns:** `{ recordMap: { block: {...}, collection_view: {...}, ... } }`

The `block` map contains all blocks on the page. Look for blocks with
`type: "collection_view"` and `parent_id` matching the page UUID. These blocks have:
- `view_ids` — Array of view UUIDs
- `format.collection_pointer` — Points to the source collection

The `collection_view` map contains view records with:
- `type` — "list", "table", "board", "gallery", "calendar", "timeline"
- `format` — View-specific formatting including property visibility

### submitTransaction
Applies mutations to Notion records. Used for deleting views and hiding titles.

```javascript
async function submitTransaction(operations) {
  return apiPost("submitTransaction", {
    requestId: crypto.randomUUID(),
    transactions: [{
      id: crypto.randomUUID(),
      spaceId: SPACE_ID,
      operations,
    }],
  });
}
```

Each operation has:
- `id` — The record ID to mutate
- `table` — Record table ("block", "collection_view", etc.)
- `path` — Property path as array (e.g., `["format", "hide_linked_collection_name"]`)
- `command` — "set", "update", "listRemove", etc.
- `args` — The value to set

---

## Script Templates

### Shared: API Helper and UUID Converter

```javascript
const TOKEN_V2 = process.env.NOTION_TOKEN_V2;
const API_BASE = "https://www.notion.so/api/v3";

// Discovered via getSpaces — update for your workspace
const USER_ID = "your-user-id-here";
const SPACE_ID = "your-space-id-here";

function toUUID(id) {
  if (id.includes("-")) return id;
  return `${id.slice(0, 8)}-${id.slice(8, 12)}-${id.slice(12, 16)}-${id.slice(16, 20)}-${id.slice(20)}`;
}

async function apiPost(endpoint, body) {
  const res = await fetch(`${API_BASE}/${endpoint}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Cookie": `token_v2=${TOKEN_V2}`,
      "x-notion-active-user-header": USER_ID,
      "x-notion-space-id": SPACE_ID,
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`${endpoint} failed: ${res.status} ${text}`);
  }
  return res.json();
}
```

### Template: Delete Old Views (cleanup-views-{slug}.js)

Deletes all non-list views from each subpage's linked database and keeps only list views.

```javascript
async function processPage(page) {
  const pageUUID = toUUID(page.id);
  const chunk = await loadPageChunk(page.id);
  const blocks = chunk.recordMap?.block || {};

  // Find the collection_view block that is a direct child of this page
  let collectionViewBlockId = null;
  let viewIds = [];
  for (const [blockId, blockData] of Object.entries(blocks)) {
    const block = blockData.value;
    if (block && block.type === "collection_view" && block.parent_id === pageUUID) {
      collectionViewBlockId = blockId;
      viewIds = block.view_ids || [];
      break;
    }
  }

  if (!collectionViewBlockId) return { status: "no_collection_view" };

  // Classify views by type
  const collectionViews = chunk.recordMap?.collection_view || {};
  const keepViewIds = [];
  const deleteViewIds = [];

  for (const viewId of viewIds) {
    const viewData = collectionViews[viewId];
    if (viewData?.value?.type === "list") {
      keepViewIds.push(viewId);
    } else {
      deleteViewIds.push(viewId);
    }
  }

  if (keepViewIds.length === 0) return { status: "no_list_view" };
  if (deleteViewIds.length === 0) return { status: "already_clean" };

  // Build transaction: update view_ids + mark deleted views as not alive
  const operations = [
    {
      id: collectionViewBlockId,
      table: "block",
      path: ["view_ids"],
      command: "set",
      args: keepViewIds,
    },
    ...deleteViewIds.map((viewId) => ({
      id: viewId,
      table: "collection_view",
      path: ["alive"],
      command: "set",
      args: false,
    })),
  ];

  await submitTransaction(operations);
  return { status: "success", deleted: deleteViewIds.length, kept: keepViewIds.length };
}
```

### Template: Hide Database Titles (hide-titles-{slug}.js)

Hides both the block-level and view-level database titles.

```javascript
async function processPage(page) {
  const pageUUID = toUUID(page.id);
  const chunk = await loadPageChunk(page.id);
  const blocks = chunk.recordMap?.block || {};

  let collectionViewBlockId = null;
  let viewIds = [];
  for (const [blockId, blockData] of Object.entries(blocks)) {
    const block = blockData.value;
    if (block && block.type === "collection_view" && block.parent_id === pageUUID) {
      collectionViewBlockId = blockId;
      viewIds = block.view_ids || [];
      break;
    }
  }

  if (!collectionViewBlockId) return false;

  const operations = [
    // Level 1: Hide the block-level linked database title
    {
      id: collectionViewBlockId,
      table: "block",
      path: ["format", "collection_pointer_title_hidden"],
      command: "set",
      args: true,
    },
    // Level 2: Hide the view-level database name inside each view
    ...viewIds.map((viewId) => ({
      id: viewId,
      table: "collection_view",
      path: ["format", "hide_linked_collection_name"],
      command: "set",
      args: true,
    })),
  ];

  await submitTransaction(operations);
  return true;
}
```

### Main Function Pattern (shared by both scripts)

```javascript
async function main() {
  if (!TOKEN_V2) {
    console.error("ERROR: Set NOTION_TOKEN_V2 environment variable.");
    process.exit(1);
  }

  console.log(`Processing ${PAGES.length} pages...\n`);

  let success = 0, skipped = 0, failed = 0;

  // Process in batches of 5 with 500ms delay
  for (let i = 0; i < PAGES.length; i += 5) {
    const batch = PAGES.slice(i, i + 5);
    const results = await Promise.allSettled(
      batch.map((page) => {
        console.log(`Processing "${page.title}"...`);
        return processPage(page);
      })
    );

    for (let j = 0; j < results.length; j++) {
      if (results[j].status === "fulfilled") {
        const r = results[j].value;
        if (r === true || r?.status === "success") success++;
        else skipped++;
      } else {
        failed++;
        console.log(`  ✗ "${batch[j].title}": ${results[j].reason.message}`);
      }
    }

    if (i + 5 < PAGES.length) {
      await new Promise((r) => setTimeout(r, 500));
    }
  }

  console.log(`\nDone! ${success} processed, ${skipped} skipped, ${failed} failed.`);
}

main().catch(console.error);
```

---

## MCP View Creation — DSL Reference

### Creating a list view with notion-create-view

```
database_id: "{database-id-with-dashes}"
```

**DSL format:**
```
FILTER "{Property Name}" {OPERATOR} "{value}";
SORT BY "{Property Name}" ASC;
SHOW "{Property 1}", "{Property 2}"
```

**Operators by property type:**
| Property Type | Operators |
|--------------|-----------|
| multi_select | CONTAINS, DOES_NOT_CONTAIN |
| select | =, != |
| text/title | CONTAINS, =, STARTS_WITH |
| number | =, >, <, >=, <= |

**Example — filter ICP page:**
```
FILTER "Ideal Customer Profile" CONTAINS "Agency owners";
SORT BY "Company Name" ASC;
SHOW "Product Idea Name"
```

**Example — filter Revenue page:**
```
FILTER "Revenue Range" = "Under $1K";
SORT BY "Company Name" ASC;
SHOW "Product Idea Name"
```

---

## Two Levels of Database Title Hiding

Notion linked databases display a title at two levels. Both must be hidden separately:

### 1. Block-level: `collection_pointer_title_hidden`
- **Target:** The `block` record (table: `"block"`)
- **Path:** `["format", "collection_pointer_title_hidden"]`
- **Effect:** Hides the title bar above the entire linked database block
- **Where it appears:** Above the view tabs

### 2. View-level: `hide_linked_collection_name`
- **Target:** Each `collection_view` record (table: `"collection_view"`)
- **Path:** `["format", "hide_linked_collection_name"]`
- **Effect:** Hides the source database name shown inside the view
- **Where it appears:** Above the list/table/gallery items, below the view tabs

If only Level 1 is set, users still see the database name inside the view.
If only Level 2 is set, users still see the block-level title bar.
**Both must be set** for a fully clean appearance.

---

## Page ID Format

Notion uses two ID formats interchangeably:
- **32-char hex (no dashes):** `321e268a566b817fb05bdc7935f91dc1`
- **UUID (with dashes):** `321e268a-566b-817f-b05b-dc7935f91dc1`

The PAGES array in scripts uses the no-dashes format. The `toUUID()` helper converts
to UUID format when needed for API calls.

The page IDs for subpages can be found in:
- The home page content (`<page url="https://www.notion.so/{id}">`)
- Existing scripts like `scripts/set-subpage-icons.js`
- The Notion page URL in the browser

---

## Rate Limits

| API | Batch Size | Delay | Notes |
|-----|-----------|-------|-------|
| Notion MCP (create-view) | 8 parallel agents | N/A | MCP handles rate limiting |
| Internal API (submitTransaction) | 5 concurrent | 500ms between batches | Conservative to avoid 429s |
| Notion REST API (set icons) | 5 concurrent | 350ms between batches | Official API rate limit |
