# Generate Images — Reference

This file contains all templates, API patterns, and pricing reference for the
`generate-images` skill. SKILL.md links here for the deep details.

---

## Section 1: Pricing Reference (April 2026)

### OpenAI `gpt-image-2` *(default)*

| Size | Quality | Approx cost |
|------|---------|-------------|
| 1024×1024 | low | \$0.011 |
| 1024×1024 | medium | \$0.042 |
| 1024×1024 | high | \$0.167 |
| 1024×1536 | medium | \$0.063 |
| 1536×1024 | medium | \$0.063 |

**Default for Rewyse AI:** `1024×1024 medium` — best fit for Notion page covers,
balanced cost.

### kie.ai

| Model | Endpoint | Approx cost |
|-------|----------|-------------|
| `gpt-image-2-text-to-image` *(default — same model as OpenAI, ~30% cheaper)* | `/api/v1/jobs/createTask` | ~\$0.030 |
| `nano-banana-2` (up to 4K) | `/api/v1/jobs/createTask` | ~\$0.040 |
| `google/nano-banana` (legacy, cheaper) | `/api/v1/jobs/createTask` | ~\$0.020 |

kie.ai pricing is positioned at 30-50% below official APIs. Confirm current rates at
`https://kie.ai/pricing` before quoting users.

**Always inflate the estimate by 10-15%** for batch overhead, retries, and the 2-3 sample
images reviewed before approval.

---

## Section 2: Per-Entry Prompt Template

For per-entry mode, build each image prompt by extracting from the entry:

### Inputs
- `title` — entry's display title
- `key_variables` — the most descriptive properties (skip Status, Date Created, etc.)
- `key_content` — first 200-400 chars of the entry's primary content section (e.g., recipe
  description, framework summary, case study one-liner)
- `style_guidance` — 1-2 sentences from the user's inspiration + product type defaults

### Template

```
A {style_guidance} illustration of {subject_phrase}.
{visual_details_from_entry}.
Composition: centered, clean negative space, suitable for a square page cover.
Style: {style_descriptor}. No text, no watermarks, no logos.
```

### Example — recipe product

Entry title: "Sweet Potato Power Bowl"
Variables: protein=tofu, cuisine=southwestern, time=15min
Content excerpt: "Roasted sweet potato cubes, charred corn, black beans, avocado-lime
dressing"

Generated prompt:
```
A warm minimalist food photography illustration of a sweet potato power bowl viewed from
overhead. Roasted orange sweet potato cubes, charred corn, black beans, sliced avocado,
drizzled lime dressing in a ceramic bowl on a wooden surface. Composition: centered, clean
negative space, suitable for a square page cover. Style: soft natural light, muted earthy
palette, food photography. No text, no watermarks, no logos.
```

### Example — mental model product

Entry title: "Inversion"
Variables: domain=decision-making
Content excerpt: "Solve problems backward by considering what would cause failure"

Generated prompt:
```
A geometric minimalist illustration representing the mental model 'inversion'. Two arrows
pointing in opposite directions, one filled and one outlined, intersecting at a central
point, with subtle gradient shading. Composition: centered, generous negative space,
suitable for a square page cover. Style: flat geometric, muted blue-and-cream palette,
editorial illustration. No text, no watermarks, no logos.
```

### Rules

- **2-4 sentences max.** Image models perform worse with long prompts.
- **Concrete nouns + adjectives** > abstract concepts.
- **Always specify "no text, no watermarks, no logos"** — image models love adding bad text.
- **Always specify composition** — "centered, clean negative space" produces better Notion
  covers than crowded compositions.
- **Style descriptor must match across all entries** for visual consistency.

---

## Section 3a: Section Prompt Templates (Multi-Section Mode)

Each section type has a default prompt template. The style descriptor (defined once per
product based on user inspiration) is prepended to every prompt for visual consistency.
Subject specifics are derived from the entry's content variables.

### Style anchor (shared across all section prompts in a product)

```
{STYLE} = "Clean overhead {subject_type} photography for {audience}. {Lighting}.
{Palette}. Composition: centered, generous negative space. Style: {aesthetic
descriptor}. No text, no watermarks, no logos."
```

### Section type → prompt template

