#!/bin/bash

# --- Odoo Skills Sync & Validation Tool ---
# Local maintenance script to ensure library integrity.
# Copyright (c) 2026 Geraldow - MIT License

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}--- Odoo Skills Sync & Validation ---${NC}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_FILE="$REPO_ROOT/AGENTS.md"
SKILLS_DIR="$REPO_ROOT/skills"

# 1. Check AGENTS.md references
echo -e "Checking skill references in AGENTS.md..."
missing_skills=0
for skill_path in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_path")
    if ! grep -q "skills/$skill_name/" "$AGENTS_FILE"; then
        echo -e "${RED}[MISSING]${NC} Skill '$skill_name' is not referenced in AGENTS.md"
        missing_skills=$((missing_skills + 1))
    fi
done

# 2. Check ODSK Unique IDs (Skill IDs)
echo -e "Checking for duplicate Skill IDs (ODSK)..."
# Use precise regex to match real ODSK-XXX-YYY patterns and ignore doc mentions
duplicates=$(grep -rohE 'ODSK-[A-Z][A-Z0-9]*-[A-Z][A-Z0-9_-]*' "$SKILLS_DIR" | sort | uniq -d)
if [ -n "$duplicates" ]; then
    echo -e "${RED}[DUPLICATE]${NC} Found duplicate Skill IDs:"
    echo "$duplicates"
    missing_skills=$((missing_skills + 1))
fi

# 3. Final Summary
if [ "$missing_skills" -eq 0 ]; then
    echo -e "${GREEN}[PASSED]${NC} Library integrity is solid."
else
    echo -e "${RED}[FAILED]${NC} Found $missing_skills issues that need fixing."
    exit 1
fi
