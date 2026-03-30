---
name: build-database
description: "Use when someone asks to create a Notion database, build a product database, set up database properties, or configure a content database."
---

## Context

Before doing anything, read:
1. [reference.md](reference.md) — Property type catalog, script templates, sample entry patterns
2. [notion-api-reference.md](../shared/notion-api-reference.md) — All API patterns, boilerplate, conventions

This skill creates a Notion database via the REST API. It is Phase 2 of the Rewyse AI pipeline.
It takes the product definition from Phase 1 (`/product-idea`) and turns it into a live
Notion database with the correct schema, a Status workflow, and 3-5 sample entries.

**State directory:** If running inside the orchestrator (`/build-product`), read the
project state from `rewyse-ai/output/{project-slug}/`. Write output to that same directory.

If running standalone, write output to `output/build-database/`.

---

## Step 1: Load Product Definition

**If orchestrated (state directory exists):**
- Read `rewyse-ai/output/{project-slug}/product-idea.md`
- Parse: product type, niche, ICP, fixed structure, variables table, entry list

**If standalone:**
- Ask the user: "Do you have a product-idea.md file from `/product-idea`?"
  - If yes: read it from the path they provide
  - If no: collect the minimum inputs needed:
    1. **Database title** — What should this database be called?
    2. **Variables** — What properties does each entry need? (name, type, purpose, example values)
    3. **Product type** — What kind of product is this? (for sample entry generation)
    4. **Target entry count** — How many entries will this database hold?

Present the loaded/collected definition back to the user for confirmation before proceeding.

---

## Step 2: Get Notion Parent Page

Ask the user:

> Where should I create this database? Provide either:
> - A Notion page URL (e.g., `https://www.notion.so/My-Page-abc123def456...`)
> - A page ID (32-character hex string)

**Extract the page ID from the URL:**
- Strip dashes, take the last 32 hex characters from the URL path
- Format as: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` (with dashes) or plain 32-char hex — both work

**Verify NOTION_TOKEN is available:**
```bash
echo $NOTION_TOKEN
```
If not set, instruct the user:
> Run this in your terminal first:
> ```
> export NOTION_TOKEN=ntn_your_token_here
> ```
> And make sure the parent page is shared with your integration
> (page "..." menu -> Connections -> select your integration).

---

## Step 3: Design Database Schema

Map each variable from the product definition to a Notion property type.

**Mandatory properties (always included):**

| Property | Type | Purpose |
|----------|------|---------|
| Name | `title` | Entry title (every database needs exactly one) |
| Status | `status` | Workflow tracking: Draft -> In Progress -> Review -> Published |

**Map product variables to Notion property types using the reference:**

| Variable Type (from product-idea) | Notion Property Type |
|-----------------------------------|---------------------|
| title | `title` (use for the Name property) |
| text | `rich_text` |
| select | `select` (with predefined options) |
| multi_select | `multi_select` (with predefined options) |
| number | `number` (with format if applicable) |
| checkbox | `checkbox` |
| url | `url` |

**Present the schema to the user:**

> ## Database Schema: [Database Title]
>
> | Property | Notion Type | Options/Format |
> |----------|-------------|----------------|
> | Name | title | — |
> | Status | status | Draft, In Progress, Review, Published |
> | [Variable 1] | [type] | [options if select/multi_select] |
> | [Variable 2] | [type] | [options if select/multi_select] |
> | ... | ... | ... |
>
> **Total properties:** [count]
>
> Approve this schema, or tell me what to change.

**Guardrail:** If the schema exceeds 18 properties, warn the user:
> This database has [N] properties. More than 18 properties makes content generation harder
> and clutters the Notion UI. Consider merging or removing some.

Wait for user approval before proceeding.

---

## Step 4: Generate and Run Database Creation Script

Generate a Node.js script at `rewyse-ai/scripts/rewyse-create-db-{slug}.js`.

**The script must:**
1. Validate `NOTION_TOKEN` is set
2. Create the database with all approved properties via `POST /v1/databases`
3. Log the database ID on success
4. Handle errors with clear messages

**Follow the script boilerplate from notion-api-reference.md exactly.** Use the complete
script template from [reference.md](reference.md) as the base.

**Property construction rules:**
- `title` property: `{ title: {} }`
- `rich_text` property: `{ rich_text: {} }`
- `select` property: include all options with colors from the color rotation in reference.md
- `multi_select` property: include all options with colors
- `number` property: include format (`"number"`, `"dollar"`, `"percent"`) when applicable
- `checkbox` property: `{ checkbox: {} }`
- `url` property: `{ url: {} }`
- `status` property: always use the Draft/In Progress/Review/Published configuration

**Run the script:**
```bash
NOTION_TOKEN="$NOTION_TOKEN" node rewyse-ai/scripts/rewyse-create-db-{slug}.js
```

**Capture the database ID from the output.** If the script fails, diagnose:
- 401: Token invalid or expired
- 403: Parent page not shared with integration
- 400: Malformed property schema — check the error body for details
- 429: Rate limited — wait and retry

---

## Step 5: Create Sample Entries

Generate 3-5 sample entries with `Status: Draft` to validate the schema works.

**Sample entry rules:**
- Each entry must have realistic, niche-appropriate values for ALL properties
- Use the product type and niche context to generate relevant sample data
- All entries start with `Status: Draft`
- Entries should demonstrate the range of the product (e.g., different categories, difficulty levels)

**Use the batch processing pattern from notion-api-reference.md:**
- Create entries via `POST /v1/pages` with `parent: { database_id: databaseId }`
- Process in a single batch (3-5 entries fits in one batch of 5)
- Log each entry as it's created

Add sample entry creation to the same script (after database creation), or generate
a second script at `rewyse-ai/scripts/rewyse-seed-db-{slug}.js` if the user wants to run them separately.

**Present results:**

> ## Database Created
>
> **Database ID:** `{database_id}`
> **URL:** `https://www.notion.so/{database_id_no_dashes}`
> **Properties:** [count] configured
> **Sample entries:** [count] created (Status: Draft)
>
> Sample entries:
> 1. [Entry name] — [key property values]
> 2. [Entry name] — [key property values]
> 3. ...