| Section type | Visual purpose | Prompt template |
|---|---|---|
| **Cover / Hero** | Anchor image for the entry | `{STYLE}\n\nSubject: {hero_description from entry title + key variables}. Composition suitable for a square page cover.` |
| **Ingredients / Components** | Flat-lay arranged for easy scanning | `{STYLE}\n\nSubject: A flat-lay arrangement of {ingredient_list from variables} on a {surface}. {Items} spaced apart like a magazine cookbook layout. {Lighting direction}.` |
| **Instructions / Process** | Final result or active process shot | `{STYLE}\n\nSubject: {finished_result_description}. {Garnish/styling details}. {Surface and lighting}.` |
| **Equipment / Setup** | Gear arranged ready-to-use | `{STYLE}\n\nSubject: {equipment_list} arranged on a {surface}, ready to use. {Mood: pre-action, post-action}.` |
| **Before & After** | Two-state comparison | `{STYLE}\n\nSubject: A side-by-side comparison — left: {before_state}, right: {after_state}. Same composition, same lighting, contrast in {what_changed}.` |
| **Diagram / Conceptual** | Abstract visual of an idea | `{STYLE}\n\nSubject: A geometric minimalist illustration representing {concept}. {Visual metaphor}. Composition: centered, generous negative space.` |

### Section name → section type mapping

When discovering sections from `content-blueprint.md`, classify each by name. Examples:

