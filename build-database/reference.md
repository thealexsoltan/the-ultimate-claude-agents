# Build Database — Reference

Companion reference for the `/build-database` skill. Contains the property type catalog,
complete script templates, sample entry generation patterns, and troubleshooting guide.

---

## Property Type Catalog

### Mapping: Product Variable Types to Notion Property Types

| Variable Type | Notion Property | API Key | When to Use |
|---------------|----------------|---------|-------------|
| title | Title | `title` | The main name/identifier. Exactly one per database. |
| text | Rich Text | `rich_text` | Freeform text: descriptions, summaries, notes. |
| select | Select | `select` | Single choice from a fixed list (e.g., Category, Difficulty). |
| multi_select | Multi-select | `multi_select` | Multiple choices from a list (e.g., Tags, Ingredients). |
| number | Number | `number` | Numeric values: price, duration, count, rating. |
| checkbox | Checkbox | `checkbox` | Boolean flags: Featured, Premium, Completed. |
| url | URL | `url` | Links: source URL, reference link, video link. |
| status | Status | `status` | Workflow state. Always use the standard 4-status config. |

### Number Formats

| Format | API Value | Use For |
|--------|-----------|---------|
| Plain number | `"number"` | Counts, ratings, quantities |
| Dollar | `"dollar"` | Prices, revenue, cost |
| Percent | `"percent"` | Rates, percentages |
| Euro | `"euro"` | European pricing |
| Pound | `"pound"` | UK pricing |

### Color Rotation for Select/Multi-select Options

Assign colors in this order. Cycle back to the start after exhausting the list:

```
blue, green, orange, red, purple, pink, yellow, gray, brown
```

Example with 4 options:
```javascript
options: [
  { name: "Beginner", color: "blue" },
  { name: "Intermediate", color: "green" },
  { name: "Advanced", color: "orange" },
  { name: "Expert", color: "red" },
]
```

---

## Status Workflow Configuration

Every database uses this exact status configuration:

```javascript
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
}
```

**Note:** Notion auto-assigns options to groups based on their position. The `option_ids`
arrays are left empty — Notion populates them on creation.

---

## Complete Script Template: Database Creation

Use this as the base for every `scripts/rewyse-create-db-{slug}.js` file.
Replace placeholders marked with `{PLACEHOLDER}`.

```javascript
// scripts/rewyse-create-db-{SLUG}.js
// Description: Creates the "{DATABASE_TITLE}" Notion database and seeds sample entries.

const NOTION_TOKEN = process.env.NOTION_TOKEN;
const PARENT_PAGE_ID = "{PARENT_PAGE_ID}";

const HEADERS = {
  "Authorization": `Bearer ${NOTION_TOKEN}`,
  "Notion-Version": "2022-06-28",
  "Content-Type": "application/json",
};

// --- Database Schema ---

const DATABASE_TITLE = "{DATABASE_TITLE}";

const DATABASE_PROPERTIES = {
  "Name": { title: {} },

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
      ],
    },
  },

  // {ADDITIONAL_PROPERTIES}
  // Add each property from the approved schema here.
  // Examples:
  // "Description": { rich_text: {} },
  // "Category": { select: { options: [{ name: "A", color: "blue" }, { name: "B", color: "green" }] } },
  // "Tags": { multi_select: { options: [{ name: "Tag1", color: "blue" }] } },
  // "Price": { number: { format: "dollar" } },
  // "Featured": { checkbox: {} },
  // "Link": { url: {} },
};

// --- Sample Entries ---

const SAMPLE_ENTRIES = [
  // {SAMPLE_ENTRIES}
  // Each entry is an object with property values matching the schema.
  // Example:
  // {
  //   "Name": { title: [{ text: { content: "Sample Entry 1" } }] },
  //   "Status": { status: { name: "Draft" } },
  //   "Category": { select: { name: "A" } },
  //   "Description": { rich_text: [{ text: { content: "A sample description." } }] },
  // },
];

// --- API Functions ---

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

async function createPage(databaseId, properties) {
  const res = await fetch("https://api.notion.com/v1/pages", {
    method: "POST",
    headers: HEADERS,
    body: JSON.stringify({
      parent: { database_id: databaseId },
      properties: properties,
    }),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Failed to create page: ${res.status} ${text}`);
  }
  return res.json();
}

