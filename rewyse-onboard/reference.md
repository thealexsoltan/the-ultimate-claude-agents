# Rewyse AI Onboarding Reference

Setup guides, verification commands, and troubleshooting for first-time Rewyse AI users.

---

## 1. Node.js Installation Guide

Rewyse AI generates Node.js scripts that interact with the Notion API — creating databases,
setting page icons, batch-writing content, and more. All scripts use the built-in `fetch`
API available in Node.js 18+, so no npm packages are required.

### macOS with Homebrew (recommended)

```bash
brew install node
```

If Homebrew is not installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install node
```

### macOS Direct Download

1. Go to https://nodejs.org
2. Download the macOS installer (LTS version recommended)
3. Run the `.pkg` installer and follow the prompts

### Verify Installation

```bash
node --version
```

Expected output: `v18.x.x` or higher (e.g., `v20.11.0`).

If the version is below 18, upgrade:

```bash
brew upgrade node
```

---

## 2. Notion Integration Setup

A Notion integration is an app that lets Rewyse AI read and write to your Notion workspace
through the API. You create it once, and it works for all future product builds.

### Step-by-Step

1. Go to https://www.notion.so/my-integrations
2. Click **"New integration"**
3. **Name it** — suggest "Rewyse AI" or "AI Product Agent"
4. **Select your workspace** — choose the workspace where you want products created
5. Under **Capabilities**, ensure all three are enabled:
   - Read content
   - Update content
   - Insert content
6. Click **Save** (or Submit)
7. Copy the **"Internal Integration Secret"** — it starts with `ntn_`

### Common Mistakes

| Mistake | What happens | Fix |
|---------|-------------|-----|
| Wrong workspace selected | Integration can't see your pages | Delete and recreate in the correct workspace |
| Capabilities not all enabled | API calls fail with 403 errors | Edit integration, enable all three, save |
| Copied the wrong field | Token doesn't work | The token is labeled "Internal Integration Secret" and starts with `ntn_` |
| Didn't click Save after creation | Token not generated | Go back and click Save/Submit |

---

## 3. NOTION_TOKEN Configuration

The `NOTION_TOKEN` environment variable is how Rewyse AI scripts authenticate with Notion.

### For zsh (default macOS shell)

Set for this session only:

```bash
export NOTION_TOKEN=ntn_your_token_here
```

Set permanently (persists across terminal sessions):

```bash
echo 'export NOTION_TOKEN=ntn_your_token_here' >> ~/.zshrc && source ~/.zshrc
```

### For bash

```bash
echo 'export NOTION_TOKEN=ntn_your_token_here' >> ~/.bashrc && source ~/.bashrc
```

### Alternative: .env File

Create a `.env` file in the project root:

```
NOTION_TOKEN=ntn_your_token_here
```

Note: Rewyse AI scripts read from the environment variable directly, so `.zshrc`/`.bashrc`
is the more reliable approach.

### Gotcha

Setting the token in `~/.zshrc` does not affect your current terminal session until you
run `source ~/.zshrc` or open a new terminal window.

---

## 4. Page Sharing Guide

Notion integrations can only access pages that have been explicitly shared with them.
This is a Notion security feature — your integration starts with zero access.

### Why This Matters

When Rewyse AI creates a product database, it needs write access to a parent page. If that
page is not shared with the integration, the API returns a 403 error and the build fails.

### How to Share a Page

1. Open the Notion page that will be the parent for your product
2. Click the **"..."** menu (top right corner of the page)
3. Click **"Connections"** (or "Add connections")
4. Find your integration name (e.g., "Rewyse AI") in the list
5. Click to connect it

### Important Details

- You must share the **parent page** where the product will be created, not a child page
- Sharing a page automatically shares all its child pages with the integration
- You will need to do this for each new parent page you use for product builds
- If you share a database directly, the integration can read it but may not be able to
  create sibling pages — always share the parent

### Common Confusion

Sharing a database is not the same as sharing the page that contains it. If your database
lives inside "My Products" page, share "My Products" — not the database itself.

---

## 5. MCP Server Configuration

The MCP (Model Context Protocol) server lets Claude interact with Notion directly —
creating pages, querying databases, updating content — without you copying and pasting
anything. It is a bridge between Claude and the Notion API.

### Config Location

The MCP configuration lives in `.mcp.json` in the project root.

### Required Entry

The `notion` key should be present inside `mcpServers`:

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

If `.mcp.json` already has other servers configured, add the `notion` entry alongside them
inside the existing `mcpServers` object. Do not overwrite the file.

### How to Verify

1. Open `.mcp.json` in the project root
2. Look for a `"notion"` key inside `"mcpServers"`
3. If present, the MCP server is configured

---

## 6. Verification Commands

Run these to confirm everything is ready for a product build.

### Node.js

```bash
node --version
```

- Expected: `v18.x.x` or higher
- If missing: see Section 1

### NOTION_TOKEN Set

```bash
echo $NOTION_TOKEN
```

- Expected: a token starting with `ntn_` (or `secret_` for older tokens)
- If empty: see Section 3

### NOTION_TOKEN Valid

```bash
curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Notion-Version: 2022-06-28" \
  https://api.notion.com/v1/users/me
