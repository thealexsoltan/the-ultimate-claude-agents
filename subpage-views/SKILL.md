---
name: subpage-views
description: "Use when someone asks to create filtered list views on subpages, set up linked database views, delete old database views, hide database titles, or configure subpage database displays in bulk."
---

## Context

This skill configures linked database views on subpages of a Notion home page at scale.
It creates filtered **list views** showing only relevant entries, deletes unwanted views
(e.g., old table views), and hides the database source title — all in bulk across dozens
of subpages.

**Why this skill exists:** Notion MCP tools can create views but cannot delete views or
hide the linked database title. This skill combines MCP tools (for creating views) with
Node.js scripts using Notion's internal API (for deleting views and hiding titles).

**Three operations** (can be run independently or together):
1. **Create filtered list views** — via Notion MCP (`notion-create-view`)
2. **Delete old/unwanted views** — via internal API script (`submitTransaction`)
3. **Hide database source title** — via internal API script (`submitTransaction`)

Before starting, read [reference.md](reference.md) for the internal API patterns,
authentication requirements, and script templates.

---

## Step 1: Gather Context

Ask the user for:

1. **Which subpages?** — A home page URL/ID whose subpages need views, or a list of
   specific page IDs.
2. **Which operations?** — Create views, delete views, hide titles, or all three.
3. **Source database** — The database to create linked views from (get the `data-source-url`
   / collection ID).
4. **View configuration:**
   - View type (default: `list`)
   - Which properties to show (default: only the title property)
   - Sort order (default: by `Company Name` ASC)
5. **Filter logic per section** — How subpages map to database filters. Typical pattern:
   each subpage title corresponds to a filter value on a specific property.

**If editing an existing home page setup:** Fetch 1-2 subpages with `notion-fetch` to
understand the current view structure before proceeding.

---

## Step 2: Map Subpages to Filters

Define the filter mapping for each section of subpages. Each section has:
- **Filter property** — The database property to filter on
- **Filter operator** — `CONTAINS` (for multi_select) or `=` (for select)
- **Filter value** — Usually the subpage title (may need adjustment)

**Example mapping from Case Studies:**

| Section | Filter Property | Operator | Example |
|---------|----------------|----------|---------|
| ICP/Niche (42 pages) | Ideal Customer Profile | CONTAINS | "Agency owners" |
| Monthly Revenue (7 pages) | Revenue Range | = | "Under \$1K" |
| Growth Channels (15 pages) | Growth Channels | CONTAINS | "Affiliate Marketing" |
| AOV Range (6 pages) | AOV Range | CONTAINS | "Under \$25" |

**Important:** Verify that subpage titles match the database option values exactly.
Watch for en-dashes (`–`) vs hyphens (`-`) in range values.

Present the full mapping to the user for approval before proceeding.

---

## Step 3: Pilot (4 pages)

Test on 1 page from each section before running in bulk:

1. **Fetch each pilot page** using `notion-fetch` to get the linked database's `database_id`
2. **Create a list view** using `notion-create-view` with the filter DSL:

```
FILTER "{property}" {operator} "{value}";
SORT BY "{sort_property}" ASC;
SHOW "{title_property}"
```

3. **Ask the user to verify** the pilot pages in Notion:
   - Does the filter show the right entries?
   - Are the right properties visible?
   - Is the sort order correct?

Wait for user approval before continuing to bulk operations.

---

## Step 4: Create Views in Bulk

Deploy **parallel agents** (up to 8) to create views on all remaining subpages.

**Each agent handles a batch and for each page:**
1. Fetches the page with `notion-fetch` to get the `database_id`
2. Creates a list view with `notion-create-view` using the correct filter DSL

**Batch strategy for efficiency:**
- Split pages into groups of 8-12 per agent
- Group by section so each agent uses the same filter property
- Each agent reports success/failure counts when done

**Example agent prompt:**
```
For each page below, fetch it with notion-fetch to get the database_id from
the linked database embed, then create a list view with notion-create-view.

Pages: [list of {id, title} objects]

For each page use this DSL:
FILTER "{property}" CONTAINS "{page_title}";
SORT BY "Company Name" ASC;
SHOW "Product Idea Name"

Report which pages succeeded and which failed.
```