---

## Step 6: Seed All Entries

After the sample entries and schema are approved, populate the database with all remaining entries.

**Check the product definition (`product-idea.md`) for the entry list:**

### Option A: User provided an entry list
If `product-idea.md` contains a specific list of entries (e.g., "50 recipe names"), create
all entries via a batch creation script at `rewyse-ai/scripts/rewyse-seed-db-{slug}.js`.

Each entry needs:
- The title (from the entry list)
- `Status: Draft`
- Any property values specified in the entry list

Use the batch processing pattern from notion-api-reference.md (batches of 5, 350ms delay).

### Option B: AI-generated entries
If the product-idea says "entries to be AI-generated", use a subagent (Agent tool, model: sonnet)
to generate the full entry list based on the product definition:

> Generate {target_count} entries for this product. For each entry, provide:
> - Title
> - Values for all select/multi_select properties (from the approved options)
> - Values for any number properties
>
> **Product context:** {niche}, {ICP}, {product_type}
> **Properties:** {list from product-idea.md}
>
> Ensure entries cover the full range of categories/dimensions. Distribute evenly across
> select options. Avoid duplicates or near-duplicates.

Then create all entries via the batch script.

### Option C: User will add manually
If the user prefers to add entries themselves, clearly note this:

> **Note:** Your database currently has {N} sample entries. Phase 7 (Generate Content)
> will only process entries that exist with Status: Draft. Add your entries to the
> database before running Phase 7, or I can generate them for you now.

**Present the seeding results:**

> **Database Seeded**
> **Total entries:** {count} (Status: Draft)
> **Categories covered:** {list of select values represented}
>
> Ready to proceed to the next phase.

---

## Step 7: Save Configuration

Write the database configuration for downstream skills.

**If orchestrated:**
- Write to `rewyse-ai/output/{project-slug}/database-config.json`:
```json
{
  "database_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "parent_page_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "title": "Database Title",
  "properties": {
    "Name": { "type": "title" },
    "Status": { "type": "status", "options": ["Draft", "In Progress", "Review", "Published"] },
    "Variable 1": { "type": "select", "options": ["Option A", "Option B"] }
  },
  "sample_entry_ids": ["page-id-1", "page-id-2", "page-id-3"],
  "created_at": "2026-03-24T00:00:00Z",
  "script_path": "rewyse-ai/scripts/rewyse-create-db-{slug}.js"
}
```
- Update `state.json`: set phase `2_build_database` to `status: "approved"`

**If standalone:**
- Write to `output/build-database/{slug}/database-config.json`

---

## Notes

- **Status is mandatory.** Every database gets the Draft/In Progress/Review/Published status workflow. This is how downstream skills (`/generate-content`) track which entries need content.
- **Property count guardrail.** Keep it under 18. More properties = more noise in the Notion UI and harder content generation prompts.
- **Dollar signs in text.** Escape `$` as `\$` in any text content sent to Notion. Unescaped `$` triggers LaTeX rendering.
- **No npm dependencies.** Scripts use only `fetch` (Node 18+ built-in). No `package.json` needed.
- **Parent page must be shared.** The most common failure is the user forgetting to share the parent page with their Notion integration. Always remind them.
- **Script naming convention.** `rewyse-ai/scripts/rewyse-create-db-{slug}.js` for creation, `rewyse-ai/scripts/rewyse-seed-db-{slug}.js` for seeding entries separately.
- **Re-running is safe.** If the script is run again, it creates a NEW database (not a duplicate). The user can delete the old one manually. Do not attempt to update an existing database schema — create fresh.
- **Select/multi_select colors.** Rotate through: blue, green, orange, red, purple, pink, yellow, gray, brown. Do not repeat until all are used.
