---
name: odoo-pr
description: >
  Standardizes Pull Request creation for odoo-skills following professional Odoo and Gentleman conventions.
  Trigger: When creating pull requests, finalizing features, or configuring GH workflows.
license: MIT
metadata:
  author: Geraldow
  version: "1.0.0"
  scope: [root]
  auto_invoke:
    - "Create a PR with gh pr create"
    - "Review PR requirements"
    - "Filling Odoo-specific PR templates"
---

## 1. PR Creation Process

1. **Change Analysis**: Compare current branch with `main` or `develop`.
2. **Version Validation**: Ensure the version in `PRD.md` matches the intended release.
3. **Template Filling**: Use the structured Odoo PR template below.
4. **Execution**: Use `gh pr create` with the generated body.

---

## 2. Odoo PR Template

```markdown
### Context

{Why this change? Link Odoo issues or architectural decisions. Example: Fixes #OD-42 or Realigns v18 ORM patterns.}

### Description

{Summary of tech changes. Mention versions affected: v17, v18 or both.}

- **Skill Impact**: {Which skills were added/updated}
- **Architecture**: {Any changes to AGENTS.md or core routing}
- **Installer**: {Does it affect setup.sh or setup.ps1?}

### Odoo Version Compatibility

- [ ] Compatible with Odoo v17
- [ ] Compatible with Odoo v18
- [ ] Includes version-specific assets (v17/v18)

### Checklist

- [ ] **ODSK-UID**: All new files have unique IDs and have been verified with `sync.sh`.
- [ ] **Linter**: All Markdown blocks have language identifiers.
- [ ] **Documentation**: Updated `PRD.md` and `README.md` if necessary.
- [ ] **Version Bump**: PRD.md version increased (if applicable).
- [ ] **Standalone**: Verified that the change works in Standalone mode (Path A).

### License

By submitting this pull request, I confirm that my contribution is made under the terms of the Apache 2.0 license.
```

---

## 3. Commands

```bash
# Preview the diff before PR
git diff main...HEAD --stat

# Create PR with the Odoo-Skills template
gh pr create --title "feat: description" --body "$(cat <<'EOF'
### Context
...
EOF
)"
```

---

## 4. Metadata
- **ODSK-UID**: ODSK-SKL-PR
- **Author**: [Geraldow](https://github.com/Geraldow)
- **Repo**: https://github.com/Yven-Labs/odoo-skills
