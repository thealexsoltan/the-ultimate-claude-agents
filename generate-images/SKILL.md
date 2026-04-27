---
name: generate-images
description: "Use when someone asks to generate images for a digital product, add cover art to Notion pages, illustrate database entries with AI images, batch-create product imagery, or run Phase 7.5 of the build pipeline."
---

## Context

Before doing anything, read the full templates and patterns in [reference.md](reference.md).
All Notion writes follow [notion-api-reference.md](../shared/notion-api-reference.md).

This is **Phase 7.5 of the Rewyse AI pipeline** — an optional image-generation phase that
runs after content is generated (Phase 7) and before the product is designed (Phase 8). It
generates AI images for the product using either OpenAI (`gpt-image-1`) or kie.ai
(`google/nano-banana`), gets approval on samples, batches the rest, and uploads them to
Notion as page covers and/or image blocks.

**Three modes** (auto-detected from product structure, confirmed with user):

| Mode | When | What it does |
|------|------|--------------|
| **Cover only** *(default)* | Visual library at a glance — recipes, workouts, case studies | One image per Published database entry, attached as page cover |
| **Multi-section** *(opt-in)* | Magazine-quality pages — recipe books, tutorials, step-by-step guides | Cover + N inline section images per entry, each placed after a target section heading |
| **Style-batch** | Abstract products (mental models, frameworks, prompts, templates) | Suggests 3 visual styles, generates 2-3 samples per style, batches N images in the chosen style for the homepage and section icons |

**State directory:** `rewyse-ai/output/{project-slug}/`

**Reads:**
| File | Purpose |
|------|---------|
| `product-idea.md` | Product type, niche, ICP — informs style suggestions |
| `database-config.json` | Database ID, properties — for entry queries |
| `expert-profile.md` | Voice/tone — informs image style language |
| `content-blueprint.md` | Page structure — used in per-entry prompt extraction |

**Writes:**
| File | Purpose |
|------|---------|
| `image-config.json` | Provider, mode, style choice, cost estimate, per-entry/per-image log |
| `images/{slug}-{n}.png` | Generated image binaries (kept locally for re-upload/retry) |

**Output scripts:** Generated at runtime in `scripts/` at project root, named
`rewyse-image-{slug}-{purpose}.js`.

---

## Step 1: Verify Prerequisites & Load State

### Check that Phase 7 is complete

Read `state.json`. If `7_generate_content` is not `approved`, stop and tell the user:
> "Image generation runs after content is generated. Run `/generate-content` first, then come back."

### Load product context

Read from `rewyse-ai/output/{project-slug}/`:
- `product-idea.md` — Extract product name, type, niche, ICP
- `database-config.json` — Database ID, properties, parent page ID
- `expert-profile.md` — Tone descriptors (used in image prompts)
- `content-blueprint.md` — Section names and page structure

If running standalone (no state directory), ask:
1. Database ID
2. Product name + type (or describe what it is)
3. Visual style direction (if any)

### Check resume state

If `image-config.json` exists, this is a resume. Load it. Skip to Step 5 (batch generation)
with already-processed entries excluded.

---

## Step 2: Provider, Inspiration & Mode Selection

### 2a. Provider choice

Present the provider options and let the user pick:

> **Image generation provider:**
>
> | Provider | Model | Cost per image (1024×1024) | Quality |
> |----------|-------|-----|---------|
> | **OpenAI** *(recommended for first-time users)* | `gpt-image-2` | ~\$0.04 (medium quality) | High, strong prompt adherence |
> | **kie.ai** *(cheaper alternative)* | `gpt-image-2-text-to-image` | ~\$0.03 (relays the same model ~30% cheaper) | Same model, lower cost |
>
> Which provider? (default: **OpenAI**)
>
> Required env var: `OPENAI_API_KEY` for OpenAI, `KIE_API_KEY` for kie.ai.

Verify the relevant env var exists:
```bash
echo "${OPENAI_API_KEY:+set}"  # or KIE_API_KEY
```

If missing, instruct the user how to set it (e.g., `export OPENAI_API_KEY=sk-...`) and wait.

### 2b. Inspiration intake

Ask:

> **Any visual inspiration?** *(optional, hit enter to skip)*
>
> You can share:
> - **Reference URLs** — Pinterest boards, image links, brand sites
> - **Mood description** — "warm minimalist, soft pastels, hand-drawn"
> - **Brand match** — "use Anthropic brand colors" *(triggers `/brand-guidelines`)*
> - **Existing artifact** — point to a file in this repo

