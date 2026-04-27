# Adding Images to Your Products — Quick Guide

Phase 7.5 is the optional AI image step inside the Rewyse pipeline. It generates cover art and inline section imagery for the entries in your Notion product, then uploads everything for you. **Existing products and progress are never affected** — this only runs when you ask for it.

---

## Before You Start

You need an API key from one of these providers (your spend, not ours):

| Provider | Recommended for | Per image |
|---|---|---|
| **OpenAI** *(default)* | Cleanest output, strong prompt adherence | ~\$0.042 |
| **kie.ai** | Same model, ~30% cheaper | ~\$0.030 |

**Set the key once in your shell** (so it persists across sessions):

```bash
# OpenAI (recommended)
echo 'export OPENAI_API_KEY=sk-...' >> ~/.zshrc && source ~/.zshrc

# OR kie.ai
echo 'export KIE_API_KEY=...' >> ~/.zshrc && source ~/.zshrc
```

That's the only setup required. The agent picks up whichever key is set.

---

## Two Ways to Use It

### A. As part of a full product build

Run `/build-product` in Claude Code as usual. After Phase 7 (content generation), the pipeline pauses and asks:

> **Phase 7.5 (Optional): Generate Images**
> Want to add AI-generated images to your product? Skip / OpenAI / kie.ai

Pick your provider or skip. If you skip, the build continues to Phase 8 unchanged.

### B. Standalone on an existing product

For products you've already built, run `/generate-images` and tell it which project. The agent reads the existing state, asks what you want, and adds images on top of what's already there. **Your existing pages stay intact.**

---

## The Three Modes (Pick One)

The agent auto-detects what fits your product type, then asks you to confirm.

| Mode | What you get | Best for | Cost order |
|---|---|---|---|
| **Cover only** | One cover image per database entry | Reference cards, prompt packs, daily training entries | \$ |
| **Multi-section** | Cover + N inline images per entry, placed after target section headings (magazine layout) | Recipes (Ingredients flat-lay + Final dish), tutorials (Setup + Process + Result), case studies (Before + After) | \$\$\$ |
| **Style-batch** | N images sharing a single style for the homepage and section icons | Mental models, frameworks, glossaries (abstract products) | \$ |

---

## What Happens When You Run It

The agent walks you through this flow. Every step pauses for your input — you're always in control.

| Step | What happens | What you do |
|---|---|---|
| 1. Provider | Pick OpenAI or kie.ai | Confirm or override |
| 2. Inspiration | "Any reference URLs, mood, brand to match?" | Paste references or skip |
| 3. Mode | Agent recommends a mode based on your product | Confirm or pick another |
| 4. Section discovery *(multi-section only)* | Agent reads your content blueprint, suggests which sections to image and which to skip | Edit the suggested list |
| 5. Cost preview | Exact total estimated spend, broken down by image count × per-image cost | See before you pay |
| 6. **Sample approval gate** | Agent generates 2–3 sample images and shows them | Approve to batch the rest, or ask for revisions |
| 7. Batch | Generates remaining images (3 at a time, ~30s each) | Wait or grab a coffee |
| 8. Upload to Notion | Each image attached as a page cover or inline image block, automatically | Done |

---

## Cost Transparency (Read This)

The agent has a **hard approval gate** before any API call. You will never spend money without explicitly authorizing it. Specifically:

- **Granted access ≠ approval to spend.** Setting an API key just gives the agent permission; it does not authorize generation.
- **Plan approval ≠ approval to spend.** Confirming "yes, run Phase 7.5" doesn't mean "yes, generate images now" — there's a separate cost gate before any actual API call.
- **Three explicit gates:** before samples, before the batch, before any retries. Each one names the exact spend.

**Multi-section spend grows fast.** The agent always shows the multiplier:
- Cover-only: 50 entries × \$0.030 = ~\$1.50
- Multi-section (cover + 2 sections): 50 entries × 3 images × \$0.030 = ~\$4.50

---

## Tips

1. **Start with cover-only on your first product.** Cheap, fast, and you'll see how the agent's prompt extraction translates your content into images. If you like the result, do multi-section next time.
2. **Use kie.ai for high-volume batches.** Same model as OpenAI, ~30% cheaper. The visual difference is negligible for most products.
3. **Inspiration can be a single phrase.** "Warm minimalist food photography" or "high-contrast editorial illustration" is plenty. Long descriptions don't help the model.
4. **Style consistency is automatic.** The agent uses one shared style anchor across all prompts within a product, so cover + ingredients + result feel like a coherent magazine spread.
5. **Heading match for multi-section is exact.** If you renamed "Ingredients" to "What You Need" after running `/generate-content`, tell the agent the new name when it asks about sections.
6. **Resume is built in.** If your laptop sleeps mid-batch or you cancel, run `/generate-images` again on the same project — it picks up where it left off, skipping already-done images.

---

## Quick Examples

### Recipe book — multi-section (magazine layout)

```
/generate-images
> "Use kie.ai. Multi-section. Inspiration: warm minimalist food photography,
   muted earthy palette."
> Confirm sections: Ingredients, Final Result. Skip: Macros, Coach's Note.
> Confirm spend: $4.50 for 50 recipes × 3 images
> Approve samples → batch → done in ~12 minutes
```

### Mental models guide — style-batch (homepage only)

```
/generate-images
> "Use OpenAI. Style-batch. Inspiration: editorial geometric illustration,
   navy + cream + terracotta accent."
> Pick from 3 sample styles
> Confirm spend: ~$0.40 for 10 homepage/section images
> Approve → done in ~5 minutes
```

### Workout library — cover only (quick visual library)

```
/generate-images
> "Use kie.ai. Cover only. Inspiration: high-energy athletic photography,
   dramatic lighting."
> Confirm spend: ~$2.40 for 80 workouts
> Approve samples → batch → done in ~15 minutes
```

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| "OPENAI_API_KEY not set" | Key wasn't exported in this shell | `export OPENAI_API_KEY=sk-...` and re-run, or add to `~/.zshrc` |
| Image rejected by OpenAI safety filter | Prompt mentions a flagged term (people in compromising contexts, brand names, weapons) | The agent flags the entry and skips it; rest of the batch continues |
| Multi-section "heading not found" | Section was renamed in Notion after the build | Tell the agent the actual heading name when it asks about sections |
| Generated images look generic | Prompt was too long or too abstract | Provide tighter inspiration ("warm minimalist") and re-run samples |
| Cover crops awkwardly in Notion | Image subject was off-center | Tell the agent "more centered subject, looser framing" and regenerate samples |

For anything else, run `/rewyse-help` in Claude Code — it answers context-aware questions about your specific project.
