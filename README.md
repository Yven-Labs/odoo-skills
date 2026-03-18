<div align="center">

<pre>
    ███████        █████                       █████████  █████       ███  ████  ████ 
  ███░░░░░███     ░░███                       ███░░░░░███░░███       ░░░  ░░███ ░░███ 
 ███     ░░███  ███████   ██████   ██████    ░███    ░░░  ░███ █████ ████  ░███  ░███ 
░███      ░███ ███░░███  ███░░███ ███░░███   ░░█████████  ░███░░███ ░░███  ░███  ░███ 
░███      ░███░███ ░███ ░███ ░███░███ ░███    ░░░░░░░░███ ░██████░   ░███  ░███  ░███ 
░░███     ███ ░███ ░███ ░███ ░███░███ ░███    ███    ░███ ░███░░███  ░███  ░███  ░███ 
 ░░░███████░  ░░████████░░██████ ░░██████    ░░█████████  ████ █████ █████ █████ █████
   ░░░░░░░     ░░░░░░░░  ░░░░░░   ░░░░░░      ░░░░░░░░░  ░░░░ ░░░░░ ░░░░░ ░░░░░ ░░░░░ 
</pre>

<h1>Odoo Skills Ecosystem</h1>

<p><strong>Odoo v17 &amp; v18. Every module. Every AI assistant. One skill library.</strong></p>

<p>
  <a href="https://github.com/Yven-Labs/odoo-skills/releases">
    <img src="https://img.shields.io/github/v/release/Yven-Labs/odoo-skills?color=714B67&label=release&style=flat-square" alt="Release">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="License: MIT">
  </a>
  <img src="https://img.shields.io/badge/odoo-v17--v18-714B67?logo=odoo&logoColor=white&style=flat-square" alt="Odoo v17-v18">
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey?style=flat-square" alt="Platform">
</p>

<br />

</div>


---

## Table of Contents

