---
name: build-product
description: "Use when someone asks to build a digital product, create a Notion product, start a new product build, run the full product creation pipeline, or make a product from scratch."
argument-hint: [project-name]
---

## Context

This is the orchestrator for the AI Digital Product Agent. It sequences 10 specialized
phases to build a complete digital product in Notion — from idea definition through
content generation to polished delivery.

Before starting, read the shared references:
- [notion-api-reference.md](../shared/notion-api-reference.md)
- [product-types-reference.md](../shared/product-types-reference.md)

For state schema and phase dependencies, see [reference.md](reference.md).

**State directory:** `rewyse-ai/output/{project-slug}/`
**State file:** `rewyse-ai/output/{project-slug}/state.json`

### Prerequisites
- `NOTION_TOKEN` environment variable must be set
- Node.js 18+ installed (for Notion API scripts)
- A Notion page where the product database will be created

---

## Step 1: Initialize or Resume

### New Project
If `$ARGUMENTS` is provided, use it as the project name. Otherwise ask:
> "What should we call this project? (This becomes the folder name — e.g., 'hyrox-recipes')"

Create the project slug: lowercase, replace spaces with hyphens, strip non-alphanumeric.

Create the state directory and initialize `state.json`:
```json
{
  "project_name": "{user's project name}",
  "project_slug": "{slug}",
  "created": "{YYYY-MM-DD}",
  "last_updated": "{YYYY-MM-DD}",
  "current_phase": 1,
  "phases": {
    "1_product_idea": { "status": "pending" },
    "2_build_database": { "status": "pending" },
    "3_expert_profile": { "status": "pending" },
    "4_content_blueprint": { "status": "pending" },
    "5_write_prompt": { "status": "pending" },
    "6_test_content": { "status": "pending" },
    "7_generate_content": { "status": "pending" },
    "8_design_product": { "status": "pending" },
    "9_product_qa": { "status": "pending" },
    "10_product_expand": { "status": "pending" }
  },
  "delivery_mode": null,
  "notion": {
    "database_id": null,
    "homepage_id": null,
    "shareable_link": null
  }
}
```

### Resume Existing Project
If `rewyse-ai/output/{slug}/state.json` exists, read it and resume from `current_phase`.

Present the project status:
> **Resuming: {project_name}**
> **Last updated:** {date}
> **Current phase:** {N} — {phase_name}
> **Completed:** {list completed phases}
>
> Continue from Phase {N}?

---

## Step 2: Validate Environment

Before running any phase, check:

1. **NOTION_TOKEN** — Run a test API call:
   ```bash
   curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $NOTION_TOKEN" -H "Notion-Version: 2022-06-28" https://api.notion.com/v1/users/me
   ```
   If not 200, instruct the user to set their token.

2. **Node.js** — Run `node --version` and verify 18+.

If either fails, provide setup instructions and wait before proceeding.

---

## Step 3: Run Phases

Execute each phase sequentially. **For every phase:**

1. **Present the phase header** — Show the user where they are:
   > ---
   > ## Phase {N} of 10: {Phase Name}
   > **Progress:** {list of completed phases} | **Current:** {this phase} | **Remaining:** {count}
   > ---
2. **Read the sub-skill's SKILL.md** — Each phase has a dedicated skill with detailed instructions.
   You MUST read and follow that skill's full workflow. The summaries below are overviews only.
3. **Execute the phase** — Follow the sub-skill's step-by-step instructions
4. **Present the phase output** to the user
5. **Wait for approval** (Approve / Revise / Go Back)
   - On **"Approve"** — Update `state.json` (set phase status to `"approved"`, increment
     `current_phase`), save the `last_updated` date, then advance to the next phase
   - On **"Revise"** — Re-run the current phase incorporating the user's feedback
   - On **"Go Back"** — Jump to the requested phase. Reset all downstream dependent phases
     to `"pending"` per the dependency map in reference.md

**CRITICAL:** Do NOT attempt to run a phase from memory or the brief summaries below.
Always read the sub-skill's SKILL.md file first. The summaries are navigation aids, not instructions.

---

### Phase 1: Product Idea
**Sub-skill:** Read and follow `rewyse-ai/product-idea/SKILL.md`
**Reads:** nothing (first phase)
**Writes:** `product-idea.md`

Walks the user through: product type selection, niche specificity, ICP definition,
value proposition, domain research (via subagent), fixed structure, and variables.
Also recommends a delivery mode (`page` or `database`). Save to `state.json → delivery_mode`.

### Phase 2: Build Database
**Sub-skill:** Read and follow `rewyse-ai/build-database/SKILL.md`
**Reads:** `product-idea.md`
**Writes:** `database-config.json`

Creates the Notion database: collects parent page, designs schema from product definition,
generates and runs creation script, seeds sample entries.

Save the database ID to both `database-config.json` and `state.json → notion.database_id`.

### Phase 3: Expert Profile
**Sub-skill:** Read and follow `rewyse-ai/expert-profile/SKILL.md`
**Reads:** `product-idea.md`
**Writes:** `expert-profile.md`

