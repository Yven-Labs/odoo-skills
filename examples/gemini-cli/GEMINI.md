# Odoo Skills Ecosystem — Gemini CLI

Add the section below to your `~/.gemini/GEMINI.md`.

---

<!-- BEGIN:odoo-skills -->
## Odoo Skills Ecosystem

This project uses the [odoo-skills](https://github.com/Geraldow/odoo-skills) library for AI-assisted Odoo development (v17/v18).

### How It Works

The master router `AGENTS.md` tells you which skill to load for each task. Skills are installed in `~/.gemini/skills/` and loaded automatically based on context.

### Auto-invoke Rules

When working on Odoo code, ALWAYS check the `AGENTS.md` auto-invoke table before writing code. Key mappings:

| Context | Skill |
|---------|-------|
| Models, fields, ORM | `odoo-orm` |
| XML views | `odoo-views` |
| Security rules | `odoo-security` |
| Module structure | `odoo-module` |
| OCA conventions | `odoo-oca` |
| General architecture | `odoo-overview` |

### Version Policy

- Supported: Odoo **17** and **18** only
- Default: Odoo **18** unless project specifies otherwise
- Detect version from `__manifest__.py` → first segment of `version` field
<!-- END:odoo-skills -->