| Section name in blueprint | Section type |
|---|---|
| Ingredients / Ingredient List / What You Need | Ingredients |
| Instructions / Steps / Method / How To Make | Instructions (use Final Result template) |
| Equipment / Setup / Gear / Tools | Equipment |
| Before & After / Transformation / Results | Before & After |
| Hero / Intro / Overview / Opening | Cover (or extra hero image) |
| Coach's Note / Pro Tip / Author's Note | **Skip** (text-only callout) |
| Macro Panel / Stats / Nutrition Facts | **Skip** (it's a table) |
| Performance Rationale / Why This Matters | **Skip** (the text IS the value) |

### Example — Hyrox Race Morning Banana Oat Pancakes (multi-section)

Style anchor:
```
Clean overhead food photography for elite endurance athletes. Soft natural daylight,
muted earthy palette (warm beige, sage, cream, tomato accent). Composition: centered,
generous negative space. Style: editorial sports-nutrition aesthetic, slightly
desaturated, premium magazine feel. No text, no watermarks, no logos.
```

Cover prompt:
```
{STYLE}
Subject: A stack of golden banana oat pancakes on a ceramic plate, drizzled with a thin
honey ribbon, topped with fresh banana slices. A small ramekin of berries and a glass of
water beside the plate. Light wooden surface, dawn lighting suggesting pre-race morning.
Composition suitable for a square page cover.
```

Ingredients prompt:
```
{STYLE}
Subject: A flat-lay arrangement of recipe ingredients on a light wooden surface — a
glass bowl of instant oats, one ripe banana, two whole eggs, a small bowl of egg white,
a tiny ramekin of baking powder, a pinch of salt, a small bottle of vanilla extract, a
small jar of coconut oil, and a glass jar of honey. Ingredients spaced apart like a
magazine cookbook layout. Soft directional morning light from upper left.
```

Instructions prompt (final-result variant):
```
{STYLE}
Subject: A finished stack of 4 golden banana oat pancakes on a ceramic plate, glossy
honey drizzled across the top dripping down the sides, sliced banana coins fanned at
the top, a small dollop of Greek yogurt next to the stack. A fork rests beside the
plate. Light wooden surface, dawn lighting. Slight steam suggesting fresh off the pan.
```

All three reuse the same `{STYLE}` block — that's what makes them feel like a coherent
magazine spread.

---

## Section 3: Style-Batch Style Suggestions

When generating the 3 candidate styles in Step 3, vary them along these axes:

1. **Illustration vs photographic vs abstract**
2. **Palette** — warm/cool, saturated/muted, monochrome/multi
3. **Composition** — centered/asymmetric, dense/sparse, geometric/organic

### Example — for a "Mental Models for Founders" product

> **Style 1 — Editorial Geometric**
> Flat geometric illustration, navy + cream + single accent color (terracotta), centered
> compositions with generous negative space. Sharp clean lines, no gradients. Feels like
> a New Yorker cover or Stripe blog header.
>
> **Style 2 — Soft Organic**
> Hand-drawn watercolor illustration, dusty pastel palette (sage, dusty pink, cream),
> organic asymmetric compositions. Loose brush strokes, gentle texture. Feels like a
> Penguin Modern Classics cover.
>
> **Style 3 — High-Contrast Conceptual**
> Black-and-white photographic still-life with a single saturated accent (red or yellow),
> minimalist objects arranged conceptually. High contrast, dramatic lighting. Feels like
> a Wieden+Kennedy ad or HBR magazine spread.

### Style prompt format (for sample generation)

For each style, prepend the style description as a system-prompt-style preamble, then add
the per-image purpose:

```
{style_description}

Image purpose: {hero | section_icon_X | category_Y}.
{specific_subject_for_this_image}

No text, no watermarks, no logos. Centered composition with clean negative space.
```

---

## Section 4: Provider Adapter Script

Save as `scripts/image-providers.js` (project root, alongside other rewyse scripts). All
batch scripts source it.

```javascript
// scripts/image-providers.js
// Unified image-generation interface for OpenAI and kie.ai.
// Usage: const { generateImage } = require('./image-providers');

const fs = require('fs');
const path = require('path');

// ---------- OpenAI gpt-image-2 ----------

async function generateOpenAI({ prompt, size = '1024x1024', quality = 'medium', outputPath, model = 'gpt-image-2' }) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) throw new Error('OPENAI_API_KEY not set');

  const res = await fetch('https://api.openai.com/v1/images/generations', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model,
      prompt,
      n: 1,
      size,
      quality,
    }),
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`OpenAI ${res.status}: ${errText}`);
  }

  const data = await res.json();
  const b64 = data.data[0].b64_json;
  const buf = Buffer.from(b64, 'base64');
  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, buf);
  return { path: outputPath, provider: 'openai' };
}

// ---------- kie.ai (gpt-image-2 default, falls back to nano-banana) ----------

async function generateKie({ prompt, aspectRatio = '1:1', resolution = '1K', model = 'gpt-image-2-text-to-image', outputPath }) {
  const apiKey = process.env.KIE_API_KEY;
  if (!apiKey) throw new Error('KIE_API_KEY not set');

  // Build input shape based on which kie.ai model is used.
  // gpt-image-2-text-to-image uses {prompt, aspect_ratio, resolution}.
  // nano-banana / nano-banana-2 use {prompt, image_size, output_format}.
  const isGptImage2 = model.startsWith('gpt-image-2');
  const input = isGptImage2
    ? { prompt, aspect_ratio: aspectRatio, resolution }
    : { prompt, image_size: aspectRatio, output_format: 'png' };

  // 1. Create task
  const createRes = await fetch('https://api.kie.ai/api/v1/jobs/createTask', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ model, input }),
  });

  if (!createRes.ok) {
    throw new Error(`kie.ai create ${createRes.status}: ${await createRes.text()}`);
  }

  const createData = await createRes.json();
  const taskId = createData.data?.taskId;
  if (!taskId) throw new Error(`kie.ai response missing taskId: ${JSON.stringify(createData)}`);

  // 2. Poll for completion (kie.ai jobs typically resolve in 5-30s)
  const maxWait = 120_000; // 2 minutes
  const start = Date.now();
  let imageUrl = null;

  while (Date.now() - start < maxWait) {
    await new Promise(r => setTimeout(r, 3000));

    const statusRes = await fetch(`https://api.kie.ai/api/v1/jobs/recordInfo?taskId=${taskId}`, {
      headers: { 'Authorization': `Bearer ${apiKey}` },
    });
    if (!statusRes.ok) continue;

    const statusData = await statusRes.json();
    const state = statusData.data?.state || statusData.data?.status;
    if (state === 'success' || state === 'completed') {
      imageUrl = statusData.data?.resultJson
        ? JSON.parse(statusData.data.resultJson).resultUrls?.[0]
        : statusData.data?.output?.[0]?.url || statusData.data?.output_url;
      break;
    }
    if (state === 'failed' || state === 'error') {
      throw new Error(`kie.ai task failed: ${statusData.data?.failMsg || 'unknown'}`);
    }
  }

  if (!imageUrl) throw new Error(`kie.ai timed out for task ${taskId}`);

  // 3. Download
  const imgRes = await fetch(imageUrl);
  if (!imgRes.ok) throw new Error(`kie.ai download failed: ${imgRes.status}`);
  const buf = Buffer.from(await imgRes.arrayBuffer());
  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, buf);
  return { path: outputPath, provider: 'kie' };
}

