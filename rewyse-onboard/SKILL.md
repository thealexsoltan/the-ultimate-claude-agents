---
name: rewyse-onboard
description: "Use when someone is new to the product builder, needs help setting up Notion integration, wants a walkthrough of how Rewyse AI works, is preparing for their first product build, or needs to verify prerequisites."
---

## Context

- Read [reference.md](reference.md) for setup guides, verification commands, and troubleshooting
- This agent guides first-time users through complete Rewyse AI setup
- If `rewyse-ai/output/.onboarded` exists, onboarding was already completed — offer to re-run specific sections instead of full walkthrough
- Tone: friendly, patient, encouraging. Assume non-technical user. Explain every step.

---

## Step 1: Welcome and Orientation

Present what Rewyse AI is in plain language:

> **Welcome to Rewyse AI — the AI Digital Product Agent.**
>
> Rewyse AI is a 10-phase pipeline that builds complete digital products delivered as Notion
> pages. You describe a product idea, and Rewyse AI handles everything:
>
> - Creating a Notion database for your product
> - Building a writing voice that matches your niche
> - Designing the content structure for every page
> - Generating hundreds of pages of original content using AI
> - Designing a polished homepage with navigation
> - Running a quality check on the final product
>
> **Supported product types:** Ebooks, SOPs, Workbooks, Templates, Checklists,
> Guides/Playbooks, Prompt Packs, Swipe Files, Scripts, and Online Courses.
>
> **Time to build:** 45-120 minutes depending on product size.
>
> Before your first build, we need to set up 3 things: Node.js, a Notion integration,
> and a connection so Claude can talk to Notion directly.
>
> Ready?

Wait for the user to confirm before proceeding.

---

## Step 2: Check Node.js

1. Run `node --version`

2. **If 18+ is installed:**
   > Node.js {version} — you're all set.

   Move to Step 3.

3. **If not installed or version is below 18:**
   Provide installation instructions from reference.md:

   > Rewyse AI uses Node.js scripts to interact with the Notion API — creating databases,
   > setting page icons, and batch-writing content. You need version 18 or higher
   > because that's when the built-in `fetch` API was added (so no extra packages needed).

   **macOS with Homebrew:**
   ```bash
   brew install node
   ```

   **macOS direct download:**
   Go to https://nodejs.org and download the LTS installer.

4. After the user installs, re-run `node --version` to verify.

5. **Do NOT proceed until Node.js 18+ is confirmed.**

---

## Step 3: Set Up Notion Integration

Walk through each step with the user. This is the most common failure point — be thorough.

> A Notion integration is an app that lets Rewyse AI read and write to your Notion workspace
> through the API. You create it once, and it works for all future product builds.

**Guide the user through these steps:**

1. Go to https://www.notion.so/my-integrations
2. Click **"New integration"**
3. **Name it** — suggest "Rewyse AI" or "AI Product Agent"
4. **Select your workspace** — this must be the workspace where you want products created
5. Under **Capabilities**, make sure all three are checked:
   - Read content
   - Update content
   - Insert content
6. Click **Save**
7. Copy the **"Internal Integration Secret"** — it starts with `ntn_`

> **Important:** Make sure you selected the right workspace in step 4. If the integration
> is in a different workspace than your pages, it won't be able to see anything.

Wait for the user to confirm they have created the integration and have the token.

---

## Step 4: Set NOTION_TOKEN

1. **Check if already set:**
   ```bash
   echo $NOTION_TOKEN
   ```

2. **If set and non-empty**, skip to the validation step (step 4 below).

3. **If not set**, provide the commands:

   For this session only:
   ```bash
   export NOTION_TOKEN=ntn_your_token_here
   ```

   To make it permanent (persists across terminal sessions):
   ```bash
   echo 'export NOTION_TOKEN=ntn_your_token_here' >> ~/.zshrc && source ~/.zshrc
   ```

   > Replace `ntn_your_token_here` with the actual token you copied in the previous step.
   > The `source ~/.zshrc` part reloads your shell config so the token takes effect immediately.

