# Rewyse AI Help — Knowledge Base

Quick-reference for the `/rewyse-help` Q&A agent. Covers every phase, dependency,
output file, error pattern, and frequently asked question about the Rewyse AI pipeline.

---

## Pipeline Overview

| Phase | Agent | Reads | Writes | What It Does |
|-------|-------|-------|--------|-------------|
| 0 | build-product | state.json | state.json | Orchestrates all phases, manages state, handles go-back and resume |
| 1 | product-idea | product-types-reference.md | product-idea.md | Defines product type, niche, ICP, fixed structure, variables, delivery mode |
| 2 | build-database | product-idea.md | database-config.json | Creates Notion database via REST API with properties, views, status workflow, sample + full entries |
| 3 | expert-profile | product-idea.md | expert-profile.md | Builds domain expert persona with voice, tone, vocabulary, perspective, knowledge boundaries |
| 4 | content-blueprint | product-idea.md, expert-profile.md | content-blueprint.md | Defines page sections, content types, word counts, variable dependencies, formatting rules |
| 5 | write-prompt | product-idea.md, expert-profile.md, content-blueprint.md | generation-prompt.md | Assembles expert + blueprint + variables into a parameterized generation prompt |
| 6 | test-content | generation-prompt.md, database-config.json, product-idea.md | test-results.md | Generates 2-3 sample pages, collects feedback, traces issues to upstream artifacts |
| 7 | generate-content | generation-prompt.md, database-config.json | content-log.json | Batch processes all Draft entries with parallel subagents, writes to Notion, marks Published |
| 8 | design-product | database-config.json, product-idea.md | design-config.json | Creates homepage, browse sections, filtered views, icons, shareable link |
| 9 | product-qa | expert-profile.md, content-blueprint.md, database-config.json, generation-prompt.md | qa-report.md | Scans all published pages for quality issues, flags and optionally regenerates |
| 10 | product-expand | product-idea.md, content-blueprint.md, expert-profile.md | expansion-brief.md | Suggests 3-5 complementary products with pre-filled briefs |

---

## Phase Summaries

### Phase 1: Product Idea (`/product-idea`)

Defines exactly what digital product to build. Collects the product type (from 10 supported types), niche, ICP, value proposition, and target entry count. Runs domain research via web search to find best-in-class examples, must-have data points, filtering dimensions, and gaps in existing products. Uses that research to define the fixed structure (elements on every page) and variables (what changes per entry). Recommends a delivery mode (page vs. database) based on entry count and category distribution. Ends with a full product definition approval gate. The user's main decisions: product type, niche specificity, variable catalog, and delivery mode. Common question: "What's the difference between fixed structure and variables?" -- fixed structure is the template that repeats on every page; variables are database properties that make each page unique.

### Phase 2: Build Database (`/build-database`)

Takes the product definition from Phase 1 and creates a live Notion database via the REST API. Maps each variable to a Notion property type (title, rich_text, select, multi_select, number, checkbox, url). Adds a mandatory Status property with Draft/In Progress/Review/Published workflow. Generates and runs a Node.js script to create the database, then seeds 3-5 sample entries to validate the schema. After schema approval, populates all remaining entries (user-provided list, AI-generated, or manual later). The user's main decisions: parent page location, schema approval, entry source. Common question: "What if I already have a database?" -- you can skip this phase, but you need to provide a database-config.json with the database ID, property names, and parent page ID.

### Phase 3: Expert Profile (`/expert-profile`)

Creates the expert persona that writes every page of the product. This is the single biggest quality lever in the pipeline. Researches the domain via web search to find real experts, terminology, frameworks, and tone benchmarks. Defines the expert's background, voice and tone (primary, secondary, avoid), vocabulary calibration (use/avoid terms, formality level), perspective and opinions (strong positions, counter-positions, teaching philosophy), and knowledge boundaries (claims/defers/never claims). Generates a 200-300 word voice sample for the user to evaluate and iterate on. The user's main decisions: tone direction, vocabulary level, perspective strength. Common question: "Can I change the expert voice after content is generated?" -- yes, but you must go back to Phase 3, which resets Phases 5-10 (everything downstream of the prompt).