// ---------- Unified entry point ----------

async function generateImage({ provider, prompt, outputPath, size, quality, model, aspectRatio, resolution }) {
  if (provider === 'openai') {
    return generateOpenAI({
      prompt,
      size: size || '1024x1024',
      quality: quality || 'medium',
      model: model || 'gpt-image-2',
      outputPath,
    });
  }
  if (provider === 'kie') {
    return generateKie({
      prompt,
      aspectRatio: aspectRatio || '1:1',
      resolution: resolution || '1K',
      model: model || 'gpt-image-2-text-to-image',
      outputPath,
    });
  }
  throw new Error(`Unknown provider: ${provider}`);
}

module.exports = { generateImage, generateOpenAI, generateKie };
```

### Notes on the kie.ai polling endpoint

kie.ai's task-detail endpoint has been documented under multiple names across versions
(`recordInfo`, `getJob`, `taskInfo`). If `recordInfo` returns 404, the script falls back
through the alternate field names. If a future kie.ai release changes the endpoint, update
this adapter — that's the only place that needs to change.

---

## Section 5: Notion File Upload Helpers

Two helper functions for any image-upload script. Both depend on `NOTION_TOKEN`.

```javascript
// Step 1+2: Upload a local file to Notion. Returns the file_upload ID.
async function uploadFileToNotion(localPath) {
  const token = process.env.NOTION_TOKEN;
  const fs = require('fs');
  const path = require('path');

  // 1. Create file_upload object
  const createRes = await fetch('https://api.notion.com/v1/file_uploads', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Notion-Version': '2022-06-28',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({}),
  });
  if (!createRes.ok) {
    throw new Error(`Notion create file_upload ${createRes.status}: ${await createRes.text()}`);
  }
  const { id, upload_url } = await createRes.json();

  // 2. Send file via multipart
  const fileBuf = fs.readFileSync(localPath);
  const filename = path.basename(localPath);
  const boundary = `----rewyse${Date.now()}`;
  const head = Buffer.from(
    `--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="${filename}"\r\nContent-Type: image/png\r\n\r\n`
  );
  const tail = Buffer.from(`\r\n--${boundary}--\r\n`);
  const body = Buffer.concat([head, fileBuf, tail]);

  const sendRes = await fetch(upload_url, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Notion-Version': '2022-06-28',
      'Content-Type': `multipart/form-data; boundary=${boundary}`,
    },
    body,
  });
  if (!sendRes.ok) {
    throw new Error(`Notion send file ${sendRes.status}: ${await sendRes.text()}`);
  }
  const sendData = await sendRes.json();
  if (sendData.status !== 'uploaded') {
    throw new Error(`Notion file status: ${sendData.status}`);
  }
  return id;
}

// Step 3a: Set as page cover
async function setPageCover(pageId, fileUploadId) {
  const token = process.env.NOTION_TOKEN;
  const res = await fetch(`https://api.notion.com/v1/pages/${pageId}`, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Notion-Version': '2022-06-28',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      cover: {
        type: 'file_upload',
        file_upload: { id: fileUploadId },
      },
    }),
  });
  if (!res.ok) throw new Error(`Notion set cover ${res.status}: ${await res.text()}`);
  return res.json();
}

// Step 3b: Append as image block on a page (at the end)
async function appendImageBlock(pageOrBlockId, fileUploadId) {
  const token = process.env.NOTION_TOKEN;
  const res = await fetch(`https://api.notion.com/v1/blocks/${pageOrBlockId}/children`, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Notion-Version': '2022-06-28',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      children: [{
        type: 'image',
        image: {
          type: 'file_upload',
          file_upload: { id: fileUploadId },
        },
      }],
    }),
  });
  if (!res.ok) throw new Error(`Notion append image ${res.status}: ${await res.text()}`);
  return res.json();
}

// Step 3c: Insert image AFTER a specific block (multi-section mode)
// Used to place section images right under their target heading.
async function insertImageAfter(pageId, afterBlockId, fileUploadId) {
  const token = process.env.NOTION_TOKEN;
  const res = await fetch(`https://api.notion.com/v1/blocks/${pageId}/children`, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Notion-Version': '2022-06-28',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      after: afterBlockId,
      children: [{
        type: 'image',
        image: {
          type: 'file_upload',
          file_upload: { id: fileUploadId },
        },
      }],
    }),
  });
  if (!res.ok) throw new Error(`Notion insert image ${res.status}: ${await res.text()}`);
  return res.json();
}

