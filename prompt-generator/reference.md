# Prompt Generator Reference

This file contains the Format-specific templates, domain expert mapping, and prompt output
format used to generate Notion database creation prompts for digital product ideas.

---

## Section 1: Format Templates

Each Format type has a base database structure skeleton. When generating a prompt for a
product, start with the matching template and customize it based on the product's Niche,
ICP, and "What It Is" description.

All templates share these common elements:
- **Status workflow:** Not Started → In Progress → Review → Published
- **Property limit:** 10-18 properties per database (keep it lean)
- **Property naming:** Natural language with spaces, title case (e.g., "Meal Type")

---

### Playbook

A step-by-step strategic guide with actionable frameworks and decision trees.

**Core Properties:**
- **Play Name** (title) — Name of the strategy or play
- **Phase** (select) — Which stage this play belongs to
- **Objective** (text) — What this play achieves
- **Steps** (text) — Detailed step-by-step instructions
- **When to Use** (text) — Trigger conditions for this play
- **Expected Outcome** (text) — What success looks like

**Categorization:**
- **Category** (select) — Group by strategic area
- **Difficulty** (select) — Beginner, Intermediate, Advanced
- **Priority** (select) — Must Do, Should Do, Nice to Have

**Status:** Status (status) — Not Started | In Progress | Review | Published

**Views:**
1. By Phase (table grouped by Phase)
2. Quick Reference (gallery showing Play Name + Objective)
3. By Difficulty (table filtered/sorted by Difficulty)

---

### Workbook

An interactive, fill-in-the-blank document with exercises, worksheets, and calculations.

**Core Properties:**
- **Exercise Name** (title) — Name of the worksheet or exercise
- **Section** (select) — Which workbook section this belongs to
- **Instructions** (text) — What the user needs to do
- **Input Fields** (text) — What the user fills in
- **Example** (text) — A completed example for reference
- **Output** (text) — What the completed exercise produces

**Categorization:**
- **Category** (select) — Topic or skill area
- **Difficulty** (select) — Beginner, Intermediate, Advanced
- **Time Estimate** (number) — Minutes to complete

**Status:** Status (status) — Not Started | In Progress | Review | Published

**Views:**
1. By Section (table grouped by Section — natural workbook flow)
2. Progress Tracker (table filtered by Status)
3. Quick Exercises (table filtered by Time Estimate < 15 min)

---

### Checklist

A task-based completion tracker with sequential or grouped items.

**Core Properties:**
- **Task** (title) — The checklist item
- **Category** (select) — Group of related tasks
- **Priority** (select) — Critical, Important, Optional
- **Done** (checkbox) — Completion status
- **Notes** (text) — Additional context or tips
- **Order** (number) — Sequence within category

**Categorization:**
- **Phase** (select) — Pre-launch, Launch, Post-launch (or similar)
- **Assignee** (select) — Who handles this (if team-based)

**Status:** Status (status) — Not Started | In Progress | Review | Published

**Views:**
1. Master Checklist (table sorted by Order, grouped by Category)
2. Outstanding (table filtered by Done = unchecked)
3. By Phase (table grouped by Phase)

---

### Template

A pre-built, fill-in-the-blank document or framework users customize for their needs.

**Core Properties:**
- **Template Name** (title) — Name of the template
- **Category** (select) — Type of template
- **Use Case** (text) — When to use this template
- **Instructions** (text) — How to customize it
- **Preview** (url) — Link to preview or screenshot
- **Customization Notes** (text) — What to change and what to keep

**Categorization:**
- **Difficulty** (select) — Beginner, Intermediate, Advanced
- **Industry** (select) — Which industries this fits
- **Tags** (multi_select) — Searchable labels

**Status:** Status (status) — Not Started | In Progress | Review | Published

**Views:**
1. By Category (table grouped by Category)
2. By Use Case (gallery with Use Case + Preview)
3. Beginner Friendly (table filtered by Difficulty = Beginner)

---

### Guide

A comprehensive reference document that teaches concepts and provides how-to instructions.

