# Contributing to odoo-skills

> **Every Odoo version. Every module. Every AI assistant. One skill library.**
>
> Created by [Geraldow](https://github.com/Geraldow) — MIT License

This document is the **coordination contract** for all contributors — human and AI agents alike. Read it fully before starting any work.

---

## 1. Who Can Contribute

This repository is maintained collaboratively by:

| Contributor | Type | Role | GitHub / ID |
|-------------|------|------|-------------|
| **Geraldow** | Human author | Architecture & review | [@Geraldow](https://github.com/Geraldow) |
| **Claude Code** | AI agent (Anthropic) | Programming | `claude-code` |
| **OpenCode** | AI agent | Programming | `opencode` |
| **Codex** | AI agent (OpenAI) | Programming | `codex` |
| **Gemini CLI** | AI agent (Google) | Documentation & design | `gemini-cli` |

All contributors — human and AI — follow the same rules defined in this document.

---

## 2. Skill Ownership

Each skill is owned by one contributor. Only the owner may open PRs that modify files inside that skill's folder.

### Programming skills (Python / backend)

| Skill | Owner | Description |
|-------|-------|-------------|
| `odoo-commit` | `claude-code` | Git commit conventions |
| `odoo-pr` | `claude-code` | Pull Request workflow |
| `odoo-ci` | `claude-code` | CI/CD and GitHub Actions |
| `odoo-changelog` | `claude-code` | CHANGELOG management |
| `odoo-orm` | `claude-code` | Models, fields, ORM patterns |
| `odoo-module` | `claude-code` | Module structure and manifest |
| `odoo-controllers` | `opencode` | HTTP routes and JSON-RPC controllers |
| `odoo-testing` | `opencode` | Python tests for Odoo |
| `odoo-security` | `opencode` | Access rights and security rules |
| `odoo-debug` | `opencode` | Debugging tools and shell usage |
| `odoo-data` | `codex` | Data and demo XML files |
| `odoo-wizards` | `codex` | TransientModel wizards |
| `odoo-cron` | `codex` | Scheduled actions |
| `odoo-performance` | `codex` | ORM optimization and N+1 patterns |
| `odoo-migration` | `codex` | Module migration between Odoo versions |

### Documentation & design skills (.md, .mdx, XML views, diagrams)

| Skill | Owner | Description |
|-------|-------|-------------|
| `odoo-views` | `gemini-cli` | XML views (form, tree, kanban, search) |
| `odoo-owl` | `gemini-cli` | OWL components (v17+) |
| `odoo-qweb` | `gemini-cli` | QWeb templates and PDF reports |
| `odoo-v17-changes` | `gemini-cli` | v16→v17 migration guide |
| `odoo-v18-changes` | `gemini-cli` | v17→v18 migration guide |
| `odoo-docker` | `gemini-cli` | Docker setup for Odoo |
| `odoo-mail` | `gemini-cli` | mail.thread / Chatter integration |

> If you need a skill assigned to you, open an Issue with the label `skill-request`.

---

## 3. Branch Naming Convention

Every branch MUST follow this pattern:

```
agent/{agent-id}/{skill-name}
```

**Examples:**
```
agent/claude-code/odoo-orm
agent/opencode/odoo-security
agent/codex/odoo-migration
agent/gemini-cli/odoo-views
```

Rules:
- `{agent-id}` MUST be one of: `claude-code`, `opencode`, `codex`, `gemini-cli`, or `geraldow`
- `{skill-name}` MUST match the folder name under `skills/`
- **No direct push to `develop` or `main`** — all changes go through PR

---

## 4. Frozen Files

The following files are **frozen** — they can only be modified via PR explicitly approved by **Geraldow**:

| File | Who Can Propose PRs |
|------|---------------------|
| `AGENTS.md` | `claude-code` only |
| `README.md` | `geraldow` only |
| `PRD.md` | `geraldow` only |
| `CHANGELOG.md` | `claude-code` (via `odoo-changelog` skill) |
| `setup.sh` | `geraldow` only |
| `setup.ps1` | `geraldow` only |
| `sync.sh` | `geraldow` only |
| `CONTRIBUTING.md` | `claude-code` only |

If you need to modify a frozen file:
1. Open a GitHub Issue with label `frozen-file`
2. Tag the responsible contributor in the Issue
3. Do NOT edit the file yourself

---

## 5. Workflow: Issue → Branch → PR → Merge

Every change follows this exact flow:

### Step 1: Issue
- A GitHub Issue MUST exist before any work starts
- The Issue MUST be assigned to the agent/contributor doing the work
- The Issue title SHOULD describe the skill or change clearly

### Step 2: Branch
```bash
git checkout develop
git pull origin develop
git checkout -b agent/{your-id}/{skill-name}
```

### Step 3: Implement
- Follow `AGENTS.md` routing rules and universal code standards
- Every new `SKILL.md` MUST include:
  - A unique `Skill ID` (format: `ODSK-{CATEGORY}-{NAME}`)
  - The `owner` field in its `metadata:` block
  - Language identifiers on all Markdown code blocks

### Step 4: Validate locally
```bash
bash sync.sh
```

### Step 5: Commit
Follow the `odoo-commit` skill conventions (conventional commits format).

### Step 6: Pull Request
- PR title MUST follow conventional commits format
- PR body MUST reference the Issue: `Closes #N` or `Refs #N`
- PR MUST target `develop` (never `main` directly)
- Follow the `odoo-pr` skill for the full PR template

### Step 7: Review & Merge
- Geraldow reviews and approves
- CI must be green before merge
- Geraldow performs the merge

---

## 6. Adding a New Skill — Checklist

Before opening a PR for a new skill, verify:

- [ ] GitHub Issue exists and is assigned to you
- [ ] Branch follows `agent/{your-id}/{skill-name}` pattern
- [ ] `skills/{skill-name}/SKILL.md` exists
- [ ] `SKILL.md` has a unique `Skill ID` (`ODSK-*`)
- [ ] `SKILL.md` `metadata.owner` matches your agent ID
- [ ] All Markdown code blocks have a language identifier
- [ ] `bash sync.sh` passes locally
- [ ] Skill is referenced in `AGENTS.md` (open a `frozen-file` Issue for `claude-code` to handle this)
- [ ] PR title follows conventional commits
- [ ] PR body references the Issue

---

## 7. Code of Conduct

- Respect ownership boundaries — do not modify another agent's skill files
- Keep PRs focused — one skill per PR
- If you discover a bug in another agent's skill, open an Issue rather than fixing it directly
- All contributions are released under the MIT License

---

## Metadata

- **Maintained by**: [Geraldow](https://github.com/Geraldow) & Claude Code
- **Repository**: [https://github.com/Yven-Labs/odoo-skills](https://github.com/Yven-Labs/odoo-skills)
- **License**: MIT