- [Table of Contents](#table-of-contents)
- [What It Does](#what-it-does)
- [The Problem](#the-problem)
- [The Solution](#the-solution)
- [Deployment Options](#deployment-options)
  - [Option 1: Standalone (Manual)](#option-1-standalone-manual)
  - [Option 2: Automated Installation (Recommended) 🚀](#option-2-automated-installation-recommended-)
- [Supported AI Tools](#supported-ai-tools)
- [Supported Odoo Versions](#supported-odoo-versions)
- [Skill Library](#skill-library)
  - [Tier 1: Core](#tier-1-core)
  - [Tier 2: Essential](#tier-2-essential)
  - [Tier 3: Advanced](#tier-3-advanced)
- [How It Works](#how-it-works)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [License](#license)

---

## What It Does

This is an **AI Skills Ecosystem** for Odoo development. It takes any AI coding assistant (Claude Code, Gemini, Cursor, etc.) and injects it with deep knowledge of Odoo internals, version-specific breaking changes, and OCA best practices.

It makes your AI code like a **Senior Odoo Architect**, ensuring that the output is not just "valid Python", but **correct Odoo code** for your specific version.

---

## The Problem

AI assistants are trained on public data but lack the specialized "delta" knowledge between Odoo versions. They often:
- Use deprecated methods (e.g., `name_get` in v18).
- Use removed syntax (e.g., `attrs` in v17+ views).
- Miss security files (`ir.model.access.csv`).
- Ignore OCA naming and modularity conventions.

---

## The Solution

A structured library of **30+ Skill Files** (Markdown + Assets) that provide:
- **Version Awareness**: Automatic detection of target Odoo version via `__manifest__.py`.
- **Validation**: Strict RFC-style requirements (R-XXX) for every generated file.
- **Ready-to-use Templates**: Assets for v16, v17, v18, and v19.
- **Safety**: Security-first generation (blocking `sudo()`, enforcing ACLs).

---

## Deployment Options

### Option 1: Standalone (Manual)
Best if you only want the Odoo skills without any additional tools.

1. **Clone in your project root**:
   ```bash
   git clone https://github.com/Yven-Labs/odoo-skills.git .odoo-skills
   ```

2. **Run the setup script**:
   ```bash
   # Linux/macOS
   ./.odoo-skills/setup.sh --all

   # Windows (PowerShell)
   .\.odoo-skills\setup.ps1 -All
   ```

### Option 2: Automated Environment (Recommended) 🚀
For a more professional and efficient workflow, we recommend using the **[gentle-ai](https://github.com/Gentleman-Programming/gentle-ai)** community configurator. It automates the environment setup and configures your AI agents following the highest engineering standards, saving significant man-hours.

**macOS / Linux**:
```bash
curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh | bash
```

**Windows (PowerShell)**:
```powershell
irm https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.ps1 | iex
```
*After setting up your environment, follow **Option 1** to deploy the Odoo skills to your workspace.*

---

## Supported AI Tools

| Tool            | ID            | Support Level                     |
| --------------- | ------------- | --------------------------------- |
| Claude Code     | `claude-code` | ✅ Full (Skills + MCP)             |
| OpenCode        | `opencode`    | ✅ Full (Skills + Commands)        |
| Gemini CLI      | `gemini-cli`  | ✅ Full (Skills via system.md)     |
| Cursor          | `cursor`      | ✅ Good (.cursorrules integration) |
| VS Code Copilot | `vscode`      | ✅ Good (Workspace instructions)   |

---

## Supported Odoo Versions

| Version     | Python | Status                 |
| ----------- | ------ | ---------------------- |
| **Odoo 17** | 3.10+  | ✅ Supported (Priority) |
| **Odoo 18** | 3.10+  | ✅ Supported (Priority) |
| Odoo 16     | 3.7+   | 🚧 Planned (Phase 4)    |
| Odoo 19     | 3.11+  | 🚧 Planned (Phase 4)    |

---

## Skill Library

### Tier 1: Core
The foundation of Odoo development.
| Skill            | ID              | Description                             |
| ---------------- | --------------- | --------------------------------------- |
| Odoo Overview    | `odoo`          | Stack, components, and version matrix   |
| Module Structure | `odoo-module`   | `__manifest__.py`, directory standards  |
| ORM Mastery      | `odoo-orm`      | Models, Fields, CRUD (name_get vs v17+) |
| Smart Views      | `odoo-views`    | XML Views (handling attrs removal)      |
| Security-First   | `odoo-security` | ACLs, Rules, and Groups                 |
| Testing          | `odoo-testing`  | TransactionCase, HttpCase, and Tours    |

### Tier 2: Essential
80% of daily development tasks.
| Skill           | ID                 | Description                       |
| --------------- | ------------------ | --------------------------------- |
| Controllers     | `odoo-controllers` | Routing, Auth, JSON-RPC changes   |
| OWL Components  | `odoo-owl`         | OWL 2.0 (v17+) vs Legacy          |
| QWeb & PDF      | `odoo-qweb`        | Reports and Template rendering    |
| Data & XML      | `odoo-data`        | Master data and XML ID management |
| OCA Conventions | `odoo-oca`         | Strict OCA naming and formatting  |
| Wizards         | `odoo-wizards`     | TransientModels and multi-step UI |

### Tier 3: Advanced
Complex project requirements.
| Skill          | ID                 | Description                               |
| -------------- | ------------------ | ----------------------------------------- |
| Mail & Chatter | `odoo-mail`        | Activities, Channels, and Threads         |
| External API   | `odoo-api`         | REST (v18+), XML-RPC, JSON-RPC            |
| Cron Jobs      | `odoo-cron`        | Scheduling and background tasks           |
| Performance    | `odoo-performance` | N+1 avoidance, Prefetching, SQL           |
| Migration      | `odoo-migration`   | Version-to-version upgrade maps           |
| Assets & JS    | `odoo-assets`      | SCSS bundles and JS modules               |
| Inheritance    | `odoo-inherit`     | Deep dives into `_inherit` vs `_inherits` |

---

## How It Works

1. **Auto-Invocation**: The `AGENTS.md` router detects your actions (e.g., editing `models/*.py`).
2. **Context Loading**: The AI assistant loads the corresponding `SKILL.md`.
3. **Version Check**: The AI reads your `__manifest__.py` to identify the target Odoo version.
4. **Implementation**: The AI selects the correct snippet from `assets/v{N}/` and applies it.

---

## Architecture

```bash
odoo-skills/
├── .github/workflows/    # CI/CD (Validation & Release)
├── skills/               # The Skill Library
│   ├── odoo-orm/         # Tier 1 Skill Folder
│   │   ├── SKILL.md      # Logic & Patterns
│   │   ├── assets/       # Version-specific code
│   │   └── references/   # Deep-dives
│   └── ...               # 30+ Skills
├── AGENTS.md             # Master Router
├── setup.sh              # Unix Installer
├── setup.ps1             # Windows Installer
├── PRD.md                # Technical Blueprint
└── README.md             # This guide
```

---

## Contributing

1. Create a branch from `develop`: `git checkout -b feat/skill-name`.
2. Implement the skill following the `ODSK` ID system.
3. Run `sync.sh` to validate the library.
4. Create a PR to `develop`.
5. Merge to `main` for automatic release.

---

## License

MIT License — Copyright (c) 2026

---
