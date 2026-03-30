# Home Page Reference

## Canonical Page Structure

Every home page follows this order. All sections are optional except the callout and
at least one navigation section.

```
1. Callout intro (bold summary text with icon)
2. Collapsible toggle sections (What's Inside, How It Works, etc.)
3. "How to Navigate" intro text
4. Navigation sections (repeating):
   a. ## Section Heading
   b. Description text
   c. <columns> block with sub-pages split 50/50
5. Database embed(s)
6. "Also Included" section with <mention-page> tags
```

---

## Notion-Flavored Markdown Block Syntax

### Callout

```markdown
<callout icon="emoji">
	**Bold intro text.** Additional description.
</callout>
```

### Toggle (collapsible section)

```markdown
<details>
<summary>Section Title</summary>
	- **Item 1** — Description
	- **Item 2** — Description
	Content inside must be indented with one tab.
</details>
```

### Columns (2-column layout for sub-pages)

```markdown
<columns>
	<column>
		<page url="https://www.notion.so/{id}">Page Title</page>
		<page url="https://www.notion.so/{id}">Page Title</page>
	</column>
	<column>
		<page url="https://www.notion.so/{id}">Page Title</page>
		<page url="https://www.notion.so/{id}">Page Title</page>
	</column>
</columns>
```

**Indentation rules:**
- `<column>` indented 1 tab inside `<columns>`
- `<page>` tags indented 2 tabs inside `<column>`
- Use tab characters, not spaces

### Page (sub-page reference)

```markdown
<page url="https://www.notion.so/{page-id-no-dashes}">Page Title</page>
```

**WARNING:** A `<page>` tag represents a child page. Removing a `<page>` tag from
content DELETES that child page. Adding a `<page>` tag with an existing URL MOVES
that page into this page as a child.

### Database embed

```markdown
<database url="https://www.notion.so/{db-id}" inline="false" icon="emoji" data-source-url="collection://{data-source-id}">Database Title</database>
```

**Critical:** Always include the `data-source-url` attribute. Omitting it can cause
the database to be deleted or recreated incorrectly.

### Page mention (inline reference, does NOT move the page)

```markdown
<mention-page url="https://www.notion.so/{page-id}"/>
```

### Section heading

```markdown
## Heading Text
```

### Divider

```markdown
---
```

### Empty block

```markdown
<empty-block/>
```

---

## Column Split Rules

For N sub-pages in a section:
- **Left column:** ceil(N / 2) items
- **Right column:** floor(N / 2) items

**Ordering within columns:**
- Items with natural ordering (price ranges, revenue tiers) → keep ascending order,
  continuing from left column to right column
- Items without natural ordering (niches, categories) → alphabetical A-Z,
  continuing from left column to right column

**Examples:**
- 42 items → 21 left, 21 right (alphabetical across both)
- 7 items → 4 left, 3 right (ascending across both)
- 6 items → 3 left, 3 right
- 15 items → 8 left, 7 right

---

## Text Escaping

- Dollar signs in titles must be escaped: `\$1K`, `\$25–\$50`
- Standard markdown escaping applies: `\*`, `\[`, `\]`, `\<`, `\>`

---

## Known Limitations & Workarounds

### 1. MCP cannot set page icons

The Notion MCP tool `update_properties` silently ignores the `icon` property — it
returns success but does not set the icon. The `<page>` tag also does not support
an `icon` attribute.

**Workaround:** Use a Node.js script that calls the Notion REST API directly:
```
PATCH https://api.notion.com/v1/pages/{page-id}
Body: { "icon": { "type": "emoji", "emoji": "..." } }
Headers: Authorization: Bearer {token}, Notion-Version: 2022-06-28
```

Batch requests in groups of 5 with 350ms delay between batches to respect rate limits.

### 2. MCP false-positive deletion warning with columns

When using `replace_content`, the MCP parser cannot detect `<page>` tags inside
`<column>` blocks. It will incorrectly warn that pages would be deleted.

**Workaround:** Set `allow_deleting_content: true`. The pages are preserved because
they ARE referenced in the content — the validation scanner just can't find them
inside column blocks.

### 3. Page titles vs page icons

Page icons and page titles are separate in Notion. Icons appear in the sidebar,
at the top of the page, and next to page links. They are NOT part of the title text.
Never add emoji prefixes to titles as a substitute for proper page icons.

---

## Icon Script Template

Generate scripts at `scripts/set-icons-{slug}.js` following the pattern established
in `scripts/set-subpage-icons.js`. Key structure:

```javascript
const NOTION_TOKEN = process.env.NOTION_TOKEN;

const PAGES = [
  // Section: {section name}
  { id: "{32-char-hex-no-dashes}", emoji: "{emoji}", title: "{title}" },
];

// updatePageIcon function: PATCH /v1/pages/{id} with icon body
// main function: batch in groups of 5, 350ms delay, report success/fail
```

Run with: `NOTION_TOKEN="..." node scripts/set-icons-{slug}.js`

The NOTION_TOKEN can be found in `.claude/settings.local.json` or provided by the user.

---

## Example: Case Studies Home Page

This is the reference implementation that established this pattern:

**Page:** "Start Here — 80+ Digital Product Case Studies" (icon: puzzle piece)
**ID:** `321e268a-566b-8143-aa25-ffa93c372b5e`

**Structure:**
1. Callout (rocket icon): bold intro about 80+ businesses
2. Toggle: "What's Inside" — 4 bullets about case studies, deep dives, product ideas, views
3. Toggle: "What's in Every Deep Dive" — 10 bold items with descriptions
4. "How to Navigate" paragraph
5. Section: "Browse by Niche / Audience" — 42 sub-pages in 2 columns (21/21)
6. Section: "Browse by Monthly Revenue" — 7 sub-pages in 2 columns (4/3)
7. Section: "Browse by Growth Channel" — 15 sub-pages in 2 columns (8/7)
8. Section: "Browse by Average Order Value" — 6 sub-pages in 2 columns (3/3)
9. Database: "80+ Digital Product Case Studies" (inline=false, broccoli icon)
10. "Also Included" section with mention-page to Ideas Library
