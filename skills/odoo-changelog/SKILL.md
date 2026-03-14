---
name: odoo-changelog
description: >
  Manages the CHANGELOG.md for odoo-skills following keepachangelog.com format.
  Trigger: When creating PRs, adding changelog entries, or updating CHANGELOG.md.
license: MIT
metadata:
  author: Geraldow
  version: "1.0.0"
  scope: [root]
  auto_invoke:
    - "Add changelog entry for a PR or feature"
    - "Update CHANGELOG.md"
    - "Create PR that requires changelog entry"
    - "Review changelog format and conventions"
---

## Format Rules (keepachangelog.com)

### Section Order (ALWAYS This Order)

```markdown
## [X.Y.Z] - YYYY-MM-DD

### 🚀 Added
### 🔄 Changed
### ❌ Removed
### 🐞 Fixed
### 🔐 Security
```

### Emoji Prefixes (Required)

| Section  | Emoji            | Usage                                            |
| :------- | :--------------- | :----------------------------------------------- |
| Added    | `### 🚀 Added`    | New skills, new features, new automation         |
| Changed  | `### 🔄 Changed`  | Modifications to existing skills or config       |
| Removed  | `### ❌ Removed`  | Deleted skills or breaking removals (MAJOR only) |
| Fixed    | `### 🐞 Fixed`    | Bug fixes in scripts, CI, or skill logic         |
| Security | `### 🔐 Security` | Security patches or safe coding improvements     |

### Entry Format

```markdown
## [0.2.0] - 2026-03-14

### 🚀 Added

- `odoo-commit` skill for standardized commit workflow [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- `odoo-pr` skill with Odoo-specific PR template [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- `odoo-ci` skill for GitHub Actions release automation [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)

### 🐞 Fixed

- Escape backticks in Markdown validation CI script [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
```

**Rules:**
- Add new entries at the **bottom** of each section.
- One entry per logical change (can link multiple PRs).
- No period at the end of entries.
- Do NOT use redundant verbs — the section header already conveys the action.
- Link PRs using `[(#NNN)](https://github.com/Yven-Labs/odoo-skills/pull/NNN)`.

---

## Semantic Versioning Rules

| Change Type                         | Bump            | Example           |
| :---------------------------------- | :-------------- | :---------------- |
| Bug fixes, typos, small doc updates | PATCH (`0.0.Z`) | `0.2.0` → `0.2.1` |
| New skill or significant feature    | MINOR (`0.Y.0`) | `0.2.1` → `0.3.0` |
| Breaking architecture or rename     | MAJOR (`X.0.0`) | `0.x.x` → `1.0.0` |

> **Note:** `### ❌ Removed` entries MUST only appear in MAJOR version releases.

---

## Adding an Entry — Step by Step

1. **Check what changed:**
```bash
git diff main...HEAD --name-only
```

2. **Determine change type** (Added / Changed / Fixed / Security).

3. **Add entry at the bottom of the correct section** in `CHANGELOG.md`.

4. **Update `PRD.md` version** if the change requires a MINOR or MAJOR bump.

---

## Released Versions Are Immutable

**NEVER modify already-released versions.** Once `vX.Y.Z` is tagged, that section is frozen.

If a PR was created during a release cycle but merged after the tag:

```markdown
## [0.2.0] - 2026-03-14   ← RELEASED, DO NOT MODIFY

### 🚀 Added
- Entry that merged too late  ← WRONG

## [0.3.0] - UNRELEASED     ← Move the entry HERE
```

---

## Commands

```bash
# Check which PRs will be included
git log main...HEAD --oneline

# View the current unreleased section
head -40 CHANGELOG.md
```

---

## Metadata

- **Skill ID**: ODSK-SKL-CHANGELOG
- **Author**: [Geraldow](https://github.com/Geraldow)
- **Repo**: https://github.com/Yven-Labs/odoo-skills
