---
name: write-prompt
description: "Use when someone asks to write a generation prompt, assemble a content prompt, build an AI prompt for a product, create a parameterized prompt, or finalize the prompt for content generation."
---

## Context

This skill assembles all prior pipeline outputs into a single, optimized generation prompt.
The prompt is parameterized — it accepts database entry variables and produces a complete page
of content following the blueprint in the expert's voice. This is Phase 5 of the Rewyse AI pipeline.

For reference on product types, see:
[product-types-reference.md](../shared/product-types-reference.md)

**State directory:** If running inside the orchestrator, read all inputs from
`rewyse-ai/output/{project-slug}/`. Write output to
`rewyse-ai/output/{project-slug}/generation-prompt.md`.

If running standalone, gather inputs from the user and write to
`output/generation-prompt/{product-slug}.md`.

---

## Step 1: Load Inputs

**If orchestrated:** Read from the state directory:
- `product-idea.md` — Product type, niche, ICP, fixed structure, variable definitions
- `expert-profile.md` — Expert persona, voice, tone, vocabulary, perspective, knowledge boundaries
- `content-blueprint.md` — Page sections, content types, word counts, variable dependencies, formatting rules

Verify all three files exist and contain approved content. If any are missing, stop and
tell the user which phase needs to be completed first.

**If standalone:** Ask the user to provide:
1. What product are you building? (type, niche, ICP, variables)
2. Who is the expert voice? (tone, vocabulary, perspective)
3. What's the page structure? (sections, content types, word counts)

---

## Step 2: Extract Variable Schema

From `product-idea.md`, extract every variable and build a schema table:

| Variable | Type | Placeholder | Used In Sections |
|----------|------|-------------|-----------------|
| [Name] | [select / text / number / etc.] | `{Variable Name}` | [Section numbers from blueprint] |

Cross-check every variable dependency listed in the blueprint against the product-idea
variables. Flag any mismatches:
- Blueprint references a variable that doesn't exist in product-idea — error, resolve before continuing
- Product-idea defines a variable that no blueprint section uses — warning, ask user if it should be removed or if a section should use it

Present the variable schema:

> **Variable Schema:**
>
> | Variable | Type | Placeholder | Sections |
> |----------|------|-------------|----------|
> | Recipe Name | title | `{Recipe Name}` | 1, 2, 7 |
> | Prep Time | select | `{Prep Time}` | 3 |
> | ... | ... | ... | ... |
>
> [Any warnings or errors]
>
> Does this look correct? Any variables to add or remove?

---

## Step 3: Assemble the Generation Prompt

Build the prompt as a single markdown document with these sections in order:

### 3a. System Context

Define who the AI is when generating content. Pull directly from the expert profile:

```
## System Context

You are [expert description from profile].

**Voice:** [primary tone] with [secondary tone]. Never sound [tone to avoid].

**Vocabulary:**
- Use: [key terms from profile]
- Avoid: [generic terms from profile]
- Formality: [level]

**Perspective:**
- [Strong positions from profile]
- [Counter-positions from profile]
- [Teaching philosophy from profile]

**Knowledge Boundaries:**
- Claim confidently: [topics]
- Acknowledge limitations: [topics]
- Never claim: [topics]
```

### 3b. Input Variables Block

Define the placeholder format and list all variables the prompt accepts:

```
## Input Variables

You will receive the following variables for each entry. Use them exactly as provided —
do not invent values for any variable.

| Variable | Type | Description |
|----------|------|-------------|
| {Variable Name} | type | what it controls |
| ... | ... | ... |
```

### 3c. Content Structure

Convert every section from the blueprint into explicit generation instructions:

```
## Content Structure

Generate the following sections in order. Follow the word counts, content types,
and rules exactly.

### Section 1: [Name]
**Type:** [heading / paragraph / table / bullets / callout / toggle]
**Word count:** [range from blueprint]
**Uses:** {Variable 1}, {Variable 2}
**Rules:**
- [Content rule 1 from blueprint]
- [Content rule 2 from blueprint]
- [Formatting rule from blueprint]

### Section 2: [Name]
...
```

### 3d. Formatting Instructions

Specify the exact output format:

```
## Formatting

- Output as Markdown
- Use ## for section headings (not # — the title is the only h1)
- Bold key terms on first use
- Use tables for structured data with 2+ columns
- Use bullet lists for 3+ items
- Use > blockquote for expert callouts / pro tips
- Separate sections with --- horizontal rules
- No introductory meta-commentary (e.g., "Here is the content for...")
- No closing summary unless the blueprint specifies one
- Total target: ~[N] words per page
```