### Phase 4: Content Blueprint (`/content-blueprint`)

Defines the exact structure of every page -- sections, order, content types (paragraph, bullets, table, callout, toggle, heading), word count ranges, and variable dependencies. Designs sections based on the product type, niche, expert voice, and ICP level. Generates a visual skeleton showing what one complete page looks like with placeholder content. The user's main decisions: section selection, content depth, formatting style. Common question: "What if sections feel too shallow?" -- reduce the number of sections and increase depth. Five deep sections beat twelve shallow ones.

### Phase 5: Write Prompt (`/write-prompt`)

Assembles all prior outputs into a single parameterized generation prompt. Extracts the variable schema from product-idea.md and cross-checks every dependency against the blueprint. Builds the prompt in five sections: system context (from expert profile), input variables block, content structure (from blueprint), formatting instructions, and quality constraints. Generates a test output with realistic variable values to validate end-to-end. The user's main decisions: approve or iterate on the test output. Common question: "How long should the prompt be?" -- under 2000 words. Longer prompts produce confused, not better, output.

### Phase 6: Test Content (`/test-content`)

Generates 2-3 sample pages to validate quality before committing to a full production run. Selects entries strategically: one typical entry, one with sparse data, one with an unusual variable combination. Launches parallel subagents to generate content using the approved prompt. Presents samples for review and runs a feedback loop that traces issues to their upstream source (generation prompt for generic content, expert profile for tone issues, blueprint for structure issues). The user's main decisions: approve samples or request changes. Common question: "What does this phase actually check?" -- it validates that the prompt, expert voice, and blueprint work together to produce specific, well-structured, on-voice content across different entry types.

### Phase 7: Generate Content (`/generate-content`)

The batch production engine. Queries all Draft entries from the Notion database, splits them into batches of 5-10, and launches parallel subagents (up to 10 per wave). Each subagent generates content, converts it to Notion block format, writes it to the page via REST API, populates rich_text database properties, and sets Status to Published. Tracks progress in content-log.json for resume capability. Reports progress after each wave and waits for confirmation before continuing. The user's main decision: batch size and when to proceed between waves. Common question: "How many entries can it handle?" -- tested up to 200+ entries. At 50 entries ~10 min, at 200 entries ~30 min.

### Phase 8: Design Product (`/design-product`)

Turns the populated database into a polished, shareable product. Verifies the delivery mode against actual entry distribution (may override Phase 1 recommendation). For database mode: creates a homepage with browse sections (one per select/multi_select property with 3+ options), sub-pages with filtered views, emoji icons, and a full database embed. For page mode: creates a homepage with category headings and entry sub-pages containing actual content. Sets icons via REST API script. Guides user through enabling public sharing (manual step in Notion UI). The user's main decisions: delivery mode confirmation, browse section selection, icon choices, public sharing. Common question: "What's the difference between page and database delivery?" -- database mode uses filtered database views on sub-pages (best for 10+ entries per category); page mode puts actual content in sub-pages (best for fewer entries per category).

### Phase 9: Product QA (`/product-qa`)

Scans all published entries against the expert profile and content blueprint. Pre-fetches all page content via REST API, then launches parallel subagents that run five checks: blueprint compliance (sections present, correct order, word counts), expert voice (tone, vocabulary, perspective), cross-entry uniqueness (fingerprinting to catch repetitive openings), formatting (heading hierarchy, tables, lists, callouts), and content quality (thin content, filler phrases, hallucinated data). Compiles a report with severity levels (Critical, Warning, Info), root cause analysis for recurring issues, and recommended actions. Can perform targeted regeneration of flagged entries. The user's main decisions: accept, regenerate flagged, regenerate all, or fix specific. Common question: "How do I re-run QA?" -- just invoke `/product-qa` again; it re-scans all published entries.

### Phase 10: Product Expand (`/product-expand`)