// Discover heading block IDs on a page by text match.
// Returns { "ingredients": "block-id-1", "instructions": "block-id-2", ... }
// Match is case-insensitive trimmed. First occurrence wins on duplicates.
async function discoverHeadings(pageId, sectionNames) {
  const token = process.env.NOTION_TOKEN;
  const headings = {};
  let cursor;
  do {
    const url = new URL(`https://api.notion.com/v1/blocks/${pageId}/children`);
    url.searchParams.set('page_size', '100');
    if (cursor) url.searchParams.set('start_cursor', cursor);
    const res = await fetch(url, {
      headers: { 'Authorization': `Bearer ${token}`, 'Notion-Version': '2022-06-28' },
    });
    if (!res.ok) throw new Error(`Notion get blocks ${res.status}: ${await res.text()}`);
    const data = await res.json();
    for (const block of data.results) {
      if (!block.type.startsWith('heading_')) continue;
      const text = (block[block.type].rich_text || []).map(t => t.plain_text).join('').trim().toLowerCase();
      for (const wanted of sectionNames) {
        const key = wanted.trim().toLowerCase();
        if (text === key && !headings[wanted]) {
          headings[wanted] = block.id;
        }
      }
    }
    cursor = data.has_more ? data.next_cursor : undefined;
  } while (cursor);
  return headings;
}
```

**Critical constraints:**
- File uploads expire 1 hour after creation if not attached.
- Notion file uploads are limited to 20MB per file. AI images at 1024×1024 are well under
  this — usually 1-3 MB.
- The `multipart/form-data` boundary must be unique per request. Using a timestamp is fine.

---

## Section 6: Batch Generation Script Template

Save as `scripts/rewyse-image-{slug}-batch.js`. Replace `{slug}` and the embedded prompt
list at runtime.

```javascript
// scripts/rewyse-image-{slug}-batch.js
const path = require('path');
const fs = require('fs');
const { generateImage } = require('./image-providers');

const PROVIDER = process.env.IMAGE_PROVIDER || 'openai'; // 'openai' | 'kie'
const OUTPUT_DIR = path.resolve(__dirname, '../rewyse-ai/output/{slug}/images');
const PROMPTS = [
  // { id: '<page_id_or_slot>', title: '...', prompt: '...', filename: 'slug.png' },
  // ... filled in by the agent at runtime
];

const CONCURRENCY = 3;

async function processOne(item) {
  const outputPath = path.join(OUTPUT_DIR, item.filename);
  if (fs.existsSync(outputPath)) {
    console.log(`SKIP ${item.id} (already exists)`);
    return { ...item, status: 'skipped' };
  }
  try {
    await generateImage({ provider: PROVIDER, prompt: item.prompt, outputPath });
    console.log(`OK   ${item.id} → ${item.filename}`);
    return { ...item, status: 'generated', path: outputPath };
  } catch (err) {
    console.log(`FAIL ${item.id}: ${err.message}`);
    return { ...item, status: 'failed', error: err.message };
  }
}

async function main() {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  console.log(`Generating ${PROMPTS.length} images via ${PROVIDER}...\n`);

  const results = [];
  for (let i = 0; i < PROMPTS.length; i += CONCURRENCY) {
    const batch = PROMPTS.slice(i, i + CONCURRENCY);
    const batchResults = await Promise.all(batch.map(processOne));
    results.push(...batchResults);
    if (i + CONCURRENCY < PROMPTS.length) {
      await new Promise(r => setTimeout(r, 500)); // small breather between waves
    }
  }

  const summary = {
    total: results.length,
    generated: results.filter(r => r.status === 'generated').length,
    skipped: results.filter(r => r.status === 'skipped').length,
    failed: results.filter(r => r.status === 'failed').length,
    failures: results.filter(r => r.status === 'failed').map(r => ({ id: r.id, error: r.error })),
  };
  console.log('\n--- Batch summary ---');
  console.log(JSON.stringify(summary, null, 2));

  fs.writeFileSync(
    path.join(OUTPUT_DIR, '..', 'image-batch-results.json'),
    JSON.stringify(results, null, 2)
  );
}

