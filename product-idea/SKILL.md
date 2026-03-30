---
name: product-idea
description: "Use when someone asks to define a product idea, choose a product type, identify product variables, plan a digital product concept, or start a new product."
---

## Context

Before doing anything, read the product types catalog:
[product-types-reference.md](../shared/product-types-reference.md)

This skill helps users define exactly what digital product to build. It identifies the
product type, niche, target customer, and — most importantly — the fixed structure vs.
variables that make automated content generation possible.

**State directory:** If running inside the orchestrator (`/build-product`), read the
project state from `rewyse-ai/output/{project-slug}/state.json`. Write output to
`rewyse-ai/output/{project-slug}/product-idea.md`.

If running standalone, write output to `output/product-idea/` with a descriptive filename.

---

## Step 1: Gather Core Inputs

Ask the user the following (skip any they've already provided):

1. **What do you want to create?**
   Present the 10 supported product types from the reference:
   > 1. Ebook
   > 2. SOP (Standard Operating Procedure)
   > 3. Workbook
   > 4. Template
   > 5. Checklist
   > 6. Guide / Playbook
   > 7. Prompt Pack
   > 8. Swipe File
   > 9. Scripts
   > 10. Online Course (Outline + Scripts)
   >
   > Pick a number, or describe your product and I'll match the best type.

2. **What niche is this for?**
   Get the specific domain. Not just "fitness" — push for specificity:
   "fitness" → "What kind of fitness? Hyrox? CrossFit? Yoga? Bodybuilding?"

3. **Who is this for? (ICP — Ideal Customer Profile)**
   Get the specific person who will buy and use this product:
   - What's their role or identity? (e.g., "Hyrox athletes training for their first race")
   - What problem are they solving? (e.g., "Don't know what to eat around training")
   - What's their experience level? (beginner, intermediate, advanced)

4. **What's the core value — why would someone buy this?**
   One sentence that captures the product's promise.

5. **How many entries/pages should the product have?**
   Get a target range (e.g., "50-100 recipes", "30 templates", "200 prompts").

---

## Step 2: Domain Research

Before defining any structure or variables, research what a world-class version of this
product looks like. Use a subagent (Agent tool, model: sonnet) to investigate the domain.

**The subagent MUST use WebSearch to find real products, competitors, and domain-specific
information.** This is real market research, not LLM knowledge generation. The subagent
should search for existing products, bestsellers, reviews, and expert content in the niche.

**Fallback:** If web searches return no useful results (obscure niche, rate limits, etc.),
the subagent should:
1. Clearly state which searches were attempted and what came back empty
2. Fall back to domain knowledge, but **label every recommendation as "based on domain
   knowledge, not verified market data"**
3. Suggest the user validate the recommendations against their own market knowledge
   before proceeding

**Subagent prompt:**
> You are a product design researcher. Your job is to research the real market for this
> product concept using WebSearch and return specific, actionable recommendations.
>
> **Product type:** {product_type}
> **Niche:** {niche}
> **ICP:** {ICP}
> **Core value:** {value_proposition}
>
> **IMPORTANT: You MUST use WebSearch for every section below.** Do not rely on your
> training data alone. Search for real products, real reviews, real competitors.
>
> Suggested searches (adapt to the niche):
> - "best {product_type} for {niche}" / "top {niche} {product_type} 2025 2026"
> - "{niche} {product_type} review" / "what makes a great {niche} {product_type}"
> - "{ICP} needs" / "what {ICP} look for in {product_type}"
> - "{niche} common mistakes" / "{niche} expert advice"
> - Marketplace searches: Gumroad, Etsy, Amazon (for ebooks), Notion template galleries
>
> Research and return:
>
> 1. **Best-in-class examples** — Find 3-5 real existing products in this space.
>    Include names, URLs where possible, what they include, pricing, and what makes
>    them stand out. What sections/elements do they include on each page?
>
> 2. **Must-have data points** — Based on what top products include and what real
>    customers mention in reviews, what specific properties/fields does this product
>    need? Think about what the ICP actually needs to make decisions. For example,
>    a recipe database for athletes needs more than just ingredients — it needs macro
>    breakdowns, timing windows, training phase tags.
>
> 3. **Filtering & browse dimensions** — How would the ICP want to find and filter
>    entries? What are the natural categories, groupings, or sorting dimensions?
>    These become select/multi_select properties.
>
> 4. **Common gaps** — Based on real customer reviews and forum discussions, what do
>    most products in this space get wrong or leave out? What would make this product
>    feel complete where others feel thin?
>
> 5. **Recommended page structure** — Based on the above, suggest:
>    - Fixed structure elements (what appears on every page)
>    - Variables (what changes per entry) with recommended types and example values
>    - Properties that should be select (fixed options) vs. text (freeform)
>
> Be specific to the niche. Generic advice is useless — every recommendation should
> reference the actual domain, ICP, and real products you found.

**Present the research findings to the user:**

> **Domain Research: What a world-class {product_type} in {niche} looks like**
>
> **Best-in-class reference points:**
> - [Finding 1]
> - [Finding 2]
>
> **Must-have data points for your ICP:**
> - [Data point] — why it matters for {ICP}
> - [Data point] — why it matters
>
> **How your audience wants to browse:**
> - By [dimension] (e.g., by training phase, by meal type)
> - By [dimension]
>
> **Gaps in existing products we can fill:**
> - [Gap]
>
> Based on this research, here's my recommended structure...

This research directly feeds into Steps 3 and 4. Do NOT present generic product type
templates — use the domain research to customize every recommendation.

---

## Step 3: Define Fixed Structure

Based on the domain research and product type, identify what stays the same on EVERY page.

Start with the "Typical Fixed Structure" from the product types reference, then **customize
it using the domain research findings.** Add niche-specific elements the research identified
as must-haves. Remove generic elements that don't serve this specific ICP.

Present the fixed structure:

> **Fixed Structure (appears on every page):**
> 1. [Element] — [description] — *[why this matters for {ICP}]*
> 2. [Element] — [description] — *[why this matters]*
> 3. [Element] — [description] — *[why this matters]*
> ...

Ask: "Does this structure work for your product, or would you add/remove/change anything?"

---

## Step 4: Define Variables

Using the domain research (especially the "must-have data points" and "filtering dimensions"),
identify what changes from page to page. For each variable:

| Variable | Type | Purpose | Example Values |
|----------|------|---------|----------------|
| [Name] | title / text / select / multi_select / number / checkbox | [What it controls] | [2-3 examples] |

**Important:** Variables become Notion database properties AND parameters in the AI generation prompt. Every variable must have:
- A clear name (natural language with spaces, e.g., "Meal Type" not "meal_type")
- A property type (determines how Notion stores it)
- A purpose (how the AI uses it to generate unique content)
- Example values (so the user can verify the variable makes sense)

**Use domain research to inform variable suggestions:**
- Properties the research identified as "filtering dimensions" → `select` or `multi_select`
- Properties the research identified as "must-have data points" → appropriate type
- Don't just list what the user asked for — suggest what the research says a great product needs

Present the variable catalog and ask for approval:

> **Variables (change per entry):**
>
> | Variable | Type | Purpose | Examples |
> |----------|------|---------|----------|
> | Recipe Name | title | Main identifier | "Vanilla Almond Dream", "Green Matcha Detox" |
> | Training Phase | select | When to consume relative to training cycle | "Base", "Build", "Peak", "Recovery", "Race Day" |
> | Prep Time | select | Time constraint for recipe | "5 min", "10 min", "15 min", "20 min" |
> | ...
>
> *Properties marked with * were suggested by domain research.*
>
> Does this capture all the variables? Anything to add or change?

---

## Step 5: Define Entry List (Optional)

If the user already knows what entries they want, collect them. Otherwise, suggest they
can populate entries later (in `/build-database`).

Options:
- **User provides a list** — "Here are my 50 recipe names" → capture them
- **User wants AI-generated entries** — Note this for the database phase
- **User will add later** — Note that entries will be added in the database phase

---

## Step 5b: Recommend Delivery Mode

Based on the planned product size and variable structure, recommend how the customer
will browse the final product.

**Two delivery modes:**
- **`database`** — Sub-pages with filtered database views. Best when categories have
  10+ entries each. Rich browsing with sortable lists.
- **`page`** — Category headings on homepage with individual entry sub-pages containing
  actual content. Best when categories have fewer than ~10 entries. Polished, not empty.

**Decision logic:**
1. Take the target entry count (from Step 1)
2. Find the largest `select` property option count (from Step 4 variables)
3. Estimate: `target_entries / largest_select_option_count`
4. If avg < 10 → recommend `page`
5. If avg >= 10 → recommend `database`

Present briefly:
> **Delivery mode:** `{page|database}` — With ~{N} entries across {M} categories,
> each averages ~{avg} entries. *(Can be overridden in Phase 8.)*

---

## Step 6: Approval Gate

Present the complete product definition:

> ## Product Definition: [Product Name]
>
> **Type:** [Product type]
> **Niche:** [Specific niche]
> **ICP:** [Target customer description]
> **Value Proposition:** [One-sentence promise]
> **Target Size:** [Number of entries/pages]
>
> ### Fixed Structure
> 1. [Element]
> 2. [Element]
> ...
>
> ### Variables
> | Variable | Type | Purpose |
> |----------|------|---------|
> | ... | ... | ... |
>
> ### Entry List
> [Provided / To be generated / To be added later]
>
> ### Delivery Mode
> **Recommended:** `{page|database}` — {one-sentence reason}
> *(Can be overridden in Phase 8 after entries are populated)*
>
> **Approve** this definition to proceed, or tell me what to change.

Wait for user approval before proceeding.

---

## Step 7: Save Output

Write the approved product definition to the appropriate location:

**If orchestrated (state directory exists):**
- Write to `rewyse-ai/output/{project-slug}/product-idea.md`
- Update `state.json`: set phase `1_product_idea` to `status: "approved"`

**If standalone:**
- Write to `output/product-idea/{product-slug}.md`

The output file should contain the full product definition in the format shown in Step 6,
as a markdown document that downstream skills can read and parse. Include the delivery
mode recommendation.

**If orchestrated:** Also save `delivery_mode` to `state.json → delivery_mode` (`"page"` or `"database"`).

---

## Notes

- **Push for niche specificity.** "Fitness" is not a niche. "Hyrox race nutrition" is. The more specific the niche, the better the expert profile and content will be in later phases.
- **Variables are the key.** If the variables are wrong, the entire generation pipeline produces bad output. Spend time getting these right.
- **Property types matter.** `select` means a fixed list of options. `multi_select` allows multiple values. `text` is freeform. `number` is numeric. Choose the right type for each variable.
- **Don't over-complicate the structure.** Keep properties lean — 10-18 max per database. More properties = more complexity in the generation prompt = worse output quality.
- **Online courses are special.** The AI generates scripts and outlines, but the user records the actual video/audio. Make sure they understand this.
- **Some products need hierarchical structure.** An ebook has chapters and sections. A course has modules and lessons. Capture the hierarchy in the variables (e.g., "Module" as a select, "Lesson" as the title).
- **Delivery mode is a recommendation, not a lock.** Phase 8 verifies against actual
  database distribution and may switch modes. The recommendation here gives a useful
  early signal for the user.
