---
name: test-content
description: "Use when someone asks to test content generation, preview sample pages, review test entries, validate the generation prompt, QA sample output, or dry-run the content pipeline before full production."
---

## Context

This skill generates 2-3 sample pages to validate that the generation prompt, expert profile,
and content blueprint produce the quality expected — before committing to a full production run.
It is Phase 6 of the Rewyse AI pipeline.

**State directory:** If running inside the orchestrator, read all inputs from
`rewyse-ai/output/{project-slug}/`. Write output to the same directory.

If running standalone, ask the user to point to the project directory or provide the
necessary files.

**Reads:**
- `generation-prompt.md` — The prompt used to generate each page (Phase 5 output)
- `database-config.json` — Database structure, properties, and entry data
- `product-idea.md` — Product type, niche, ICP, variables, fixed structure

**Writes:**
- `test-results.md` — Test samples, feedback rounds, and final approved versions

---

## Step 1: Load Upstream Artifacts

**If orchestrated:** Read from `rewyse-ai/output/{project-slug}/`:
- `generation-prompt.md` — Required. If missing, stop and tell the user Phase 5 must run first.
- `database-config.json` — Required. Contains database ID, properties, and entry data.
- `product-idea.md` — Required. Needed for variable definitions and product context.
- `expert-profile.md` — Optional read for context if the generation prompt references it.
- `content-blueprint.md` — Optional read for context if reviewing section structure.

**If standalone:** Ask the user for:
1. Path to the generation prompt file
2. Path to the database config or product idea file
3. Any specific concerns to watch for during testing

Verify all required files exist before proceeding.

---

## Step 2: Select Test Entries

The goal is to pick 2-3 entries that stress-test different parts of the generation prompt.

### If Notion Database Exists

Check `database-config.json` for a `database_id`. If present, generate and run a Node.js
script to query the Notion database for Draft entries (same REST API pattern as
generate-content Step 1 — use `POST /v1/databases/{database_id}/query` with a Status = "Draft" filter).

From the full entry list, select 2-3 entries using this strategy:
1. **Typical entry** — One that represents the most common variable combination (the "average" page)
2. **Edge case: sparse data** — An entry with minimal or missing optional variables
3. **Edge case: unusual combination** — An entry with an atypical variable mix (different
   category, extreme values, or uncommon niche within the product)

Present the selections:

> **Test entries selected:**
>
> | # | Entry | Why Selected |
> |---|-------|-------------|
> | 1 | [name] | Typical — represents the most common variable combo |
> | 2 | [name] | Edge case — sparse data (missing [X], [Y]) |
> | 3 | [name] | Edge case — unusual combo ([reason]) |
>
> These 3 entries will exercise different paths in the generation prompt.
> Want to swap any out?

Wait for user confirmation before generating.

### If No Database Yet

Generate 2-3 plausible test entries from `product-idea.md`:
- Extract the variable definitions (what changes per entry)
- Create realistic test data that covers the same diversity strategy above
- Present the synthetic entries for user approval before generating

---

## Step 3: Generate Test Samples

For each selected entry, launch a subagent (Agent tool, model: sonnet) to generate the
full page content using the generation prompt.

### Subagent Prompt Template

```
You are generating a single page of content for a digital product.

## Your Instructions

Read the generation prompt below and follow it exactly. Generate the complete page content
for the entry provided.

## Generation Prompt

{contents of generation-prompt.md}

## Entry Data

{entry variables as key-value pairs}

## Output

Return the complete page content in Markdown format. Follow every section, word count
guideline, and formatting rule in the generation prompt. Do not add sections that aren't
in the prompt. Do not skip sections that are.
```

Launch all 2-3 subagents in parallel using `run_in_background: true`.

After all complete, collect the generated content for each entry.

---

## Step 4: Present Samples for Review

Display each sample with clear labels. Format for easy side-by-side comparison:

> ## Test Sample 1: [Entry Name] (Typical)
>
> [Full generated content]
>
> ---
>
> ## Test Sample 2: [Entry Name] (Sparse Data)
>
> [Full generated content]
>
> ---
>
> ## Test Sample 3: [Entry Name] (Unusual Combo)
>
> [Full generated content]

After presenting all samples, ask:

> **Review these samples. For each, consider:**
> - Does the tone match your expert profile?
> - Are all sections present and at the right depth?
> - Is the content specific to each entry's variables, or is it generic?
> - Are there formatting issues (headings, tables, callouts)?
>
> You can:
> - **Approve all** — Samples look good, proceed to production
> - **Request changes** — Tell me what's off and I'll identify which upstream file to fix

---

## Step 5: Feedback Loop

When the user requests changes, diagnose which upstream artifact needs adjustment:

| User Feedback | Likely Source | Fix Target |
|--------------|--------------|------------|
| "Too generic" / "Not specific enough" | Generation prompt lacks variable interpolation | `generation-prompt.md` |
| "Tone is off" / "Doesn't sound like an expert" | Expert profile needs tuning | `expert-profile.md` |
| "Missing section X" / "Section order is wrong" | Blueprint structure issue | `content-blueprint.md` |
| "Section Y is too long/short" | Word count rules in prompt | `generation-prompt.md` |
| "Wrong formatting" / "Tables should be bullets" | Blueprint format specs | `content-blueprint.md` |
| "Content is wrong for this entry type" | Prompt doesn't handle variable edge cases | `generation-prompt.md` |
| "Variable data is missing/wrong" | Database config or entry data issue | `database-config.json` |

Present the diagnosis:

> **Diagnosis:** The issue "[user's feedback]" traces to `[file]`.
>
> **Suggested fix:** [Specific change to make]
>
> Want me to apply this fix and re-generate the affected samples?

If the user approves the fix:
1. Apply the change to the identified upstream file
2. Re-generate only the affected samples (not all 3, unless the change is structural)
3. Present the updated samples for another round of review
4. Repeat until the user approves

Track each feedback round — the test-results file should capture the iteration history.

---

## Step 6: Save Results & Approval

Once the user approves all samples, write `test-results.md` to the state directory:

```markdown
# Test Results: [Product Name]

**Date:** [YYYY-MM-DD]
**Status:** Approved
**Entries tested:** [N]

## Test Entries

| # | Entry | Type | Result |
|---|-------|------|--------|
| 1 | [name] | Typical | Approved |
| 2 | [name] | Sparse data | Approved |
| 3 | [name] | Unusual combo | Approved |

## Feedback History

### Round 1
- **Feedback:** [what the user said]
- **Diagnosis:** [which file, what fix]
- **Changes applied:** [summary of edits]

### Round 2 (if applicable)
- ...

## Approved Samples

### Sample 1: [Entry Name]
[Final approved content]

### Sample 2: [Entry Name]
[Final approved content]

### Sample 3: [Entry Name]
[Final approved content]
```

**If orchestrated:**
- Write to `rewyse-ai/output/{project-slug}/test-results.md`
- Update `state.json`: set phase `6_test_content` to `status: "approved"`

**If standalone:**
- Write to `output/test-content/{project-slug}/test-results.md`

Confirm completion:

> **Test phase complete.** All [N] samples approved.
> Results saved to `test-results.md`.
> [N] feedback rounds were needed.
>
> Ready for full production generation.

---

## Notes

- **This is a quality gate, not a formality.** The test phase catches prompt issues before
  they multiply across hundreds of pages. Take feedback seriously.
- **2-3 samples is the sweet spot.** Fewer misses edge cases. More wastes time before
  the user has seen any output.
- **Diverse selection matters more than random selection.** Pick entries that exercise
  different variable combinations — a "typical + two edge cases" strategy catches the
  most issues with the fewest samples.
- **Diagnose before fixing.** When the user says something is wrong, trace it to the
  specific upstream file before making changes. Fixing the prompt when the blueprint is
  the problem wastes iterations.
- **Re-generate only what changed.** If a prompt fix only affects Section 3, you can
  re-generate all samples (the prompt changed globally), but if a blueprint fix only
  affects one section's format, targeted re-generation is fine.
- **Track every feedback round.** The test-results file should be a complete record of
  what was tried, what failed, and what was changed. This is useful if the user comes
  back later to understand why certain decisions were made.
- **Synthetic test data should be realistic.** If generating entries from product-idea.md
  variables, use plausible real-world values, not "Example 1" / "Test Entry A".
- **The generation prompt is the contract.** If a sample looks wrong but follows the
  generation prompt exactly, the prompt is the problem — not the subagent.
