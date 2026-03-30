# Generate Content — Reference

Templates, schemas, and patterns for the content generation engine.

---

## Section 1: Subagent Prompt Template

Each subagent receives this prompt. Fill in all `{placeholders}` before launching.

```
You are a content generation agent. You will generate page content for a batch of
Notion database entries and publish them via the Notion API.

## Step 1: Read References

Read the Notion API reference for script patterns:
{notion_api_reference_path}

## Step 2: Generation Prompt

Use this prompt to generate content for EVERY entry in your batch. The prompt contains
the expert voice, content blueprint, section structure, and all content rules.

--- START GENERATION PROMPT ---
{generation_prompt}
--- END GENERATION PROMPT ---

## Step 3: Your Batch

Process these entries. Each entry has a page_id and variable properties.
Apply the generation prompt to each entry's variables to produce the full page content.

{entries_json}

## Step 4: For Each Entry

For each entry in the batch:

1. **Generate content** — Apply the generation prompt. Replace all variable placeholders
   with the entry's actual property values. Generate the complete page content following
   the blueprint structure (every section, correct word counts, proper formatting).

2. **Convert to Notion blocks** — Transform the generated content into Notion API block
   format. Use the block types from the API reference:
   - heading_1, heading_2, heading_3 for section headings
   - paragraph for body text
   - bulleted_list_item for bullet lists
   - numbered_list_item for numbered lists
   - callout for expert notes, tips, warnings
   - table for data tables
   - toggle for expandable sections
   - divider for section breaks

3. **Extract property values** — For each output property in the entry's `output_properties`
   list, extract a concise value from the corresponding generated section. Use the generation
   prompt's "Uses:" annotations to identify which section maps to which property.

   Extraction rules:
   - Callout blocks (Before State, After State, Common Mistake Prevented) → extract the
     callout body text only (no emoji, no heading)
   - Bold paragraphs (One-Line Job) → extract the paragraph text, strip bold markers
   - Paragraphs (What It Replaces, Primary Output) → extract the opening sentence only
   - Numbered lists (How It Works) → join steps as "1. [step] 2. [step] 3. [step]"
   - Toggle content (Example Output) → extract a 1-2 sentence summary, not the full toggle
   - Truncate any value to 2000 characters max (Notion rich_text limit)
   - Escape dollar signs as \$ in property values
   - Only populate properties that are empty — do not overwrite existing values

4. **Generate and run a Node.js script** that:
   a. Validates NOTION_TOKEN is set
   b. Clears existing page content (delete all child blocks)
   c. Appends new content blocks (chunked to max 100 blocks per API call)
   d. Updates ALL page properties in one PATCH call: sets each output property's
      rich_text value AND sets Status to "Published"
   e. Logs success or failure

   Run with: NOTION_TOKEN="$NOTION_TOKEN" node scripts/rewyse-generate-{slug}-batch-{batch_id}.js

5. **Report result** — Return one line per entry:
   RESULT|{page_id}|{title}|SUCCESS
   or:
   RESULT|{page_id}|{title}|FAILED|{error_message}

## Important Rules

- Escape ALL dollar signs as \$ in content text. Notion renders $ as LaTeX.
- Split rich_text elements at 2000 characters max.
- Chunk block appends at 100 blocks max per API call.
- Add 350ms delay between API calls (rate limit buffer).
- Add 100ms delay between block deletions when clearing pages.
- Process entries sequentially within the batch (not in parallel) to avoid rate limits.
- Do NOT re-query the database. Use only the entry data provided above.
- Generate ALL entries in the batch. Do not skip any.
```

---

## Section 2: Content Write Script Template

Each subagent generates a script based on this template. This is the Node.js script
that writes content to Notion and updates the entry status.

```javascript
// scripts/generate-batch-{batch_id}.js
// Generates content for batch of entries and publishes to Notion

const NOTION_TOKEN = process.env.NOTION_TOKEN;
if (!NOTION_TOKEN) {
  console.error("ERROR: Set NOTION_TOKEN environment variable first.");
  console.error("Run: export NOTION_TOKEN=ntn_your_token_here");
  process.exit(1);
}

const HEADERS = {
  "Authorization": `Bearer ${NOTION_TOKEN}`,
  "Notion-Version": "2022-06-28",
  "Content-Type": "application/json",
};

const delay = (ms) => new Promise((r) => setTimeout(r, ms));

// --- API Functions ---

async function getPageBlocks(pageId) {
  let allBlocks = [];
  let startCursor = undefined;
  let hasMore = true;
  while (hasMore) {
    const url = new URL(`https://api.notion.com/v1/blocks/${pageId}/children`);
    if (startCursor) url.searchParams.set("start_cursor", startCursor);
    const res = await fetch(url.toString(), { method: "GET", headers: HEADERS });
    if (!res.ok) throw new Error(`Failed to get blocks: ${res.status}`);
    const data = await res.json();
    allBlocks = allBlocks.concat(data.results);
    hasMore = data.has_more;
    startCursor = data.next_cursor;
  }
  return allBlocks;
}