---

## Step 5: Delete Old Views

Notion MCP cannot delete views. Use a Node.js script with Notion's internal API.

1. **Get the user's `token_v2`** — Required for internal API authentication.
   > "I need your Notion `token_v2` cookie for the internal API (MCP can't delete views).
   > Get it from: Browser DevTools → Application → Cookies → notion.so → `token_v2`"

2. **Generate the cleanup script** at `scripts/notion/cleanup-views-{slug}.js` following the
   template in [reference.md](reference.md). The script:
   - Loads each subpage via `loadPageChunk` to find `collection_view` blocks
   - Identifies which views to keep (list views) vs delete (non-list views)
   - Uses `submitTransaction` to update the block's `view_ids` and set `alive: false`
     on deleted views
   - Processes in batches of 5 with 500ms delay

3. **Run the script:**
   ```bash
   NOTION_TOKEN_V2="..." node scripts/notion/cleanup-views-{slug}.js
   ```

4. Report results: X cleaned, Y skipped, Z failed.

---

## Step 6: Hide Database Titles

The linked database source title (e.g., "80+ Digital Product Case Studies") appears
above the list items. There are **two levels** of title hiding:

### Level 1: Block-level title (the linked database block header)
Set `collection_pointer_title_hidden: true` on the `block` record:
```javascript
{
  id: collectionViewBlockId,
  table: "block",
  path: ["format", "collection_pointer_title_hidden"],
  command: "set",
  args: true,
}
```

### Level 2: View-level title (the database name shown inside the view)
Set `hide_linked_collection_name: true` on each `collection_view` record:
```javascript
{
  id: viewId,
  table: "collection_view",
  path: ["format", "hide_linked_collection_name"],
  command: "set",
  args: true,
}
```

**Both levels must be set** to fully hide the database title. Generate a script at
`scripts/notion/hide-titles-{slug}.js` following the template in [reference.md](reference.md)
that applies both operations.

Run the script:
```bash
NOTION_TOKEN_V2="..." node scripts/notion/hide-titles-{slug}.js
```

---

## Step 7: Verify & Clean Up

1. **Spot-check 5+ pages** across all sections in Notion:
   - List view present with correct filter
   - Only the intended properties visible
   - Old views deleted (no table view tabs)
   - Database title hidden (no "80+ Digital Product Case Studies" text)

2. **Present final summary:**
   ```
   ## Subpage Views — Complete

   **Pages processed:** {N}
   **Views created:** {N} list views
   **Views deleted:** {N} old views removed
   **Titles hidden:** {N} (block-level + view-level)

   **Sections:**
   - {Section 1}: {N} pages — filter on "{property}"
   - {Section 2}: {N} pages — filter on "{property}"
   ...

   **Scripts generated:**
   - scripts/notion/cleanup-views-{slug}.js
   - scripts/notion/hide-titles-{slug}.js
   ```

3. **Clean up:** Scripts can be kept for future use (e.g., if new subpages are added)
   or deleted if this was a one-time operation.

---

## Notes

- **Internal API auth requires three values:** `token_v2` (browser cookie),
  `USER_ID`, and `SPACE_ID`. Use the `getSpaces` endpoint to discover USER_ID
  and SPACE_ID if not already known. See reference.md for the discovery process.
- **token_v2 expires** — If the script returns 401 or empty recordMaps, ask the
  user for a fresh token.
- **Batch sizes:** MCP view creation uses parallel agents (up to 8). Internal API
  scripts use batches of 5 with 500ms delay to respect rate limits.
- **Filter value mismatches:** Subpage titles may not exactly match database option
  values (e.g., "Ecommerce sellers" page vs "Ecommerce operators" option). Always
  verify the mapping in Step 2.
- **En-dashes vs hyphens:** Revenue and AOV ranges use en-dashes (`–`) in Notion
  option values, not hyphens (`-`). Ensure scripts and filter DSL use the correct character.
- **MCP false-positive warnings:** When MCP warns about page deletion during
  `replace_content`, set `allow_deleting_content: true` if pages are referenced
  inside `<column>` blocks (known parser limitation).
- **Cannot change view type:** MCP cannot convert a table view to a list view.
  The workflow is: create new list view → delete old table view.
