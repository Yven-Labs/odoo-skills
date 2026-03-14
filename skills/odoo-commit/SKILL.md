---
name: odoo-commit
description: >
  Creates professional git commits for the odoo-skills project following conventional-commits.
  Trigger: When creating commits, after completing changes, or when asked to commit.
license: MIT
metadata:
  author: Geraldow
  version: "1.0.0"
  scope: [root, core, skills, installer, docs, ci]
  auto_invoke:
    - "Creating a git commit"
    - "Committing changes"
---

## 1. Universal Rules

- **Conventional Format**: ALWAYS use `type(scope): description`.
- **Length**: Keep the first line under 72 characters.
- **Verification**: ALWAYS check for ODSK UID uniqueness before committing new assets.
- **Draft Status**: Commit messages MUST reflect the functional impact, not the file names.
- **Proactiveness**: NEVER commit without explicit user confirmation of the proposed message.

## 2. Type & Scope Matrix

### Types
| Type | Use When |
| :--- | :--- |
| `feat` | Adding a new skill or major automation feature. |
| `fix` | Correcting a technical error in a skill, template, or script. |
| `docs` | Updating PRD.md, README.md, or reference files. |
| `chore` | Maintenance, version bumps, or CI updates. |
| `refactor` | Restructuring skill files without changing functionality. |
| `style` | Formatting changes (linting Markdown). |

### Scopes
| Scope | Target Area |
| :--- | :--- |
| `core` | AGENTS.md, CLAUDE.md, and root configuration. |
| `skills` | Any change inside the `skills/` directory. |
| `installer` | `setup.sh` or `setup.ps1` changes. |
| `docs` | PRD.md or README.md focus. |
| `ci` | Changes in `.github/workflows/`. |
| *omit* | Changes affecting multiple scopes or global refactors. |

---

## 3. Intelligent Versioning (Smart-Bump)

Before proposing a commit, analyze the impact on the project's lifecycle:

1. **PATCH (0.x.Z)**: Any `fix`, `style`, or small `docs` change. 
   - *Example*: Fixing a typo in `odoo-orm`.
2. **MINOR (0.Y.0)**: Any `feat` or significant `refactor`.
   - *Example*: Adding the `odoo-accounting` skill.
3. **MAJOR (X.0.0)**: Groundbreaking architecture changes or full v1.0.0 release.

**Action**: If a bump is required, advise the user: *"Estimado, he detectado que este cambio requiere un aumento de versión a X.Y.Z en el PRD.md. ¿Procedo a actualizarlo antes del commit?"*.

---

## 4. Workflow

1. **Analyze Diff**: Run `git diff --cached` (or current changes) to understand the scope.
2. **Verify Integrity**: Ensure all new `.md` files have their ODSK-UID and language identifiers.
3. **Draft Message**: Create a concise title and a bulleted body for complex changes.
4. **Suggest Bump**: Check if `PRD.md` needs a version update based on the changes.
5. **Confirm**: Show the final message and the list of files to the user for approval.

### Commit Example
```
feat(skills): add odoo-commit for automated versioning logic

- Implement intelligent versioning check (Smart-Bump)
- Define Odoo-specific scopes (installer, core, skills)
- Add ODSK-UID verification rules before commit
```

---

## 5. Metadata
- **ODSK-UID**: ODSK-SKL-COMMIT
- **Author**: [Geraldow](https://github.com/Geraldow)
- **Repo**: https://github.com/Yven-Labs/odoo-skills