// --- Main ---

async function main() {
  if (!NOTION_TOKEN) {
    console.error("ERROR: Set NOTION_TOKEN environment variable first.");
    console.error("Run: export NOTION_TOKEN=ntn_your_token_here");
    process.exit(1);
  }

  // Step 1: Create the database
  console.log(`Creating database "${DATABASE_TITLE}"...`);
  const db = await createDatabase(PARENT_PAGE_ID, DATABASE_TITLE, DATABASE_PROPERTIES);
  const databaseId = db.id;
  console.log(`Database created! ID: ${databaseId}`);
  console.log(`URL: https://www.notion.so/${databaseId.replace(/-/g, "")}`);

  // Step 2: Seed sample entries
  if (SAMPLE_ENTRIES.length > 0) {
    console.log(`\nCreating ${SAMPLE_ENTRIES.length} sample entries...`);
    const entryIds = [];

    const results = await Promise.allSettled(
      SAMPLE_ENTRIES.map((entry) => createPage(databaseId, entry))
    );

    let success = 0;
    let failed = 0;
    for (let i = 0; i < results.length; i++) {
      if (results[i].status === "fulfilled") {
        success++;
        const title = SAMPLE_ENTRIES[i]["Name"]?.title?.[0]?.text?.content || `Entry ${i + 1}`;
        const pageId = results[i].value.id;
        entryIds.push(pageId);
        console.log(`OK [${i + 1}/${SAMPLE_ENTRIES.length}] ${title}`);
      } else {
        failed++;
        console.log(`FAIL [${i + 1}/${SAMPLE_ENTRIES.length}]: ${results[i].reason.message}`);
      }
    }
    console.log(`\nEntries: ${success} created, ${failed} failed.`);

    // Output entry IDs for downstream use
    console.log(`\nSAMPLE_ENTRY_IDS=${JSON.stringify(entryIds)}`);
  }

  // Output database ID for downstream use
  console.log(`\nDATABASE_ID=${databaseId}`);
}

main().catch((err) => {
  console.error("Script failed:", err.message);
  process.exit(1);
});
```

---

## Script Template: Add Entries to Existing Database

Use this when adding more entries to an already-created database.
Script path: `scripts/rewyse-seed-db-{slug}.js`

```javascript
// scripts/rewyse-seed-db-{SLUG}.js
// Description: Adds entries to the "{DATABASE_TITLE}" database.

const NOTION_TOKEN = process.env.NOTION_TOKEN;
const DATABASE_ID = "{DATABASE_ID}";

const HEADERS = {
  "Authorization": `Bearer ${NOTION_TOKEN}`,
  "Notion-Version": "2022-06-28",
  "Content-Type": "application/json",
};

const ENTRIES = [
  // Each entry follows the page properties format:
  // {
  //   "Name": { title: [{ text: { content: "Entry Title" } }] },
  //   "Status": { status: { name: "Draft" } },
  //   "Category": { select: { name: "Option A" } },
  // },
];