**Core Properties:**
- **Topic** (title) — Subject of this guide entry
- **Section** (select) — Chapter or module
- **Content** (text) — The guide content
- **Key Takeaway** (text) — Main lesson in one sentence
- **Related Topics** (text) — Cross-references to other entries

**Categorization:**
- **Level** (select) — Beginner, Intermediate, Advanced
- **Type** (select) — Concept, How-To, Reference, Case Study
- **Tags** (multi_select) — Searchable labels

**Status:** Status (status) — Not Started | In Progress | Review | Published

**Views:**
1. By Section (table grouped by Section — reading order)
2. Quick Reference (gallery showing Topic + Key Takeaway)
3. By Level (table grouped by Level)

---

### Toolkit

A curated collection of tools, resources, and assets organized for a specific workflow.

**Core Properties:**
- **Tool Name** (title) — Name of the tool or resource
- **Category** (select) — Type of tool
- **Description** (text) — What it does and why it's useful
- **How to Use** (text) — Quick-start instructions
- **Link** (url) — Where to access the tool
- **Cost** (select) — Free, Freemium, Paid

**Categorization:**
- **Workflow Stage** (select) — Where in the workflow this tool fits
- **Skill Level** (select) — Beginner, Intermediate, Advanced
- **Tags** (multi_select) — Searchable labels

**Status:** Status (status) — Not Started | In Progress | Review | Published

**Views:**
1. By Category (table grouped by Category)
2. Free Tools (table filtered by Cost = Free)
3. By Workflow Stage (board grouped by Workflow Stage)

---

### Cheat Sheet

A quick-reference document with condensed, scannable information.

**Core Properties:**
- **Item** (title) — The concept, command, or reference item
- **Category** (select) — Group of related items
- **Quick Reference** (text) — The essential info (keep it short)
- **Syntax / Formula** (text) — Exact syntax, formula, or format
- **Example** (text) — A concrete usage example
- **Tips** (text) — Pro tips or common mistakes

**Categorization:**
- **Difficulty** (select) — Basic, Intermediate, Advanced
- **Tags** (multi_select) — Searchable labels

**Status:** Status (status) — Not Started | In Progress | Review | Published

**Views:**
1. By Category (table grouped by Category — scannable sections)
2. Basics Only (table filtered by Difficulty = Basic)
3. All Items A-Z (table sorted alphabetically)

---

### Planner

A time-based planning document with calendars, schedules, and goal tracking.

**Core Properties:**
- **Task** (title) — The planned item or goal
- **Date** (date) — When it's scheduled
- **Time Block** (select) — Morning, Afternoon, Evening (or custom)
- **Duration** (number) — Minutes allocated
- **Category** (select) — Area of life or business
- **Priority** (select) — High, Medium, Low
- **Done** (checkbox) — Completion status

**Categorization:**
- **Frequency** (select) — Daily, Weekly, Monthly, Quarterly
- **Goal** (select) — Which bigger goal this supports
- **Tags** (multi_select) — Searchable labels

**Status:** Status (status) — Not Started | In Progress | Review | Published

**Views:**
1. Weekly View (calendar by Date)
2. By Category (table grouped by Category)
3. Upcoming (table sorted by Date, filtered to future dates)
4. Goals Dashboard (table grouped by Goal)

---

### Prompt Pack

A collection of AI prompts organized by use case and context.

**Core Properties:**
- **Prompt Name** (title) — Descriptive name for the prompt
- **Category** (select) — Type of task this prompt handles
- **The Prompt** (text) — The full prompt text
- **Variables** (text) — Placeholders the user customizes (e.g., [YOUR NICHE])
- **Example Output** (text) — What good output looks like
- **Use Case** (text) — When and why to use this prompt

**Categorization:**
- **AI Tool** (select) — ChatGPT, Claude, Midjourney, etc.
- **Difficulty** (select) — Beginner, Intermediate, Advanced
- **Tags** (multi_select) — Searchable labels

**Status:** Status (status) — Not Started | In Progress | Review | Published

**Views:**
1. By Category (table grouped by Category)
2. By AI Tool (table grouped by AI Tool)
3. Quick Wins (table filtered by Difficulty = Beginner)