main().catch(err => {
  console.error('Fatal:', err);
  process.exit(1);
});
```

---

## Section 7: Notion Upload Script Template

Save as `scripts/rewyse-image-{slug}-upload.js`. Reads `image-batch-results.json` and
attaches each generated image as a page cover.

```javascript
// scripts/rewyse-image-{slug}-upload.js
const path = require('path');
const fs = require('fs');

// Pull helpers (paste them here, or require a shared module)
async function uploadFileToNotion(localPath) { /* ... see reference Section 5 ... */ }
async function setPageCover(pageId, fileUploadId) { /* ... see reference Section 5 ... */ }

const RESULTS_PATH = path.resolve(__dirname, '../rewyse-ai/output/{slug}/image-batch-results.json');
const CONCURRENCY = 3;

async function uploadOne(item) {
  if (item.status !== 'generated') return { ...item, upload_status: 'skipped' };
  try {
    const fileId = await uploadFileToNotion(item.path);
    await setPageCover(item.id, fileId);
    console.log(`OK   ${item.id} (${item.title})`);
    return { ...item, upload_status: 'uploaded', file_upload_id: fileId };
  } catch (err) {
    console.log(`FAIL ${item.id}: ${err.message}`);
    return { ...item, upload_status: 'failed', upload_error: err.message };
  }
}

async function main() {
  if (!process.env.NOTION_TOKEN) {
    console.error('NOTION_TOKEN not set');
    process.exit(1);
  }
  const items = JSON.parse(fs.readFileSync(RESULTS_PATH, 'utf-8'));
  console.log(`Uploading ${items.length} images to Notion...\n`);

  const out = [];
  for (let i = 0; i < items.length; i += CONCURRENCY) {
    const batch = items.slice(i, i + CONCURRENCY);
    const batchResults = await Promise.all(batch.map(uploadOne));
    out.push(...batchResults);
    if (i + CONCURRENCY < items.length) {
      await new Promise(r => setTimeout(r, 350));
    }
  }

  const summary = {
    total: out.length,
    uploaded: out.filter(r => r.upload_status === 'uploaded').length,
    failed: out.filter(r => r.upload_status === 'failed').length,
  };
  console.log('\n--- Upload summary ---');
  console.log(JSON.stringify(summary, null, 2));

  fs.writeFileSync(
    path.join(path.dirname(RESULTS_PATH), 'image-upload-results.json'),
    JSON.stringify(out, null, 2)
  );
}

main().catch(err => { console.error('Fatal:', err); process.exit(1); });
```

---

## Section 7b: Multi-Section Upload Script Template

Save as `scripts/rewyse-image-{slug}-multi-upload.js`. Reads `image-batch-results.json`
(grouped by entry) and: discovers headings → uploads each image → places cover or inserts
after the target heading.

```javascript
// scripts/rewyse-image-{slug}-multi-upload.js
const path = require('path');
const fs = require('fs');

// Helpers (paste from Section 5):
async function uploadFileToNotion(localPath) { /* ... */ }
async function setPageCover(pageId, fileUploadId) { /* ... */ }
async function insertImageAfter(pageId, afterBlockId, fileUploadId) { /* ... */ }
async function discoverHeadings(pageId, sectionNames) { /* ... */ }

const RESULTS_PATH = path.resolve(__dirname, '../rewyse-ai/output/{slug}/image-batch-results.json');
const SECTION_NAMES = []; // populated by agent — e.g., ["Ingredients", "Instructions"]
const ENTRY_CONCURRENCY = 3;

// Group images by entry
function groupByEntry(items) {
  const byEntry = new Map();
  for (const item of items) {
    if (item.status !== 'generated') continue;
    if (!byEntry.has(item.page_id)) byEntry.set(item.page_id, []);
    byEntry.get(item.page_id).push(item);
  }
  return byEntry;
}

