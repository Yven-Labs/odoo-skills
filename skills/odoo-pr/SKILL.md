---
name: odoo-pr
description: >
  Creates Pull Requests for odoo-skills following the project template and conventions.
  Trigger: When creating PRs, reviewing PR requirements, checking PR title conventions, or inspecting .github/workflows.
license: MIT
metadata:
  author: Geraldow
  version: "1.1.0"
  scope: [root]
  auto_invoke:
    - "Create a PR with gh pr create"
    - "Review PR requirements and template"
    - "Fill .github/pull_request_template.md sections"
    - "Inspect PR CI workflows (.github/workflows/*)"
---

## PR Creation Process

1. **Analyze changes**: `git diff main...HEAD` to understand ALL commits.
2. **Determine affected components**: Skills, Installer, CI, Docs.
3. **Fill template sections** based on changes.
4. **Create PR** with `gh pr create`.

---

## PR Template Structure

```markdown
### Context

{Why this change? Describe the business or technical reason. Link issues with `Fix #XXXX` if applicable.}

### Description

{Summary of changes. Mention which Odoo module and versions are affected (v17, v18 or both).}

- **Module**: {Module name, e.g. `sale_custom`}
- **Odoo Version**: {v17 / v18 / both}
- **Breaking Change**: {Yes/No — does this modify existing behavior?}

### Odoo Version Compatibility

- [ ] Tested on Odoo v17
- [ ] Tested on Odoo v18
- [ ] N/A — Not version-sensitive

### Steps to Review

{How to test/verify the changes. Example: Install module X, go to Sales > Orders, create a record...}

### Checklist

- [ ] All new models have an entry in `ir.model.access.csv`.
- [ ] No deprecated API used (`name_get()`, `attrs`, `type="json"`), verified against target Odoo version.
- [ ] Tests added or updated for changed behavior.
- [ ] OCA naming conventions followed.
- [ ] `README.md` updated if this module is user-facing.

### License

By submitting this pull request, I confirm that my contribution is made under the terms of the applicable module license (LGPL-3 or AGPL-3).
```

---

## Component-Specific Rules

| Component | Extra Checks |
| :--- | :--- |
| `models/*.py` | Security rules added? Deprecated API avoided? |
| `views/*.xml` | `attrs` removed? `t-raw` replaced by `t-out`? |
| `security/*.csv` | Every new model covered? |
| `tests/test_*.py` | `TransactionCase` or `HttpCase` used correctly? |
| `__manifest__.py` | Version format `X.Y.A.B.C`? `license` field set? |

---

## Commands

```bash
# Check what commits will be included in the PR
git log main..HEAD --oneline

# View full diff
git diff main...HEAD

# Create PR with heredoc body (recommended for multi-line)
gh pr create --title "feat: description" --body "$(cat <<'EOF'
### Context
...
EOF
)"

# Create draft PR to iterate
gh pr create --draft --title "feat: description"
```

---

## Title Conventions

Follow conventional commits:
- `feat:` — New skill or major feature
- `fix:` — Bug fix in skill, script, or CI
- `docs:` — Documentation update
- `chore:` — Maintenance, version bumps
- `refactor:` — Code restructure, no behavior change
- `style:` — Formatting only

---

## Before Creating PR

1. ✅ All CI checks pass (or are understood).
2. ✅ ODSK-UIDs are unique across the library.
3. ✅ Markdown code blocks have language identifiers.
4. ✅ Branch is up to date with `develop`.
5. ✅ Commits are clean and follow Conventional Commits.
6. ✅ Version in `PRD.md` is updated if needed.

---

## Metadata

- **ODSK-UID**: ODSK-SKL-PR
- **Author**: [Geraldow](https://github.com/Geraldow)
- **Repo**: https://github.com/Yven-Labs/odoo-skills
