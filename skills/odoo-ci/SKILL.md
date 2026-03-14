---
name: odoo-ci
description: >
  Manages GitHub Actions CI workflows for odoo-skills including release automation and PR gates.
  Trigger: When investigating failing CI jobs, editing .github/workflows/, or working with release logic.
license: MIT
metadata:
  author: Geraldow
  version: "1.0.0"
  scope: [root]
  auto_invoke:
    - "Inspect or debug a GitHub Actions job failing on a PR"
    - "Edit or understand .github/workflows/"
    - "Work with release.yml or ci.yml"
    - "Understand how version bumps trigger a GitHub Release"
---

## What This Skill Covers

Use this skill whenever you are:

- Reading or changing GitHub Actions workflows under `.github/workflows/`
- Debugging why a CI job is failing (Validate Skill Library Integrity)
- Understanding how the release pipeline reads the version from `PRD.md`
- Triggering an automated GitHub Release through a version bump

---

## Quick Map (Where to Look)

| Thing to Understand | File |
| :--- | :--- |
| Skill library integrity checks | `.github/workflows/ci.yml` |
| Automated release creation | `.github/workflows/release.yml` |
| Version source of truth | `PRD.md` (line: `**Version**: X.Y.Z`) |

---

## CI Validation Pipeline (`ci.yml`)

Runs on every **push to `develop`** and every **PR to `main` or `develop`**.

### Steps & What They Check

| Step | What It Validates | Common Failure Reason |
| :--- | :--- | :--- |
| Check skill dirs in AGENTS.md | Every `skills/*/` name must appear in `AGENTS.md` | New skill added but not registered |
| Check every skill has SKILL.md | Every `skills/*/` must have a `SKILL.md` file | Folder created without the required file |
| Check for duplicate ODSK IDs | `ODSK-...` UIDs must be unique across all skills | Copy-paste without updating the UID |
| Check Markdown code blocks | No ` ``` ` without a language identifier | Code block opened without `python`, `bash`, etc. |

### Debug Checklist

1. Find the failing step in GitHub Actions UI.
2. Read the exact error message (file name and line number are shown).
3. Check path filters — is the workflow supposed to run for your changed files?
4. Common quick fixes:
   - **AGENTS.md missing entry**: Add `skills/your-skill/` to the router table.
   - **Missing SKILL.md**: Create `skills/your-skill/SKILL.md`.
   - **Duplicate ODSK-UID**: Change the UID in the new file.
   - **Code block no language**: Change ` ``` ` to ` ```bash ` or ` ```python `.

---

## Release Pipeline (`release.yml`)

Runs only on **push to `main`** (i.e., after a PR is merged).

### How the Automated Release Works

```
PR merged to main
       ↓
release.yml reads **Version**: X.Y.Z from PRD.md
       ↓
Checks if tag vX.Y.Z already exists
       ↓
If new → packages skills/ + AGENTS.md + README.md into .zip
       ↓
Creates GitHub Release with tag vX.Y.Z and auto-generated notes
```

### Version Bump Strategy (SemVer)

The version in `PRD.md` MUST be updated manually (or by the AI using `odoo-commit`) before merging to `main`:

| Commit Type in PR | Required Bump | Example |
| :--- | :--- | :--- |
| `feat:` | **MINOR** → `0.Y.0` | `0.1.0` → `0.2.0` |
| `fix:` / `docs:` / `chore:` | **PATCH** → `0.0.Z` | `0.2.0` → `0.2.1` |
| Breaking architecture change | **MAJOR** → `X.0.0` | `0.x.x` → `1.0.0` |

> **Rule**: If the version in `PRD.md` is the same as the last tag, the release step is **skipped automatically** (no error). This prevents duplicate releases.

---

## Fixing a Failing Release

```bash
# 1. Check what the last tag was
git tag --sort=-version:refname | head -5

# 2. Check what version is currently in PRD.md
grep -m1 "^\*\*Version\*\*:" PRD.md

# 3. Update PRD.md to a new version if needed
# (Edit manually or ask the AI with odoo-commit context)

# 4. Push to develop, then merge to main
git add PRD.md
git commit -m "chore(docs): bump version to 0.2.1"
git push origin develop
```

---

## Key Rules

- NEVER manually create git tags — the release pipeline handles this.
- NEVER modify already-released versions in `CHANGELOG.md` once tagged.
- ALWAYS bump the version in `PRD.md` before merging a `feat:` PR to `main`.
- Use `no-changelog` label equivalents (skip release step) by NOT changing the version.

---

## Metadata

- **ODSK-UID**: ODSK-SKL-CI
- **Author**: [Geraldow](https://github.com/Geraldow)
- **Repo**: https://github.com/Yven-Labs/odoo-skills