Builds the expert persona: domain research, expertise definition, tone/voice,
vocabulary, perspective, knowledge boundaries, and a voice sample the user must approve.

### Phase 4: Content Blueprint
**Sub-skill:** Read and follow `rewyse-ai/content-blueprint/SKILL.md`
**Reads:** `product-idea.md`, `expert-profile.md`
**Writes:** `content-blueprint.md`

Defines the page template: sections, order, content types, word counts, variable
dependencies, formatting rules, and a sample skeleton.

### Phase 5: Write Prompt
**Sub-skill:** Read and follow `rewyse-ai/write-prompt/SKILL.md`
**Reads:** `product-idea.md`, `expert-profile.md`, `content-blueprint.md`
**Writes:** `generation-prompt.md`

Assembles the expert profile + blueprint + variable injection into a single
parameterized generation prompt. Includes a test generation for validation.

### Phase 6: Test Content
**Sub-skill:** Read and follow `rewyse-ai/test-content/SKILL.md`
**Reads:** `generation-prompt.md`, `database-config.json`
**Writes:** `test-results.md`

Generates 2-3 sample pages. Presents side by side for review.

**This is the quality gate.** If samples aren't good enough:
- Trace the issue to the upstream artifact (expert profile, blueprint, or prompt)
- Loop back to the relevant phase
- Re-run downstream phases after the fix

Only proceed to Phase 7 when test samples are approved.

### Phase 7: Generate Content
**Sub-skill:** Read and follow `rewyse-ai/generate-content/SKILL.md`
**Reads:** `generation-prompt.md`, `database-config.json`
**Writes:** `content-log.json`

Batch processes all Draft entries using parallel subagents (batches of 5-10).
Writes content to Notion pages, populates rich_text database properties from generated
content, and updates Status to Published.

Reports progress between batches. Supports resume if interrupted.

### Phase 8: Design Product
**Sub-skill:** Read and follow `rewyse-ai/design-product/SKILL.md`
**Reads:** `database-config.json`, `product-idea.md`
**Writes:** `design-config.json`

Checks `delivery_mode` from `state.json` and verifies against actual entry distribution.
If mode is `database`: creates homepage with browse sections, filtered views, icons, and shareable link.
If mode is `page`: creates homepage with category headings and entry sub-pages containing actual content.

Save homepage ID and shareable link to `state.json → notion`.

### Phase 9: Product QA
**Sub-skill:** Read and follow `rewyse-ai/product-qa/SKILL.md`
**Reads:** `expert-profile.md`, `content-blueprint.md`, `database-config.json`
**Writes:** `qa-report.md`

Scans all published pages against blueprint and expert profile.
Flags issues. Offers targeted regeneration for flagged entries.

### Phase 10: Product Expand
**Sub-skill:** Read and follow `rewyse-ai/product-expand/SKILL.md`
**Reads:** `product-idea.md`, `content-blueprint.md`, `expert-profile.md`
**Writes:** `expansion-brief.md`

Suggests 3-5 complementary products. Generates briefs for approved suggestions.
Each brief can feed back into a new `/build-product` run.

---

## Step 4: Project Complete

After all phases (or after the user chooses to stop), present the final summary:

> ## Project Complete: {project_name}
>
> **Product:** {product type} — {niche}
> **Database:** {N} entries published
> **Homepage:** {shareable_link}
> **QA:** {N issues found, N resolved}
>
> ### Phase Summary
> | Phase | Status | Output |
> |-------|--------|--------|
> | 1. Product Idea | Approved | product-idea.md |
> | 2. Build Database | Approved | {database_id} |
> | ... | ... | ... |
>
> ### Next Steps
> - Share the product link: {shareable_link}
> - Run `/product-expand {slug}` to build complementary products
> - Run `/product-qa {slug}` anytime to re-check quality
>
> **All project files:** `rewyse-ai/output/{slug}/`

---

## Notes

- **Always write state before advancing.** If the conversation ends mid-phase, the user
  can resume with `/build-product {slug}`.
- **Never skip approval gates.** Every phase requires user approval before moving forward.
- **Phase 6 is the critical gate.** This is where quality issues surface. Be thorough
  in helping the user trace problems to their root cause (usually expert profile or blueprint).
- **Go Back resets downstream.** If the user goes back to Phase 3 (expert profile) after
  Phase 5, phases 5 and 6 must be re-run. See the dependency map in reference.md.
- **NOTION_TOKEN validation is non-negotiable.** Don't attempt any Notion operations
  without a valid token. The test call in Step 2 prevents wasted time.
- **Always read the sub-skill SKILL.md before executing a phase.** The orchestrator
  coordinates and passes state — the actual step-by-step work is defined in each skill's
  SKILL.md. Never run a phase from the brief summary alone.
- **Dollar signs** must be escaped as `\$` in all Notion content.
- **Scripts go in `scripts/`** at the project root, named `rewyse-{operation}-{slug}.js`.
- **`delivery_mode` in `state.json`** tracks the recommended mode from Phase 1 (`"page"` or
  `"database"`). Phase 8 verifies this against actual data and records the final mode in
  `design-config.json`.
