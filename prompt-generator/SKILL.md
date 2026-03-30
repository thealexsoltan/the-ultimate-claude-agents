---
name: prompt-generator
description: "Use when someone asks to generate database prompts, create notion prompts, build database prompts for products, generate a prompt for a product, or batch generate prompts for digital product ideas."
---

## Context

Before doing anything, read the full templates and rules in [reference.md](reference.md).
All generated prompts must follow the Format-specific templates, domain expert mapping, and
prompt output structure documented there. Do not generate prompts from generic knowledge —
use the templates and rules exactly as described in the reference.

**Database:** 800+ Digital Product Ideas
**Database URL:** `https://www.notion.so/e6bf2ce7122d417eabeec28ad3406a9e`
**Data Source:** `collection://e563c76e-e263-443b-a110-b12f6f4d32cd`

This skill uses the Notion MCP tools to fetch product data and update pages.

**Output Directory:** `output/prompt-generator/` in the project root.
**Progress File:** `output/prompt-generator/progress.json` — tracks which products have been processed.
**Prompts Directory:** `output/prompt-generator/prompts/` — individual prompt files saved here.

**Properties used as context (per product):**

| Property | Type | Purpose |
|----------|------|---------|
| Product Name | title | Database name + prompt title |
| Format | select | Determines base template (12 types) |
| What It Is | text | Detailed description — primary context |
| Why It Sells | text | Value prop — informs DB emphasis |
| ICP | multi_select | Target audience — shapes properties + samples |
| Niche | select | Specific domain — drives expert persona |
| Niche Category | select | Broad category — fallback for domain mapping |
| Price Point | number | Pricing context |
| Funnel Position | select | Product positioning |
| Growth Channel | multi_select | Distribution context |
| Source Company | text | Origin case study |
| Source Revenue | text | Revenue context |

---

## Two Modes

### Single Mode
When the user provides **one specific product name**.
Uses the approval gate — present prompt, wait for user decision, then push to Notion.
See: Steps 1 → 2-Single → 3 → 4 → 5

### Batch Mode (default for multiple)
When the user says "batch", "generate all", "do all", or provides a number (e.g., "do 50").
**Autonomous agents** — each agent handles a batch of 5-10 products of the SAME Format type
end-to-end (generate + save files). No approval gate per product.
See: Steps 1 → 2-Batch → 3 → 4 → 5

---

## Step 1: Fetch & Group Products

### Query the Database

Query using `notion-query-database-view` with the data source:
`collection://e563c76e-e263-443b-a110-b12f6f4d32cd`

**IMPORTANT:** The query result will be too large to display directly and will be saved to a
temp file. Do NOT try to read the file manually. Instead, use Bash with `jq` and `python3`
to extract what you need:

```bash
cat '<temp-file-path>' | jq -r '.[0].text' | python3 -c "
import json, sys, re
data = json.load(sys.stdin)
products = []
for r in data.get('results', []):
    products.append({
        'name': r.get('Product Name', ''),
        'format': r.get('Format', ''),
        'what_it_is': r.get('What It Is', ''),
        'why_it_sells': r.get('Why It Sells', ''),
        'icp': r.get('ICP', []),
        'niche': r.get('Niche', ''),
        'niche_category': r.get('Niche Category', ''),
        'price_point': r.get('Price Point', ''),
        'funnel_position': r.get('Funnel Position', ''),
        'growth_channel': r.get('Growth Channel', []),
        'source_company': r.get('Source Company', ''),
        'source_revenue': r.get('Source Revenue', ''),
        'url': r.get('url', '')
    })
# Group by Format
from collections import defaultdict
by_format = defaultdict(list)
for p in products:
    by_format[p['format']].append(p)
for fmt, items in sorted(by_format.items()):
    print(f'{fmt}: {len(items)} products')
print(f'Total: {len(products)}')
# Save full product list as JSON for later use
import json as j
with open('/Users/alexander/Downloads/RW - Claude Code Project/output/prompt-generator/products.json', 'w') as f:
    j.dump({'by_format': {k: v for k, v in by_format.items()}, 'total': len(products)}, f, indent=2)
"
```

