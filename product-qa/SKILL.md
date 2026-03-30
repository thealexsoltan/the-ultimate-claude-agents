---
name: product-qa
description: "Use when someone asks to QA a product, check content quality, scan for issues across database entries, audit generated pages, review product quality, or run a quality check on a Notion product."
---

## Context

This is Phase 9 of the Rewyse AI pipeline. After content generation, this skill scans all
published entries for quality issues — repetitive phrasing, missing sections, tone drift,
thin content, formatting problems, and inconsistencies.

Before doing anything, read the full quality criteria and templates in [reference.md](reference.md).
All QA checks must follow the checklists, severity definitions, and report format documented there.

For Notion API patterns, see:
[notion-api-reference.md](../shared/notion-api-reference.md)

For product type context, see:
[product-types-reference.md](../shared/product-types-reference.md)

**State directory:** `rewyse-ai/output/{project-slug}/`

**Reads:**
- `expert-profile.md` — Voice, tone, vocabulary, perspective
- `content-blueprint.md` — Section structure, word counts, content rules
- `database-config.json` — Database ID, property schema
- `generation-prompt.md` — The prompt used to generate content (for diagnosing root causes)

**Writes:**
- `qa-report.md` — Full QA report with flagged pages, issues, and severity

---

## Step 1: Load Project Context

Read all four files from the state directory:

```
rewyse-ai/output/{project-slug}/expert-profile.md
rewyse-ai/output/{project-slug}/content-blueprint.md
rewyse-ai/output/{project-slug}/database-config.json
rewyse-ai/output/{project-slug}/generation-prompt.md
```

Extract from these:
- **Database ID** from `database-config.json`
- **Section list** from `content-blueprint.md` — names, order, types, word count ranges
- **Voice spec** from `expert-profile.md` — tone, vocabulary, terms to use/avoid
- **Generation prompt** from `generation-prompt.md` — for root cause analysis if issues found

If any file is missing, tell the user which file is absent and that the relevant checks
will be skipped (e.g., no expert profile = skip voice checks).

---

## Step 2: Fetch All Published Entries

Query the database for all entries with Status = "Published":

```javascript
const filter = { property: "Status", status: { equals: "Published" } };
```

Use the paginated `queryAllPages` pattern from the Notion API reference.

For each entry, extract:
- Page ID
- Title (from the title property)
- All database properties

Tell the user how many entries were found:

> "Found {N} published entries in the database. Batching into groups of {batch_size}
> for parallel QA scanning. Each batch will check: blueprint compliance, expert voice,
> cross-entry uniqueness, formatting, and content quality."

---

## Step 3: Batch Scan with Subagents

Split entries into batches of 5-10 (aim for 5 per batch for databases under 50 entries,
10 per batch for larger databases). Launch one subagent per batch.

Use `model: sonnet` and `run_in_background: true` for all subagents.

### Pre-fetch Page Content

Before launching subagents, generate and run a Node.js script at
`rewyse-ai/scripts/rewyse-qa-fetch-{slug}.js` that fetches all page content for the batch.

The script must:
1. Accept a list of page IDs (from Step 2)
2. For each page, fetch all blocks via `GET /v1/blocks/{page_id}/children` (paginate if `has_more`)
3. Write structured JSON to `{state_dir}/qa-batch-{batch_id}-content.json` with this format:
```json
{
  "pages": {
    "{page_id}": {
      "title": "Entry Title",
      "blocks": [ "...all blocks..." ]
    }
  }
}
```
4. Use the batch processing pattern from notion-api-reference.md (batches of 5, 350ms delay)

Run the script before launching any subagents:
```bash
NOTION_TOKEN="$NOTION_TOKEN" node rewyse-ai/scripts/rewyse-qa-fetch-{slug}.js
```

### Subagent Prompt Template

Each subagent receives this prompt (fill in the batch-specific values):