4. **Validate the token** by running:
   ```bash
   curl -s -o /dev/null -w "%{http_code}" \
     -H "Authorization: Bearer $NOTION_TOKEN" \
     -H "Notion-Version: 2022-06-28" \
     https://api.notion.com/v1/users/me
   ```

5. **If the result is `200`:**
   > NOTION_TOKEN is valid and working.

   Move to Step 5.

6. **If the result is `401`:**
   > The token was rejected. This usually means it was copied incorrectly or has expired.

   Help the user go back to https://www.notion.so/my-integrations, find their integration,
   and regenerate the token. Then update their environment variable and test again.

7. **If any other error:** consult the troubleshooting matrix in reference.md for the
   specific error and guide the user through the fix.

8. **Do NOT proceed until the curl test returns `200`.**

---

## Step 5: Share a Notion Page

> The Notion integration you created can only access pages you explicitly share with it.
> This is a security feature — by default, your integration has zero access to your workspace.
>
> You need a Notion page that will be the home for your first product. This is where
> Rewyse AI will create the product database.

**Walk through:**

1. Open Notion and create a new page (or pick an existing one) where the product will live
2. Click the **"..."** menu in the top right corner of the page
3. Click **"Connections"** (or "Add connections")
4. Find your integration name (e.g., "Rewyse AI") and click to connect it

> **Tip:** Sharing a page also shares all its child pages. So if you share "My Products",
> every product you create inside it will be accessible too.

**This is a soft gate.** The user can do this later when `/build-product` asks for a parent
page. Let them know:

> You can also do this later — `/build-product` will remind you to share the page when it's
> time. But doing it now means one less step during your first build.

---

## Step 6: Verify Notion MCP Server

1. Read `.mcp.json` in the project root.

2. Look for a `notion` key inside `mcpServers`.

3. **If present:**
   > Notion MCP server is configured.
   >
   > The MCP server lets Claude interact with Notion directly — creating pages, querying
   > databases, updating content — without you copying and pasting anything. It's what makes
   > the build process seamless.

4. **If missing or `.mcp.json` does not exist:**
   > The Notion MCP server is not configured yet. This is what lets Claude talk to Notion
   > directly during the build.

   Provide the entry to add inside `.mcp.json` under `mcpServers`:

   ```json
   "notion": {
     "command": "npx",
     "args": ["-y", "mcp-remote", "https://mcp.notion.com/mcp"]
   }
   ```

   If `.mcp.json` does not exist, create it:

   ```json
   {
     "mcpServers": {
       "notion": {
         "command": "npx",
         "args": ["-y", "mcp-remote", "https://mcp.notion.com/mcp"]
       }
     }
   }
   ```

   Help the user add it if needed.

---

## Step 7: Pipeline Overview

> Now that your environment is ready, here's how the product build works.
>
> Rewyse AI has 10 phases. You don't need to memorize them — `/build-product` walks you through
> each one in order. But here's the map so you know what to expect:

| Phase | Name | What Happens |
|-------|------|-------------|
| 1 | Product Idea | You describe what to build — product type, niche, audience, what varies per entry |
| 2 | Build Database | Rewyse AI creates a Notion database with the right properties and sample entries |
| 3 | Expert Profile | Rewyse AI builds a writing persona — voice, tone, vocabulary, expertise level |
| 4 | Content Blueprint | Defines the exact structure of every page — sections, order, word counts |
| 5 | Write Prompt | Combines the expert profile and blueprint into one generation prompt |
| 6 | Test Content | Generates 2-3 sample pages for you to review before the big run |
| 7 | Generate Content | Batch-generates all your content in parallel and writes it to Notion |
| 8 | Design Product | Creates a polished homepage with navigation, icons, and a shareable link |
| 9 | Product QA | Scans every page for quality issues — repetition, missing sections, tone drift |
| 10 | Product Expand | Suggests complementary products you could build next |

**Highlight 3 key moments:**