---

### Bundle

A curated package combining multiple product types into a single offering.

**Core Properties:**
- **Item Name** (title) — Name of the bundle component
- **Item Type** (select) — Template, Guide, Checklist, Cheat Sheet, etc.
- **Description** (text) — What this component delivers
- **Included In** (select) — Which bundle tier includes this
- **Standalone Value** (number) — What this would cost individually
- **Order** (number) — Sequence within the bundle

**Categorization:**
- **Category** (select) — Topic or skill area
- **Tags** (multi_select) — Searchable labels

**Status:** Status (status) — Not Started | In Progress | Review | Published

**Views:**
1. Bundle Overview (table grouped by Item Type)
2. By Tier (table grouped by Included In)
3. Value Breakdown (table with Standalone Value column visible)

---

### Swipe File

A curated collection of proven examples to model and adapt.

**Core Properties:**
- **Example Name** (title) — Descriptive name for the swipe
- **Category** (select) — Type of content (e.g., Headlines, Emails, Ads)
- **The Example** (text) — The actual swipe content
- **Why It Works** (text) — Analysis of what makes it effective
- **How to Adapt** (text) — Instructions for customizing it
- **Source** (text) — Where it came from (for reference)

**Categorization:**
- **Industry** (select) — Which industry this example is from
- **Tone** (select) — Professional, Casual, Urgent, Inspirational
- **Tags** (multi_select) — Searchable labels

**Status:** Status (status) — Not Started | In Progress | Review | Published

**Views:**
1. By Category (table grouped by Category)
2. By Industry (table grouped by Industry)
3. Gallery (gallery showing Example Name + The Example preview)

---

### Ebook

A structured long-form document with chapters, sections, and supporting content.

**Core Properties:**
- **Chapter Title** (title) — Name of the chapter or section
- **Chapter Number** (number) — Order in the book
- **Content** (text) — The chapter content
- **Word Count** (number) — Length of the chapter
- **Key Points** (text) — Main takeaways from this chapter
- **Call to Action** (text) — What the reader should do next

**Categorization:**
- **Part** (select) — Book section (Part 1, Part 2, etc.)
- **Type** (select) — Introduction, Core Content, Case Study, Conclusion
- **Tags** (multi_select) — Searchable labels

**Status:** Status (status) — Not Started | In Progress | Review | Published

**Views:**
1. Reading Order (table sorted by Chapter Number)
2. Writing Progress (table with Status + Word Count visible)
3. By Part (table grouped by Part)

---

## Section 2: Domain Expert Mapping

When generating a prompt, adopt the domain expert persona that matches the product's
**Niche Category**. This ensures database properties, sample entries, and terminology
are authentic to the field.

| Niche Category | Expert Persona | Expertise Focus |
|---------------|---------------|-----------------|
| Blogging & Content | Content Strategy Consultant | editorial calendars, SEO, content funnels |
| Crafts & DIY | Handmade Business Advisor | materials, techniques, pricing handmade goods |
| Design & Creative | Creative Business Strategist | design systems, client workflows, portfolios |
| Ecommerce & Retail | Ecommerce Operations Specialist | product listings, inventory, conversion |
| Education & Career | Education Product Designer | curriculum design, learning outcomes, assessments |
| Entrepreneurship | Startup Business Consultant | business models, validation, growth metrics |
| Finance & Investing | Financial Products Strategist | financial modeling, risk, compliance, returns |
| Food & Hospitality | Culinary Business Consultant | recipes, nutrition, food safety, menu design |
| Freelancing & Remote Work | Freelance Business Advisor | client management, proposals, rate setting |
| Health & Lifestyle | Wellness Business Strategist | health protocols, certifications, client tracking |
| Marketing & Branding | Digital Marketing Strategist | campaigns, funnels, conversion, brand assets |
| Music & Audio | Music Industry Consultant | production, licensing, distribution, gear |
| Photography & Video | Visual Media Business Advisor | shoots, editing workflows, licensing, gear |
| Productivity & Tools | Productivity Systems Designer | workflows, automations, integrations |
| Real Estate | Real Estate Business Strategist | property analysis, market research, transactions |
| Sports & Entertainment | Sports Media Consultant | stats, content calendars, fan engagement |
| Trades & Construction | Trades Business Advisor | inspections, certifications, project management |
| Travel | Travel Industry Specialist | itineraries, deals, booking, destinations |
| Web Development & Tech | Technical Education Specialist | code examples, frameworks, deployment, debugging |