### 3e. Quality Constraints

Add guardrails that prevent common AI failure modes:

```
## Quality Constraints

1. **No filler.** Every sentence must contain specific information or actionable advice.
   Cut "In today's world...", "It's important to note that...", and similar padding.
2. **No hallucinated data.** Only reference facts, numbers, or claims that follow
   logically from the provided variables. Do not invent statistics.
3. **Match the variable.** If {Difficulty} is "Beginner", the entire page must be
   beginner-appropriate. Do not mix levels.
4. **Consistent voice.** Maintain the expert voice across all sections. The same person
   is writing the overview and the pro tip.
5. **Variable-driven variation.** Two entries with different variables must produce
   meaningfully different content — not the same template with swapped words.
6. **Respect word counts.** Stay within the specified range for each section. Err on the
   side of the upper bound rather than padding to reach it.
7. **No self-reference.** Never mention "this prompt", "as an AI", or "I was asked to".
   Write as the expert, not as a system following instructions.
```

---

## Step 4: Generate Test Output

Pick one entry from the product's domain (use realistic variable values) and run the
assembled prompt to generate a sample page. This validates the prompt end-to-end.

If the user provided an entry list in `product-idea.md`, use the first entry. Otherwise,
invent a plausible entry with realistic variable values.

Present the test output:

> **Test Generation: [Entry Name]**
>
> **Variables used:**
> | Variable | Value |
> |----------|-------|
> | {Recipe Name} | Vanilla Almond Dream |
> | {Prep Time} | 10 min |
> | ... | ... |
>
> ---
>
> [Full generated page content]
>
> ---
>
> Review this test output:
> - Does the voice match the expert profile?
> - Does the structure match the blueprint?
> - Are the word counts in range?
> - Does the content feel specific (not generic)?
>
> Tell me what to adjust, or **Approve** to finalize the prompt.

If the user requests changes, adjust the relevant prompt section (system context, structure,
formatting, or constraints) and regenerate the test. Iterate until approved.

---

## Step 5: Approval Gate

Present the complete generation prompt:

> ## Generation Prompt: [Product Name]
>
> **Sections:** [N] sections per page
> **Target words:** ~[N] per page
> **Variables:** [N] input variables
> **Expert voice:** [one-line summary from profile]
>
> ### Full Prompt
> [The complete assembled prompt from Step 3 — all sections]
>
> ### Test Output
> [The approved test generation from Step 4]
>
> **Approve** this prompt to proceed, or tell me what to change.

---

## Step 6: Save Output

Write the approved generation prompt to the appropriate location:

**If orchestrated:**
- Write to `rewyse-ai/output/{project-slug}/generation-prompt.md`
- Update `state.json`: set phase `5_write_prompt` to `status: "approved"`

**If standalone:**
- Write to `output/generation-prompt/{product-slug}.md`

The output file should contain:
1. A metadata header (product name, date, variable count, section count)
2. The complete generation prompt (all subsections from Step 3)
3. The test output that was approved
4. Any user-approved modifications or notes

---

## Notes

- **The prompt is the product's engine.** Every page the user generates runs through this prompt.
  A 1% improvement here multiplies across hundreds of pages. Spend the time to get it right.
- **System context is not optional.** Without the expert voice baked into the prompt, the AI
  defaults to generic assistant tone. The system context section is what makes every page sound
  like it was written by a domain expert, not ChatGPT.
- **Placeholders must match exactly.** `{Recipe Name}` in the prompt must match the variable
  name in `product-idea.md` exactly — same capitalization, same spacing. Mismatched placeholders
  produce broken output at generation time.
- **Quality constraints prevent drift.** Without explicit guardrails, the AI will pad content,
  hallucinate data, and lose the expert voice by page 20. The constraints section is what keeps
  page 100 as good as page 1.
- **The test output is non-negotiable.** Never skip it. It's the only way to validate the prompt
  before it drives bulk generation. A prompt that looks good on paper can produce bad content.
- **Don't over-constrain.** The prompt should guide, not micromanage. If every sentence is
  scripted, the AI can't adapt to different variable combinations and output becomes repetitive.
  Leave room for variable-driven variation.
- **Keep the prompt under 2000 words.** Longer prompts don't produce better output — they
  produce confused output. If the prompt is growing beyond 2000 words, the blueprint probably
  has too many sections.