### Check Progress

Read `output/prompt-generator/progress.json` to get already-processed product slugs.
Filter them out from the product list before proceeding.

### Present Summary

> "Found {N} products across {F} Format types:
> - Workbook: {n}
> - Checklist: {n}
> - Template: {n}
> - ...
> Already processed: {M}
> Remaining: {N - M}
>
> Ready to generate prompts?"

For **Single Mode**, skip the grouping — just find the specific product and proceed.

---

## Step 2-Single: Generate One Prompt (Single Mode)

Use a subagent (Agent tool, model sonnet) to generate the prompt.

Tell the subagent to:

1. **Read the reference file:**
   `rewyse-ai/prompt-generator/reference.md`

2. **Use this product's metadata:**
   - Product Name: {name}
   - Format: {format}
   - What It Is: {what_it_is}
   - Why It Sells: {why_it_sells}
   - ICP: {icp}
   - Niche: {niche}
   - Niche Category: {niche_category}
   - Price Point: {price_point}

3. **Generate a complete database creation prompt** following:
   - The Format-specific template from reference.md (Section 1)
   - The domain expert persona from reference.md (Section 2)
   - The exact prompt output format from reference.md (Section 3)

4. **Save to:**
   `/Users/alexander/Downloads/RW - Claude Code Project/output/prompt-generator/prompts/{slug}.md`

5. **Return:** `RESULT|{slug}|{format}|{niche_category}|SUCCESS`

Then proceed to Step 3 (Review Gate).

---

## Step 2-Batch: Autonomous Agents (Batch Mode)

Process products grouped by Format for maximum efficiency.

### Preparation

Read `output/prompt-generator/products.json` (saved in Step 1).
Read `output/prompt-generator/progress.json` to filter out already-processed products.
Split each Format group into batches of 5-10 products.

### Launch Agents

Launch **up to 15 agents in parallel**, each handling one batch of same-Format products.
Use `model: sonnet` and `run_in_background: true` for all agents.

### Agent Prompt Template

Each agent receives this prompt (fill in `{format}`, `{format_template}`, and `{product_list}`):

```
You are a Notion database prompt generator. You will generate complete, ready-to-paste
database creation prompts for a batch of digital product ideas — all of the same Format type.

## Step 1: Read Reference

Read the reference file for templates, domain mapping, and output format:
rewyse-ai/prompt-generator/reference.md

## Step 2: Your Batch

Format: {format}

Here is the Format-specific template skeleton to use as your base:

{format_template}

Products to process:

{product_list}

## Step 3: Generate Prompts

For EACH product in the batch:

1. Identify the domain expert persona based on the product's Niche Category
   (see Section 2 of reference.md)
2. Start with the Format template skeleton above
3. Customize the database properties, views, and sample entries based on:
   - The product's "What It Is" description (primary context)
   - The product's "Why It Sells" (what to emphasize)
   - The product's ICP (who will use this database)
   - The product's Niche (domain-specific terminology)
4. Generate 3-5 realistic sample entries using domain expertise
5. Follow the exact prompt output format from Section 3 of reference.md

## Step 4: Save Files

For each product, derive the slug: lowercase the Product Name, replace spaces and
non-alphanumeric characters with hyphens, strip trailing hyphens, collapse multiple hyphens.

Save each prompt to:
/Users/alexander/Downloads/RW - Claude Code Project/output/prompt-generator/prompts/{slug}.md

## Step 5: Return Results

Return one line per product in this EXACT format:
RESULT|{slug}|{format}|{niche_category}|SUCCESS

Or if a product fails:
RESULT|{slug}|{format}|ERROR|{reason}

IMPORTANT:
- Generate ALL products in the batch — do not skip any.
- Each prompt must be complete and ready-to-paste (not a skeleton).
- Apply genuine domain expertise — use real terminology from the niche, not generic placeholder text.
- Follow the prompt output format EXACTLY as defined in reference.md Section 3.
- Property names must use natural language with spaces (e.g., "Meal Type" not "Meal_Type").
- Keep database structures lean — 10-18 properties max per database.
```