**How to apply:**
1. Read the product's Niche Category
2. Find the matching expert persona above
3. Use that expertise to:
   - Choose domain-accurate property names (e.g., "Protein Source" not "Ingredient Type" for nutrition)
   - Select realistic category options (e.g., actual meal types, real exercise categories)
   - Write sample entries using correct terminology
   - Include metrics that professionals actually track

**If the Niche Category doesn't match any above**, use the more specific **Niche** field to
determine the closest expert persona. When in doubt, default to "Business Product Strategist".

**Zero Hallucination Rule:** Only include domain-specific elements you can confidently justify.
If a categorization or field is industry-standard, include it. Never invent metrics, categories,
or terminology that don't exist in the field.

---

## Section 3: Prompt Output Format

Every generated prompt MUST follow this exact structure. Do not add, remove, or reorder sections.
Use bullet points (•) for all property lists — no markdown bold, no dashes.

```
[EMOJI] [Product Name] - Database Creation Prompt

Create a Notion database called "[Product Name]" for a digital product that [condensed
1-sentence version of "What It Is" — start with a verb like "helps", "walks", "teaches"].

Domain Expertise Applied: [2-4 specific domain skills applied, comma-separated.
E.g., "Digital product pricing strategy, offer positioning, perceived value analysis,
and margin-based pricing design."]

DATABASE STRUCTURE

Core Information
• [Property Name] (title) - [description, under 8 words]
• [Property Name] (number) - [description, under 8 words]
• [Property Name] (text) - [description, under 8 words]
[2-4 core properties. Include an Order/Sequence number property for formats that have
a natural reading order: Workbook, Ebook, Playbook, Checklist, Guide.]

Status & Workflow
• Status (status property) - Tracks entry progress through workflow
    ◦ Draft
    ◦ Review
    ◦ Published

Categorization Properties
• [Property Name] (select) - [description, under 8 words]
• [Property Name] (multi-select) - [description, under 8 words]
• [Property Name] (select) - [description, under 8 words]
[3-5 categorization properties. Use multi-select when entries can belong to multiple
categories. Use select when entries belong to exactly one.]

[Domain-Specific Section Name]
[This section name should reflect the product's field — e.g., "Pricing Strategy & Financials",
"Nutritional Breakdown", "Technical Specifications", "Campaign Metrics".]
• [Property Name] (number) - [description, under 8 words]
• [Property Name] (number) - [description, under 8 words]
[3-8 domain-specific properties. Include formula properties where calculations add genuine
value (margins, scores, totals). Use this syntax for formulas:]
• [Property Name] (formula) - [description, under 8 words]
  Formula: [actual Notion formula syntax, e.g., prop("Price") * (1 - prop("Fee") / 100)]
[Only include formulas when the math is genuinely useful for the product's purpose.]

Content Fields
• [Property Name] (text) - [description, under 8 words]
• [Property Name] (text) - [description, under 8 words]
[2-4 text properties for the main content the user creates or fills in.]

Media
• [Property Name] (url) - [description, under 8 words]
[Only include if the product type needs media. Skip entirely for text-only products.]

RECOMMENDED OPTIONS

[List all select/multi-select properties with their full option sets. This is the
"menu" of options — separate from the structure above for clarity.]

[Property Name]
• [Option 1]
• [Option 2]
• [Option 3]
• [Option 4]
• [Option 5]
[4-8 options per property. Use real domain terminology.]

[Property Name]
• [Option 1]
• [Option 2]
...

VIEWS TO CREATE

1. [View Name] — [View type: Table/Board/Gallery/Calendar/List view]
[1 sentence: what it shows and how it's organized.]

2. [View Name] — [View type]
[1 sentence description.]

3. [View Name] — [View type]
[1 sentence description.]

4. [View Name] — [View type]
[1 sentence description.]

5. [View Name] — [View type]
[1 sentence description.]
[4-6 views. Mix view types — don't use only tables. Board views are great for
grouping by select properties. Gallery for visual products. Calendar for date-based.]

SAMPLE ENTRY FORMAT

Use this format for every row:
• [Property Name]: [How to fill it — brief guidance]
• [Property Name]: [How to fill it — brief guidance]
[List ALL properties with a short instruction on what goes in each field.
This helps the AI agent understand the expected data shape.]

SAMPLE ENTRY

[One COMPLETE example entry showing ALL properties filled in with realistic,
domain-specific content. Use actual terminology — not "Example 1" or "Sample".
Format as a bullet list with • Property Name: Value]

SAMPLE ENTRIES TO ADD

Add [6-10] sample entries covering the full [product scope]:
1. [Entry name]
2. [Entry name]
3. [Entry name]
4. [Entry name]
5. [Entry name]
6. [Entry name]
7. [Entry name]
8. [Entry name]
[6-10 entries that represent the full range of content. Name them descriptively.]

PROPERTY NAMING RULES
• Use natural language with spaces: "[Good Example]" not "[Bad_Example]"
• No underscores, hyphens, or special characters
• Keep names short and clear: "[Short Name]" not "[Long Verbose Name With Extra Words]"
• Use title case consistently

CONSTRAINTS
• Use only Notion-native property types
• Every property must include a short description
• Keep property names clean, readable, and automation-friendly
• Apply real [domain] terminology only
• Status workflow is always: Draft → Review → Published
• Keep the database lean and essential
• Assume each row is one [unit of content] unless changed

BEGIN

Build the database now using this structure.
Set the default sort to [primary sort property] ascending.

Use this database as the master content system for:
• [content type 1]
• [content type 2]
• [content type 3]
• [content type 4]
• [content type 5]
[5-8 bullet points describing what the database manages. These should map to the
product's key deliverables from "What It Is".]

Ensure the final database feels like a [what the product should feel like],
not a generic content library.
```