Analyzes the completed product and suggests 3-5 complementary products serving the same audience. Runs market research via web search to find real complementary product opportunities. Evaluates through five lenses: adjacent problems, before/after needs, format gaps, depth vs. breadth, and pricing ladder. For each suggestion provides name, type, relationship to existing product, ICP overlap, pricing, description, and cross-sell hook. Generates pre-filled product-idea.md briefs that can be fed directly into `/build-product`. The user's main decision: which expansions to develop. Common question: "Do I have to run this phase?" -- no, Phase 10 is the only phase that can be skipped.

---

## Dependency Map

```
Phase 1 (product-idea)
|---> Phase 2 (build-database)
|---> Phase 3 (expert-profile)
|---> Phase 4 (content-blueprint)

Phase 3 (expert-profile) ---> Phase 5 (write-prompt)
Phase 4 (content-blueprint) ---> Phase 5 (write-prompt)

Phase 5 (write-prompt) ---> Phase 6 (test-content)

Phase 2 (build-database) ---> Phase 6 (test-content)
Phase 6 (test-content) ---> Phase 7 (generate-content)

Phase 7 (generate-content) ---> Phase 8 (design-product)
Phase 7 (generate-content) ---> Phase 9 (product-qa)

Phase 9 (product-qa) ---> Phase 10 (product-expand)
```

Key insight: Phases 2, 3, and 4 can run in parallel after Phase 1 (they only depend on product-idea.md). Phase 5 requires both 3 and 4. Phase 6 requires both 2 and 5. Phase 8 and 9 are independent of each other.

---

## Go-Back Reset Rules

When the user goes back to a phase, all downstream dependent phases reset to `pending`.

| If user goes back to... | Reset these phases |
|-------------------------|-------------------|
| Phase 1 (product-idea) | 2, 3, 4, 5, 6, 7, 8, 9, 10 (everything) |
| Phase 2 (build-database) | 6, 7, 8, 9, 10 |
| Phase 3 (expert-profile) | 5, 6, 7, 8, 9, 10 |
| Phase 4 (content-blueprint) | 5, 6, 7, 8, 9, 10 |
| Phase 5 (write-prompt) | 6, 7, 8, 9, 10 |
| Phase 6 (test-content) | 7, 8, 9, 10 |
| Phase 7 (generate-content) | 8, 9, 10 |
| Phase 8 (design-product) | (none -- independent) |
| Phase 9 (product-qa) | 10 |

**Exception:** Phase 8 (design-product) is independent from Phase 9 (product-qa). Going back to Phase 8 does NOT reset Phase 9, and vice versa.

**Exception:** Going back to Phase 3 or 4 does NOT reset Phase 2. The database structure is unaffected by expert profile or blueprint changes.

---

## Output Files Glossary

| File | Phase | Contents | Used By |
|------|-------|----------|---------|
| `product-idea.md` | 1 | Product type, niche, ICP, value proposition, fixed structure, variables table, delivery mode recommendation, entry list | Phases 2, 3, 4, 5, 6, 8, 10 |
| `database-config.json` | 2 | Database ID, parent page ID, title, property schema with types and options, sample entry IDs, script path, created timestamp | Phases 6, 7, 8, 9 |
| `expert-profile.md` | 3 | Expert background, voice/tone (primary, secondary, avoid), vocabulary (use, avoid, formality), perspective (positions, counter-positions, teaching philosophy), knowledge boundaries, approved voice sample | Phases 4, 5, 6, 9 |
| `content-blueprint.md` | 4 | Section overview table, section-by-section details (type, word count, variable dependencies, content rules, format, example), sample skeleton | Phases 5, 6, 9, 10 |
| `generation-prompt.md` | 5 | System context, input variables block, content structure instructions, formatting rules, quality constraints, approved test output | Phases 6, 7, 9 |
| `test-results.md` | 6 | Test entries tested, feedback history (rounds, diagnoses, changes), final approved sample content | Phase 7 (confidence gate) |
| `content-log.json` | 7 | Per-entry status (published/failed/remaining), timestamps, wave numbers, error messages, aggregate stats | Resume on re-run, Phase 9 |
| `design-config.json` | 8 | Homepage ID, shareable link, delivery mode, browse sections with sub-page IDs, icon count, scripts generated | State record |
| `qa-report.md` | 9 | Summary metrics, critical/warning/info issues by page, cross-entry uniqueness flags, root cause analysis, recommended actions, regeneration log | Phase 10 |
| `expansion-brief.md` | 10 | Summary of approved expansions, full product definition briefs for each (type, niche, ICP, structure, variables, cross-sell hooks, example entries) | `/build-product` for next product |
| `state.json` | 0 | Project name, slug, created/updated dates, current phase, per-phase status, Notion IDs (database, parent page, homepage, shareable link), delivery mode | All phases (orchestrator state) |

