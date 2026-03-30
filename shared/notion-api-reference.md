# Notion REST API Reference — Rewyse AI Skills

Shared reference for all Rewyse AI skills that interact with Notion. Every generated script
must follow the patterns documented here.

---

## Authentication

All Notion API calls require a `NOTION_TOKEN` environment variable (an internal integration token).

**How customers get their token:**
1. Go to https://www.notion.so/my-integrations
2. Click "New integration"
3. Name it (e.g., "AI Product Agent")
4. Select the workspace
5. Copy the "Internal Integration Secret" (starts with `ntn_`)
6. Share target pages/databases with the integration (click "..." → "Connections" → select the integration)

**Validation pattern** — always check at the start of any script:
```javascript
const NOTION_TOKEN = process.env.NOTION_TOKEN;
if (!NOTION_TOKEN) {
  console.error("ERROR: Set NOTION_TOKEN environment variable first.");
  console.error("Run: export NOTION_TOKEN=ntn_your_token_here");
  process.exit(1);
}
```

**Running scripts:**
```bash
NOTION_TOKEN="$NOTION_TOKEN" node scripts/rewyse-{operation}.js
```

---

## Common Headers

Every API call uses these headers:

```javascript
const HEADERS = {
  "Authorization": `Bearer ${NOTION_TOKEN}`,
  "Notion-Version": "2022-06-28",
  "Content-Type": "application/json",
};
```

---

## Core API Endpoints

### 1. Create a Database

`POST https://api.notion.com/v1/databases`

Used by: `/build-database`

```javascript
async function createDatabase(parentPageId, title, properties) {
  const res = await fetch("https://api.notion.com/v1/databases", {
    method: "POST",
    headers: HEADERS,
    body: JSON.stringify({
      parent: { type: "page_id", page_id: parentPageId },
      title: [{ type: "text", text: { content: title } }],
      properties: properties,
    }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Failed to create database: ${res.status} ${body}`);
  }
  return res.json();
}
```

**Properties object format:**
```javascript
const properties = {
  // Title property (required — every database needs exactly one)
  "Name": { title: {} },

  // Rich text
  "Description": { rich_text: {} },

  // Select
  "Category": {
    select: {
      options: [
        { name: "Option A", color: "blue" },
        { name: "Option B", color: "green" },
      ]
    }
  },

  // Multi-select
  "Tags": {
    multi_select: {
      options: [
        { name: "Tag 1", color: "red" },
        { name: "Tag 2", color: "yellow" },
      ]
    }
  },

  // Number
  "Price": { number: { format: "dollar" } },

  // Checkbox
  "Featured": { checkbox: {} },

  // Status (for Draft → Published workflow)
  "Status": {
    status: {
      options: [
        { name: "Draft", color: "default" },
        { name: "In Progress", color: "blue" },
        { name: "Review", color: "yellow" },
        { name: "Published", color: "green" },
      ],
      groups: [
        { name: "To-do", option_ids: [] },
        { name: "In progress", option_ids: [] },
        { name: "Complete", option_ids: [] },
      ]
    }
  },

  // URL
  "Link": { url: {} },
};
```

### 2. Create a Page (Database Entry)

`POST https://api.notion.com/v1/pages`

Used by: `/build-database`, `/generate-content`

```javascript
async function createPage(databaseId, properties, content) {
  const body = {
    parent: { database_id: databaseId },
    properties: properties,
  };

  // Optional: add page content (children blocks)
  if (content) {
    body.children = content;
  }

  const res = await fetch("https://api.notion.com/v1/pages", {
    method: "POST",
    headers: HEADERS,
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Failed to create page: ${res.status} ${text}`);
  }
  return res.json();
}
```

**Properties value format (for page creation):**
```javascript
const pageProperties = {
  "Name": { title: [{ text: { content: "My Page Title" } }] },
  "Description": { rich_text: [{ text: { content: "Some text" } }] },
  "Category": { select: { name: "Option A" } },
  "Tags": { multi_select: [{ name: "Tag 1" }, { name: "Tag 2" }] },
  "Price": { number: 29.99 },
  "Featured": { checkbox: true },
  "Status": { status: { name: "Draft" } },
  "Link": { url: "https://example.com" },
};
```

### 3. Update a Page (Properties)

`PATCH https://api.notion.com/v1/pages/{page_id}`

