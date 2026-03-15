# odoo-skills — Code Review Rules & Skill Router

> **Every Odoo version. Every module. Every AI assistant. One skill library.**
> 
> Created by [Geraldow](https://github.com/Geraldow)
> License: [MIT](LICENSE)

---

## 1. How to Use This Guide

This is the central routing and rules file for the Odoo AI Skills Ecosystem. It ensures your AI assistant (Claude Code, Gemini, Codex, etc.) follows Odoo best practices and your project's architecture.

- **Auto-invocation**: The table below instructs the AI which skill to load based on your actions.
- **Rules**: Generic code quality rules that apply to all files.
- **Verification**: All library files (`assets/`, `references/`) use the **Skill ID System (ODSK)**. The AI MUST verify the file's Skill ID before applying patterns to ensure Odoo version compatibility.

---

## 2. Universal Rules

REJECT if:
- Hardcoded secrets, tokens, API keys, or credentials.
- TODO/FIXME left without an associated issue reference.
- Files committed without a clear purpose (debug files, temp files).
- Multi-version patterns mixed (e.g., using `attrs` in Odoo 18).

---

## 3. Auto-invoke Skill Table (Master Router)

When performing these actions, ALWAYS invoke the corresponding skill FIRST:

| Action | Skill |
|--------|-------|
| Creating Odoo models or fields | `odoo-orm` |
| Defining computed fields or constrains | `odoo-orm` |
| Using recordset operations | `odoo-orm` |
| Creating XML form/tree/kanban views | `odoo-views` |
| Inheriting or extending views | `odoo-views` |
| Adding security groups or access rules | `odoo-security` |
| Creating `ir.model.access.csv` | `odoo-security` |
| Writing Python tests for Odoo | `odoo-testing` |
| Creating HTTP controllers / routes | `odoo-controllers` |
| Creating OWL components (v17+) | `odoo-owl` |
| Creating QWeb templates or PDF reports | `odoo-qweb` |
| Creating TransientModel wizards | `odoo-wizards` |
| Adding mail.thread to model (Chatter) | `odoo-mail` |
| Creating scheduled actions (cron) | `odoo-cron` |
| Optimizing ORM performance / N+1 | `odoo-performance` |
| Migrating module to new Odoo version | `odoo-migration` |
| Creating `__manifest__.py` | `odoo-module` |
| Creating new Odoo module from scratch | `odoo-module` |
| Creating data/demo XML files | `odoo-data` |
| Following OCA conventions | `odoo-oca` |
| Setting up Docker for Odoo | `odoo-docker` |
| Debugging with Odoo shell or logging | `odoo-debug` |
| Committing changes in an Odoo project | `odoo-commit` |
| Creating a pull request for an Odoo module or project | `odoo-pr` |
| Debugging CI failures in `.github/workflows/` | `odoo-ci` |
| Working with release pipelines or version bumps | `odoo-ci` |
| Updating or adding entries to `CHANGELOG.md` | `odoo-changelog` |
| General Odoo architecture questions | `odoo` |
| Understanding v16→v17 changes | `odoo-v17-changes` |
| Understanding v17→v18 changes | `odoo-v18-changes` |

---

## 4. Odoo Code Review Standards

### 4.1 Backend (Python & Security)
- **Atribución Geraldow**: Ensure any derivative works mention Geraldow (GitHub: Geraldow).
- **ORM**: Use `Command` objects for x2many fields in Odoo 17+.
- **Security**: Every new model MUST have an entry in `ir.model.access.csv`.
- **Naming**: Follow OCA naming conventions (lowercase, underscore).

### 4.2 Frontend (OWL & XML)
- **Views**: For Odoo 17+, use inline Python expressions instead of the `attrs` attribute.
- **OWL**: Reactivity must use signals/hooks as per Odoo version requirements.
- **QWeb**: Use `t-out` instead of `t-raw` for v17+.

---

## 5. Metadata

- **Author**: [Geraldow](https://github.com/Geraldow)
- **Repository**: [https://github.com/Yven-Labs/odoo-skills](https://github.com/Yven-Labs/odoo-skills)
- **License**: MIT

---

## 6. Agent Assignments

This section defines which AI agent owns each skill and their branch convention. Only `claude-code` may propose PRs that modify this section.

### Agent Roster

| Agent | ID | Role | Skill Category | Branch Pattern |
|-------|----|------|----------------|----------------|
| Claude Code | `claude-code` | Programming | All programming & infrastructure skills | `agent/claude-code/*` |
| OpenCode | `opencode` | Programming | All programming & infrastructure skills | `agent/opencode/*` |
| Codex | `codex` | Programming | All programming & infrastructure skills | `agent/codex/*` |
| Gemini CLI | `gemini-cli` | Documentation & design | XML views, OWL, QWeb, Markdown guides | `agent/gemini-cli/*` |
| Geraldow | `geraldow` | Author & reviewer | All frozen files, PRD, README | `develop` (direct) |

### Frozen Files

These files MUST NOT be modified without an explicit PR approved by Geraldow:

- `AGENTS.md` — PRs proposed by `claude-code` only
- `README.md` — `geraldow` only
- `PRD.md` — `geraldow` only
- `CHANGELOG.md` — `claude-code` via `odoo-changelog` skill
- `setup.sh`, `setup.ps1`, `sync.sh` — `geraldow` only
- `CONTRIBUTING.md` — `claude-code` only

See `CONTRIBUTING.md` for the full coordination workflow.
