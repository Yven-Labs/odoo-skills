# Repository Guidelines

## 1. How to Use This Guide

This is the central routing and rules file for the Odoo AI Skills Ecosystem. It ensures your AI assistant (Claude Code, Gemini, Codex, etc.) follows Odoo best practices and your project's architecture.

- **Auto-invocation**: The table below instructs the AI which skill to load based on your actions.
- **Rules**: Generic code quality rules that apply to all files.
- **Verification**: All library files (`assets/`, `references/`) use the **Skill ID System (ODSK)**. The AI MUST verify the file's Skill ID before applying patterns to ensure Odoo version compatibility.

---

## 2. Available Skills

Use these skills for detailed patterns on-demand:

### Odoo Development Skills

| Skill           | Description                                     | URL                                       |
| --------------- | ----------------------------------------------- | ----------------------------------------- |
| `odoo-overview` | Stack overview, version matrix, component map   | [SKILL.md](skills/odoo-overview/SKILL.md) |
| `odoo-module`   | Module structure, `__manifest__.py`, data files | [SKILL.md](skills/odoo-module/SKILL.md)   |
| `odoo-orm`      | Models, fields, decorators, recordsets, CRUD    | [SKILL.md](skills/odoo-orm/SKILL.md)      |
| `odoo-views`    | Form, list, search, kanban views (v16/v17/v18)  | [SKILL.md](skills/odoo-views/SKILL.md)    |
| `odoo-security` | ir.model.access.csv, ir.rule, res.groups        | [SKILL.md](skills/odoo-security/SKILL.md) |
| `odoo-testing`  | TDD workflow: TransactionCase, HttpCase, @tagged | [SKILL.md](skills/odoo-testing/SKILL.md) |
| `odoo-oca`      | OCA conventions: naming, versioning, manifest   | [SKILL.md](skills/odoo-oca/SKILL.md)      |

### DevOps & Workflow Skills

| Skill            | Description                                  | URL                                        |
| ---------------- | -------------------------------------------- | ------------------------------------------ |
| `odoo-commit`    | Conventional commits for Odoo projects       | [SKILL.md](skills/odoo-commit/SKILL.md)    |
| `odoo-pr`        | Pull request template and conventions        | [SKILL.md](skills/odoo-pr/SKILL.md)        |
| `odoo-ci`        | CI checks, GitHub Actions, release pipelines | [SKILL.md](skills/odoo-ci/SKILL.md)        |
| `odoo-changelog` | CHANGELOG.md entries and format              | [SKILL.md](skills/odoo-changelog/SKILL.md) |

---

## 3. Universal Rules

REJECT if:
- Hardcoded secrets, tokens, API keys, or credentials.
- TODO/FIXME left without an associated issue reference.
- Files committed without a clear purpose (debug files, temp files).
- Multi-version patterns mixed (e.g., using `attrs` in Odoo 18).

---

## 4. Auto-invoke Skill Table (Master Router)

When performing these actions, ALWAYS invoke the corresponding skill FIRST:

| Action                                                | Skill              |
| ----------------------------------------------------- | ------------------ |
| Creating Odoo models or fields                        | `odoo-orm`         |
| Defining computed fields or constrains                | `odoo-orm`         |
| Using recordset operations                            | `odoo-orm`         |
| Creating XML form/tree/kanban views                   | `odoo-views`       |
| Inheriting or extending views                         | `odoo-views`       |
| Adding security groups or access rules                | `odoo-security`    |
| Creating `ir.model.access.csv`                        | `odoo-security`    |
| Defining `ir.rule` record rules                       | `odoo-security`    |
| Writing Python tests for Odoo                         | `odoo-testing`     |
| Creating HTTP controllers / routes                    | `odoo-controllers` |
| Creating OWL components (v17+)                        | `odoo-owl`         |
| Creating QWeb templates or PDF reports                | `odoo-qweb`        |
| Creating TransientModel wizards                       | `odoo-wizards`     |
| Adding mail.thread to model (Chatter)                 | `odoo-mail`        |
| Creating scheduled actions (cron)                     | `odoo-cron`        |
| Optimizing ORM performance / N+1                      | `odoo-performance` |
| Migrating module to new Odoo version                  | `odoo-migration`   |
| Creating `__manifest__.py`                            | `odoo-module`      |
| Creating new Odoo module from scratch                 | `odoo-module`      |
| Creating data/demo XML files                          | `odoo-data`        |
| Following OCA conventions                             | `odoo-oca`         |
| Setting up Docker for Odoo                            | `odoo-docker`      |
| Debugging with Odoo shell or logging                  | `odoo-debug`       |
| Committing changes in an Odoo project                 | `odoo-commit`      |
| Creating a pull request for an Odoo module or project | `odoo-pr`          |
| Debugging CI failures in `.github/workflows/`         | `odoo-ci`          |
| Working with release pipelines or version bumps       | `odoo-ci`          |
| Updating or adding entries to `CHANGELOG.md`          | `odoo-changelog`   |
| General Odoo architecture questions                   | `odoo-overview`    |
| Understanding v16→v17 changes                         | `odoo-overview`    |
| Understanding v17→v18 changes                         | `odoo-overview`    |

