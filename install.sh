#!/bin/bash
# Rewyse AI — Installer
# Installs the Rewyse AI digital product pipeline into your Claude Code project.

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Rewyse AI — AI Digital Product Agent${NC}"
echo -e "${BLUE}  Installing into your Claude Code project...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Detect project root (go up from the cloned directory)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INSTALL_DIR="$PROJECT_ROOT/rewyse-ai"

# Check if already in the right place
if [ "$(basename "$SCRIPT_DIR")" = "rewyse-ai" ]; then
  echo -e "${GREEN}[ok]${NC} Already installed at $SCRIPT_DIR"
else
  # Move the cloned repo to rewyse-ai/ in the parent directory
  if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}[!]${NC} rewyse-ai/ already exists at $INSTALL_DIR"
    echo "    Remove it first or install manually."
    exit 1
  fi
  mv "$SCRIPT_DIR" "$INSTALL_DIR"
  SCRIPT_DIR="$INSTALL_DIR"
  echo -e "${GREEN}[ok]${NC} Moved to $INSTALL_DIR"
fi

# Create output and scripts directories (gitignored, needed at runtime)
mkdir -p "$INSTALL_DIR/output"
mkdir -p "$INSTALL_DIR/scripts"
echo -e "${GREEN}[ok]${NC} Created output/ and scripts/ directories"

# Add Rewyse AI registration to root CLAUDE.md if not already present
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
  if grep -q "rewyse-ai" "$CLAUDE_MD" 2>/dev/null; then
    echo -e "${GREEN}[ok]${NC} CLAUDE.md already has Rewyse AI registration"
  else
    cat >> "$CLAUDE_MD" << 'REGISTRATION'

---

### Rewyse AI — AI Digital Product Agent (`rewyse-ai/`)

See `rewyse-ai/CLAUDE.md` for full pipeline documentation.

**Quick start:**
- `/rewyse-onboard` — First-time setup guide
- `/build-product` — Build a new digital product
- `/rewyse-help` — Q&A and troubleshooting

**All commands:** `/build-product`, `/product-idea`, `/build-database`, `/expert-profile`,
`/content-blueprint`, `/write-prompt`, `/test-content`, `/generate-content`, `/design-product`,
`/product-qa`, `/product-expand`, `/home-page`, `/subpage-views`, `/prompt-generator`,
`/rewyse-help`, `/rewyse-onboard`
REGISTRATION
    echo -e "${GREEN}[ok]${NC} Added Rewyse AI registration to CLAUDE.md"
  fi
else
  cat > "$CLAUDE_MD" << 'NEWCLAUDE'
# Project Instructions

## Rewyse AI — AI Digital Product Agent (`rewyse-ai/`)

See `rewyse-ai/CLAUDE.md` for full pipeline documentation.

**Quick start:**
- `/rewyse-onboard` — First-time setup guide
- `/build-product` — Build a new digital product
- `/rewyse-help` — Q&A and troubleshooting

**All commands:** `/build-product`, `/product-idea`, `/build-database`, `/expert-profile`,
`/content-blueprint`, `/write-prompt`, `/test-content`, `/generate-content`, `/design-product`,
`/product-qa`, `/product-expand`, `/home-page`, `/subpage-views`, `/prompt-generator`,
`/rewyse-help`, `/rewyse-onboard`
NEWCLAUDE
  echo -e "${GREEN}[ok]${NC} Created CLAUDE.md with Rewyse AI registration"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Next steps:"
echo ""
echo "  1. Open Claude Code in this project directory"
echo "  2. Run /rewyse-onboard to set up prerequisites"
echo "     (Notion integration, NOTION_TOKEN, Node.js)"
echo "  3. Run /build-product to create your first digital product"
echo ""
echo "  Need help? Run /rewyse-help anytime."
echo ""