### After All Agents Complete

Parse each agent's RESULT lines and:
1. Update `output/prompt-generator/progress.json` with all results
2. Count successes and failures per Format type
3. Proceed to Step 3 (Review Gate)

---

## Step 3: Review Gate

### Single Mode
Present the generated prompt to the user. Ask:

> "Here's the database creation prompt for [Product Name]. Review it:
> - **Approve** — I'll push it to the Notion page
> - **Revise** — Tell me what to change
> - **Skip** — Don't push this one
>
> I won't update Notion until you confirm."

### Batch Mode
After the first wave of agents completes, show a summary + 1 sample prompt per Format type:

> "**Generation complete — first wave**
> Processed: {N} products across {F} Format types
> Successes: {S} | Failures: {E}
>
> Sample prompts (one per Format):
> [Show 1 prompt per unique Format in the batch]
>
> Review the samples above. You can:
> - **Approve all** — Continue generating remaining products + push to Notion
> - **Adjust** — Tell me what to change in the template approach
> - **Review more** — I'll show more samples before proceeding"

Wait for user decision before continuing with remaining batches or pushing to Notion.

---

## Step 4: Push to Notion

After prompts are approved (or in batch mode, after all generation is complete):

For each product, use `notion-update-page` to write the prompt as a **code block** on the
product's Notion page body. This allows one-click copy.

### Push Format

Use `notion-update-page` with command `replace_content`:
- `page_id`: extract from product's `url` property
- `new_str`: wrap the prompt in a code fence:

````
```
[full prompt content here]
```
````

**Important:** Escape dollar signs as `\$` in any content sent to Notion.

### Batch Push

In batch mode, launch up to 10 parallel push agents (run_in_background).
Each agent pushes prompts for a batch of products.

Track push status in `progress.json` — update each product's `pushed` field to `true`.

---

## Step 5: Save Progress & Session Summary

### Update Progress File (both modes)

Read `output/prompt-generator/progress.json`, add new entries, and write back:

```json
{
  "last_updated": "YYYY-MM-DD",
  "generated": {
    "{slug}": {
      "date": "YYYY-MM-DD",
      "format": "Workbook",
      "niche_category": "Finance & Investing",
      "status": "generated",
      "pushed": false
    }
  },
  "stats": {
    "total_generated": N,
    "total_pushed": N,
    "total_remaining": N
  }
}
```

### Session Summary

> **Prompt Generation Session Summary**
> **Date:** {YYYY-MM-DD}
> **Products processed:** {N}
> **Prompts generated:** {S}
> **Prompts pushed to Notion:** {P}
>
> | Format | Generated | Pushed | Remaining |
> |--------|-----------|--------|-----------|
> | Workbook | N | N | N |
> | Checklist | N | N | N |
> | ... | ... | ... | ... |
>
> **Total remaining:** {N} products

---

## Notes

- **Always read reference.md first.** The Format templates, domain mapping, and prompt output
  format are the foundation of every generated prompt.
- **Batch mode groups by Format.** This is the key optimization — each subagent handles 5-10
  products of the SAME Format type, reusing the template skeleton across all products in the batch.
- **Up to 15 parallel agents** in batch mode. If more products remain, process in waves.
- **Progress tracking is mandatory.** Always update progress.json after each session. This
  allows stop/resume across conversations.
- **Dollar signs in Notion** must be escaped as `\$`.
- **Slug derivation:** Lowercase the Product Name, replace spaces and non-alphanumeric chars
  with hyphens, collapse multiple hyphens, strip leading/trailing hyphens.
- **Code blocks for prompts.** Always wrap prompts in code fences when pushing to Notion.
  This enables one-click copy for users.
- **Domain expertise is critical.** Each prompt must use real terminology from the product's
  niche — not generic placeholder text. The domain expert persona mapping in reference.md
  guides this.
- If `progress.json` doesn't exist, create it with an empty structure.
- If `products.json` doesn't exist, run Step 1 first to fetch and group products.
- **Carry the Notion page URL** through from Step 1 to Step 4 — don't re-fetch.