```
You are a QA scanner for a Notion-based digital product. You will read a batch of pages
and check each one against the content blueprint and expert profile.

## Files to Read First

1. Expert profile: {state_dir}/expert-profile.md
2. Content blueprint: {state_dir}/content-blueprint.md
3. QA reference: rewyse-ai/product-qa/reference.md

## Pages to Scan

{list of page IDs and titles for this batch}

## Page Content

The page content has been pre-fetched and is available in:
{state_dir}/qa-batch-{batch_id}-content.json

Read this file to get all block content for each page in this batch. Do NOT make
any Notion API calls — all content is already in the JSON file.

## Instructions

For each page:

1. Read the page's blocks from the pre-fetched content JSON file.
2. Parse the blocks into a section-by-section breakdown.
3. Run all 5 checks against the content:

### Check 1: Blueprint Compliance
- Are all sections from the blueprint present? In the correct order?
- Is each section within the specified word count range?
- Are the correct content types used (paragraph vs. bullets vs. table)?

### Check 2: Expert Voice
- Does the tone match the expert profile (primary + secondary tone)?
- Are domain-specific terms from the vocabulary list used correctly?
- Are any "avoid" terms present?
- Does the perspective align with the expert's stated positions?

### Check 3: Cross-Entry Uniqueness
- Record the first 100 characters of each section's content.
- Flag any opening paragraphs or sections that are suspiciously similar
  to other entries in this batch (>60% character overlap after normalization).
- Record these for cross-batch comparison by the main agent.

### Check 4: Formatting
- Proper heading hierarchy (h1 for title, h2 for sections, h3 for subsections)?
- Tables have correct column count and headers?
- Lists are properly structured (not single-item lists)?
- No broken or malformed blocks?
- Callouts have correct emoji and formatting?

### Check 5: Content Quality
- Any section below 50% of its target word count? (Flag as thin content)
- Generic filler phrases present? ("In today's world", "It's important to note",
  "This is a great way to", "In conclusion")
- Hallucinated data? (specific numbers, statistics, or claims not grounded
  in the entry's variable data)
- Repetitive sentence structures within a section?

## Output Format

Return your findings as structured data — one block per page:

PAGE|{page_id}|{title}
ISSUE|{severity}|{check_name}|{section}|{description}
ISSUE|{severity}|{check_name}|{section}|{description}
FINGERPRINT|{section_name}|{first_100_chars}
---

Severity levels:
- CRITICAL — Missing section, broken formatting, completely wrong structure
- WARNING — Thin content (<50% word count), minor tone drift, generic filler
- INFO — Minor inconsistency, slight vocabulary mismatch, cosmetic issue

If a page has zero issues, output:
PAGE|{page_id}|{title}
CLEAN
---

IMPORTANT: Be specific in issue descriptions. "Tone is off" is not helpful.
"Section 3 uses casual language ('super easy') while expert profile specifies
clinical/authoritative tone" is helpful.
```

### After All Subagents Complete

1. Parse all subagent outputs.
2. Run **cross-batch uniqueness check**: compare FINGERPRINT data across all batches.
   Flag any sections where two different entries have >60% overlap in their opening content.
3. Compile all issues into the QA report.

---

## Step 4: Compile QA Report

Build the report in this structure:

```markdown
# QA Report: {Product Name}

**Date:** {YYYY-MM-DD}
**Database:** {database_id}
**Entries scanned:** {N}
**Project:** {project-slug}

## Summary

| Metric | Count |
|--------|-------|
| Total entries scanned | {N} |
| Clean entries (no issues) | {N} |
| Entries with issues | {N} |
| Critical issues | {N} |
| Warnings | {N} |
| Info items | {N} |

## Critical Issues

{List each critical issue with page title, section, and description}

## Warnings

{List each warning with page title, section, and description}

## Info

{List each info item with page title, section, and description}

## Cross-Entry Uniqueness Flags

{List any entries with suspiciously similar content, showing both entry titles,
the section name, and a snippet of the overlapping text}

## Root Cause Analysis

{For recurring issues (same issue type appearing in 3+ entries), identify the
likely root cause in the generation prompt and suggest a fix}

## Recommended Actions

1. {Action — e.g., "Regenerate entries X, Y, Z with revised prompt section for..."}
2. {Action}
3. {Action}
```