async function processEntry(pageId, items) {
  const out = [];
  let headings = null;

  // Lazy-discover headings on first non-cover slot for this entry
  for (const item of items) {
    try {
      const fileId = await uploadFileToNotion(item.path);
      if (item.slot === 'cover') {
        await setPageCover(pageId, fileId);
        out.push({ ...item, upload_status: 'cover_set', file_upload_id: fileId });
      } else {
        if (!headings) headings = await discoverHeadings(pageId, SECTION_NAMES);
        const headingId = headings[item.slot];
        if (!headingId) {
          out.push({ ...item, upload_status: 'heading_not_found' });
          console.log(`WARN ${pageId} (${item.title}): heading "${item.slot}" not found, skipping insert`);
          continue;
        }
        await insertImageAfter(pageId, headingId, fileId);
        out.push({ ...item, upload_status: 'inserted', file_upload_id: fileId, heading_block_id: headingId });
      }
      console.log(`OK   ${item.title} [${item.slot}]`);
    } catch (err) {
      out.push({ ...item, upload_status: 'failed', upload_error: err.message });
      console.log(`FAIL ${item.title} [${item.slot}]: ${err.message}`);
    }
    await new Promise(r => setTimeout(r, 350));
  }
  return out;
}

(async () => {
  if (!process.env.NOTION_TOKEN) { console.error('NOTION_TOKEN not set'); process.exit(1); }
  const items = JSON.parse(fs.readFileSync(RESULTS_PATH, 'utf-8'));
  const byEntry = groupByEntry(items);
  const entries = Array.from(byEntry.entries());
  console.log(`Uploading images for ${entries.length} entries (multi-section)...\n`);

  const all = [];
  for (let i = 0; i < entries.length; i += ENTRY_CONCURRENCY) {
    const wave = entries.slice(i, i + ENTRY_CONCURRENCY);
    const results = await Promise.all(wave.map(([pageId, items]) => processEntry(pageId, items)));
    for (const r of results) all.push(...r);
  }

  fs.writeFileSync(
    path.join(path.dirname(RESULTS_PATH), 'image-upload-results.json'),
    JSON.stringify(all, null, 2)
  );
  console.log(`\n--- Upload summary ---`);
  console.log(JSON.stringify({
    total: all.length,
    inserted: all.filter(r => r.upload_status === 'inserted').length,
    cover_set: all.filter(r => r.upload_status === 'cover_set').length,
    heading_not_found: all.filter(r => r.upload_status === 'heading_not_found').length,
    failed: all.filter(r => r.upload_status === 'failed').length,
  }, null, 2));
})().catch(err => { console.error('Fatal:', err); process.exit(1); });
```

---

## Section 8: Style-Batch Image Library Page

When in style-batch mode, all generated images are uploaded to a single hidden "Image
Library" Notion page so they're hosted and ready for `/design-product` to embed elsewhere.

### Create the library page

Use `notion-create-pages` MCP to create a page:
- Parent: the product's parent page (from `database-config.json → parent_page_id`)
- Title: `{Product Name} — Image Library`
- Icon: `🎨`

Then for each generated image, append an image block (Section 5 helper) with the file
upload ID. Save the resulting `notion_url` for each block in `image-config.json` so Phase 8
can reference them by purpose (hero / section_X / etc.).

---

## Common Failure Modes

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| OpenAI returns `safety` rejection | Prompt contains policy-flagged terms (people in compromising contexts, brand names, weapons) | Rewrite prompt without flagged terms; flag entry for user review |
| OpenAI 429 rate limit | Burst over org tier | Reduce concurrency to 2; add 1s delay between waves |
| kie.ai task stuck in `running` for 2+ min | Provider-side queue | Cancel via dashboard, retry; reduce concurrency |
| Notion file_upload returns 404 on attach | Upload expired (>1 hour old) | Always attach in same script run; re-upload if expired |
| Notion attach returns 400 `validation_error` | Page ID has dashes or wrong format | Strip dashes from page IDs in script |
| Image looks generic / off-style | Prompt too long or too abstract | Shorten to 2-3 sentences, add concrete style anchors |
| All images look identical despite different entries | Style language overpowering subject | Reduce style sentence weight, foreground entry-specific subject |
| Quality is poor on `low` quality tier | OpenAI low quality is for drafts only | Bump to `medium` for production; keep `low` only for samples |
| Multi-section: heading not found | User customized content after generation; heading text changed | Log warning, skip the insert for that section. Don't fail the whole batch. |
| Multi-section: section images drift visually from cover | Different style anchors used across prompts | Ensure all prompts in a product reuse the same `{STYLE}` block; only subject/composition vary |
| Multi-section: one entry partially placed (e.g., cover yes, ingredients no) | Heading discovery succeeded but insert failed mid-way | Re-run; helpers are idempotent (Notion accepts duplicate inserts but you'll get two images — manually delete the duplicate) |