Used by: `/generate-content`, `/product-qa`

```javascript
async function updatePageProperties(pageId, properties) {
  const res = await fetch(`https://api.notion.com/v1/pages/${pageId}`, {
    method: "PATCH",
    headers: HEADERS,
    body: JSON.stringify({ properties }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Failed to update page ${pageId}: ${res.status} ${body}`);
  }
  return res.json();
}
```

### 4. Append Content to a Page

`PATCH https://api.notion.com/v1/blocks/{block_id}/children`

Used by: `/generate-content`, `/design-product`

```javascript
async function appendContent(pageId, children) {
  const res = await fetch(`https://api.notion.com/v1/blocks/${pageId}/children`, {
    method: "PATCH",
    headers: HEADERS,
    body: JSON.stringify({ children }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Failed to append content to ${pageId}: ${res.status} ${body}`);
  }
  return res.json();
}
```

**Common block types:**
```javascript
const blocks = [
  // Heading 1
  {
    object: "block",
    type: "heading_1",
    heading_1: {
      rich_text: [{ type: "text", text: { content: "Section Title" } }]
    }
  },

  // Paragraph
  {
    object: "block",
    type: "paragraph",
    paragraph: {
      rich_text: [{ type: "text", text: { content: "Paragraph text here." } }]
    }
  },

  // Bulleted list item
  {
    object: "block",
    type: "bulleted_list_item",
    bulleted_list_item: {
      rich_text: [{ type: "text", text: { content: "List item" } }]
    }
  },

  // Callout
  {
    object: "block",
    type: "callout",
    callout: {
      icon: { type: "emoji", emoji: "💡" },
      rich_text: [{ type: "text", text: { content: "Callout text" } }]
    }
  },

  // Divider
  { object: "block", type: "divider", divider: {} },

  // Toggle
  {
    object: "block",
    type: "toggle",
    toggle: {
      rich_text: [{ type: "text", text: { content: "Toggle heading" } }],
      children: [
        {
          object: "block",
          type: "paragraph",
          paragraph: {
            rich_text: [{ type: "text", text: { content: "Hidden content" } }]
          }
        }
      ]
    }
  },
];
```

### 5. Query a Database

`POST https://api.notion.com/v1/databases/{database_id}/query`

Used by: `/generate-content`, `/product-qa`

```javascript
async function queryDatabase(databaseId, filter, sorts, startCursor) {
  const body = {};
  if (filter) body.filter = filter;
  if (sorts) body.sorts = sorts;
  if (startCursor) body.start_cursor = startCursor;

  const res = await fetch(`https://api.notion.com/v1/databases/${databaseId}/query`, {
    method: "POST",
    headers: HEADERS,
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Failed to query database: ${res.status} ${text}`);
  }
  return res.json();
}

// Paginate through all results
async function queryAllPages(databaseId, filter, sorts) {
  let allResults = [];
  let startCursor = undefined;
  let hasMore = true;

  while (hasMore) {
    const response = await queryDatabase(databaseId, filter, sorts, startCursor);
    allResults = allResults.concat(response.results);
    hasMore = response.has_more;
    startCursor = response.next_cursor;
  }

  return allResults;
}
```

**Common filters:**
```javascript
// Filter by Status = "Draft"
const draftFilter = {
  property: "Status",
  status: { equals: "Draft" }
};

// Filter by Status = "Published"
const publishedFilter = {
  property: "Status",
  status: { equals: "Published" }
};

// Compound filter (AND)
const compoundFilter = {
  and: [
    { property: "Status", status: { equals: "Draft" } },
    { property: "Category", select: { equals: "Recipes" } },
  ]
};
```

### 6. Retrieve a Page

`GET https://api.notion.com/v1/pages/{page_id}`

Used by: `/product-qa`

```javascript
async function getPage(pageId) {
  const res = await fetch(`https://api.notion.com/v1/pages/${pageId}`, {
    method: "GET",
    headers: HEADERS,
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Failed to get page ${pageId}: ${res.status} ${body}`);
  }
  return res.json();
}
```

### 7. Get Page Content (Blocks)

`GET https://api.notion.com/v1/blocks/{block_id}/children`

Used by: `/product-qa`

```javascript
async function getPageContent(pageId) {
  let allBlocks = [];
  let startCursor = undefined;
  let hasMore = true;

  while (hasMore) {
    const url = new URL(`https://api.notion.com/v1/blocks/${pageId}/children`);
    if (startCursor) url.searchParams.set("start_cursor", startCursor);

    const res = await fetch(url.toString(), { method: "GET", headers: HEADERS });
    if (!res.ok) {
      const body = await res.text();
      throw new Error(`Failed to get blocks for ${pageId}: ${res.status} ${body}`);
    }
    const data = await res.json();
    allBlocks = allBlocks.concat(data.results);
    hasMore = data.has_more;
    startCursor = data.next_cursor;
  }

  return allBlocks;
}
```

### 8. Delete All Page Content (Before Replacing)

To replace page content, first delete existing blocks, then append new ones.

```javascript
async function clearPageContent(pageId) {
  const blocks = await getPageContent(pageId);
  for (const block of blocks) {
    await fetch(`https://api.notion.com/v1/blocks/${block.id}`, {
      method: "DELETE",
      headers: HEADERS,
    });
    await new Promise(r => setTimeout(r, 100)); // Rate limit buffer
  }
}
```

### 9. Set Page Icon

`PATCH https://api.notion.com/v1/pages/{page_id}`

