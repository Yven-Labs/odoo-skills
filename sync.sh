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
    if ! grep -q "\`$skill_name\`" "$AGENTS_FILE"; then
        echo -e "${RED}[MISSING]${NC} Skill '$skill_name' is not referenced in AGENTS.md"
        missing_skills=$((missing_skills + 1))
    fi
done

# 2. Check Skill IDs
echo -e "Checking for duplicate Skill IDs..."
# Extract ONLY the values of the **Skill ID** field to avoid false positives from body text
ids=$(grep -rhE "\*\*Skill ID\*\*:\s*ODSK-[A-Z0-9_-]+" "$SKILLS_DIR" 2>/dev/null | sed 's/.*Skill ID\*\*:\s*//' | tr -d '\r' || true)
duplicates=$(echo "$ids" | sort | uniq -d)
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
