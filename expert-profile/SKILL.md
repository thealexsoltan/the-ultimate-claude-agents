---
name: expert-profile
description: "Use when someone asks to build an expert profile, create an expert persona, define a content voice, set writing tone for a product, or establish domain expertise for content generation."
---

## Context

This skill creates the expert persona that writes every page of the product. The expert
profile defines WHO is writing — their expertise, tone, vocabulary, perspective, and
knowledge boundaries. This is the single biggest quality lever in the entire pipeline.

For reference on product types and structures, see:
[product-types-reference.md](../shared/product-types-reference.md)

**State directory:** If running inside the orchestrator, read `product-idea.md` from
`rewyse-ai/output/{project-slug}/` for context. Write output to
`rewyse-ai/output/{project-slug}/expert-profile.md`.

If running standalone, ask the user for product context and write to
`output/expert-profile/{product-slug}.md`.

---

## Step 1: Load Product Context

**If orchestrated:** Read `rewyse-ai/output/{project-slug}/product-idea.md` and extract:
- Product type
- Niche
- ICP (target customer)
- Value proposition
- Fixed structure and variables

**If standalone:** Ask the user:
1. What product are you building? (type + niche)
2. Who is it for? (ICP)
3. What's the product's core promise?

---

## Step 2: Domain Research

Use a subagent (Agent tool, model: sonnet) to research the product's domain.

**The subagent MUST use WebSearch to find real experts, real content, and real terminology
in the niche.** This grounds the expert profile in how actual domain experts communicate,
not LLM approximations.

**Fallback:** If web searches return no useful results (obscure niche, rate limits, etc.),
the subagent should:
1. Clearly state which searches were attempted and what came back empty
2. Fall back to domain knowledge, but **label every recommendation as "based on domain
   knowledge, not verified market data"**
3. Suggest the user validate the terminology, tone benchmarks, and expert references
   against their own knowledge before proceeding

**Prompt the subagent with:**
> Research the following domain for building an expert content persona. You MUST use
> WebSearch for every section — find real experts, real content, and real terminology.
>
> **Niche:** {niche}
> **Product type:** {product_type}
> **Target audience:** {ICP}
>
> Suggested searches (adapt to the niche):
> - "top {niche} experts" / "best {niche} content creators"
> - "{niche} terminology glossary" / "{niche} key concepts"
> - "{niche} common mistakes beginners" / "{niche} expert vs beginner"
> - "{niche} certifications" / "how to become {niche} expert"
> - Find 2-3 real expert blogs, YouTube channels, or social accounts in the niche
>   and analyze how they write/speak
>
> Find and return:
> 1. **Key terminology** — 15-20 domain-specific terms that real experts in this space
>    actually use. Search for glossaries, expert content, and professional resources.
>    Not jargon for jargon's sake — terms that signal real expertise.
> 2. **Common frameworks or models** — Established methodologies in this field.
>    Search for what frameworks practitioners actually reference.
> 3. **Common mistakes** — What beginners get wrong that an expert would correct.
>    Search forums, Reddit, Quora for real beginner questions and expert corrections.
> 4. **Expert perspectives** — What separates a surface-level take from a deep one.
>    Find real expert content and identify what makes their takes different from generic advice.
> 5. **Credibility signals** — What certifications, experience types, or knowledge areas
>    make someone credible in this space. Search for real credential paths.
> 6. **Content tone benchmarks** — Find 2-3 real respected experts/creators in this niche.
>    How do they communicate? Link to examples. Are they clinical, conversational,
>    data-heavy, story-driven? What's the standard the ICP expects?

Present the research summary to the user for validation:

> **Domain Research Summary:**
> - Key terms: [list 5-7 highlights]
> - Expert differentiators: [what separates good from great in this domain]
> - Tone benchmark: [how experts in this space typically communicate]
>
> Does this align with your vision for the product? Anything to adjust?

---

## Step 3: Build the Expert Profile

Using the domain research and product context, define:

### 3a. Expertise Definition
- **Who is this expert?** (role, background, years of experience)
- **What do they specialize in?** (specific sub-domain)
- **What credentials or experience back them up?** (not fabricated — archetypal)

### 3b. Voice & Tone
- **Primary tone:** (authoritative / conversational / clinical / coaching / academic)
- **Secondary tone:** (warm / direct / witty / empathetic / no-nonsense)
- **Tone to avoid:** (what this expert would NEVER sound like)

### 3c. Vocabulary Calibration
- **Use these terms:** [10-15 domain-specific terms the expert uses naturally]
- **Avoid these terms:** [generic terms that signal lack of expertise]
- **Formality level:** (casual / professional / technical)

### 3d. Perspective & Opinion
- **Strong positions:** What does this expert believe that's non-obvious?
- **Counter-positions:** What popular advice do they disagree with?
- **Teaching philosophy:** How do they approach explaining things?

### 3e. Knowledge Boundaries
- **Claims confidently:** [topics within their expertise]
- **Acknowledges limitations:** [topics they defer to other experts on]
- **Never claims:** [things outside their domain]

---

## Step 4: Generate Voice Sample

Write a 200-300 word sample paragraph in the expert's voice on a topic from the product's
niche. This gives the user a concrete preview of how content will sound.

Choose a topic from the product's variable list — pick something specific enough to
demonstrate the expert voice in action.

Present the voice sample:

> **Voice Sample:**
>
> [200-300 word paragraph]
>
> Does this voice feel right for your product? You can adjust:
> - **More/less formal** — "Make it more conversational" or "More authoritative"
> - **More/less technical** — "Simpler language" or "More technical depth"
> - **Different perspective** — "More opinionated" or "More neutral"
> - **Different tone** — "Warmer" or "More direct"

If the user requests changes, adjust the profile and regenerate the voice sample.
Iterate until they approve.

---

## Step 5: Approval Gate

Present the complete expert profile:

> ## Expert Profile: [Product Name]
>
> ### The Expert
> [Who they are, background, specialization]
>
> ### Voice & Tone
> - **Primary:** [tone]
> - **Secondary:** [tone]
> - **Avoids:** [tone]
>
> ### Vocabulary
> - **Uses:** [key terms]
> - **Avoids:** [generic terms]
> - **Formality:** [level]
>
> ### Perspective
> - **Strong positions:** [beliefs]
> - **Counter-positions:** [disagreements with mainstream]
> - **Teaching approach:** [philosophy]
>
> ### Knowledge Boundaries
> - **Claims:** [topics]
> - **Defers:** [topics]
>
> ### Voice Sample
> [The approved sample paragraph]
>
> **Approve** this profile to proceed, or tell me what to change.

---

## Step 6: Save Output

Write the approved expert profile to the appropriate location:

**If orchestrated:**
- Write to `rewyse-ai/output/{project-slug}/expert-profile.md`
- Update `state.json`: set phase `3_expert_profile` to `status: "approved"`

**If standalone:**
- Write to `output/expert-profile/{product-slug}.md`

---

## Notes

- **The expert profile is the quality multiplier.** A generic profile produces generic content. A specific, opinionated expert profile produces content that reads like it was written by a real specialist. This is the difference between "$5 ebook" and "$50 resource."
- **Don't fabricate real credentials.** The expert is an archetype, not a real person. "A sports nutritionist with 10 years of experience working with hybrid endurance athletes" is fine. "Dr. Sarah Johnson, PhD from Harvard" is not.
- **Vocabulary calibration is critical.** If the expert "uses" the term "macroperiodization" but the ICP is beginners, the content will alienate its audience. Match vocabulary to the ICP's level, not the expert's maximum capability.
- **The voice sample is non-negotiable.** Never skip it. It's the only way the user can validate the profile before it drives hundreds of pages of content.
- **Knowledge boundaries prevent hallucination.** By defining what the expert does NOT claim, you constrain the AI from generating content outside its defined expertise.
- **Iterate the voice sample, not the profile.** If the user doesn't like the voice, adjust the profile fields first, then regenerate. Don't just rewrite the sample — fix the underlying instructions.