Used by: `/design-product`

```javascript
async function setPageIcon(pageId, emoji) {
  const res = await fetch(`https://api.notion.com/v1/pages/${pageId}`, {
    method: "PATCH",
    headers: HEADERS,
    body: JSON.stringify({
      icon: { type: "emoji", emoji },
    }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Failed to set icon for ${pageId}: ${res.status} ${body}`);
  }
  return res.json();
}
```

---

## Batch Processing Pattern

For operations on multiple items (entries, pages, icons), use this pattern:

```javascript
async function processBatch(items, operation, batchSize = 5, delayMs = 350) {
  let success = 0;
  let failed = 0;
  const errors = [];

  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    const results = await Promise.allSettled(
      batch.map((item) => operation(item))
    );

    for (let j = 0; j < results.length; j++) {
      if (results[j].status === "fulfilled") {
        success++;
        console.log(`OK [${i + j + 1}/${items.length}] ${batch[j].name || batch[j].id}`);
      } else {
        failed++;
        errors.push({ item: batch[j], error: results[j].reason.message });
        console.log(`FAIL [${i + j + 1}/${items.length}] ${batch[j].name || batch[j].id}: ${results[j].reason.message}`);
      }
    }

    // Rate limit buffer between batches
    if (i + batchSize < items.length) {
      await new Promise((r) => setTimeout(r, delayMs));
    }
  }

  console.log(`\nDone! ${success} succeeded, ${failed} failed out of ${items.length}.`);
  return { success, failed, errors };
}
```

---

## Script Boilerplate

Every generated Notion script should follow this structure:

```javascript
// scripts/rewyse-{operation}.js
// Description: {what this script does}

const NOTION_TOKEN = process.env.NOTION_TOKEN;

const HEADERS = {
  "Authorization": `Bearer ${NOTION_TOKEN}`,
  "Notion-Version": "2022-06-28",
  "Content-Type": "application/json",
};

// --- API Functions (only include what's needed) ---

// ... (from the endpoint patterns above)

// --- Main ---

async function main() {
  if (!NOTION_TOKEN) {
    console.error("ERROR: Set NOTION_TOKEN environment variable first.");
    console.error("Run: export NOTION_TOKEN=ntn_your_token_here");
    process.exit(1);
  }

  // ... script logic here
}

main().catch((err) => {
  console.error("Script failed:", err.message);
  process.exit(1);
});
```

---

## Important Notes

- **Dollar signs:** Escape `$` as `\$` in any text content written to Notion. Notion renders unescaped `$` as inline LaTeX math.
- **Rate limits:** Notion API allows ~3 requests/second. The batch pattern with 5 concurrent + 350ms delay stays well within limits.
- **Page IDs:** Can be with or without dashes. The API accepts both formats. When extracting from URLs, the ID is the 32-character hex string at the end.
- **Rich text limit:** Each rich_text array element has a 2000-character limit. For longer content, split into multiple elements.
- **Block append limit:** You can append up to 100 blocks per API call. For longer content, split into multiple append calls.
- **No npm dependencies:** All scripts use only `fetch` (built into Node.js 18+). No `package.json` needed.
- **Parent page sharing:** The customer must share the parent page (or workspace) with their integration for database creation to work.
