---
name: product-expand
description: "Use when someone asks to suggest next products, expand their product line, find complementary products, or grow their digital product business."
---

## Context

This skill is Phase 10 of the Rewyse AI pipeline. After a user has built a complete digital
product, this skill analyzes it and suggests 3-5 complementary products that serve the
same audience but solve different problems. The goal: build a product LINE, not a single product.

For reference on product types, see:
[product-types-reference.md](../shared/product-types-reference.md)

**State directory:** If running inside the orchestrator (`/build-product`), read from
`rewyse-ai/output/{project-slug}/`. Write output to the same directory.

If running standalone, ask the user which project to expand and locate (or create) the
appropriate state directory.

---

## Step 1: Load the Existing Product

**If orchestrated:** Read from the state directory:
- `product-idea.md` — Product type, niche, ICP, variables, value proposition
- `content-blueprint.md` — Page structure and section design
- `expert-profile.md` — Expert voice, domain knowledge, vocabulary
- `database-config.json` — *Optional.* Database properties and entry metadata
- `qa-report.md` — *Optional.* Quality scan results (gaps and patterns inform suggestions)

Extract and confirm:
- **Product name**
- **Product type** (which of the 10 types)
- **Niche** (specific domain)
- **ICP** (who bought this product)
- **Core value proposition** (what problem it solved)
- **Price point** (if known)

**If standalone:** Ask the user:
1. What product did you build? (name, type, niche)
2. Who is it for? (ICP)
3. What problem does it solve?
4. What's the price point? (if known)

Present a summary and confirm before proceeding:

> **Existing Product:**
> - **Name:** [name]
> - **Type:** [type]
> - **Niche:** [niche]
> - **ICP:** [description]
> - **Core Value:** [proposition]
>
> Is this correct? Anything to add or update?

---

## Step 2: Research Complementary Product Opportunities

Before generating suggestions, run market research using a subagent to ground expansion
ideas in real market data rather than pure LLM inference.

Launch a subagent (Agent tool, model: sonnet) with this prompt:

> You are a market researcher analyzing complementary product opportunities.
>
> **Completed product:** {product_type} for {niche} targeting {ICP}
> **Core product:** {value_proposition}
>
> **IMPORTANT: You MUST use WebSearch for every section below.** Do not rely on training data alone.
>
> Suggested searches:
> - "complementary products for {niche}" / "{niche} product bundle"
> - "what else do {ICP} buy" / "{ICP} needs beyond {product_type}"
> - "{niche} digital products" / "best selling {niche} products Gumroad Etsy"
> - "{niche} upsell ideas" / "{niche} product ecosystem"
>
> Research and return:
> 1. **Market gaps** — What complementary products exist? What's missing?
> 2. **Customer journey** — What does the ICP need before, during, and after using the core product?
> 3. **Competitor bundles** — How do competitors package complementary products?
> 4. **Demand signals** — What are people asking for in forums, reviews, social media?
> 5. **Recommended expansions** — Based on real market data, suggest 5 product directions with evidence.
>
> **Fallback:** If web searches return no useful results, clearly state which searches were attempted, fall back to domain knowledge labeled as "based on domain knowledge, not verified market data", and suggest the user validate.

Present the research summary to the user before proceeding to generate final suggestions.

---

## Step 3: Identify Expansion Angles

Analyze the existing product through five lenses to find complementary opportunities:

1. **Adjacent problems** — What other problems does this ICP face that the current
   product does NOT solve? (e.g., a recipe book doesn't solve meal planning)
2. **Before/after needs** — What does the customer need BEFORE using this product
   or AFTER finishing it? (e.g., before a training plan: equipment checklist)
3. **Format gaps** — What would this content look like in a DIFFERENT format?
   (e.g., an ebook's content repackaged as templates or checklists)
4. **Depth vs. breadth** — Could you go DEEPER on one subtopic, or WIDER to cover
   a related domain? (e.g., from general recipes to race-week-specific nutrition)
5. **Pricing ladder** — What's missing from the product line at a lower price
   (lead magnet / tripwire) or higher price (premium / bundle)?

Do NOT present these lenses to the user. Use them internally to generate suggestions.

---

## Step 4: Generate 3-5 Complementary Product Suggestions

**Use data from upstream artifacts to sharpen suggestions:**
- If `database-config.json` is available, check entry distribution across categories to identify underserved areas
- If `qa-report.md` is available, use quality gaps or thin content areas as expansion signals

For each suggestion, provide:

| Field | Description |
|-------|-------------|
| **Product Name** | Clear, specific name |
| **Product Type** | One of the 10 supported types (ebook, SOP, workbook, template, checklist, guide, prompt pack, swipe file, scripts, online course) |
| **Why It Complements** | 1-2 sentences on how it relates to the existing product |
| **ICP Overlap** | Same audience, different need — what specific need does this serve? |
| **Pricing Relationship** | Upsell (higher price, more depth), cross-sell (similar price, different angle), downsell (lower price, simpler format), or bundle component |
| **Description** | 2-3 sentences describing the product and its value |
| **Cross-Sell Hook** | How this product references or links back to the existing product |

Present all suggestions in a numbered list:

> ## Expansion Suggestions for [Existing Product Name]
>
> ### 1. [Product Name] — [Product Type]
> **Why it complements:** [explanation]
> **ICP overlap:** Same audience ([ICP]), different need: [need]
> **Pricing:** [upsell / cross-sell / downsell / bundle] — suggested $[range]
> **Description:** [2-3 sentences]
> **Cross-sell hook:** [how it references the existing product]
>
> ### 2. [Product Name] — [Product Type]
> ...
>
> ---
> **Which of these would you like to develop?** Pick one or more (e.g., "1 and 3"),
> or tell me to adjust any suggestion.

Wait for user selection before proceeding.

---

## Step 5: Generate Expansion Briefs

For each selected suggestion, generate a pre-filled `product-idea.md` that can be
used directly with `/build-product` or `/product-idea`. Format it identically to the
output of the `/product-idea` skill:

> ## Product Definition: [Product Name]
>
> **Type:** [Product type]
> **Niche:** [Specific niche]
> **ICP:** [Target customer — carried from existing product]
> **Value Proposition:** [One-sentence promise]
> **Target Size:** [Estimated number of entries/pages]
> **Pricing Relationship:** [upsell / cross-sell / downsell / bundle] to [existing product name]
>
> ### Fixed Structure
> 1. [Element] — [description]
> 2. [Element] — [description]
> ...
>
> ### Variables
> | Variable | Type | Purpose | Example Values |
> |----------|------|---------|----------------|
> | ... | ... | ... | ... |
>
> ### Cross-Sell Integration
> - [How this product references the existing product]
> - [Bundle opportunity or upsell path]
>
> ### Entry List
> [5-10 example entries to illustrate scope]

Present each brief for approval. The user can request changes before finalizing.

---

## Step 6: Save Output

Write the approved expansion briefs to:

**If orchestrated:**
- Write `expansion-brief.md` to `rewyse-ai/output/{project-slug}/`
  containing all approved briefs in a single file
- Each brief is separated by a horizontal rule (`---`)
- Include a summary section at the top listing all approved expansions

**If standalone:**
- Write to `rewyse-ai/output/{project-slug}/expansion-brief.md`
  (create the directory if needed, using the existing product's slug)

The expansion brief file should be structured as:

```
# Expansion Brief: [Existing Product Name]

## Summary
- Original product: [name] ([type])
- Approved expansions: [count]
- [List each: name — type — pricing relationship]

---

## Brief 1: [Product Name]
[Full product definition from Step 5]

---

## Brief 2: [Product Name]
[Full product definition from Step 5]
```

Tell the user they can now run `/build-product` or `/product-idea` using any of
these briefs as a starting point.

**If orchestrated:** Update `state.json`: set phase `10_product_expand` to `status: "approved"`.

---

## Notes

- **Same ICP, different problem.** Every suggestion must serve the SAME audience. If the ICP shifts, it's not a complementary product — it's a different business. Push back if suggestions drift.
- **Vary the product types.** Don't suggest 5 ebooks. Mix formats: a checklist, a template, a guide, a workbook. Different formats = different price points = a real product line.
- **The pricing ladder matters.** A good product line has a low-ticket entry ($9-19), a core offer ($29-49), and a premium tier ($79-149+). Suggest products that fill gaps in the user's pricing ladder.
- **Cross-sell hooks are non-negotiable.** Every product in the line should mention or reference the others. "If you're using our [Existing Product], this [New Product] is the perfect companion because..." This is how product lines compound.
- **Pre-filled briefs save time.** The expansion brief should be detailed enough that the user can hand it to `/product-idea` and skip half the questions. Don't generate vague suggestions — generate actionable briefs.
- **3-5 suggestions, not more.** Overwhelm kills action. If you can identify 10 possibilities, pick the 5 strongest. Quality over quantity.
- **Respect what exists.** Read the existing product files carefully. Suggestions should feel like natural extensions, not random ideas. If the expert profile has a coaching voice, the expansion products should maintain that voice.
