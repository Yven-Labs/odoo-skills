#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Odoo Skills — Install Script
# Detects installed AI tools, installs skills, and injects the Odoo Skills
# block into each tool's global instructions file. Safe to re-run.
# Cross-platform: macOS, Linux, Windows (Git Bash / WSL)
# Copyright (c) 2026 Geraldow - MIT License
# ============================================================================

# Remote execution support: when piped via curl | bash, __file__ is /dev/stdin
# Detect this and clone the repo to a temp dir first.
if [[ "${BASH_SOURCE[0]}" == "/dev/stdin" ]] || [[ "${BASH_SOURCE[0]}" == "bash" ]]; then
    TEMP_DIR="$(mktemp -d)"
    echo "[INFO] Remote execution detected. Cloning odoo-skills..."
    git clone --depth 1 https://github.com/Geraldow/odoo-skills.git "$TEMP_DIR" 2>&1 | grep -v '^Cloning'
    bash "$TEMP_DIR/scripts/install.sh" "$@"
    rm -rf "$TEMP_DIR"
    exit $?
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_SRC="$REPO_DIR/skills"
EXAMPLES_DIR="$REPO_DIR/examples"

MARKER_BEGIN='<!-- BEGIN:odoo-skills -->'
MARKER_END='<!-- END:odoo-skills -->'

# ============================================================================
# OS Detection
# ============================================================================

detect_os() {
    case "$(uname -s)" in
        Darwin)  OS="macos" ;;
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                OS="wsl"
            else
                OS="linux"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)  OS="windows" ;;
        *)  OS="unknown" ;;
    esac
}

os_label() {
    case "$OS" in
        macos)   echo "macOS" ;;
        linux)   echo "Linux" ;;
        wsl)     echo "WSL" ;;
        windows) echo "Windows (Git Bash)" ;;
        *)       echo "Unknown" ;;
    esac
}

# ============================================================================
# Color support
# ============================================================================

setup_colors() {
    if [ -t 1 ] && [ "${TERM:-}" != "dumb" ]; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        CYAN='\033[0;36m'
        BOLD='\033[1m'
        NC='\033[0m'
    else
        RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
    fi
}

# ============================================================================
# Path Resolution
# ============================================================================

get_home() {
    if [[ "$OS" == "windows" ]] && [[ -n "${USERPROFILE:-}" ]]; then
        cygpath -u "$USERPROFILE" 2>/dev/null || echo "$HOME"
    elif [[ "$OS" == "wsl" ]] && [[ -n "${USERPROFILE:-}" ]]; then
        wslpath "$USERPROFILE" 2>/dev/null || echo "$HOME"
    else
        echo "$HOME"
    fi
}

get_tool_path() {
    local tool="$1"
    local h
    h="$(get_home)"
    case "$tool" in
        claude-code)  echo "$h/.claude/skills" ;;
        opencode)     echo "$h/.config/opencode/skills" ;;
        gemini-cli)   echo "$h/.gemini/skills" ;;
        codex)        echo "$h/.codex/skills" ;;
        vscode)       echo "$h/.copilot/skills" ;;
        cursor)       echo "$h/.cursor/skills" ;;
    esac
}

get_prompt_path() {
    local tool="$1"
    local h
    h="$(get_home)"
    case "$tool" in
        claude-code)  echo "$h/.claude/CLAUDE.md" ;;
        opencode)     echo "$h/.config/opencode/AGENTS.md" ;;
        gemini-cli)   echo "$h/.gemini/GEMINI.md" ;;
        codex)        echo "$h/.codex/AGENTS.md" ;;
        vscode)       echo "$h/.config/Code/User/prompts/odoo-skills.instructions.md" ;;
        cursor)       echo "$h/.cursor/rules/odoo-skills.mdc" ;;
    esac
}

get_example_file() {
    local tool="$1"
    case "$tool" in
        claude-code)  echo "$EXAMPLES_DIR/claude-code/CLAUDE.md" ;;
        opencode)     echo "$EXAMPLES_DIR/opencode/AGENTS.md" ;;
        gemini-cli)   echo "$EXAMPLES_DIR/gemini-cli/GEMINI.md" ;;
        codex)        echo "$EXAMPLES_DIR/codex/agents.md" ;;
        vscode)       echo "$EXAMPLES_DIR/vscode/copilot-instructions.md" ;;
        cursor)       echo "$EXAMPLES_DIR/cursor/.cursorrules" ;;
    esac
}

