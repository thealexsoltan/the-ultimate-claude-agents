---
name: content-blueprint
description: "Use when someone asks to define content structure, create a page template, plan a content blueprint, design page layout for a product, or structure content sections."
---

## Context

This skill defines the exact structure of every page in the product — what sections appear,
in what order, at what detail level, with what formatting. The blueprint is the template
that every generated page follows.

For reference on product types, see:
[product-types-reference.md](../shared/product-types-reference.md)

**State directory:** If running inside the orchestrator, read `product-idea.md` and
`expert-profile.md` from `rewyse-ai/output/{project-slug}/`. Write output to
`rewyse-ai/output/{project-slug}/content-blueprint.md`.

If running standalone, ask the user for product and expert context and write to
`output/content-blueprint/{product-slug}.md`.

---

## Step 1: Load Context

**If orchestrated:** Read from the state directory:
- `product-idea.md` — Product type, niche, ICP, fixed structure, variables
- `expert-profile.md` — Expert voice, tone, vocabulary, perspective

**If standalone:** Ask the user:
1. What product are you building? (type, niche, ICP)
2. What's the fixed structure? (elements on every page)
3. What are the variables? (what changes per entry)
4. Do you have an expert profile? (if not, ask about desired tone/voice)

---

## Step 2: Design Page Sections

Based on the product type, niche, and expert profile, define the sections that appear
on every page of the product. For each section:

| # | Section | Content Type | Word Count | Variable Dependencies | Notes |
|---|---------|-------------|------------|----------------------|-------|
| 1 | [name] | [paragraph / bullets / table / callout / heading] | [range] | [which variables feed this section] | [formatting or content rules] |

**Guidelines for section design:**

- **Start with value.** The first section after the title should immediately deliver value,
  not background or context.
- **Match the product type.** A recipe needs ingredients and steps. A template needs
  the template itself and customization instructions. A guide needs strategy sections.
- **Use the expert voice.** If the expert profile says "coaching tone," include sections
  where the expert gives direct advice (e.g., "Coach's Note," "Pro Tip," "Common Mistake").
- **Include the ICP's context.** If the product is for beginners, include more explanation.
  If for advanced users, skip basics and go deeper.
- **Keep it scannable.** Mix content types — don't make every section a wall of paragraphs.
  Use tables, bullets, callouts, and short paragraphs.
- **10-18 properties max.** Don't over-engineer the structure.

Present the section design:

> **Page Blueprint: [Product Name]**
>
> Every page in your product will follow this structure:
>
> | # | Section | Type | ~Words | Driven By |
> |---|---------|------|--------|-----------|
> | 1 | [Title] | heading_1 | — | {title variable} |
> | 2 | [Overview] | paragraph | 50-80 | {variable1}, {variable2} |
> | 3 | [Data Table] | table | — | {variable3}, {variable4} |
> | ... | ... | ... | ... | ... |
>
> **Estimated total per page:** ~[N] words
>
> Does this structure work? Want to add, remove, or reorder anything?

---

## Step 3: Define Section Details

For each section, document the exact content rules the AI must follow:

### Section Template Format

For each section, specify:

```
### Section [N]: [Name]
**Type:** [paragraph / bullets / table / callout / toggle / heading]
**Word count:** [range, e.g., 80-120]
**Variable dependencies:** [which database properties feed this section]
**Content rules:**
- [Specific instruction about what to include]
- [Specific instruction about tone or perspective]
- [Specific instruction about what NOT to include]
**Format:**
- [Markdown formatting rules — bold, italic, emoji usage, etc.]
**Example:**
[A brief example of what this section looks like for a sample entry]
```

Work through each section with the user. For complex sections (like a data table or
a multi-part breakdown), provide more detailed specifications.

---

## Step 4: Generate Sample Skeleton

Create a visual skeleton showing what one complete page looks like with placeholder content.
Use a real-ish example (pick a plausible entry from the product's niche).

> **Sample Page Skeleton: [Example Entry Name]**
>
> # [Title]
>
> [Overview paragraph — 2-3 sentences...]
>
> | Property | Value |
> |----------|-------|
> | [Prop 1] | [Value] |
> | [Prop 2] | [Value] |
>
> ## [Section 3 Heading]
> [Content description...]
>
> ## [Section 4 Heading]
> - [Bullet 1]
> - [Bullet 2]
> - [Bullet 3]
>
> > **[Expert Note Section]**
> > [One-paragraph expert insight...]

This skeleton gives the user a concrete visual of the final product page.

Ask: "This is how every page in your product will look. The AI will fill in all the
content based on each entry's variables. Does this structure work?"

---

## Step 5: Approval Gate

Present the complete content blueprint:

> ## Content Blueprint: [Product Name]
>
> ### Page Structure Overview
> | # | Section | Type | Words | Dependencies |
> |---|---------|------|-------|-------------|
> | ... | ... | ... | ... | ... |
>
> **Total estimated words per page:** ~[N]
>
> ### Section Details
> [Full section-by-section specifications from Step 3]
>
> ### Sample Skeleton
> [The visual skeleton from Step 4]
>
> **Approve** this blueprint to proceed, or tell me what to change.

---

## Step 6: Save Output

Write the approved content blueprint to the appropriate location:

**If orchestrated:**
- Write to `rewyse-ai/output/{project-slug}/content-blueprint.md`
- Update `state.json`: set phase `4_content_blueprint` to `status: "approved"`

**If standalone:**
- Write to `output/content-blueprint/{product-slug}.md`

The output should contain:
1. The section overview table
2. Full section-by-section details (from Step 3)
3. The sample skeleton
4. Any user-approved modifications or notes

---

## Notes

- **The blueprint drives the prompt.** Every section defined here becomes an instruction
  in the generation prompt. Vague sections = vague output. Specific sections = specific output.
- **Word counts are ranges, not targets.** They guide the AI's output length. "80-120 words"
  is better than "100 words" because it allows natural variation across entries.
- **Variable dependencies matter.** If a section says "driven by {Category}" but the
  variable doesn't exist in the product definition, the AI will hallucinate. Cross-check
  every dependency against the product-idea.md variables.
- **Don't duplicate the expert profile.** The blueprint says WHAT goes on the page. The
  expert profile says HOW it's written. The blueprint shouldn't re-specify tone or
  vocabulary — that's the expert profile's job.
- **Tables work for structured data.** If the product has numeric properties (calories,
  price, duration), present them as a table, not inline text.
- **Callouts for expert insights.** If the expert profile includes a coaching or advisory
  perspective, add a callout section (e.g., "Coach's Note", "Pro Tip") where the expert
  voice comes through most strongly.
- **Fewer sections, more depth > More sections, shallow content.** A page with 5 deep
  sections is better than a page with 12 shallow ones.