Present the report to the user.

---

## Step 5: Approval Gate

After presenting the report, ask:

> "QA scan complete. {N} entries scanned, {N} issues found ({critical} critical,
> {warnings} warnings, {info} info).
>
> You can:
> - **Regenerate flagged** — I'll regenerate only the entries with Critical or Warning issues,
>   using the original prompt plus targeted fix instructions for each page
> - **Regenerate all** — Full regeneration of every entry (use if systemic issues found)
> - **Accept as-is** — No changes needed
> - **Fix specific** — Tell me which pages or issue types to address
>
> What would you like to do?"

---

## Step 6: Targeted Regeneration (if requested)

For each flagged entry the user wants regenerated:

1. Read the original `generation-prompt.md`.
2. Read the specific issues for that entry from the QA report.
3. Build a **targeted fix prompt** that includes:
   - The original generation instructions
   - Specific fix instructions for each flagged issue
   - The entry's variable data (from database properties)
4. Clear the existing page content (delete all blocks).
5. Generate new content using the targeted prompt.
6. Append the new content to the page.
7. Log the regeneration in the QA report.

Process regenerations in batches of 3-5 with subagents, same as the scan phase.

After regeneration, offer to re-run QA on just the regenerated entries:

> "Regenerated {N} entries. Want me to re-scan just those pages to verify the fixes?"

---

## Step 7: Save QA Report

Write the final QA report to:
`rewyse-ai/output/{project-slug}/qa-report.md`

**If orchestrated:** Update `state.json`: set phase `9_product_qa` to `status: "approved"`
(only when the user accepts the QA results — if regeneration is in progress, keep status as `"in_progress"`).

Include a regeneration log at the bottom if any entries were regenerated:

```markdown
## Regeneration Log

| Entry | Issues Fixed | Regenerated At |
|-------|-------------|----------------|
| {title} | {issue descriptions} | {timestamp} |
```

---

## Notes

- **Always read reference.md first.** The quality criteria, checklists, and severity
  definitions are the foundation of every QA scan. Do not assess quality from generic
  intuition — use the documented criteria.
- **Batch size matters.** 5 entries per subagent for databases under 50 entries, 10 per
  subagent for larger databases. This keeps each subagent's context manageable.
- **Cross-entry uniqueness is the hardest check.** Within a batch, the subagent can compare
  directly. Across batches, the main agent must compare FINGERPRINT data. This is why
  fingerprints are collected.
- **Root cause analysis is the real value.** Individual issues are symptoms. The root cause
  is usually in the generation prompt — a vague section instruction, missing vocabulary
  constraint, or absent formatting rule. Always trace recurring issues back to the prompt.
- **Targeted regeneration > full regeneration.** If only 5 out of 50 entries have issues,
  regenerate those 5 with fix instructions. Don't waste API calls and time regenerating
  clean entries.
- **The expert profile is the voice benchmark.** Every tone/voice issue should reference
  a specific part of the expert profile that was violated.
- **Word count ranges are ranges, not exact targets.** A section specified as "80-120 words"
  that has 75 words is not a critical issue. A section at 30 words (below 50% of the 80-word
  minimum) IS a warning.
- **Dollar signs in Notion content** must be escaped as `\$` to avoid LaTeX rendering.
- **Rate limits:** Keep Notion API calls within ~3 requests/second. The batch pattern with
  5 concurrent + 350ms delay handles this.
- **If the database has fewer than 5 entries,** run a single subagent instead of batching.
- **Regeneration preserves database properties.** Only page content (blocks) is replaced.
  Properties stay unchanged.