---

## Error Catalog

### Notion API Errors

| Error | Code | Cause | Fix |
|-------|------|-------|-----|
| Unauthorized | 401 | Token expired, revoked, or wrong | Regenerate token at notion.so/my-integrations. Re-export `NOTION_TOKEN`. |
| Not Found | 404 | Token does not have access to the page/database | Share the page with the integration: page "..." menu > Connections > select integration. |
| Rate Limited | 429 | Too many API calls (limit is ~3 req/sec) | Wait 30-60 seconds. Reduce batch size. Scripts use 350ms delay between calls. |
| Bad Request | 400 | Malformed property schema or block structure | Check the error body for the specific field. Common: wrong property type, missing required field, exceeding 2000-char rich text limit. |
| Forbidden | 403 | Parent page not shared with integration | Same fix as 404: share the page with the integration. |

### Script Failures

| Error | Cause | Fix |
|-------|-------|-----|
| `node: command not found` | Node.js not installed | Install Node.js 18+ from nodejs.org. |
| `fetch is not defined` | Node.js version < 18 | Upgrade to Node.js 18+ (native fetch required). |
| `NOTION_TOKEN is not set` | Environment variable missing | Run `export NOTION_TOKEN=ntn_your_token_here` in terminal. |
| Script hangs or times out | Network issue or Notion API downtime | Check internet connection. Check status.notion.so. |
| `Cannot find module` | Wrong working directory or path | Run scripts from the project root. Check file paths. |

### Quality Issues (Content Problems)

| Symptom | Root Cause | Fix Target | Action |
|---------|-----------|------------|--------|
| Content too generic / not specific | Expert profile lacks domain depth or generation prompt has weak variable interpolation | `expert-profile.md` or `generation-prompt.md` | Go back to Phase 3 or 5 and add more specific vocabulary, positions, and variable-driven instructions |
| Tone drift (voice changes across pages) | Expert profile voice spec too vague, or quality constraints missing in prompt | `expert-profile.md` | Go back to Phase 3 and sharpen primary/secondary tone, add "avoid" examples |
| Missing sections on some pages | Blueprint sections not explicit enough, or generation prompt omits section instructions | `content-blueprint.md` | Go back to Phase 4 and make section specs more explicit with clear rules |
| Wrong format (bullets where tables should be) | Blueprint format specs not strict enough | `content-blueprint.md` | Go back to Phase 4 and add explicit formatting rules per section |
| All entries sound the same | Generation prompt lacks variable-driven variation instructions | `generation-prompt.md` | Go back to Phase 5 and add stronger variation constraints, ensure variables drive meaningful content differences |
| Thin content (sections below word count) | Word count ranges too loose or prompt doesn't emphasize depth | `generation-prompt.md` | Go back to Phase 5 and tighten word count ranges, add "err on upper bound" instruction |
| Hallucinated data (fake statistics, numbers) | Quality constraints missing or insufficient | `generation-prompt.md` | Go back to Phase 5 and strengthen the "no hallucinated data" constraint |
| Filler phrases ("In today's world...") | Quality constraints not enforced | `generation-prompt.md` | Go back to Phase 5 and add explicit filler phrase blacklist |

---

## Prerequisites Checklist

Before starting any Rewyse AI build, verify:

- [ ] **NOTION_TOKEN** -- Set as environment variable (`export NOTION_TOKEN=ntn_...`). Get it from notion.so/my-integrations. Must be an internal integration token.
- [ ] **Node.js 18+** -- Required for all scripts (native `fetch`). Check with `node --version`.
- [ ] **Notion MCP server** -- Connected in `.mcp.json` under the `notion` key. Provides `notion-fetch`, `notion-create-pages`, `notion-update-page`, `notion-create-view`.
- [ ] **Parent page shared with integration** -- The Notion page where the database will be created must be shared with the integration. Page "..." menu > Connections > select your integration.
- [ ] **No npm dependencies needed** -- All scripts use native `fetch`. No `package.json` or `npm install` required.

---

## FAQ

**1. How long does a full build take?**
Roughly 45-120 minutes depending on product size and review speed. Phases 1-6 take ~25-55 minutes (mostly user review time). Phase 7 is 5-30 minutes depending on entry count (50 entries ~10 min, 200 entries ~30 min). Phases 8-10 take ~15-30 minutes.

**2. Can I run a single phase standalone?**
Yes. Every phase skill can run independently outside the orchestrator. When standalone, it asks for inputs instead of reading from state files, and writes output to `output/{phase-name}/` instead of `rewyse-ai/output/{slug}/`.

**3. What if I want to change the expert voice after content is generated?**
Go back to Phase 3 (`/expert-profile`). This resets Phases 5, 6, 7, 8, 9, and 10. You will need to re-run the generation prompt, test content, and full generation. Phase 2 (database) is preserved.

**4. Can I use an existing Notion database?**
Yes, but you need to provide a `database-config.json` with the database ID, property names and types, and parent page ID. You can skip Phase 2 and start from Phase 3. The database must have a Status property with at least "Draft" and "Published" options.

**5. What are the supported product types?**
Ten types: Ebook, SOP (Standard Operating Procedure), Workbook, Template, Checklist, Guide/Playbook, Prompt Pack, Swipe File, Scripts, and Online Course (Outline + Scripts). See `rewyse-ai/shared/product-types-reference.md` for full details on each.

**6. How does delivery mode work (page vs database)?**
Database mode creates sub-pages with filtered database views -- best when categories average 10+ entries each. Page mode creates sub-pages with actual content copied from database entries -- best when categories have fewer than ~10 entries. Phase 1 recommends a mode; Phase 8 verifies against actual data and may switch.

**7. What if I close the conversation mid-build?**
State is persisted in `state.json`. Run `/build-product {slug}` to resume. The orchestrator reads the state, finds the first non-approved phase, checks required inputs exist, and picks up where you left off. Phase 7 is also resumable -- `content-log.json` tracks which entries were already published.

**8. Can I skip a phase?**
Phase 10 (product-expand) is the only phase you can formally skip. All other phases produce outputs required by downstream phases. However, if you already have the equivalent output (e.g., an existing database), you can provide the output file manually and skip that phase.

**9. What's the quality gate?**
Phase 6 (test-content) is the quality gate. It generates 2-3 diverse sample pages and requires user approval before full production. If samples fail, feedback is traced to the upstream artifact (prompt, expert profile, or blueprint) and fixed before retesting.

**10. How many entries can it handle?**
Tested up to 200+ entries. Phase 7 processes in waves of parallel subagents (up to 10 agents, 5-10 entries each). At 50 entries, expect ~10 minutes. At 200 entries, expect ~30 minutes. The content-log.json enables resume if the session is interrupted.

**11. What does Phase 6 (test-content) actually check?**
It validates that the generation prompt, expert voice, and content blueprint work together. Selects three strategically diverse entries (typical, sparse data, unusual combo), generates full pages, and presents them for review. The user checks: tone match, section presence and depth, variable specificity, and formatting correctness.

**12. Why does going back reset downstream phases?**
Because downstream outputs depend on upstream artifacts. If you change the expert profile (Phase 3), the generation prompt (Phase 5) that was built from it is now stale. Similarly, all content generated using the old prompt needs regeneration. The reset ensures consistency.

**13. How do I re-run QA?**
Invoke `/product-qa` again. It re-scans all published entries from scratch. The previous qa-report.md is overwritten with fresh results.