---

## 5. Odoo Code Review Standards

### 5.1 Backend (Python & Security)
- **ORM**: Use `Command` objects for x2many fields in Odoo 17+.
- **Security**: Every new model MUST have an entry in `ir.model.access.csv`.
- **Naming**: Follow OCA naming conventions (lowercase, underscore).

### 5.2 Frontend (OWL & XML)
- **Views**: For Odoo 17+, use inline Python expressions instead of the `attrs` attribute.
- **OWL**: Reactivity must use signals/hooks as per Odoo version requirements.
- **QWeb**: Use `t-out` instead of `t-raw` for v17+.

---

## 6. Agent Assignments

This section defines which AI agent owns each skill and their branch convention. Only `claude-code` may propose PRs that modify this section.

### Agent Roster

| Agent       | ID            | Role                   | Skill Category                          | Branch Pattern        |
| ----------- | ------------- | ---------------------- | --------------------------------------- | --------------------- |
| Claude Code | `claude-code` | Programming            | All programming & infrastructure skills | `agent/claude-code/*` |
| OpenCode    | `opencode`    | Programming            | All programming & infrastructure skills | `agent/opencode/*`    |
| Codex       | `codex`       | Programming            | All programming & infrastructure skills | `agent/codex/*`       |
| Gemini CLI  | `gemini-cli`  | Documentation & design | XML views, OWL, QWeb, Markdown guides   | `agent/gemini-cli/*`  |
| Geraldow    | `geraldow`    | Author & reviewer      | All frozen files, PRD, README           | `develop` (direct)    |

### Frozen Files

These files MUST NOT be modified without an explicit PR approved by Geraldow:

- `AGENTS.md` — PRs proposed by `claude-code` only
- `README.md` — `geraldow` only
- `PRD.md` — `geraldow` only
- `CHANGELOG.md` — `claude-code` via `odoo-changelog` skill
- `setup.sh`, `setup.ps1`, `sync.sh` — `geraldow` only
- `CONTRIBUTING.md` — `claude-code` only

See `CONTRIBUTING.md` for the full coordination workflow.

---

## 7. Project Overview

odoo-skills is an AI skill library for Odoo development — a curated collection of patterns, templates, and guardrails for AI assistants working on Odoo modules.

| Component    | Location          | Purpose                                      |
| ------------ | ----------------- | -------------------------------------------- |
| Skills       | `skills/`         | Skill definitions (SKILL.md + assets + refs) |
| Examples     | `examples/`       | Drop-in orchestration configs per AI tool    |
| Scripts      | `scripts/`        | setup.sh / setup.ps1 / sync.sh installers   |
| CI Workflows | `.github/workflows/` | PR validation + automated releases        |

**Supported Odoo Versions:** v16 · v17 · v18
**Python:** 3.7+ (v16) · 3.10+ (v17/v18)

---

## 8. Development Setup

```bash
# Install skills into your project (Linux/macOS)
bash <(curl -fsSL https://raw.githubusercontent.com/Yven-Labs/odoo-skills/main/scripts/setup.sh)

# Install skills into your project (Windows PowerShell)
irm https://raw.githubusercontent.com/Yven-Labs/odoo-skills/main/scripts/setup.ps1 | iex

# Sync skills after upstream updates
bash sync.sh
```

---

## 9. Commit & PR Guidelines

Follow conventional-commit style: `<type>[scope]: <description>`

**Types:** `feat`, `fix`, `docs`, `chore`, `perf`, `refactor`, `style`, `test`

**Branch workflow:**
1. Create feature branch from `develop`: `git checkout -b feat/<name>`
2. PR `feat/<name>` → `develop` (squash merge)
3. PR `develop` → `main` (squash merge, triggers release)

Before creating a PR:
1. Invoke `odoo-pr` skill for the PR template
2. Invoke `odoo-changelog` skill to add a CHANGELOG entry
3. Ensure all CI checks pass (`CI — Skill Library Validation`)