declare -A AGENT_BINARIES=(
    [claude-code]="claude"
    [opencode]="opencode"
    [gemini-cli]="gemini"
    [codex]="codex"
    [vscode]="code"
    [cursor]="cursor"
)

# ============================================================================
# Helpers
# ============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}   ___       _                ____  _    _ _ _     ${NC}"
    echo -e "${CYAN}  / _ \   __| | ___   ___    / ___|| | _(_) | |___ ${NC}"
    echo -e "${CYAN} | | | | / \`_ |/ _ \ / _ \   \___ \| |/ / | | / __|${NC}"
    echo -e "${CYAN} | |_| || (_| | (_) | (_) |   ___) |   <| | | \__ \\${NC}"
    echo -e "${CYAN}  \___/  \__,_|\___/ \___/  |____/|_|\_\_|_|_|___/ ${NC}"
    echo ""
    echo -e "  Odoo Skills — configure any AI agent, any OS"
    echo ""
}

print_ok()    { echo -e "  ${GREEN}✓${NC} $1"; }
print_warn()  { echo -e "  ${YELLOW}!${NC} $1"; }
print_error() { echo -e "  ${RED}✗${NC} $1"; }
print_info()  { echo -e "  ${BLUE}→${NC} $1"; }
print_head()  { echo -e "\n${CYAN}$1${NC}"; }

show_help() {
    echo "Usage: install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all               Auto-detect and set up all found agents"
    echo "  --agent NAME        Set up a specific agent"
    echo "  --non-interactive   No prompts (for external installers)"
    echo "  -h, --help          Show this help"
    echo ""
    echo "Agents: claude-code, opencode, gemini-cli, codex, vscode, cursor"
    echo ""
    echo "Remote install (Unix):"
    echo "  curl -fsSL https://raw.githubusercontent.com/Geraldow/odoo-skills/main/scripts/install.sh | bash"
}

# ============================================================================
# Prerequisites
# ============================================================================

check_prerequisites() {
    if ! command -v git &>/dev/null; then
        echo -e "${RED}[error]${NC}   git is required but not found in PATH." >&2
        echo -e "  Please install git and try again." >&2
        exit 1
    fi
}

# ============================================================================
# Agent Detection
# ============================================================================

