---
name: odoo-commit
description: >
  Creates professional git commits for Odoo projects following conventional-commits format.
  Trigger: When committing changes in an Odoo module, project, or related configuration.
license: MIT
metadata:
  author: Geraldow
  owner: claude-code
  version: "1.1.0"
  scope: [root, core, skills, installer, docs, ci]
  auto_invoke:
    - "Creating a git commit"
    - "Committing changes to the skill library"
---

## Critical Rules

- ALWAYS use conventional-commits format: `type(scope): description`
- ALWAYS keep the first line under 72 characters
- ALWAYS ask for user confirmation before committing
- NEVER be overly specific (avoid counts like "6 files", "3 rules")
- NEVER include implementation details in the title
- NEVER use `git push --force` or `git push -f`
- NEVER proactively offer to commit — wait for user to explicitly request it

---

## Commit Format

```text
type(scope): concise description

- Key change 1
- Key change 2
- Key change 3
```

### Types

| Type       | Use When                                            |
| :--------- | :-------------------------------------------------- |
| `feat`     | New skill added or major new functionality          |
| `fix`      | Correcting a technical error in a skill or script   |
| `docs`     | Changes to PRD.md, README.md, or reference files    |
| `chore`    | Version bumps, CI maintenance, metadata updates     |
| `refactor` | Restructuring skill files without changing behavior |
| `style`    | Markdown formatting fixes, no content change        |

### Scopes

| Scope         | Target Area                                            |
| :------------ | :----------------------------------------------------- |
| `module`      | Changes to `__manifest__.py` or module-level structure |
| `orm`         | Models, fields, computed fields, constraints           |
| `views`       | XML views (form, tree, kanban, search)                 |
| `security`    | `ir.model.access.csv`, `ir.rule`, groups               |
| `tests`       | Python test files (`test_*.py`)                        |
| `controllers` | HTTP routes and JSON-RPC controllers                   |
| `owl`         | OWL components and frontend logic                      |
| `data`        | Data/demo XML files                                    |
| `ci`          | `.github/workflows/` changes                           |
| `docs`        | Documentation-only changes                             |
| *omit*        | Changes affecting multiple scopes                      |

---

## Good vs Bad Examples

### Title Line

```text
# GOOD — Concise and clear
feat(orm): add sale order line computed field for margin
fix(views): correct invisible condition in invoice form (v17+)
chore(security): add ir.model.access for res.partner extension
docs: update module readme with installation steps

# BAD — Too specific or verbose
feat(orm): add computed field for margin on sale.order.line with @api.depends on price_unit
fix(views): fix line 45 in sale_order_form.xml where invisible was using deprecated attrs
```

### Body Bullets

```text
# GOOD — High-level changes
- Add version-aware routing for v17 and v18
- Define Odoo-specific scopes for commit strategy
- Include Skill ID verification rules

# BAD — Too granular
- Add routing logic on line 45 for v17.0.x manifest patterns
- Update 3 lines in setup.sh to fix the if-block on line 23
```

---

## Workflow

1. **Check status**:
```bash
git status
git diff --stat HEAD
git log -3 --oneline
```

2. **Draft message**: Choose type and scope, write concise title, add 2–5 bullets.

3. **Present to user**: Show files to be committed, the proposed message, and wait for explicit confirmation.

4. **Execute**:
```bash
git add <files>
git commit -m "$(cat <<'EOF'
type(scope): description

- Change 1
- Change 2
EOF
)"
```

---

## Decision Tree

```text
Single file changed?
├─ Yes → Title only (omit body)
└─ No  → Include body bullets

Multiple scopes affected?
├─ Yes → Omit scope: `feat: description`
└─ No  → Include scope: `feat(orm): description`

Fixing a bug?
├─ User-facing error → fix(scope): description
└─ Internal issue   → chore(scope): fix description

Adding documentation?
├─ Code comments only → Part of the feat or fix
└─ Standalone docs   → docs: or docs(scope):
```

---

## ODSK Integrity Check (Only When Contributing to odoo-skills)

If you are contributing to the `odoo-skills` library itself:
1. Verify every new `SKILL.md` has a `Skill ID` in its metadata.
2. Verify all Markdown code blocks have a language identifier.
3. Run `sync.sh` (when available) to validate UID uniqueness.

For standard Odoo project commits (models, views, security, etc.), this check does NOT apply.

---

## Metadata

- **Skill ID**: ODSK-SKL-COMMIT
- **Author**: [Geraldow](https://github.com/Geraldow)
- **Repo**: https://github.com/Yven-Labs/odoo-skills
