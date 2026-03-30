---
name: generate-content
description: "Use when someone asks to generate content for database entries, run content generation, produce pages for a product, batch generate content, publish draft entries, or execute Phase 7 of the build pipeline."
---

## Context

Before doing anything, read the full templates and patterns in [reference.md](reference.md).
All generated scripts must follow the Notion API patterns documented in:
[notion-api-reference.md](../shared/notion-api-reference.md)

This is the batch production engine — Phase 7 of the Rewyse AI pipeline. It processes all
Draft entries in a Notion database, generates page content using the approved generation
prompt, writes content to each Notion page body, populates rich_text database properties
from the generated content, and updates Status to Published.

**State directory:** `rewyse-ai/output/{project-slug}/`

**Reads these files from state directory:**
| File | Purpose |
|------|---------|
| `generation-prompt.md` | The approved prompt that drives content generation |
| `database-config.json` | Database ID, property names, entry data |
| `expert-profile.md` | Expert voice/tone (embedded in generation prompt) |
| `content-blueprint.md` | Page structure (embedded in generation prompt) |

**Writes:**
| File | Purpose |
|------|---------|
| `content-log.json` | Per-entry status tracking (generated/published/failed) |

**Output scripts:** Generated at runtime in `scripts/` at the project root, named `rewyse-generate-{slug}-batch-{id}.js`.

---

## Step 1: Load State & Query Drafts

### Read State Files

Read from `rewyse-ai/output/{project-slug}/`:
1. `generation-prompt.md` — **Required.** This is the prompt each subagent uses.
2. `database-config.json` — **Required.** Contains `database_id` and entry metadata.
3. `content-log.json` — **Optional.** If it exists, this is a resume. Load already-processed entries.

If `generation-prompt.md` or `database-config.json` is missing, stop and tell the user:
> "Missing required files. Run the generation prompt phase first (`/write-prompt`)."

### Query Draft Entries

Generate and run a Node.js script to query the Notion database for all Draft entries:

```javascript
// Query filter: Status = "Draft"
const filter = { property: "Status", status: { equals: "Draft" } };
```

Extract from each entry:
- `page_id` — The Notion page ID
- `title` — The page title (title property)
- All variable properties defined in `database-config.json`

Save the full entry list to a temp file for subagent consumption.

### Identify Output Properties

Check which `rich_text` properties in `database-config.json` are currently empty across the
queried entries. These are **output properties** — the subagent must populate them from
generated content. Properties that already have values (select, multi_select, number, title,
status, checkbox) are **input properties** — the subagent reads them but does not overwrite them.

Pass the output property list to subagents as `{output_properties}`.

### Check Resume State

If `content-log.json` exists, filter out entries where `status` is `"published"` or `"generated"`.
Only process entries not yet in the log, or entries with `status: "failed"` (retry those).

### Present Summary

> "**Content Generation — {Project Name}**
>
> Database entries: {total}
> Already processed: {done} (from previous session)
> Failed (will retry): {failed_count}
> Remaining: {remaining}
>
> Batch size: {batch_size} entries per agent
> Parallel agents: {agent_count}
> Estimated waves: {waves}
>
> Ready to generate?"

Wait for user confirmation before proceeding.

---

## Step 2: Prepare Batches

### Read the Generation Prompt

Read `generation-prompt.md` in full. This prompt contains:
- The expert profile (voice, tone, vocabulary)
- The content blueprint (section structure, word counts, formatting rules)
- Entry-specific variable placeholders
- Content rules and constraints

### Split Into Batches

Group remaining entries into batches of 5-10 entries each.

**Batching rules:**
- Default batch size: 5 entries per agent (increase to 10 for simple products)
- Maximum 10 parallel agents per wave
- If entries share a category/type property, group same-type entries together
  for more consistent output

### Prepare Entry Data

For each batch, serialize the entry data as a JSON array containing:
- `page_id`
- `title`
- All variable properties from `database-config.json`
- `output_properties` — Array of `rich_text` property names that need population from generated content

---

## Step 3: Launch Subagents

Launch subagents in parallel waves. Each subagent handles one batch end-to-end.

### Subagent Configuration

- **Tool:** Agent tool
- **Model:** sonnet
- **run_in_background:** true
- **Max parallel:** 10 agents per wave

### Subagent Prompt

Each agent receives the prompt template from [reference.md](reference.md) Section 1,
filled with:
- `{generation_prompt}` — Full contents of `generation-prompt.md`
- `{entries_json}` — JSON array of entries in this batch
- `{database_config}` — Relevant config (database ID, property names)
- `{state_dir}` — Absolute path to the state directory
- `{notion_api_reference}` — Path to the shared Notion API reference

