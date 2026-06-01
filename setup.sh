#!/bin/bash

# ============================================
#  CORTEX — ONE CLICK SETUP
#  An operating system for Claude Code
# ============================================
#
#  Run with:
#  curl -fsSL https://raw.githubusercontent.com/matteo-stratega/claude-cortex/main/setup.sh -o setup.sh
#  bash setup.sh
#
#  This installer clones the repo and assembles a clean personal workspace
#  from its files — it embeds no copies, so it can never drift from source.
# ============================================

set -eo pipefail

# Repo + workspace parent are overridable for testing.
REPO_URL="${CORTEX_REPO:-https://github.com/matteo-stratega/claude-cortex.git}"
WORKSPACE_PARENT="${CORTEX_HOME:-$HOME}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}   CORTEX SETUP${NC}"
echo -e "${CYAN}   An operating system for Claude Code${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# ============================================
# STEP 1: Check prerequisites
# ============================================
echo -e "${YELLOW}[1/4] Checking prerequisites...${NC}"

for tool in node python3 git; do
    if ! command -v "$tool" &> /dev/null; then
        echo -e "${RED}$tool not found!${NC}"
        echo ""
        case "$tool" in
            node)    echo "  → Install Node.js (LTS): https://nodejs.org" ;;
            python3) echo "  → Install Python 3: https://python.org (required for enforcement hooks)" ;;
            git)     echo "  → Install Git: https://git-scm.com" ;;
        esac
        echo ""
        echo "Then run this script again."
        exit 1
    fi
done
echo -e "${GREEN}  ✓ node $(node --version), $(python3 --version), $(git --version | awk '{print $1, $3}')${NC}"

if command -v claude &> /dev/null; then
    echo -e "${GREEN}  ✓ Claude Code already installed${NC}"
else
    echo -e "${YELLOW}  Installing Claude Code...${NC}"
    npm install -g @anthropic-ai/claude-code
    echo -e "${GREEN}  ✓ Claude Code installed${NC}"
fi

# ============================================
# STEP 2: Workspace name
# ============================================
echo ""
echo -e "${YELLOW}[2/4] Naming workspace...${NC}"

read -p "Workspace name (default: cortex): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-cortex}
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr ' ' '-' | tr -cd '[:alnum:]-')

WORKSPACE_PATH="$WORKSPACE_PARENT/$PROJECT_NAME"

if [ -d "$WORKSPACE_PATH" ]; then
    echo -e "${YELLOW}  ! Folder already exists: $WORKSPACE_PATH${NC}"
    read -p "  Merge into it anyway? (y/n): " confirm
    if [[ $confirm != "y" ]]; then
        echo "Aborted."
        exit 1
    fi
fi
echo -e "${GREEN}  ✓ Workspace: $WORKSPACE_PATH${NC}"

# ============================================
# STEP 3: Clone + assemble workspace
# ============================================
echo ""
echo -e "${YELLOW}[3/4] Assembling workspace from source...${NC}"

TMP_SRC="$(mktemp -d)"
trap 'rm -rf "$TMP_SRC"' EXIT

git clone --depth 1 --quiet "$REPO_URL" "$TMP_SRC"

mkdir -p "$WORKSPACE_PATH"
# Copy everything (including dotfiles like .claude, .gitignore), then strip
# the bits that belong to the repo/plugin but not to a personal workspace.
cp -R "$TMP_SRC"/. "$WORKSPACE_PATH"/

cd "$WORKSPACE_PATH"
rm -rf .git .claude-plugin skills          # repo git, plugin manifest, canonical plugin skills (workspace uses .claude/skills)
rm -f  hooks/hooks.json                     # plugin hook config (workspace uses .claude/settings.json)
rm -f  setup.sh setup-windows.ps1           # installers
rm -f  scripts/sync.sh                      # repo dev tool
rm -f  README.md                            # repo readme, not the user's workspace

echo -e "${GREEN}  ✓ Workspace assembled${NC}"

# ============================================
# STEP 4: Initialize git
# ============================================
echo ""
echo -e "${YELLOW}[4/4] Initializing git...${NC}"

if [ ! -d ".git" ]; then
    git init --quiet
    git add -A
    git commit -m "Initial setup — Cortex" --quiet
fi
# Activate the brain tripwire (blocks context.md bloat + broken frontmatter).
git config core.hooksPath .githooks 2>/dev/null || true
echo -e "${GREEN}  ✓ Git initialized (brain tripwire active via .githooks)${NC}"

# ============================================
# DONE!
# ============================================
echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}   CORTEX SETUP COMPLETE${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo "Your workspace is ready:"
echo -e "  ${BLUE}$WORKSPACE_PATH${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. cd $WORKSPACE_PATH"
echo "  2. claude     (on first launch, ACCEPT the folder-trust prompt —"
echo "                 that's what activates the enforcement hooks)"
echo "  3. /setup     (guided onboarding — fills in your context)"
echo ""
echo -e "${YELLOW}Skills:${NC} /setup  /start  /close  /brief  /plan  /review  /weekly"
echo -e "${YELLOW}Agents:${NC} call cto · call content-strategist · call growth-hacker · call war-council"
echo ""
echo -e "  ${BLUE}Repo:${NC}   github.com/matteo-stratega/claude-cortex"
echo -e "  ${BLUE}Author:${NC} Matteo Lombardi"
echo ""