```

- Expected: `200`
- If `401`: token is wrong or expired — regenerate at notion.so/my-integrations
- If `403`: token is valid but page not shared — see Section 4
- If connection error: check internet connection

### MCP Config

Read `.mcp.json` and verify the `notion` key exists inside `mcpServers`.

---

## 7. Troubleshooting Matrix

| Problem | Cause | Fix |
|---------|-------|-----|
| Integration not in Connections list | Created in a different workspace | Delete the integration and create a new one in the correct workspace |
| Token starts with `secret_` | Old token format (pre-2024) | Still works, but you can regenerate at notion.so/my-integrations for a `ntn_` prefix token |
| curl returns `401` | Wrong or expired token | Regenerate at https://www.notion.so/my-integrations and update `NOTION_TOKEN` |
| curl returns `403` | Page not shared with integration | Open page in Notion, click "..." > "Connections" > add your integration |
| `npx: command not found` | Node.js not installed or not in PATH | Reinstall Node.js via Homebrew or nodejs.org |
| MCP server timeout | Network issue or Notion service disruption | Retry the operation; check your internet connection |
| `node --version` shows < 18 | Old Node.js installation | Run `brew upgrade node` or download latest from nodejs.org |
| `NOTION_TOKEN` is empty after setting | Shell config not reloaded | Run `source ~/.zshrc` (or `source ~/.bashrc`) or open a new terminal |
| "Could not find database" error | Database not shared with integration | Share the parent page containing the database via Connections menu |
| Script fails with "fetch is not defined" | Node.js version < 18 | Upgrade to Node.js 18+ where `fetch` is built-in |

---

## 8. Product Type Sampler

Rewyse AI supports 10 digital product types. Here is a quick overview to inspire your first build.

| # | Type | What It Is | Example |
|---|------|-----------|---------|
| 1 | **Ebook** | A multi-chapter digital book delivered as Notion pages, each chapter AI-generated | "The Hyrox Nutrition Playbook" — 20 chapters on race-day fueling, recovery, and meal prep for hybrid athletes |
| 2 | **SOP** | Step-by-step process documents with instructions, tools needed, and expected outcomes | "Agency Onboarding SOPs" — 50 procedures for client intake, project setup, and team assignment |
| 3 | **Workbook** | Interactive exercises with prompts, frameworks, and space for the user to fill in answers | "The Brand Strategy Workbook" — 30 exercises on positioning, messaging, and competitive analysis |
| 4 | **Template** | Pre-built fill-in-the-blank documents customers customize for their situation | "100 Email Templates for Real Estate Agents" — templates for lead follow-up, listing announcements, and nurturing |
| 5 | **Checklist** | Actionable checklists for specific processes, organized by phase or category | "The Product Launch Checklist Library" — 40 checklists for pre-launch, launch day, and iteration |
| 6 | **Guide / Playbook** | Comprehensive how-to guides with strategies, tactics, examples, and implementation steps | "Growth Channel Playbooks" — 25 guides on SEO, paid ads, content marketing, and community building for SaaS founders |
| 7 | **Prompt Pack** | Curated collections of AI prompts with context, the prompt itself, and expected output | "200 ChatGPT Prompts for Content Creators" — prompts for ideation, writing, repurposing, and analytics |
| 8 | **Swipe File** | Curated real-world examples with analysis of why they work and how to adapt them | "High-Converting Landing Page Swipe File" — 75 landing pages with conversion analysis and CTA breakdowns |
| 9 | **Scripts** | Ready-to-use scripts for sales calls, videos, webinars, or customer interactions | "50 Sales Call Scripts for Coaches" — scripts for discovery calls, objection handling, and closing |
| 10 | **Online Course** | Course curriculum with lesson outlines, scripts, slide notes, and exercises | "Complete Pinterest Marketing Course" — 30 lessons across 5 modules on profile setup, pin strategy, and monetization |

Every product has a **fixed structure** (sections that appear on every page) and **variables**
(what changes from page to page). Rewyse AI combines these to generate unique content for each entry.

Good first products for learning the flow: recipe collections, prompt packs, or template libraries.
Start with 30-50 entries to keep your first build fast (under an hour).