Capture whatever the user provides. Save raw inspiration text/URLs in `image-config.json`
under `inspiration`.

### 2c. Auto-detect generation mode

Inspect `database-config.json`, `content-blueprint.md`, and the published entries to
recommend a mode:

- **Cover-only recommended if:** Per-entry visuals matter (each entry has a distinct
  subject) but pages are short or list-heavy — quick reference cards, prompt packs,
  daily training entries.
- **Multi-section recommended if:** Pages are long, structured, and visually rich —
  recipes (Ingredients + Final dish), workouts (Setup + Form + Recovery), tutorials
  (Step diagrams), case studies (Before + After). Look for multiple distinct named
  sections in `content-blueprint.md` where each has different visual potential.
- **Style-batch recommended if:** Product is conceptual or repetitive — mental models,
  frameworks, glossaries, short reference cards. Entries share visual identity rather
  than per-entry distinctness.

Present:

> **Detected mode: {cover-only | multi-section | style-batch}** ({reasoning})
>
> - **Cover only** — one cover image per entry. Fast, ~\${cover_total}.
> - **Multi-section** — cover + section images per entry (magazine layout). Slower, ~\${multi_total}.
> - **Style-batch** — N homepage/section images in one shared style.
>
> Use the detected mode? Or override?

Wait for user confirmation.

### 2d. Section discovery (multi-section mode only)

If the user picked multi-section, run section discovery before estimating cost.

1. **Read `content-blueprint.md`** to extract the section list (headings inside each
   page template).
2. **Score each section by visual potential:**
   - **Image-worthy:** Sections that describe a physical thing, a layout, a process result,
     a finished state, or a hero/intro. Examples: "Ingredients", "Instructions",
     "Setup", "Final Result", "Before & After", "Equipment List".
   - **Skip:** Tables (macro panels, stats), single-callout sections (Coach's Note,
     Gut-Safety Note), short metadata (Times, Serves, Difficulty), pure navigation/text
     sections (Performance Rationale, Why This Matters).
3. **Propose to the user** with reasoning:

> **Multi-section image plan for {product name}**
>
> Sections in your page template: {list of all blueprint sections}
>
> **I'd suggest images in:**
> - **{Section A}** — {1-line reason, e.g., "flat-lay shot of ingredients arranged"}
> - **{Section B}** — {1-line reason, e.g., "the finished plated dish"}
>
> **Skip:**
> - **{Section X}** — {1-line reason, e.g., "it's a macro table, no visual value"}
> - **{Section Y}** — {1-line reason, e.g., "single callout sentence"}
>
> Want me to also include a **page cover** image? *(recommended: yes, anchors the entry)*
>
> Confirm sections to image, or edit the list.

Wait for user confirmation. Save the chosen section list (with cover yes/no) to
`image-config.json` under `sections`.

---

## Step 3: Plan & Cost Estimate

### Cover-only mode planning

Query the database for all `Published` entries. Count them. Ask:

> **Cover-only image plan**
>
> Published entries: {N}
>
> **Settings:**
> - Image size: 1024×1024 (square, ideal for Notion page covers)
> - Quality: medium (good detail, balanced cost)
> - One image per entry, attached as the page cover
>
> **Cost estimate:**
> | Provider | Per image | Total ({N} images) |
> |----------|-----------|-------------------|
> | OpenAI gpt-image-2 (medium 1024×1024) | \$0.042 | **\${total_openai}** |
> | kie.ai gpt-image-2-text-to-image | \$0.030 | **\${total_kie}** |
>
> **How many entries to image?**
> - All ({N}) — full coverage
> - Top {N/2} — sample first, expand later
> - Custom — specify count or filter (e.g., only entries in a category)
>
> What's the cap?

Wait for the user's count. Confirm the spend before generating.

### Multi-section mode planning

Once sections are confirmed in Step 2d, calculate per-entry image count and total cost:

```
images_per_entry = (cover ? 1 : 0) + count(chosen_sections)
total_images     = entries_to_image × images_per_entry
total_cost       = total_images × per_image_cost
```

Present:

> **Multi-section image plan**
>
> Published entries: {N}
> Images per entry: {M}  ({cover_yes_no} cover + {S} section images)
> Total images: {N × M}
>
> **Cost estimate:**
> | Provider | Per image | Total ({N × M} images) |
> |----------|-----------|-------------------------|
> | OpenAI gpt-image-2 | \$0.042 | **\${total_openai}** |
> | kie.ai gpt-image-2-text-to-image | \$0.030 | **\${total_kie}** |
>
> **Wallclock estimate:** ~{(N×M) / 3 × 35}s with 3 concurrent generations.
>
> **How many entries to image?**
> - All ({N}) — full magazine layout across the library
> - Top {N/2} — sample first, expand later
> - Custom — specify count or filter
>
> What's the cap?

