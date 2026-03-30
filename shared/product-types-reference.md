# Product Types Reference — Rewyse AI Skills

Catalog of digital product types supported by the AI Digital Product Agent.
Each type includes its description, typical fixed structure, typical variables,
and an example product to illustrate the concept.

The key concept: every product has a **fixed structure** (elements that stay the same
on every page) and **variables** (elements that change from page to page). The AI agent
generates unique content for each page by combining the fixed structure with different
variable values.

---

## 1. Ebook

**Description:** A multi-chapter digital book delivered as Notion pages. Each chapter
or section is a database entry with AI-generated long-form content.

**Typical Fixed Structure:**
- Chapter number
- Chapter title
- Introduction paragraph
- Main content sections (3-5 per chapter)
- Key takeaways / summary
- Call-to-action or transition to next chapter

**Typical Variables:**
- Chapter topic
- Subtopics
- Target outcome for the chapter
- Key concepts to cover

**Example:** "The Hyrox Nutrition Playbook" — 20 chapters covering race-day fueling,
recovery nutrition, supplement protocols, and meal prep strategies for hybrid athletes.

---

## 2. SOP (Standard Operating Procedure)

**Description:** Step-by-step process documents. Each entry is a specific procedure
with detailed instructions, tools needed, and expected outcomes.

**Typical Fixed Structure:**
- Procedure title
- Purpose / objective
- Tools / resources needed
- Prerequisites
- Step-by-step instructions
- Expected outcome
- Troubleshooting / common issues
- Version / last updated

**Typical Variables:**
- Procedure name
- Department / category
- Complexity level
- Tools required
- Number of steps

**Example:** "Agency Onboarding SOPs" — 50 procedures covering client intake, project
setup, team assignment, reporting setup, and communication protocols.

---

## 3. Workbook

**Description:** Interactive exercise-based products. Each entry is a worksheet or
exercise with prompts, frameworks, and space for the user to fill in their answers.

**Typical Fixed Structure:**
- Exercise title
- Learning objective
- Context / background
- Exercise prompts (questions or frameworks)
- Example answer
- Reflection questions
- Next steps

**Typical Variables:**
- Exercise topic
- Skill area
- Difficulty level
- Framework type

**Example:** "The Brand Strategy Workbook" — 30 exercises covering positioning,
messaging, visual identity, and competitive analysis.

---

## 4. Template

**Description:** Pre-built, fill-in-the-blank documents. Each entry is a ready-to-use
template that customers customize for their specific situation.

**Typical Fixed Structure:**
- Template title
- Use case description
- Instructions for customization
- The template itself (with placeholder text)
- Tips for best results
- Related templates

**Typical Variables:**
- Template name
- Category / use case
- Industry / niche
- Complexity level

**Example:** "100 Email Templates for Real Estate Agents" — templates for lead
follow-up, listing announcements, open house invitations, and client nurturing.

---

## 5. Checklist

**Description:** Actionable checklists for specific processes or goals. Each entry
is a complete checklist with items organized by phase or category.

**Typical Fixed Structure:**
- Checklist title
- Purpose / when to use
- Category or phase labels
- Checklist items (with descriptions)
- Completion criteria
- Pro tips

**Typical Variables:**
- Checklist topic
- Category
- Number of items
- Context / scenario

**Example:** "The Product Launch Checklist Library" — 40 checklists covering
pre-launch, launch day, post-launch, and iteration phases for digital products.

---

## 6. Guide / Playbook

**Description:** Comprehensive how-to guides on specific topics. Each entry is a
deep guide with strategies, tactics, examples, and implementation steps.

**Typical Fixed Structure:**
- Guide title
- Overview / what you'll learn
- Why this matters
- Core strategy sections (3-7 per guide)
- Implementation steps
- Common mistakes to avoid
- Resources / tools mentioned
- Action items

**Typical Variables:**
- Topic
- Strategy area
- Target audience level (beginner/intermediate/advanced)
- Industry context

**Example:** "Growth Channel Playbooks" — 25 guides covering SEO, paid ads,
content marketing, partnerships, and community building for SaaS founders.

---

## 7. Prompt Pack

**Description:** Curated collections of AI prompts for specific use cases. Each
entry is a prompt with context, the prompt itself, expected output, and variations.

**Typical Fixed Structure:**
- Prompt title
- Use case
- AI tool (ChatGPT, Claude, Midjourney, etc.)
- The prompt (copy-paste ready)
- Expected output description
- Customization tips
- Variations / follow-up prompts

**Typical Variables:**
- Prompt topic
- Category
- AI tool
- Difficulty / specificity level

**Example:** "200 ChatGPT Prompts for Content Creators" — prompts for ideation,
writing, repurposing, engagement, and analytics across platforms.

---

## 8. Swipe File

**Description:** Curated collections of real-world examples to study and model.
Each entry is a documented example with analysis of why it works.

**Typical Fixed Structure:**
- Example title
- Source / origin
- Category
- The example itself (text, screenshot description, or breakdown)
- Why it works (analysis)
- How to adapt it
- Key principles demonstrated

**Typical Variables:**
- Example name
- Category
- Source type
- Industry / niche

**Example:** "High-Converting Landing Page Swipe File" — 75 documented landing
pages with conversion analysis, headline breakdowns, and CTA strategies.

---

## 9. Scripts

**Description:** Ready-to-use scripts for specific situations — sales calls,
videos, podcasts, webinars, or customer interactions. Each entry is a complete
script with stage directions and customization notes.

**Typical Fixed Structure:**
- Script title
- Scenario / context
- Duration estimate
- Opening
- Main body sections
- Closing / CTA
- Customization notes
- Objection handling (if sales-related)

**Typical Variables:**
- Script topic
- Scenario type
- Audience
- Tone (formal/casual/urgent)
- Duration

**Example:** "50 Sales Call Scripts for Coaches" — scripts for discovery calls,
objection handling, closing conversations, and follow-up calls.

---

## 10. Online Course (Outline + Scripts)

**Description:** Course curriculum with lesson outlines and scripts. Each entry is
a lesson with learning objectives, script content, slide notes, and exercises.
Note: the AI generates the text content — the customer records the course themselves
(or uses AI voiceover tools like ElevenLabs).

**Typical Fixed Structure:**
- Lesson title
- Module number
- Learning objectives
- Lesson script / talking points
- Slide notes (if applicable)
- Key concepts
- Exercise / homework
- Transition to next lesson

**Typical Variables:**
- Lesson topic
- Module
- Concepts to cover
- Exercise type
- Duration target

**Example:** "Complete Pinterest Marketing Course" — 30 lessons across 5 modules
covering profile setup, pin strategy, SEO, analytics, and monetization.

---

## Identifying Fixed Structure vs. Variables

When working with a customer to define their product, use these questions:

### For Fixed Structure:
- "What elements appear on EVERY page of your product?"
- "What's the consistent format — does every entry have the same sections?"
- "What properties in the database stay the same across all entries?"

### For Variables:
- "What changes from one page/entry to the next?"
- "What makes each entry unique?"
- "What data does the AI need to generate different content for each page?"

### The Smoothie Library Example (from the training):
- **Fixed structure:** Recipe name field, calorie table, carbs field, description field, dietary tag
- **Variables:** The actual recipe name, specific calorie count, specific ingredients, specific instructions

The AI prompt uses the fixed structure as the template and plugs in variable values
for each database entry. This is what allows one prompt to generate hundreds of
unique pages.