### Prompt Output Rules

1. **Emoji selection:** Choose an emoji that matches the product's niche (e.g., 🍳 for cooking,
   💰 for finance, 🎨 for design, 📓 for workbooks). Do not reuse the same emoji across products.

2. **Property naming:** Use natural language with spaces, title case.
   Good: "Meal Type", "Cooking Time", "Protein Source"
   Bad: "Meal_Type", "cooking_time", "proteinSource"

3. **Property count:** 15-25 properties total. Enough to be genuinely functional, including
   formulas where calculations add value.

4. **Formula properties:** Include Notion formula properties when calculations are useful
   (margins, scores, totals, percentages). Always provide the actual formula syntax.

5. **Select/multi_select options:** List ALL options in the RECOMMENDED OPTIONS section.
   4-8 options per property, using real domain terminology. Never use generic options.

6. **Sample entries:** Must use real domain terminology. 6-10 entries covering the full
   product scope. For a fitness product, use actual exercise names. For a cooking product,
   use real recipes.

7. **Domain expertise:** The domain-specific section name should reflect the product's field.
   The "Domain Expertise Applied" line should list 2-4 specific skills, not just the persona name.

8. **Keep it actionable:** Every property should serve a clear purpose. If a user wouldn't
   actually fill it in or filter by it, remove it.

9. **No markdown formatting in output** — use plain bullets (•) and indented sub-bullets (◦).
   No bold (**), no dashes (-), no headers (#). The prompt should be plain text that pastes
   cleanly into any AI chat interface.

10. **The prompt is self-contained** — a user should be able to paste it into a Notion AI agent
    and get a working database without any additional context. The BEGIN section ensures the
    AI agent knows exactly what to build.

11. **View variety:** Mix table, board, gallery, calendar, and list views. Don't default to
    all tables. Board views work great for select properties, gallery for visual content.

12. **SAMPLE ENTRY FORMAT section is mandatory** — it teaches the AI agent what data shape
    to expect for every row, preventing misinterpretation of properties.
