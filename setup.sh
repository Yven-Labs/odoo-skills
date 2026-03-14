#!/bin/bash

# --- Odoo Skills Installer for Unix (Linux/macOS) ---
# Automates the integration of AI skills with coding assistants.
# Copyright (c) 2026 Geraldow - MIT License

set -euo pipefail

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Helper Functions
info() { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Branding
echo -e "${MAGENTA}"
cat << "EOF"
 ██████  ██████   ██████   ██████      ███████ ██   ██ ██ ██      ██      ███████ 
██    ██ ██   ██ ██    ██ ██    ██     ██      ██  ██  ██ ██      ██      ██      
██    ██ ██   ██ ██    ██ ██    ██     ███████ █████   ██ ██      ██      ███████ 
██    ██ ██   ██ ██    ██ ██    ██          ██ ██  ██  ██ ██      ██           ██ 
 ██████  ██████   ██████   ██████      ███████ ██   ██ ██ ███████ ███████ ███████ 
EOF
echo -e "${NC}"
echo -e "--- Odoo Skills Installer for Unix ---\n"

# Initialization
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$REPO_ROOT")"
AGENTS_FILE="$REPO_ROOT/AGENTS.md"

# Check Repo Integrity
if [ ! -f "$AGENTS_FILE" ]; then
    error "Could not find AGENTS.md in $REPO_ROOT. Please run from the repo root."
fi

# Detect Target Odoo Project
IS_INSIDE_ODOO=false
if [ -f "$PARENT_DIR/__manifest__.py" ]; then
    info "Detected Odoo project at: $PARENT_DIR"
    IS_INSIDE_ODOO=true
else
    warn "Not running inside an Odoo project (no __manifest__.py found in $PARENT_DIR)."
    read -p "Do you want to proceed with a standalone installation? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 0; fi
fi

# --- Resolve tasks from flags or interactive menu ---
tasks=()

usage() {
    echo "Usage: $0 [--all | --claude | --cursor]"
    echo ""
    echo "Options:"
    echo "  --all      Install all integrations"
    echo "  --claude   Install Claude Code integration only"
    echo "  --cursor   Install Cursor integration only"
    echo "  (no args)  Interactive menu"
    exit 0
}

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)    tasks=(1 2); shift;;
        --claude) tasks=(1); shift;;
        --cursor) tasks=(2); shift;;
        --help|-h) usage;;
        *) error "Unknown flag: $1. Use --help for usage.";;
    esac
done

# Interactive menu if no flags provided
if [ ${#tasks[@]} -eq 0 ]; then
    echo -e "\nSelect integration targets:"
    echo "1) Claude Code (AGENTS.md)"
    echo "2) Cursor (.cursorrules)"
    echo "3) All of the above"
    echo "q) Quit"
    read -p "Choice: " choice

    case "$choice" in
        1) tasks=(1);;
        2) tasks=(2);;
        3) tasks=(1 2);;
        q) exit 0;;
        *) error "Invalid choice";;
    esac
fi

# --- Task Execution ---

# Helper: Link AGENTS.md
link_agents() {
    local target_agents="$PARENT_DIR/AGENTS.md"
    info "Linking AGENTS.md to Odoo project root..."
    if [ -f "$target_agents" ]; then
        warn "AGENTS.md already exists. Backing up..."
        mv "$target_agents" "$target_agents.bak"
    fi
    ln -sf "$AGENTS_FILE" "$target_agents"
    success "Linked: $target_agents -> $AGENTS_FILE"
}

# Helper: Cursor rules
setup_cursor() {
    local cursor_rules="$PARENT_DIR/.cursorrules"
    info "Updating .cursorrules..."
    echo -e "\n# Odoo Skills Ecosystem\n@AGENTS.md" >> "$cursor_rules"
    success "Updated $cursor_rules"
}

for task in "${tasks[@]}"; do
    case "$task" in
        1) link_agents;;
        2) setup_cursor;;
    esac
done

echo -e "\n${GREEN}Integration complete! Happy Odoo Coding.${NC}\n"