**14. Can I edit generated content manually in Notion?**
Yes. Manual edits in Notion are preserved unless you re-run Phase 7 (generate-content), which clears and regenerates page content. If you only re-run QA (Phase 9), manual edits are safe. If Phase 9 triggers targeted regeneration, only the flagged pages are regenerated.

**15. What if the Notion API rate limits me?**
All scripts use 350ms delays between API calls and process in batches of 5 concurrent requests. If you hit 429 errors, wait 30-60 seconds and re-run. You can also reduce the batch size. The content-log.json ensures failed entries are retried on the next run.

**16. What's the difference between fixed structure and variables?**
Fixed structure is the template that repeats identically on every page (e.g., section headings, formatting, layout). Variables are database properties that change per entry (e.g., recipe name, prep time, category) and drive unique content generation.

**17. How do I start from scratch if something goes wrong?**
Delete the project directory at `rewyse-ai/output/{slug}/` and run `/build-product` to start fresh. Or, go back to the earliest problematic phase -- the reset rules will cascade properly.

**18. Can the pipeline generate images or media?**
No. Rewyse AI generates text content only. The pipeline creates structured Notion pages with headings, paragraphs, tables, lists, callouts, and toggles. For images, the user adds them manually in Notion after generation.

**19. What happens if a subagent fails during batch generation?**
The entry is logged as `"failed"` in content-log.json with the error message. Failed entries are automatically retried on the next run. Successfully published entries are never re-processed.

**20. How do I know which slash command to run for a specific phase?**
See the Slash Command Quick Reference below. Or ask `/rewyse-help` with a question about what to do next and it will check your project state and recommend the right command.

---

## Slash Command Quick Reference

| Command | Phase | Description |
|---------|-------|-------------|
| `/build-product` | 0 | Orchestrate a full product build or resume an existing one |
| `/product-idea` | 1 | Define product type, niche, ICP, variables, and delivery mode |
| `/build-database` | 2 | Create Notion database with properties, views, and entries |
| `/expert-profile` | 3 | Build domain expert persona for content voice |
| `/content-blueprint` | 4 | Define page structure, sections, word counts, formatting |
| `/write-prompt` | 5 | Assemble expert + blueprint into a generation prompt |
| `/test-content` | 6 | Generate 2-3 sample pages for quality validation |
| `/generate-content` | 7 | Batch process all entries and publish to Notion |
| `/design-product` | 8 | Create homepage, browse sections, icons, shareable link |
| `/product-qa` | 9 | Scan for quality issues and optionally regenerate |
| `/product-expand` | 10 | Suggest complementary products with pre-filled briefs |
| `/home-page` | -- | Create or edit Notion home pages (used by Phase 8) |
| `/subpage-views` | -- | Configure linked database views on sub-pages (used by Phase 8) |
| `/prompt-generator` | -- | Generate database creation prompts for product ideas |
| `/rewyse-help` | -- | Q&A, troubleshooting, and status for the Rewyse AI pipeline |

---

## Phase Status Values

| Status | Meaning |
|--------|---------|
| `pending` | Not yet started |
| `in_progress` | Currently being worked on |
| `approved` | User approved the output |
| `needs_revision` | User requested changes |
| `skipped` | User chose to skip (only for Phase 10) |

---

## Phase Timing Estimates

| Phase | Typical Duration | Notes |
|-------|-----------------|-------|
| 1. Product Idea | 5-10 min | Conversational, depends on user clarity |
| 2. Build Database | 2-5 min | Mostly automated (script generation + run) |
| 3. Expert Profile | 5-10 min | Includes voice sample iteration |
| 4. Content Blueprint | 5-10 min | Section design + skeleton review |
| 5. Write Prompt | 3-5 min | Assembly + test generation |
| 6. Test Content | 5-15 min | Depends on revision cycles |
| 7. Generate Content | 5-30 min | Depends on entry count (50 ~10 min, 200 ~30 min) |
| 8. Design Product | 5-10 min | Homepage + views + icons |
| 9. Product QA | 5-15 min | Scan + targeted fixes |
| 10. Product Expand | 3-5 min | Suggestion generation |

**Total: ~45-120 min** for a complete product build.
