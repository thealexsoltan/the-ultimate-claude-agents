#!/bin/bash
# Rewyse AI — Updater
# Pulls the latest version, registers any new slash commands, preserves your data.
# Run from inside rewyse-ai/:  bash update.sh
# Compatible with bash 3.2+ (macOS default)

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Move to script directory so it works regardless of where it's called from
cd "$(dirname "$0")"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Rewyse AI — Updating to latest${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ── 1. Sanity checks ────────────────────────────────────────────────────────

if [ ! -d ".git" ]; then
  echo -e "${RED}[err]${NC} This doesn't look like a rewyse-ai checkout (no .git directory found)."
  echo "       Run this script from inside the rewyse-ai/ folder."
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo -e "${RED}[err]${NC} git is not installed. Install git first, then re-run this script."
  exit 1
fi

# ── 2. Capture current state for the summary ────────────────────────────────

CURRENT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
CURRENT_MSG=$(git log -1 --pretty=format:'%s' 2>/dev/null || echo "unknown")

# ── 3. Stash any local tracked-file changes automatically ──────────────────

HAS_LOCAL_CHANGES=0
STASH_REF=""
if ! git diff --quiet HEAD 2>/dev/null || ! git diff --quiet --cached 2>/dev/null; then
  HAS_LOCAL_CHANGES=1
  STASH_REF="rewyse-ai-update-$(date +%Y%m%d-%H%M%S)"
  echo -e "${YELLOW}[!]${NC}  Local edits detected — saving them safely as a stash"
  git stash push -m "$STASH_REF" --quiet
  echo -e "${GREEN}[ok]${NC} Local changes stashed as: $STASH_REF"
  echo ""
fi

# ── 4. Fetch + pull ─────────────────────────────────────────────────────────

echo -e "${BLUE}[..]${NC} Fetching latest from GitHub..."
if ! git fetch --quiet 2>&1; then
  echo -e "${RED}[err]${NC} Fetch failed. Check your internet connection or repo access."
  if [ "$HAS_LOCAL_CHANGES" -eq 1 ]; then
    echo "       Your changes are safe in: git stash list (look for '$STASH_REF')"
  fi
  exit 1
fi

# Check if there's anything new
LOCAL_HEAD=$(git rev-parse HEAD)
REMOTE_HEAD=$(git rev-parse @{u} 2>/dev/null || echo "$LOCAL_HEAD")

if [ "$LOCAL_HEAD" = "$REMOTE_HEAD" ]; then
  echo -e "${GREEN}[ok]${NC} Already on the latest version."
  ALREADY_LATEST=1
else
  ALREADY_LATEST=0
  echo -e "${BLUE}[..]${NC} Pulling new commits..."
  if ! git pull --ff-only --quiet 2>/dev/null; then
    # Fast-forward failed — probably a divergence (rare)
    echo -e "${RED}[err]${NC} Could not fast-forward — your local history has diverged from upstream."
    echo "       This usually means you committed changes locally that aren't on GitHub."
    echo "       Contact support or run manually: git pull --rebase"
    if [ "$HAS_LOCAL_CHANGES" -eq 1 ]; then
      echo "       Your edits are safe in: git stash list (look for '$STASH_REF')"
    fi
    exit 1
  fi
  NEW_COMMIT=$(git rev-parse --short HEAD)
  echo -e "${GREEN}[ok]${NC} Updated to $NEW_COMMIT"
fi

# ── 5. Register any new slash commands via install.sh ──────────────────────

echo -e "${BLUE}[..]${NC} Registering any new slash commands..."
INSTALL_LOG="/tmp/rewyse-update-install-$$.log"
if bash install.sh > "$INSTALL_LOG" 2>&1; then
  # Extract the slash-commands line from install.sh output for the summary
  SKILL_LINE=$(grep -E "Registered|already registered" "$INSTALL_LOG" | tail -1 | sed -E 's/.*\[ok\][^A-Za-z0-9]+//')
  echo -e "${GREEN}[ok]${NC} ${SKILL_LINE:-Slash commands registered}"
  rm -f "$INSTALL_LOG"
else
  echo -e "${RED}[err]${NC} install.sh failed. See log: $INSTALL_LOG"
  if [ "$HAS_LOCAL_CHANGES" -eq 1 ]; then
    echo "       Your edits are safe in: git stash list (look for '$STASH_REF')"
  fi
  exit 1
fi

# ── 6. Restore local changes (if any) ──────────────────────────────────────

STASH_RESTORED=0
STASH_CONFLICT=0
if [ "$HAS_LOCAL_CHANGES" -eq 1 ]; then
  echo -e "${BLUE}[..]${NC} Restoring your local changes..."
  if git stash pop --quiet 2>/dev/null; then
    STASH_RESTORED=1
    echo -e "${GREEN}[ok]${NC} Local changes restored cleanly"
  else
    STASH_CONFLICT=1
    echo -e "${YELLOW}[!]${NC}  Local changes conflict with the new version (rare)"
    echo "       Your edits are still safe — kept as stash: $STASH_REF"
    echo "       To restore manually: git stash pop  (then resolve the conflict)"
    echo "       To discard them:    git stash drop"
  fi
fi

# ── 7. Summary ──────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Update complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$ALREADY_LATEST" -eq 1 ]; then
  echo "  You were already on the latest version: $CURRENT_COMMIT"
  echo "  ($CURRENT_MSG)"
else
  NEW_COMMIT=$(git rev-parse --short HEAD)
  NEW_MSG=$(git log -1 --pretty=format:'%s')
  echo "  Was on:  $CURRENT_COMMIT  ($CURRENT_MSG)"
  echo "  Now on:  $NEW_COMMIT  ($NEW_MSG)"
  echo ""
  echo "  What's new:"
  git log "$CURRENT_COMMIT..HEAD" --pretty=format:'    • %s' --reverse 2>/dev/null || echo "    (commit details unavailable)"
  echo ""
fi

if [ "$STASH_CONFLICT" -eq 1 ]; then
  echo ""
  echo -e "${YELLOW}  Heads up:${NC} Your previous local edits are saved as a stash."
  echo "  Run \`git stash list\` to see them, or \`git stash pop\` to restore (and resolve)."
fi

echo ""
echo "  Your products in output/ and your slash commands in .claude/skills/ are intact."
echo "  Run /rewyse-help in Claude Code if you have questions."
echo ""