find_agents() {
    local found=()
    print_head "Detecting installed AI tools..."

    for agent in $(echo "${!AGENT_BINARIES[@]}" | tr ' ' '\n' | sort); do
        local binary="${AGENT_BINARIES[$agent]}"
        if command -v "$binary" &>/dev/null; then
            print_ok "$agent  ($binary found in PATH)"
            found+=("$agent")
        else
            print_warn "$agent  ($binary not found in PATH — skipping)"
        fi
    done

    echo ""
    if [ ${#found[@]} -eq 0 ]; then
        print_warn "No agents detected. Use ./install.sh for manual installation."
    else
        echo -e "  ${GREEN}${#found[@]} agent(s) detected${NC}"
    fi

    echo "${found[@]}"
}

# ============================================================================
# Install Skills
# ============================================================================

install_skills() {
    local target_dir="$1"
    local tool_name="$2"

    print_info "Installing skills -> $target_dir"
    mkdir -p "$target_dir"

    local count=0
    for skill_dir in "$SKILLS_SRC"/odoo-*/; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name=$(basename "$skill_dir")

        if [ ! -f "$skill_dir/SKILL.md" ]; then continue; fi

        mkdir -p "$target_dir/$skill_name"
        cp "$skill_dir/SKILL.md" "$target_dir/$skill_name/SKILL.md"

        [ -d "$skill_dir/assets" ]     && cp -r "$skill_dir/assets"     "$target_dir/$skill_name/"
        [ -d "$skill_dir/references" ] && cp -r "$skill_dir/references" "$target_dir/$skill_name/"

        count=$((count + 1))
    done

    print_ok "$count Odoo skills installed"
}

# ============================================================================
# Inject Odoo Skills Block (idempotent)
# ============================================================================

inject_block() {
    local prompt_path="$1"
    local example_file="$2"
    local agent_name="$3"

    if [ ! -f "$example_file" ]; then
        print_warn "No example file for $agent_name — skipping prompt configuration"
        return
    fi

    # Extract content between markers in example file
    local content
    content="$(awk "/$MARKER_BEGIN/{found=1; next} /$MARKER_END/{found=0} found{print}" "$example_file")"
    if [ -z "$content" ]; then
        content="$(cat "$example_file")"
    fi

    local prompt_dir
    prompt_dir="$(dirname "$prompt_path")"
    mkdir -p "$prompt_dir"

    if [ -f "$prompt_path" ]; then
        if grep -qF "$MARKER_BEGIN" "$prompt_path"; then
            # Replace existing block using awk
            awk -v begin="$MARKER_BEGIN" -v end="$MARKER_END" -v new_content="$MARKER_BEGIN\n$content\n$MARKER_END" '
                $0 == begin { inside=1; printf "%s\n", new_content; next }
                inside && $0 == end { inside=0; next }
                inside { next }
                { print }
            ' "$prompt_path" > "${prompt_path}.tmp" && mv "${prompt_path}.tmp" "$prompt_path"
            print_ok "Odoo Skills block updated in $prompt_path"
        elif grep -qF "## Odoo Skills Ecosystem" "$prompt_path"; then
            print_warn "Odoo Skills block already present in $prompt_path (no markers)"
            print_info "To enable auto-updates, wrap the block with: $MARKER_BEGIN / $MARKER_END"
        else
            # Append
            printf "\n\n%s\n%s\n%s\n" "$MARKER_BEGIN" "$content" "$MARKER_END" >> "$prompt_path"
            print_ok "Odoo Skills block appended to $prompt_path"
        fi
    else
        # Create new file
        printf "%s\n%s\n%s\n" "$MARKER_BEGIN" "$content" "$MARKER_END" > "$prompt_path"
        print_ok "Odoo Skills block created at $prompt_path"
    fi
}

# ============================================================================
# Full Setup for One Agent
# ============================================================================

setup_agent() {
    local agent="$1"
    print_head "Setting up $agent"

    install_skills "$(get_tool_path "$agent")" "$agent"
    inject_block "$(get_prompt_path "$agent")" "$(get_example_file "$agent")" "$agent"
}

# ============================================================================
# Next Steps
# ============================================================================

print_next_steps() {
    local agents=("$@")
    echo ""
    echo -e "${GREEN}${BOLD}Setup complete!${NC}"
    echo ""
    for a in "${agents[@]}"; do
        echo -e "  ${GREEN}✓${NC} ${BOLD}$a${NC}"
        echo "    Skills : $(get_tool_path "$a")"
        echo "    Prompt : $(get_prompt_path "$a")"
    done
    echo ""
    echo -e "Open any Odoo project and your AI tool will use the skills automatically."
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    detect_os
    setup_colors

    AGENT=""
    RUN_ALL=false
    NON_INTERACTIVE=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --agent)           AGENT="$2"; shift 2 ;;
            --all)             RUN_ALL=true; shift ;;
            --non-interactive) NON_INTERACTIVE=true; shift ;;
            -h|--help)         show_help; exit 0 ;;
            *) echo "Unknown option: $1"; show_help; exit 1 ;;
        esac
    done

    print_header
    check_prerequisites

    local installed_agents=()

    if [[ -n "$AGENT" ]]; then
        setup_agent "$AGENT"
        installed_agents+=("$AGENT")
    elif $RUN_ALL || $NON_INTERACTIVE; then
        read -ra detected <<< "$(find_agents)"
        for a in "${detected[@]}"; do
            setup_agent "$a"
            installed_agents+=("$a")
        done
    else
        read -ra detected <<< "$(find_agents)"
        if [ ${#detected[@]} -eq 0 ]; then
            echo ""
            print_warn "No agents detected. Use ./install.sh for manual installation."
            exit 0
        fi

        echo ""
        read -rp "Set up all detected agents? [Y/n]: " answer
        answer="${answer:-y}"

        if [[ "$answer" =~ ^[Yy] ]]; then
            for a in "${detected[@]}"; do
                setup_agent "$a"
                installed_agents+=("$a")
            done
        else
            echo ""
            echo "Select agents to set up (space-separated numbers):"
            echo ""
            for i in "${!detected[@]}"; do
                echo "  $((i+1))) ${detected[$i]}"
            done
            echo ""
            read -rp "Choice: " choices
            for c in $choices; do
                idx=$((c - 1))
                if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#detected[@]}" ]; then
                    setup_agent "${detected[$idx]}"
                    installed_agents+=("${detected[$idx]}")
                fi
            done
        fi
    fi

    if [ ${#installed_agents[@]} -gt 0 ]; then
        print_next_steps "${installed_agents[@]}"
    else
        echo ""
        print_warn "No agents were set up."
    fi
}

main "$@"
