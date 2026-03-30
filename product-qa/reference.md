# Product QA Reference — Quality Criteria & Templates

This document contains the detailed quality criteria, checklists, prompt templates,
and report formats for the product-qa skill. Every QA scan must use these definitions.

---

## QA Checklist by Product Type

### Universal Checks (all product types)

- [ ] All blueprint sections present and in correct order
- [ ] Each section within specified word count range (flag if <50% of minimum)
- [ ] Heading hierarchy is correct (h1 title, h2 sections, h3 subsections)
- [ ] No broken or malformed Notion blocks
- [ ] No generic filler phrases
- [ ] No hallucinated statistics or data
- [ ] Tone matches expert profile throughout
- [ ] Domain vocabulary used correctly
- [ ] "Avoid" terms from expert profile are absent
- [ ] Opening paragraph is unique across entries
- [ ] No single-item bullet lists
- [ ] Tables have correct column count and headers
- [ ] Callouts have appropriate emoji and formatting
- [ ] Dollar signs escaped as \$ in financial content

### Ebook / Guide Additions

- [ ] Chapters flow logically from one to the next
- [ ] No repeated examples across chapters
- [ ] Key takeaways actually summarize the chapter content (not generic)
- [ ] Internal cross-references point to valid chapters
- [ ] Progressive complexity — later chapters build on earlier ones

### SOP / Process Document Additions

- [ ] Steps are numbered and sequential
- [ ] Prerequisites listed before instructions
- [ ] Tools/resources mentioned are specific (not "use a tool")
- [ ] Expected outcomes are measurable or verifiable
- [ ] Troubleshooting section addresses real failure modes

### Database / Directory Additions

- [ ] Each entry has a distinct value proposition (not interchangeable descriptions)
- [ ] Category assignments are accurate
- [ ] Numeric properties (price, rating, etc.) are plausible
- [ ] URLs/links are formatted correctly
- [ ] Entries in the same category are differentiated

### Template / Swipe File Additions

- [ ] Templates are actually usable (not just descriptions of templates)
- [ ] Customization instructions are specific and actionable
- [ ] Variables/placeholders are clearly marked
- [ ] Examples demonstrate realistic use cases

### Recipe / Formula Additions

- [ ] Ingredients/components are specific (quantities, names)
- [ ] Steps are in the correct logical order
- [ ] Measurements are consistent (no mixing metric/imperial without conversion)
- [ ] Serving sizes or yield are stated
- [ ] Timing information included where relevant

---

## Quality Criteria Definitions

### What Counts as "Repetitive"

Content is flagged as repetitive when:

- **Cross-entry overlap:** Two or more entries share >60% character similarity in the
  same section (after normalizing whitespace and lowercasing). Measured on the first 100
  characters of each section.
- **Structural repetition:** 3+ entries use the identical sentence template with only
  variable nouns swapped. Example: "This [product] is designed for [ICP] who want to
  [outcome]" appearing verbatim in multiple entries.
- **Opening paragraph clones:** The first paragraph of a page follows the same structure,
  uses the same transitional phrases, and delivers the same type of information in the
  same order as another entry. Even if individual words differ, the pattern is a clone.