async function createPage(databaseId, properties) {
  const res = await fetch("https://api.notion.com/v1/pages", {
    method: "POST",
    headers: HEADERS,
    body: JSON.stringify({
      parent: { database_id: databaseId },
      properties: properties,
    }),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Failed to create page: ${res.status} ${text}`);
  }
  return res.json();
}

async function main() {
  if (!NOTION_TOKEN) {
    console.error("ERROR: Set NOTION_TOKEN environment variable first.");
    console.error("Run: export NOTION_TOKEN=ntn_your_token_here");
    process.exit(1);
  }

  console.log(`Adding ${ENTRIES.length} entries to database ${DATABASE_ID}...\n`);

  let success = 0;
  let failed = 0;

  // Process in batches of 5 to respect rate limits
  for (let i = 0; i < ENTRIES.length; i += 5) {
    const batch = ENTRIES.slice(i, i + 5);
    const results = await Promise.allSettled(
      batch.map((entry) => createPage(DATABASE_ID, entry))
    );

    for (let j = 0; j < results.length; j++) {
      const idx = i + j;
      const title = batch[j]["Name"]?.title?.[0]?.text?.content || `Entry ${idx + 1}`;
      if (results[j].status === "fulfilled") {
        success++;
        console.log(`OK [${idx + 1}/${ENTRIES.length}] ${title}`);
      } else {
        failed++;
        console.log(`FAIL [${idx + 1}/${ENTRIES.length}] ${title}: ${results[j].reason.message}`);
      }
    }

    // Rate limit buffer between batches
    if (i + 5 < ENTRIES.length) {
      await new Promise((r) => setTimeout(r, 350));
    }
  }

  console.log(`\nDone! ${success} created, ${failed} failed out of ${ENTRIES.length}.`);
}

main().catch((err) => {
  console.error("Script failed:", err.message);
  process.exit(1);
});
```

---

## Sample Entry Generation Patterns by Product Type

When generating sample entries, use these patterns to create realistic, niche-appropriate data.

### Ebook / Guide / Playbook

Entries represent chapters or sections:
```javascript
{
  "Name": { title: [{ text: { content: "Chapter 3: The Morning Routine Protocol" } }] },
  "Status": { status: { name: "Draft" } },
  "Chapter Number": { number: 3 },
  "Section": { select: { name: "Foundations" } },
  "Word Count Target": { number: 2500 },
}
```

### SOP (Standard Operating Procedure)

Entries represent individual procedures:
```javascript
{
  "Name": { title: [{ text: { content: "Client Onboarding Checklist" } }] },
  "Status": { status: { name: "Draft" } },
  "Department": { select: { name: "Operations" } },
  "Complexity": { select: { name: "Medium" } },
  "Estimated Time": { rich_text: [{ text: { content: "45 minutes" } }] },
}
```

### Template

Entries represent individual templates:
```javascript
{
  "Name": { title: [{ text: { content: "Weekly Sprint Planning Template" } }] },
  "Status": { status: { name: "Draft" } },
  "Category": { select: { name: "Project Management" } },
  "Use Case": { rich_text: [{ text: { content: "Plan weekly team sprints with task assignments and priorities." } }] },
  "Difficulty": { select: { name: "Beginner" } },
}
```

### Checklist

Entries represent individual checklists:
```javascript
{
  "Name": { title: [{ text: { content: "Pre-Launch SEO Audit" } }] },
  "Status": { status: { name: "Draft" } },
  "Category": { select: { name: "SEO" } },
  "Items Count": { number: 24 },
  "Time to Complete": { select: { name: "30 min" } },
}
```

### Prompt Pack

Entries represent individual prompts:
```javascript
{
  "Name": { title: [{ text: { content: "Cold Email Opener — Pain Point Angle" } }] },
  "Status": { status: { name: "Draft" } },
  "Category": { select: { name: "Email" } },
  "AI Tool": { select: { name: "ChatGPT" } },
  "Use Case": { rich_text: [{ text: { content: "Write a cold email opener that leads with the prospect's pain point." } }] },
}
```

### Swipe File

Entries represent individual examples/swipes:
```javascript
{
  "Name": { title: [{ text: { content: "Apple — 'Think Different' Campaign" } }] },
  "Status": { status: { name: "Draft" } },
  "Category": { select: { name: "Brand Campaign" } },
  "Source": { url: "https://example.com/source" },
  "Why It Works": { rich_text: [{ text: { content: "Positions the brand as a rebel identity, not a product." } }] },
}
```

### Scripts

Entries represent individual scripts:
```javascript
{
  "Name": { title: [{ text: { content: "Discovery Call — Budget Qualifier" } }] },
  "Status": { status: { name: "Draft" } },
  "Script Type": { select: { name: "Sales Call" } },
  "Duration": { select: { name: "5-10 min" } },
  "Tone": { select: { name: "Consultative" } },
}
```

### Workbook

Entries represent exercises or worksheets:
```javascript
{
  "Name": { title: [{ text: { content: "Exercise 5: Identify Your Core Values" } }] },
  "Status": { status: { name: "Draft" } },
  "Module": { select: { name: "Self-Discovery" } },
  "Exercise Type": { select: { name: "Reflection" } },
  "Estimated Time": { select: { name: "20 min" } },
}
```

### Online Course

Entries represent lessons:
```javascript
{
  "Name": { title: [{ text: { content: "Lesson 2.3: Setting Up Your First Funnel" } }] },
  "Status": { status: { name: "Draft" } },
  "Module": { select: { name: "Module 2: Funnel Foundations" } },
  "Lesson Number": { number: 3 },
  "Lesson Type": { select: { name: "Video + Worksheet" } },
  "Duration Target": { select: { name: "10-15 min" } },
}
```

---

## Property Value Formats for Page Creation

Quick reference for constructing property values when creating pages (entries):

| Notion Type | Value Format |
|-------------|-------------|
| title | `{ title: [{ text: { content: "Text" } }] }` |
| rich_text | `{ rich_text: [{ text: { content: "Text" } }] }` |
| select | `{ select: { name: "Option Name" } }` |
| multi_select | `{ multi_select: [{ name: "Tag1" }, { name: "Tag2" }] }` |
| number | `{ number: 42 }` |
| checkbox | `{ checkbox: true }` |
| status | `{ status: { name: "Draft" } }` |
| url | `{ url: "https://example.com" }` |

**Important:** For `rich_text`, each text element has a 2000-character limit. Split longer
content across multiple elements in the array.

---

## Troubleshooting

### 401 Unauthorized
- Token is invalid, expired, or missing
- Fix: verify `NOTION_TOKEN` is set correctly (`echo $NOTION_TOKEN`)
- Tokens start with `ntn_` — check for trailing whitespace or quotes

### 403 Forbidden / Insufficient Permissions
- The parent page is not shared with the integration
- Fix: Open the parent page in Notion -> click "..." -> "Connections" -> add the integration
- Note: sharing a parent page shares all child pages, but the parent itself must be explicitly shared

### 400 Bad Request
- Malformed property schema — the error body contains details
- Common causes:
  - Two `title` properties (only one allowed per database)
  - Invalid color name in select/multi_select options
  - Missing `options` array in select/multi_select
  - Invalid number format string

### 409 Conflict
- Rare. Usually means a concurrent operation on the same resource
- Fix: wait a few seconds and retry

### 429 Rate Limited
- Too many requests (Notion allows ~3 req/sec)
- Fix: the batch processing pattern with 350ms delay between batches prevents this
- If hit anyway: wait 1 second and retry the failed request

### Database Created but No Entries Appear
- Check if entries were created with the correct `database_id`
- Verify the property names in entries EXACTLY match the database property names (case-sensitive)
- Check that select/multi_select values match defined option names exactly

### Script Runs but Database Not Visible
- The database was created but you may not be looking at the right page
- Check the URL logged by the script
- The parent page must be in your Notion sidebar or accessible via search

### Dollar Signs Showing as LaTeX
- Notion renders unescaped `$` as inline math
- Fix: escape as `\$` in all text content (rich_text, title, paragraphs)
- Example: `"Price: \\$29.99"` (double-escaped in JS strings)