> **Phase 1 (Product Idea)** is an interactive conversation. You'll pick a product type,
> define your niche, and describe what changes from page to page. Take your time here —
> a clear product idea makes everything downstream better.
>
> **Phase 6 (Test Content)** is the quality gate. You'll review 2-3 sample pages before
> committing to full generation. This is your last chance to adjust voice, structure, or
> content before the big run. If something feels off, Rewyse AI traces the problem to its
> source and loops you back to fix it.
>
> **Phase 7 (Generate Content)** is the big one. Rewyse AI generates all your content in
> parallel batches and writes it directly to Notion. For 50 entries, expect about 10
> minutes. For 200 entries, about 30 minutes.

**Explain the approval flow:**

> Every phase pauses and asks for your sign-off. You can:
> - **Approve** — move to the next phase
> - **Revise** — re-run the current phase with your feedback
> - **Go Back** — jump to an earlier phase if you want to change something

**Explain resume:**

> If you close the conversation mid-build, just run `/build-product {your-project-name}`
> to pick up exactly where you left off. Your progress is saved after every phase.

---

## Step 8: Tips for Best Results

> Before you start your first build, here are 7 tips from experience:

1. **Be specific about your niche.** "Fitness" is too broad. "Hyrox race nutrition for
   beginner athletes" is perfect. The more specific you are in Phase 1, the better your
   content will be in Phase 7.

2. **The expert profile (Phase 3) is the most important phase for content quality.** This
   is where Rewyse AI defines the writing voice, expertise level, and perspective. Take time
   to review the voice sample and ask for changes if it doesn't sound right.

3. **Phase 6 (test content) is your safety net.** Don't rush through it. Read the sample
   pages carefully. If anything feels off — too generic, wrong tone, missing detail — flag
   it before you generate 100+ pages.

4. **If content quality is off, the problem is usually upstream.** Bad content almost always
   traces back to the expert profile or content blueprint, not the generation prompt. If
   samples are disappointing, go back to Phase 3 or 4.

5. **You can run individual phases standalone.** For example, `/product-idea` without a full
   build lets you experiment with different product concepts before committing.

6. **Have a product idea ready before starting.** Good first products: recipe collections,
   prompt packs, template libraries, or checklist bundles. These have clear structures
   and obvious variables.

7. **Start small.** Aim for 30-50 entries on your first build. You'll learn the flow quickly,
   and you can always expand later.

---

## Step 9: Readiness Check + Wrap Up

Present the final checklist using the actual results from earlier steps:

> **Readiness Check**
>
> - [x / .] Node.js 18+: {detected version or "not installed"}
> - [x / .] NOTION_TOKEN: {valid / not set / invalid}
> - [x / .] Notion page shared: {verified / skipped for now}
> - [x / .] Notion MCP server: {configured / missing}

**If all checks pass:**

> You're all set! Run `/build-product` to start your first product build.
>
> If you ever get stuck during a build, the pipeline will guide you through each phase.
> And if you want to revisit this setup later, just run `/rewyse-onboard` again.

**If any checks fail:**

> Almost there! Fix the items marked above, then run `/rewyse-onboard` again to re-check.
> You can also fix them during your first `/build-product` run — it validates the same
> prerequisites before starting.

**Save onboarding marker** to `rewyse-ai/output/.onboarded`:

```json
{
  "completed": "YYYY-MM-DD",
  "node_version": "{detected version}",
  "notion_token_valid": true,
  "mcp_server_configured": true
}
```

Use the actual date and detected values. Write this file silently — no need to mention it
to the user.

---

## Notes

- Be friendly, patient, and encouraging. Assume the user may not be technical.
- Do NOT rush through steps. Wait for the user to confirm at each step before moving on.
- If `rewyse-ai/output/.onboarded` already exists, ask: "You've already completed onboarding.
  Want to re-run the readiness check, or is there a specific setup step you need help with?"
- The Notion integration creation (Step 3) is the most common failure point. Be extra
  thorough — walk through each sub-step and anticipate mistakes.
- Never skip NOTION_TOKEN validation. A bad token wastes the entire first build attempt.
- Cross-reference with reference.md troubleshooting matrix when errors occur.
- If the user mentions a product idea during onboarding, acknowledge it warmly and suggest
  they save it for `/build-product` — don't derail the setup flow.
- When presenting the Product Type Sampler (if the user asks or during Step 7), pull
  examples from the table in reference.md Section 8.