- **Filler recycling:** The same generic phrases appear in the same position across
  multiple entries (e.g., every entry's Section 3 starts with "Let's dive deeper into...").

**How to measure:** Normalize text (lowercase, strip punctuation, collapse whitespace),
then compare using character-level overlap. >60% overlap on the first 100 characters of
any section = flag.

### What Counts as "Thin Content"

A section is thin when:

- **Below 50% of minimum word count.** If the blueprint says "80-120 words" and the section
  has fewer than 40 words, it is thin.
- **Surface-level treatment.** The section touches the topic but provides no actionable
  detail, specific examples, or expert insight. It reads like a placeholder.
- **Single-sentence sections.** Any section that is just one sentence (unless the blueprint
  explicitly calls for a single-line element like a tagline or callout).
- **List padding.** A bullet list where each item is 3-5 generic words with no elaboration,
  and the blueprint expected substantive bullet points.

**Threshold:** <50% of minimum word count = WARNING. <25% = CRITICAL.

### What Counts as "Tone Drift"

Tone drift occurs when:

- **Wrong register.** The expert profile says "authoritative and clinical" but the content
  uses casual language ("super easy", "you guys", "honestly").
- **Wrong perspective.** The expert profile says "coaching — direct second-person" but the
  content uses third-person or passive voice.
- **Vocabulary violation.** The content uses terms from the expert profile's "avoid" list
  or fails to use terms from the "use" list in contexts where they naturally apply.
- **Inconsistent tone within a page.** One section is formal and another is casual without
  a clear structural reason (e.g., a callout section being more conversational is fine if
  the blueprint designates it as such).
- **Generic voice.** The content sounds like it could have been written by any AI — no
  markers of the specific expert persona. No domain terms, no opinions, no personality.

**Key signal:** Compare suspect passages against the voice sample in the expert profile.
If the passage could NOT have been written by the same "person," it's tone drift.

### What Counts as "Hallucinated Data"

Content contains hallucinated data when:

- **Specific numbers without source.** Statistics, percentages, dollar amounts, or metrics
  that are not grounded in the entry's variable data or the expert profile's knowledge domain.
- **Fake studies or citations.** References to studies, research, or publications that don't
  exist or can't be verified.
- **Invented examples with false specificity.** "Company X increased revenue by 340% using
  this method" when no such data was provided in the variables.
- **Precise claims from general knowledge.** "The average conversion rate for landing pages
  is 2.35%" — even if approximately true, presenting unverified numbers as fact is a flag.

**Exception:** General directional claims are acceptable ("most businesses see improvement
within the first month") as long as they don't cite specific numbers.

### What Counts as "Formatting Problems"

- **Heading hierarchy violation.** Using h3 before h2, skipping levels, or using h1 for
  anything other than the page title.
- **Orphaned content.** Content that appears before any heading, or blocks that seem
  disconnected from the surrounding structure.
- **Broken tables.** Wrong column count, missing headers, empty cells where content is expected.
- **Single-item lists.** A bullet or numbered list with only one item (should be a paragraph).
- **Empty blocks.** Blank paragraphs, empty callouts, or toggle blocks with no children.
- **Malformed callouts.** Callouts missing their emoji icon, or using the wrong icon type
  for the section purpose.
- **Unescaped dollar signs.** `$` not escaped as `\$` — will render as LaTeX in Notion.

---

## Severity Levels

### CRITICAL

Issues that make the entry unusable or significantly degrade the product:

- Missing section (an entire blueprint section is absent)
- Broken formatting (page structure is visibly broken)
- Completely wrong structure (sections in wrong order, wrong content types)
- Hallucinated data with false specificity (fake statistics, invented citations)
- Content below 25% of minimum word count

**Action:** Must regenerate the entry.

### WARNING

Issues that noticeably reduce quality but don't break the entry:

- Thin content (section below 50% of minimum word count, above 25%)
- Minor tone drift (isolated instances, not pervasive)
- Generic filler phrases (2+ per section)
- Cross-entry repetition (similar openings or structural clones)
- Vocabulary violations (using "avoid" terms or missing key domain terms)
- Single-item lists or minor formatting issues

**Action:** Should regenerate with targeted fix instructions.

### INFO

Minor issues that are worth noting but don't require action:

- Slight vocabulary mismatch (one instance of a non-preferred term)
- Section at the low end of word count range (above 50% but below minimum)
- Minor stylistic inconsistency within a page
- Cosmetic formatting preference (e.g., could benefit from a callout but uses paragraph)

**Action:** Optional. Note for future generation prompt refinement.

---

## Subagent Prompt Template

Use this template for each QA scanning subagent. Fill in `{placeholders}` before dispatching.

```
You are a QA scanner for a Notion-based digital product. You will read {batch_size} pages
and check each one against the content blueprint and expert profile.

## Reference Files

Read these files before scanning:

1. Expert profile: {state_dir}/expert-profile.md
2. Content blueprint: {state_dir}/content-blueprint.md
3. QA reference: rewyse-ai/product-qa/reference.md

## Pages to Scan

{page_list — format: "- Page ID: {id} | Title: {title}" for each page}

## Page Content

The page content has been pre-fetched and is available in:
{state_dir}/qa-batch-{batch_id}-content.json

Read this file to get all block content for each page in this batch. Do NOT make
any Notion API calls — all content is already in the JSON file.

## Quality Checks

For each page, run these 5 checks:

### 1. Blueprint Compliance
Compare the page structure against the content blueprint:
- All sections present? List any missing by name.
- Sections in correct order? Note any out-of-order sections.
- Each section within word count range? Count words per section. Flag if <50% of minimum.
- Correct content types? (heading, paragraph, bullets, table, callout per blueprint)

### 2. Expert Voice
Compare the content against the expert profile:
- Primary tone present throughout?
- Domain-specific vocabulary used? Count occurrences of key terms.
- Any "avoid" terms present? List them with their location.
- Expert perspective/opinions reflected in advisory sections?

### 3. Cross-Entry Uniqueness
- Record the first 100 characters of each section (after normalizing: lowercase, strip
  punctuation, collapse whitespace).
- Within this batch, flag any two entries where the same section has >60% character overlap.
- Always output FINGERPRINT lines for cross-batch comparison.

### 4. Formatting
- Heading hierarchy: h1 for title only, h2 for sections, h3 for subsections.
- Tables: correct column count, headers present, no empty cells.
- Lists: no single-item lists. Minimum 2 items.
- No empty/blank blocks.
- Callouts have emoji icons.
- Dollar signs escaped as \$.

### 5. Content Quality
- Any section below 50% of minimum word count? → Flag as thin.
- Generic filler phrases? Check for: "In today's world", "It's important to note",
  "This is a great way to", "In conclusion", "Let's dive into", "Without further ado",
  "At the end of the day", "It goes without saying".
- Hallucinated data? Any specific numbers/statistics/citations not grounded in the
  entry's variable data?
- Repetitive sentence structures within a single section? (same pattern 3+ times)

## Output Format

For each page, output in this exact format:

PAGE|{page_id}|{title}
ISSUE|{CRITICAL/WARNING/INFO}|{check_name}|{section_name}|{specific description}
FINGERPRINT|{section_name}|{first_100_chars_normalized}
---

If a page has no issues:
PAGE|{page_id}|{title}
CLEAN
FINGERPRINT|{section_name}|{first_100_chars_normalized}
---

IMPORTANT:
- Be specific in descriptions. Reference exact phrases, word counts, and section names.
- Always output FINGERPRINT lines, even for clean pages.
- Use ONLY the severity levels defined: CRITICAL, WARNING, INFO.
- Do not invent new check categories — use the 5 defined checks only.
```

---

## QA Report Format Template

```markdown
# QA Report: {Product Name}

**Date:** {YYYY-MM-DD}
**Database:** {database_id}
**Entries scanned:** {total_scanned}
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

### Issue Distribution by Check

| Check | Critical | Warning | Info |
|-------|----------|---------|------|
| Blueprint Compliance | {N} | {N} | {N} |
| Expert Voice | {N} | {N} | {N} |
| Cross-Entry Uniqueness | {N} | {N} | {N} |
| Formatting | {N} | {N} | {N} |
| Content Quality | {N} | {N} | {N} |

## Critical Issues

### {Page Title}
- **Section:** {section_name}
- **Check:** {check_name}
- **Issue:** {specific description}
- **Fix:** {what needs to change}

{repeat for each critical issue}

## Warnings

### {Page Title}
- **Section:** {section_name}
- **Check:** {check_name}
- **Issue:** {specific description}
- **Fix:** {what needs to change}

{repeat for each warning}

## Info

### {Page Title}
- **Section:** {section_name}
- **Check:** {check_name}
- **Note:** {description}

{repeat for each info item}

## Cross-Entry Uniqueness Flags

| Entry A | Entry B | Section | Overlap | Snippet |
|---------|---------|---------|---------|---------|
| {title} | {title} | {section} | {pct}% | "{first 50 chars}..." |

## Root Cause Analysis

{For each recurring issue (same type in 3+ entries), trace it to the generation prompt}

### {Issue Pattern}: {description}
- **Affected entries:** {count} ({list titles})
- **Likely cause:** {specific part of generation prompt or missing instruction}
- **Suggested prompt fix:** {exact change to make in generation-prompt.md}

## Recommended Actions

1. **{Priority}.** {Action description} — affects {N} entries
2. **{Priority}.** {Action description} — affects {N} entries
3. **{Priority}.** {Action description} — affects {N} entries

## Regeneration Log

| Entry | Issues Fixed | Regenerated At |
|-------|-------------|----------------|
| {title} | {issue descriptions} | {timestamp or "pending"} |
```

---

## Regeneration Prompt Template

When regenerating a flagged entry, use this structure to build the targeted fix prompt:

```
You are regenerating a single page for a Notion-based digital product. The page was
previously generated but flagged during QA for specific issues. You must fix ONLY the
flagged issues while maintaining the same overall structure and quality.

## Original Generation Instructions

{paste the full generation-prompt.md content here}

## Entry Variables

{paste the database properties for this specific entry}

## QA Issues to Fix

The following issues were flagged during quality review. Address each one specifically:

{for each issue:}
### Issue {N}: {severity} — {check_name}
- **Section:** {section_name}
- **Problem:** {specific description}
- **Required fix:** {what needs to change}

## Fix Instructions

- Regenerate the ENTIRE page content (all sections), not just the flagged sections.
  This ensures consistency and flow.
- For flagged sections, apply the specific fixes above.
- For unflagged sections, maintain quality but do NOT copy the previous content
  verbatim — generate fresh content to avoid the appearance of lazy regeneration.
- Follow the content blueprint exactly: correct section order, content types, word counts.
- Match the expert profile voice throughout.
- Escape all dollar signs as \$ in financial content.

## Output

Return the full page content as Notion API blocks (JSON array), ready to be appended
via PATCH https://api.notion.com/v1/blocks/{page_id}/children.
```

---

## Common Quality Issues and Root Causes

### 1. Repetitive Opening Paragraphs

**Symptom:** Multiple entries start with nearly identical introductions — same structure,
same transitional phrases, same information flow.

**Root cause:** The generation prompt's first section instruction is too generic. Example:
"Write an overview paragraph introducing the topic" produces the same AI template every time.

**Fix:** Add variation instructions to the generation prompt: "Vary the opening approach
across entries — some should start with a bold claim, some with a question, some with a
scenario, some with a surprising fact. Never use the same opening structure consecutively."

### 2. Thin Expert Insight Sections

**Symptom:** Advisory or "pro tip" sections are surface-level — generic advice that could
apply to any entry, not specific to the topic.

**Root cause:** The generation prompt references the expert profile but doesn't instruct
the model to apply domain-specific knowledge to the particular entry. The expert voice is
treated as a tone overlay rather than a knowledge source.

**Fix:** Add to the generation prompt: "In [expert section name], the expert must provide
advice specific to THIS entry's [key variable]. Reference the entry's specific attributes.
Generic advice that could apply to any entry in the database is not acceptable."

### 3. Generic Filler Phrases

**Symptom:** Recurring phrases like "In today's world," "It's important to note,"
"Let's dive into," "Without further ado."

**Root cause:** No explicit prohibition in the generation prompt. The model defaults
to common AI writing patterns when filling space.

**Fix:** Add a "Banned phrases" section to the generation prompt listing specific
phrases to never use. Also increase the specificity of section instructions so the model
has enough direction to fill space with real content instead of filler.

### 4. Formatting Inconsistencies

**Symptom:** Some entries use h2 for sections, others use h3. Some use bullet lists,
others use numbered lists for the same section type.

**Root cause:** The blueprint specifies section names and word counts but not the exact
Notion block types. The generation prompt leaves formatting to the model's discretion.

**Fix:** Specify exact block types in the generation prompt: "Section 3 must use a
heading_2 block for the title, followed by a bulleted_list_item for each point."

### 5. Hallucinated Statistics

**Symptom:** Entries contain specific percentages, dollar amounts, or research citations
that were not provided in the variable data.

**Root cause:** The generation prompt encourages "data-driven" or "evidence-based" content
without providing actual data. The model fills the gap with plausible but fabricated numbers.

**Fix:** Either provide real data in the variables, or add to the prompt: "Do not cite
specific statistics, percentages, or research studies unless the data is provided in the
entry variables. Use directional language instead ('most businesses see,' 'typically
improves,' 'often leads to')."

### 6. Tone Drift in Later Sections

**Symptom:** The first few sections match the expert voice well, but later sections
become more generic or shift to a different tone.

**Root cause:** The model's attention to the expert profile instructions fades as it
generates more content. Common in longer pages (1000+ words).

**Fix:** Add a mid-page voice reminder in the generation prompt: "IMPORTANT: Maintain
the expert voice throughout the entire page. The final section should sound as distinctly
expert as the first. Re-read the expert profile before writing sections [N] through [end]."

### 7. Identical Table Structures with Minimal Data Variation

**Symptom:** Tables across entries have the same values in most cells, with only 1-2
cells changing per entry.

**Root cause:** The generation prompt specifies the table structure but the variable
data doesn't provide enough differentiation. Or the model treats the table as a template
to fill rather than a unique data presentation.

**Fix:** Review whether the table section is actually adding value. If entries don't have
enough unique data to populate a distinct table, consider replacing the table with a
different content type or making the table columns dependent on entry-specific variables.

### 8. Missing Sections in Some Entries

**Symptom:** A section from the blueprint is absent in 10-20% of entries, often a section
near the end of the page.

**Root cause:** The model hit its output limit or lost track of the section list for
longer pages. More common with blueprints that have 10+ sections.

**Fix:** Add a section checklist at the end of the generation prompt: "Before finishing,
verify all sections are present: [list all section names]. If any section is missing,
add it before returning the output."