async function clearPageContent(pageId) {
  const blocks = await getPageBlocks(pageId);
  for (const block of blocks) {
    const res = await fetch(`https://api.notion.com/v1/blocks/${block.id}`, {
      method: "DELETE",
      headers: HEADERS,
    });
    if (!res.ok) {
      const body = await res.text();
      console.warn(`Warning: Failed to delete block ${block.id}: ${body}`);
    }
    await delay(100);
  }
}

async function appendBlocks(pageId, blocks) {
  // Chunk into groups of 100 (Notion API limit)
  for (let i = 0; i < blocks.length; i += 100) {
    const chunk = blocks.slice(i, i + 100);
    const res = await fetch(`https://api.notion.com/v1/blocks/${pageId}/children`, {
      method: "PATCH",
      headers: HEADERS,
      body: JSON.stringify({ children: chunk }),
    });
    if (!res.ok) {
      const body = await res.text();
      throw new Error(`Failed to append blocks (chunk ${Math.floor(i/100)+1}): ${res.status} ${body}`);
    }
    if (i + 100 < blocks.length) await delay(350);
  }
}

async function updatePageProperties(pageId, properties) {
  // Merge output properties with Status update into one PATCH call
  const payload = { ...properties, "Status": { status: { name: "Published" } } };
  const res = await fetch(`https://api.notion.com/v1/pages/${pageId}`, {
    method: "PATCH",
    headers: HEADERS,
    body: JSON.stringify({ properties: payload }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Failed to update properties for ${pageId}: ${res.status} ${body}`);
  }
}

// Helper: build a rich_text property value (truncates to 2000 chars)
function richTextProperty(text) {
  const truncated = text.length > 2000 ? text.slice(0, 2000) : text;
  return { rich_text: [{ type: "text", text: { content: truncated } }] };
}

// --- Entry Data ---
// Each entry: { page_id, title, blocks, properties }
// `blocks` = Notion block objects for page content
// `properties` = output property values (rich_text format) to write to the database
// The subagent populates both fields.

const ENTRIES = [
  // {
  //   page_id: "abc123",
  //   title: "Entry Title",
  //   blocks: [ /* Notion block objects */ ],
  //   properties: {
  //     "One-Line Job": richTextProperty("Takes X and produces Y so you never have to Z."),
  //     "Before State": richTextProperty("You spend days doing..."),
  //     // ... other output properties
  //   },
  // },
];

// --- Main ---

async function processEntry(entry) {
  console.log(`Processing: ${entry.title} (${entry.page_id})`);
  try {
    // 1. Clear existing content
    await clearPageContent(entry.page_id);
    await delay(350);

    // 2. Append new content
    await appendBlocks(entry.page_id, entry.blocks);
    await delay(350);

    // 3. Update all properties (output properties + Status = Published)
    await updatePageProperties(entry.page_id, entry.properties || {});

    console.log(`RESULT|${entry.page_id}|${entry.title}|SUCCESS`);
  } catch (err) {
    console.error(`RESULT|${entry.page_id}|${entry.title}|FAILED|${err.message}`);
  }
}

async function main() {
  console.log(`Processing ${ENTRIES.length} entries...`);
  for (const entry of ENTRIES) {
    await processEntry(entry);
    await delay(350); // Buffer between entries
  }
  console.log("Batch complete.");
}

main().catch((err) => {
  console.error("Script failed:", err.message);
  process.exit(1);
});
```

**How subagents use this template:**
1. Copy the template
2. Generate Notion blocks for each entry (applying the generation prompt)
3. Extract property values from the generated content for each output property
4. Populate the `ENTRIES` array with `{ page_id, title, blocks, properties }` objects
5. Write the script to `{state_dir}/scripts/generate-batch-{batch_id}.js`
6. Run it with `NOTION_TOKEN="$NOTION_TOKEN" node {script_path}`

---

## Section 3: content-log.json Schema

```json
{
  "project": "hyrox-nutrition-playbook",
  "database_id": "abc123def456",
  "last_updated": "2026-03-24T14:30:00",
  "entries": {
    "page-id-001": {
      "title": "Race Day Fueling Strategy",
      "status": "published",
      "generated_at": "2026-03-24T14:20:00",
      "published_at": "2026-03-24T14:21:00",
      "wave": 1,
      "error": null
    },
    "page-id-002": {
      "title": "Pre-Race Carb Loading",
      "status": "failed",
      "generated_at": "2026-03-24T14:22:00",
      "published_at": null,
      "wave": 1,
      "error": "Rate limit exceeded: 429 Too Many Requests"
    }
  },
  "stats": {
    "total_entries": 50,
    "published": 38,
    "failed": 2,
    "remaining": 10
  }
}
```

**Field definitions:**
| Field | Type | Description |
|-------|------|-------------|
| `project` | string | The project slug from the state directory |
| `database_id` | string | Notion database ID |
| `last_updated` | ISO timestamp | When the log was last written |
| `entries` | object | Keyed by page_id |
| `entries.*.status` | enum | `"published"`, `"failed"`, or `"generated"` (content created but not yet written to Notion) |
| `entries.*.wave` | number | Which wave processed this entry |
| `entries.*.error` | string/null | Error message if failed, null if successful |
| `stats` | object | Running totals (recalculated on each write) |

---

## Section 4: Resume Logic

Resume allows generation to continue across conversations.

### On Startup (Step 1)

```
1. Read content-log.json
2. If file missing → create empty structure, process all Draft entries
3. If file exists:
   a. Collect all page_ids where status = "published" → skip these
   b. Collect all page_ids where status = "failed" → include these (retry)
   c. Query database for Draft entries
   d. Filter out already-published entries
   e. Add failed entries to the processing queue
   f. Report: "Resuming — {published} already done, {failed} to retry, {new} new drafts"
```

### After Each Wave

```
1. Read current content-log.json
2. Merge new results (don't overwrite existing entries)
3. Recalculate stats
4. Write updated content-log.json
```

### Idempotency

Re-running on an already-published entry is safe because:
- The script clears page content before writing (delete all blocks, then append)
- Property updates are idempotent (writing the same rich_text values again is a no-op)
- Status update is idempotent (setting "Published" on an already-Published page is a no-op)

---

## Section 5: Error Handling Patterns

### Script-Level Errors

| Error | Cause | Handling |
|-------|-------|----------|
| `NOTION_TOKEN not set` | Missing env var | Script exits with clear message |
| `Failed to create page: 401` | Invalid or expired token | Stop batch, report to user |
| `Failed to append blocks: 400` | Malformed block JSON | Log error, mark entry failed, continue |
| `Failed to append blocks: 413` | Payload too large | Reduce chunk size, retry |
| `429 Too Many Requests` | Rate limit hit | Wait 1s, retry up to 3 times |

### Retry Logic (inside scripts)

```javascript
async function fetchWithRetry(url, options, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    const res = await fetch(url, options);
    if (res.status === 429) {
      const retryAfter = res.headers.get("Retry-After") || 1;
      console.warn(`Rate limited. Waiting ${retryAfter}s (attempt ${attempt}/${maxRetries})`);
      await delay(Number(retryAfter) * 1000);
      continue;
    }
    return res;
  }
  throw new Error(`Failed after ${maxRetries} retries (429 rate limit)`);
}
```

### Subagent-Level Errors

| Error | Handling |
|-------|----------|
| Agent times out | Mark all entries in batch as failed, include in next wave |
| Agent returns no RESULT lines | Mark all entries as failed with "No results returned" |
| Agent returns partial results | Mark returned entries appropriately, mark missing entries as failed |

### Wave-Level Recovery

If a wave has >50% failure rate:
1. Report the failure pattern to the user
2. Ask if they want to: retry the wave, skip to next wave, or stop
3. Do NOT automatically retry — let the user decide

---

## Section 6: Rate Limit Considerations

### Notion API Limits

- **Rate:** ~3 requests/second per integration
- **Burst:** Short bursts up to ~10 requests tolerated
- **Block append:** 100 blocks per call
- **Rich text:** 2000 chars per rich_text element
- **Page size:** No hard limit, but pages with >500 blocks may load slowly

### Script-Level Throttling

Each script processes entries **sequentially** (not in parallel) with delays:
- 100ms between block deletions (clearing)
- 350ms between API calls (appending, status updates)
- 350ms between entries

### Agent-Level Parallelism

Multiple agents run in parallel, each generating and running its own script.
Since each agent targets different pages, there are no conflicts. However, all
agents share the same Notion API rate limit.

**Conservative settings (recommended):**
- 5 entries per batch
- 5 agents per wave
- = 25 entries per wave
- At ~3 req/s shared, each entry takes ~5-10 API calls → ~15s per entry
- Wave completion: ~75s

**Aggressive settings (for simple products with few sections):**
- 10 entries per batch
- 10 agents per wave
- = 100 entries per wave
- Higher risk of 429 errors — retry logic handles it

### Cross-Agent Rate Limit Mitigation

Since all agents share one Notion token, stagger agent launches:
- Launch agents 1-5 immediately
- Launch agents 6-10 after a 2-second delay
- This spreads the initial burst of API calls

---

## Section 7: Notion Block Conversion Patterns

Common content-to-block conversions for subagents:

### Markdown to Notion Blocks

| Markdown | Notion Block Type |
|----------|-------------------|
| `# Heading` | `heading_1` |
| `## Heading` | `heading_2` |
| `### Heading` | `heading_3` |
| Regular paragraph | `paragraph` |
| `- Item` | `bulleted_list_item` |
| `1. Item` | `numbered_list_item` |
| `> Quote` | `quote` |
| `---` | `divider` |
| `> **Tip:** text` | `callout` (with emoji icon) |

### Bold and Italic in Rich Text

```javascript
// Bold text
{ type: "text", text: { content: "bold text" }, annotations: { bold: true } }

// Italic text
{ type: "text", text: { content: "italic text" }, annotations: { italic: true } }

// Mixed: "This is **bold** and normal"
[
  { type: "text", text: { content: "This is " } },
  { type: "text", text: { content: "bold" }, annotations: { bold: true } },
  { type: "text", text: { content: " and normal" } },
]
```

### Long Text Splitting

For text >2000 characters, split into multiple rich_text elements:

```javascript
function splitRichText(text, maxLen = 2000) {
  const elements = [];
  for (let i = 0; i < text.length; i += maxLen) {
    elements.push({
      type: "text",
      text: { content: text.slice(i, i + maxLen) },
    });
  }
  return elements;
}
```

### Dollar Sign Escaping

```javascript
function escapeForNotion(text) {
  return text.replace(/\$/g, "\\$");
}
```

Apply `escapeForNotion()` to ALL text content before building block objects.

---

## Section 8: Property Extraction from Generated Content

After generating page content, the subagent must extract concise property values from the
generated sections and write them to the database alongside the page blocks.

### How It Works

1. The generation prompt's Content Structure defines sections with "Uses:" annotations
   (e.g., "Section 2: The One-Line Job — Uses: {One-Line Job}")
2. The entry's `output_properties` list names the `rich_text` properties that need values
3. For each output property, find the section that "Uses:" it, then extract the value

### Extraction Patterns

| Section Pattern | Extraction Rule |
|----------------|-----------------|
| Bold paragraph (standalone) | Extract the paragraph text, strip bold markers |
| Callout block | Extract the callout body text only (no emoji prefix, no heading) |
| Paragraph + bullet list | Extract the opening sentence only |
| Numbered list (3 steps) | Join as: "1. [step] 2. [step] 3. [step]" |
| Toggle block | Extract a 1-2 sentence summary of the toggle content |
| Heading + paragraph | Extract the paragraph text only (no heading) |

### Constraints

- **2000 character limit** — Each rich_text property value has a 2000-char max. Truncate if needed.
- **Dollar sign escaping** — Escape `$` as `\$` in property values too.
- **Only update output properties** — Do not overwrite select, multi_select, number, title,
  checkbox, or status properties (except Status → "Published"). Those are input properties.
- **Empty output properties only** — If an output property already has a value in the entry data,
  do NOT overwrite it. Only populate empty ones.
- **One API call** — Combine all property updates (including Status) into a single PATCH call
  to minimize rate limit usage. Use `updatePageProperties()` from the script template.

### Example

Given a generation prompt where Section 2 "Uses: {One-Line Job}" and the generated content is:

> **The Expert Profile Agent takes your product's niche and produces a complete expert
> persona — so every page reads like it was written by a domain specialist, not a generic chatbot.**

The extracted property value would be:

```javascript
"One-Line Job": richTextProperty("The Expert Profile Agent takes your product's niche and produces a complete expert persona — so every page reads like it was written by a domain specialist, not a generic chatbot.")
```
