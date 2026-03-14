# odoo-skills

> **Every Odoo version. Every module. Every AI assistant. One skill library.**
>
> by [Geraldow](https://github.com/Geraldow)

AI Skills Ecosystem for Odoo development — teaches any AI coding assistant (Claude Code, Gemini, Codex, Cursor, Copilot) to write correct, version-aware, convention-following Odoo code across **v16, v17, v18, and v19**.

---

## The Problem

AI assistants know Python. They **don't** know Odoo.

Without this library, your AI will:
- Use `name_get()` in Odoo 18 (deprecated since v17 — silently broken)
- Write `attrs="{'invisible': ...}"` in v17+ (removed — hard crash)
- Skip `ir.model.access.csv` entirely (no security = security hole)
- Ignore OCA conventions (wrong naming, missing license, invalid version format)
- Create monolithic modules instead of upgrade-safe, modular code

**Result**: Code that *looks* correct but fails the moment it hits your target version.

---

## The Solution

A structured library of AI skills — Markdown files that any AI assistant reads to understand:

- ✅ ORM patterns (models, fields, decorators, recordsets) — version-aware
- ✅ XML views (form, tree, kanban) — including v17's `attrs` removal
- ✅ Security (ACLs, record rules, groups) — with templates
- ✅ Testing (TransactionCase, tours) — correct patterns
- ✅ OWL components — v16 legacy vs v17+ OWL 2
- ✅ QWeb templates & PDF reports
- ✅ OCA conventions — naming, versioning, manifest
- ✅ And 20+ more skills covering the full Odoo development lifecycle

---

## Quick Start

```bash
# 1. Clone in your Odoo project
git clone https://github.com/Geraldow/odoo-skills.git .odoo-skills

# 2. Set up for your AI tool
./odoo-skills/setup.sh --gemini    # Gemini CLI
./odoo-skills/setup.sh --claude    # Claude Code
./odoo-skills/setup.sh --all       # All supported tools

# Windows
.\odoo-skills\setup.ps1 -All
```

That's it. Your AI assistant will now:
1. Detect the Odoo version from `__manifest__.py`
2. Load the correct skill
3. Apply version-specific patterns automatically

---

## Supported AI Tools

| Tool           | Support Level |
| -------------- | ------------- |
| Claude Code    | ✅ Full        |
| Gemini CLI     | ✅ Full        |
| Codex (OpenAI) | ✅ Full        |
| GitHub Copilot | ✅ Full        |
| Cursor         | ✅ Full        |

---

## Supported Odoo Versions

| Version | Status      | Python |
| ------- | ----------- | ------ |
| Odoo 16 | ✅ Supported | 3.8+   |
| Odoo 17 | ✅ Supported | 3.10+  |
| Odoo 18 | ✅ Supported | 3.10+  |
| Odoo 19 | ✅ Supported | 3.11+  |

---

## Skill Library

### Core Skills (Phase 1 — MVP)

| Skill                                    | What it teaches                                       |
| ---------------------------------------- | ----------------------------------------------------- |
| [`odoo`](skills/odoo/)                   | Overview: stack, versions, commands                   |
| [`odoo-module`](skills/odoo-module/)     | Module structure, `__manifest__.py`, data files       |
| [`odoo-orm`](skills/odoo-orm/)           | Models, fields, decorators, CRUD — all versions       |
| [`odoo-views`](skills/odoo-views/)       | Form, tree, kanban, search — v16 attrs vs v17+ inline |
| [`odoo-security`](skills/odoo-security/) | ACLs, record rules, groups — with templates           |
| [`odoo-testing`](skills/odoo-testing/)   | TransactionCase, HttpCase, tours                      |
| [`odoo-oca`](skills/odoo-oca/)           | OCA conventions: naming, versioning, manifest         |

See [PRD.md](PRD.md) for the complete skill roadmap (26 core + 6 optional skills).

---

## How It Works

Each skill contains:
1. **`SKILL.md`** — Core patterns (80% version-agnostic)
2. **`assets/v{N}/`** — Implementation templates for each Odoo version (UID: ODSK-ASSET-...)
3. **`references/`** — Deep-dive documentation and architectural decisions (UID: ODSK-REF-...)

The `AGENTS.md` routing system auto-invokes the right skill:

```markdown
| Action                         | Skill           |
| ------------------------------ | --------------- |
| Creating Odoo models or fields | `odoo-orm`      |
| Creating XML views             | `odoo-views`    |
| Adding security rules          | `odoo-security` |
...
```

After `setup.sh`, your AI reads `AGENTS.md` → detects action → loads skill → applies correct patterns for your version.

---

## SDD Integration

Works seamlessly with [Spec-Driven Development](https://github.com/Gentleman-Programming/agent-teams-lite):

```
/sdd-apply Task 2: Create support ticket model
→ AI detects models/*.py context
→ Auto-invokes odoo-orm
→ Reads __manifest__.py: v18
→ Applies v18 patterns (_compute_display_name, Command objects)
→ Writes correct Odoo 18 code
```

---

## License

MIT License — See [LICENSE](LICENSE) for details.

---

Made with care by [Geraldow](https://github.com/Geraldow).