The subagent:
1. Reads the generation prompt and Notion API reference
2. For each entry in its batch:
   a. Generates the full page content by applying the generation prompt to the entry's variables
   b. Converts the content into Notion block format (headings, paragraphs, bullets, callouts, tables, toggles)
   c. Extracts property values from the generated content for each output property (see reference.md Section 8)
   d. Generates a Node.js script that: clears existing page content, appends new blocks (chunked to 100 blocks per call), updates ALL page properties (output properties + Status = "Published")
   e. Runs the script
3. Returns RESULT lines (one per entry)

### Between Waves

After each wave completes:

1. **Parse results** — Collect RESULT lines from all agents in the wave
2. **Update content-log.json** — Write status for each processed entry
3. **Report progress:**

> "**Wave {N} complete**
> Processed: {wave_count} entries
> Published: {success_count}
> Failed: {fail_count} {failure_details_if_any}
>
> Overall progress: {total_done}/{total_remaining}
>
> Continue with next wave?"

4. Wait for user confirmation before launching the next wave.

---

## Step 4: Update Content Log

After each wave (and at the end of generation), update `content-log.json`:

```json
{
  "project": "{project-slug}",
  "database_id": "{database_id}",
  "last_updated": "YYYY-MM-DDTHH:MM:SS",
  "entries": {
    "{page_id}": {
      "title": "Entry Title",
      "status": "published",
      "generated_at": "YYYY-MM-DDTHH:MM:SS",
      "published_at": "YYYY-MM-DDTHH:MM:SS",
      "wave": 1,
      "error": null
    }
  },
  "stats": {
    "total_entries": N,
    "published": N,
    "failed": N,
    "remaining": N
  }
}
```

For failed entries, record the error:
```json
{
  "status": "failed",
  "error": "Rate limit exceeded on append call",
  "generated_at": "YYYY-MM-DDTHH:MM:SS",
  "published_at": null
}
```

---

## Step 5: Session Summary

After all waves complete (or if the user stops early), present:

> **Content Generation Summary**
> **Project:** {project-slug}
> **Date:** {YYYY-MM-DD}
>
> | Metric | Count |
> |--------|-------|
> | Total entries | {N} |
> | Published this session | {N} |
> | Previously published | {N} |
> | Failed | {N} |
> | Remaining | {N} |
>
> {If failures exist:}
> **Failed entries:**
> | Entry | Error |
> |-------|-------|
> | {title} | {error} |
>
> **Next steps:**
> - {If remaining > 0: "Run `/generate-content` again to process remaining entries."}
> - {If failed > 0: "Failed entries will be retried on next run."}
> - {If remaining == 0: "All entries published. Run `/product-qa` for quality checks."}

**If orchestrated:** Update `state.json`: set phase `7_generate_content` to `status: "approved"`
(only when all entries are published — if entries remain, keep status as `"in_progress"`).

---

## Notes

- **Always read the generation prompt first.** The prompt file contains the expert profile,
  content blueprint, and all content rules. Subagents must receive the full prompt — do not
  summarize or truncate it.
- **Dollar signs must be escaped as \$ in all Notion content.** Unescaped `$` renders as
  LaTeX. Every subagent script must escape dollar signs before writing.
- **100-block append limit.** Notion allows max 100 blocks per append call. For pages with
  more than 100 blocks, chunk into multiple sequential append calls.
- **2000-character rich text limit.** Each rich_text element has a 2000-char max. Split
  longer text across multiple rich_text elements in the same block.
- **Rate limits:** Notion allows ~3 requests/second. Scripts use 350ms delay between calls
  and process batches of 5 concurrent requests max.
- **Resume is automatic.** If the conversation ends mid-generation, the next run reads
  `content-log.json` and picks up where it left off. Already-published entries are skipped.
- **Failed entries retry automatically.** Entries with `status: "failed"` in the log are
  included in the next run's processing queue.
- **Clear before append.** Each script deletes existing page content before writing new
  content. This makes re-runs idempotent — running twice produces the same result.
- **No npm dependencies.** All scripts use native `fetch` (Node.js 18+). No package.json needed.
- **Scripts are ephemeral.** Generated scripts in the `scripts/` subdirectory are disposable.
  They exist only for the current run.
- **Batch size trade-offs:** Smaller batches (5) = more reliable, easier to debug failures.
  Larger batches (10) = faster throughput. Default to 5 unless the product is simple.
- **If `content-log.json` doesn't exist, create it** with an empty structure on first run.
- **Carry page IDs from Step 1 through to Step 3.** Do not re-query the database inside subagents.
