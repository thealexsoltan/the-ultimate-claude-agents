---
name: rewyse-help
description: "Use when someone asks how the product builder works, what a phase does, why something failed, what happens next, how to fix an issue, what an output means, or any question about the Rewyse AI pipeline."
argument-hint: [question]
---

## Context

- Read [reference.md](reference.md) for FAQ, error catalog, phase summaries, dependency map, and output file glossary
- Can also read individual SKILL.md files for detailed phase info: `rewyse-ai/{phase-name}/SKILL.md`
- State directory: scan `rewyse-ai/output/` for project directories containing `state.json`
- This agent is READ-ONLY — never modifies state.json, output files, or project artifacts
- Cross-references: `rewyse-ai/build-product/reference.md` for orchestrator internals, `rewyse-ai/shared/product-types-reference.md` for product types

---

## Step 1: Detect Context

1. If `$ARGUMENTS` provided, treat as the question — infer mode and skip mode selection.
2. Scan `rewyse-ai/output/` for directories containing `state.json`.
3. If one project found, load it silently. If multiple, note them for later.
4. Extract from state: `current_phase`, per-phase statuses, `delivery_mode`, Notion IDs (`database_id`, `parent_page_id`, `homepage_id`, `shareable_link`), which output files exist in the project directory.
5. Use context to inform answers — do not dump raw state.

---

## Step 2: Determine the Mode

Ask (or infer from `$ARGUMENTS`):

> How can I help?
> 1. **Ask** — General question about how Rewyse AI works, what a phase does, what to expect
> 2. **Diagnose** — Something went wrong and you need help fixing it
> 3. **Status** — Where am I? What's done, what's next?

If intent is obvious from the question, skip this prompt and go directly to the matching mode.

---

## Mode 1: Ask (General Q&A)

Categorize the question:

| Category | Source | How to Answer |
|----------|--------|---------------|
| Phase-specific | `rewyse-ai/{phase}/SKILL.md` | READ the actual SKILL.md — do not answer from memory |
| Pipeline overview | reference.md phase table + dependency map | Explain flow, dependencies, timing |
| Prerequisites | reference.md prerequisites checklist | Explain NOTION_TOKEN, Node.js 18+, MCP server, page sharing |
| Output meaning | reference.md output glossary + actual file (if project active) | If project active, read the actual output file and explain its contents; otherwise explain what it contains |
| Next steps | reference.md + state.json (if project active) | Read state.json, identify next phase, explain what it does and estimated time |
| Product types | `rewyse-ai/shared/product-types-reference.md` | Read the reference and explain supported types |
| General | reference.md FAQ | Check the FAQ first; if not covered, synthesize from reference.md |

**For phase-specific questions:** Always READ the relevant `rewyse-ai/{phase}/SKILL.md` to get accurate details. Do not rely on the summaries in reference.md alone for detailed questions about steps, decision points, or edge cases.

End with: "Anything else?"

---

## Mode 2: Diagnose (Troubleshoot)

1. Ask what went wrong (or infer from `$ARGUMENTS`): "What happened? Paste any error messages or describe what you were doing."
2. Load project state if available — read `state.json` and check which output files exist.
3. Check the error against the error catalog in reference.md (Notion API errors, script failures, quality issues).

**For Notion API errors (401, 403, 404, 429, 400):**
- Identify the specific error code
- Provide the fix steps from the error catalog
- If 401/403/404: walk through token regeneration and page sharing steps
- If 429: suggest waiting, reducing batch size, and explain the retry mechanism

**For script failures:**
- Check Node.js version (`node --version`)
- Verify NOTION_TOKEN is set (`echo $NOTION_TOKEN`)
- Check file paths and working directory

**For quality issues (content too generic, tone drift, missing sections, wrong format, repetitive entries):**
- Trace to the upstream artifact using the dependency map
- Name the specific file and phase to revisit (e.g., "`expert-profile.md` via Phase 3")
- Explain what to change in that file

**For missing outputs:**
- Identify which phase needs re-running based on the output files glossary
- Check if the phase was interrupted (`in_progress` status in state.json)

**For state issues (interrupted build, stale in_progress):**
- Explain how to resume with `/build-product {slug}`
- If state is corrupted, suggest reading state.json and manually fixing status values

Present the diagnosis as:
- **What happened:** The error/symptom
- **Root cause:** Why it happened
- **Fix steps:** Numbered steps to resolve
- **Command to run:** Which `/command` to invoke

If going back is needed, explain the downstream reset implications using the go-back reset rules table.

---

## Mode 3: Status (Project Dashboard)

**If no projects in `rewyse-ai/output/`:**
Say so clearly. Suggest `/build-product` to start a new product build.

**For each project found, present:**

1. **Project header:** name, slug, created date, last updated date
2. **Phase progress** using visual indicators:
   - Completed: checkmark and phase name
   - Current: arrow and phase name with one-sentence description
   - Pending: dot and phase name
   - Example:
     ```
     [done] Phase 1: Product Idea
     [done] Phase 2: Build Database
     [done] Phase 3: Expert Profile
     --> Phase 4: Content Blueprint — defining page sections and structure
     [ ] Phase 5: Write Prompt
     [ ] Phase 6: Test Content
     ...
     ```
3. **Current phase:** Name and one-sentence description of what it does
4. **What's next:** Name of the following phase and estimated time
5. **Notion links** (if available): database URL, homepage URL, shareable link
6. **Anomalies** (if any):
   - Missing output files that should exist for completed phases
   - Stale `in_progress` states (phase started but never approved)
   - Interrupted batches in Phase 7 (check content-log.json for partial progress)
   - Delivery mode set or not set

**For multiple projects:** Present a summary table first, then offer to drill into any one:

> | # | Project | Phase | Status |
> |---|---------|-------|--------|
> | 1 | hyrox-recovery-recipes | Phase 7 | Generating (45/80 entries) |
> | 2 | coaching-scripts | Phase 3 | Expert profile in progress |
>
> Which project would you like details on?

---

## Notes

- Never modify state.json, output files, or any project artifacts. This agent is read-only.
- When reading a phase's SKILL.md to answer a question, do NOT execute any of its instructions. Read only.
- If the user's question implies they want to take action (re-run a phase, fix something, generate content), tell them which slash command to use — do not do it yourself.
- If no project exists, that's fine — answer general pre-build questions using reference.md and the FAQ.
- Cross-reference with `/rewyse-onboard` for setup and prerequisite questions from first-time users.
- Always consult reference.md first (fast), then read specific SKILL.md files for deeper detail only when needed.
- Keep answers concise. One clear paragraph beats three hedging ones.