Wait for the user's count. **Multi-section spend grows fast** (3 sections × 50 entries = 150
images = ~\$4.50). Always state the multiplier explicitly so the user sees what they're
authorizing.

### Style-batch mode planning

Ask how many distinct images the product needs:

> **Style-batch image plan**
>
> Suggested image counts by usage:
> - **Hero only** — 1 image (homepage cover)
> - **Hero + section icons** — 5-10 images (homepage + section headers)
> - **Hero + per-category** — 1 + (one per category in primary browse property)
> - **Custom** — you tell me
>
> How many images do you want?

Once N is set, present cost estimate (same format as per-entry mode).

Then generate **3 candidate visual styles** based on product context + inspiration:

> **Three style options for {product name}:**
>
> **Style 1 — {name}** ({1-line vibe})
> {2-3 sentence description: composition, palette, illustration style, mood}
>
> **Style 2 — {name}** ({1-line vibe})
> {description}
>
> **Style 3 — {name}** ({1-line vibe})
> {description}
>
> Want me to generate 2-3 sample images per style so you can pick? *(samples cost
> ~{sample_count}× per-image price, charged to your provider)*

If the user says yes, jump to Step 4a. Otherwise let them pick a style by name and skip
to Step 5.

---

## Step 4: Sample Approval Gate

### 4a. Confirm sample spend (HARD GATE — required)

**You MUST stop here and get an explicit "go" / "approve" / "yes generate samples" before
making any API call.** Granted access (Notion sharing, env vars set) is **not** approval to
spend. Plan approval upstream is **not** approval to spend. Only an explicit go-ahead at
this gate authorizes the sample generation.

State the cost and scope of *just the samples* clearly, separate from the batch:

> **Ready to spend ~\${sample_cost} on {N} sample images via {provider}?**
> *(After you see them, you'll have a separate gate before I batch the remaining {batch_count}.)*

If the user has not said something that explicitly approves spending right now, ask. Do not
infer "yes" from earlier turns about plans, access, or keys. If unsure, ask.

### 4b. Generate samples

**Cover-only mode:** Pick 2-3 representative entries (varied across categories if a
primary browse property exists). Generate one image each using the prompt template from
[reference.md](reference.md) Section 2.

**Multi-section mode:** Pick **one** representative entry. Generate the **full set** of
images for that one entry (cover + each chosen section). This validates that the cover
and section images form a coherent visual set before committing to the full batch — much
more useful than 3 isolated covers.

**Style-batch mode:** For each of the 3 styles, generate 2 sample images using diverse
prompts from the product (e.g., "homepage hero", "first-category icon").

Use the provider script template from [reference.md](reference.md) Section 4. Save sample
images to `output/{slug}/images/samples/`. For multi-section, organize subdirectories by
entry slug (e.g., `samples/{entry-slug}/cover.png`, `samples/{entry-slug}/{section}.png`).

### 4c. Present samples

For each generated sample:
1. Note the local file path
2. Tell the user where to view them: `output/{slug}/images/samples/`
3. Open the samples in the user's default viewer (`open <paths>` on macOS) so they can
   review without hunting through the file system
4. Optionally upload one sample to a temporary Notion page so the user can preview at
   actual cover-image dimensions

Ask:

> **Sample review**
>
> Per-entry: Do these 2-3 samples look right for the product? Approve to batch the rest.
>
> Style-batch: Which style do you want to use? Or should I revise the prompts and
> regenerate samples?

If revisions requested:
- Adjust prompt templates based on user feedback ("more minimalist", "warmer palette",
  "no people", etc.)
- Regenerate up to 2 more rounds before stopping for a deeper conversation

Wait for explicit approval before continuing.

---

## Step 5: Batch Generation

### 5a. Build the prompt list

**Cover-only mode:** For each entry to image, run the per-entry prompt extraction
(reference.md Section 2). Each entry produces one prompt string:

```js
{
  page_id: "...",
  title: "...",
  slot: "cover",
  prompt: "...",
  output_path: "output/{slug}/images/{entry-slug}-cover.png"
}
```

**Multi-section mode:** For each entry × each chosen slot (cover + sections), produce one
prompt. Cover uses the per-entry template from reference.md Section 2; each section uses
its section-type template from reference.md Section 3a (e.g., "ingredients flat-lay",
"final result", "step diagram"). All prompts in a product reuse the same style anchor for
visual consistency.

```js
[
  { page_id, title, slot: 'cover',          prompt, output_path: 'images/{slug}/cover.png' },
  { page_id, title, slot: 'ingredients',    prompt, output_path: 'images/{slug}/ingredients.png' },
  { page_id, title, slot: 'final-result',   prompt, output_path: 'images/{slug}/final-result.png' },
  // ... for each chosen section
]
```

**Style-batch mode:** Compose N prompts using the chosen style + per-image purpose
(hero, section_X, etc.). See reference.md Section 3.

### 5b. Generate the script

Create `scripts/rewyse-image-{slug}-batch.js` from the template in reference.md Section 4.
The script:
1. Reads the prompt list (embedded array or external JSON)
2. Calls the chosen provider's generate function in batches of 3-5 concurrent
3. Saves each result to `output/{slug}/images/{filename}.png`
4. Writes a per-image status line to stdout
5. Tracks failures for retry

### 5c. Run with confirmation

Before running, present the final spend:

> **Ready to generate {N} images via {provider}.**
> Estimated cost: \${total}
> Output directory: `output/{slug}/images/`
>
> Confirm to proceed?

Run `node scripts/rewyse-image-{slug}-batch.js` and stream output. Track results.

### 5d. Handle failures

Failures common to image APIs:
- Content policy rejection → log + skip + flag for user review
- Rate limit → retry with backoff (already in script)
- Timeout → retry once
- Bad prompt → regenerate prompt and retry once

After the batch, report:
> **Batch complete.**
> Generated: {N}
> Failed: {M}  *(if any: {list with reason})*
> Local images: `output/{slug}/images/`

---

## Step 6: Upload to Notion

### 6a. Cover-only mode

For each generated image, attach to its corresponding Notion page **as the page cover**
using the file-upload flow from reference.md Section 5.

Three calls per image:
1. `POST /v1/file_uploads` → get `upload_url` and `file_upload_id`
2. `POST {upload_url}` (multipart with the PNG file)
3. `PATCH /v1/pages/{page_id}` with cover = `{type: "file_upload", file_upload: {id}}`

Use the upload script template (reference.md Section 5). Run with a 350ms delay between
calls and process 3 images concurrently.

**Critical:** Each `file_upload` ID expires 1 hour after upload if not attached. The script
must attach immediately after sending.

### 6b. Multi-section mode

For each entry, the upload flow does TWO things:

1. **Discover heading block IDs.** Fetch the page's blocks once
   (`GET /v1/blocks/{page_id}/children?page_size=100`). Scan for `heading_2`/`heading_3`
   blocks and build a `{section_name → heading_block_id}` map by case-insensitive trimmed
   text match. Cache this per entry.
2. **Upload + place each image.** For each image generated for this entry:
   - If `slot === 'cover'`: same as Cover-only mode (set as page cover).
   - If `slot === 'section_name'`: upload the file, then `PATCH /v1/blocks/{page_id}/children`
     with `{ after: heading_block_id, children: [{ type: 'image', image: { type: 'file_upload',
     file_upload: { id } } }] }` to insert the image **immediately after the section
     heading**.

Use the multi-section upload script template (reference.md Section 7b). Process 3 entries
concurrently (one entry's full image set in sequence per worker — keeps per-entry images
together in case of partial failure).

**Heading match failures:** If a section's heading is not found in the page's blocks (e.g.,
content was customized post-generation), log a warning, save the image locally, and skip
the insert. Do not block the rest of the batch.

### 6c. Style-batch mode

Style-batch images are typically used by `/design-product` (Phase 8) on the homepage and
section pages. For now:
1. Upload all generated images to a single "image library" Notion page (under the parent
   page) so they're hosted and ready to embed
2. Save the file IDs and Notion-hosted URLs in `image-config.json` so Phase 8 can reference
   them when building the homepage

Optional: If the user already named specific destination pages (e.g., "use image 3 as
homepage cover"), upload directly to those instead.

### 6d. Confirmation

Spot-check 2-3 uploaded covers in Notion to confirm they render. Report:

> **Notion upload complete.**
> Uploaded: {N}
> Failed: {M}  *(if any: list with reason — usually expired file_upload or 404 page)*
> Verify in Notion: {first uploaded page URL}

---

## Step 7: Save State & Summary

### Write `image-config.json`

```json
{
  "project": "{project-slug}",
  "provider": "openai" | "kie",
  "model": "gpt-image-1" | "google/nano-banana",
  "mode": "cover-only" | "multi-section" | "style-batch",
  "size": "1024x1024",
  "quality": "medium",
  "inspiration": "{user-provided text/urls}",
  "style": {
    "name": "{chosen style name, style-batch only}",
    "description": "{full style description}"
  },
  "sections": {
    "cover": true,
    "section_names": ["Ingredients", "Instructions"]
  },
  "stats": {
    "requested": N,
    "generated": N,
    "uploaded": N,
    "failed": N,
    "estimated_cost_usd": 1.23,
    "actual_cost_usd": 1.21
  },
  "images": {
    "{page_id_or_slot}": {
      "title": "...",
      "prompt": "...",
      "local_path": "images/...",
      "file_upload_id": "...",
      "notion_url": "...",
      "status": "uploaded" | "generated" | "failed",
      "error": null
    }
  },
  "last_updated": "YYYY-MM-DDTHH:MM:SS"
}
```

### Final summary

> ## Image Generation Complete
>
> **Provider:** {provider} ({model})
> **Mode:** {per-entry | style-batch}
> **Images generated:** {N}
> **Uploaded to Notion:** {N}
> **Total spend:** \${actual}  *(estimated: \${estimated})*
>
> **Output:**
> - Local images: `output/{slug}/images/`
> - Config: `output/{slug}/image-config.json`
>
> **Next step:**
> - Run `/design-product` (Phase 8) to build the homepage. It will pick up image references
>   from `image-config.json` automatically.

**If orchestrated:** Update `state.json`: set phase `7_5_generate_images` to
`status: "approved"`. (If the user skipped at Step 2, set `status: "skipped"` and move on.)

---

## Notes

- **This phase is optional.** When `/build-product` reaches Phase 7.5 it must ask
  permission before invoking — many products don't need AI imagery, and cost is real.
- **Cost transparency is mandatory.** Always show the cost estimate before each batch.
  Never silently spend the user's API budget.
- **Three separate approval gates, three separate spends.** The user must explicitly
  authorize spending at each: (1) before samples (Step 4a), (2) before the batch (Step 5c),
  (3) before any re-runs after revision. Granted access (Notion sharing, env vars set) is
  *not* approval to spend. Plan approval is *not* approval to spend. Only an explicit
  "go" / "approve" / "yes generate" at the spend gate authorizes the API calls. When
  unsure, ask — the cost of pausing is zero, the cost of an unwanted spend is real money
  and lost trust.
- **Default to OpenAI gpt-image-2 medium 1024×1024.** It's the most common combination
  and produces good Notion cover art. Square 1024×1024 fits Notion's cover crop best.
- **Multi-section spend grows fast.** 3 sections × 50 entries = 150 images = ~\$4.50.
  Always state the multiplier when presenting the plan, never just the per-image cost.
- **Multi-section style consistency depends on a single shared style anchor.** The agent
  must use the same style descriptor across cover + every section prompt within a product.
  Without this, sections drift visually and the magazine feel breaks.
- **Heading text must match exactly** when discovering section block IDs. Notion stores
  heading text including casing; match case-insensitively and trim whitespace. If the
  user customized content after generation, the heading text may have changed — log
  warnings, don't fail.
- **kie.ai is cheaper but less consistent.** Recommend it for high-volume products
  (50+ entries) or when the user explicitly wants to save money.
- **Notion file uploads expire in 1 hour.** Always upload-and-attach in the same script
  run. Never split these into separate scripts with hours between.
- **Save images locally first, then upload.** This makes retries cheap (no re-generation
  on Notion-side failures) and lets the user manually review before push.
- **Style-batch outputs feed Phase 8.** Phase 8 (`/design-product`) reads
  `image-config.json` to find the homepage hero, section icons, etc.
- **Per-entry resume is automatic.** If the conversation ends mid-batch, the next run
  reads `image-config.json` and skips entries with `status: "uploaded"`.
- **Content policy rejections happen.** OpenAI is stricter than kie.ai. If a prompt is
  rejected, log it, skip the entry, and flag for the user — don't kill the whole batch.
- **Prompts must be short and concrete.** Long flowery prompts produce worse results
  than 2-3 sentence concrete descriptions. See reference.md Section 2 for the template.
- **Inspiration ≠ direct copying.** Reference URLs guide the prompt's style language;
  the model never sees the URL. Translate visual references into prompt vocabulary
  (palette, composition, illustration style, mood).
