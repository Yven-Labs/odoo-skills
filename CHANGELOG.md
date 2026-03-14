# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.2.0] - 2026-03-14

### 🚀 Added

- `odoo-commit` skill for standardized commit workflow with Odoo-specific scopes [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- `odoo-pr` skill with professional PR template and Odoo v17/v18 compatibility checklist [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- `odoo-ci` skill for GitHub Actions pipeline navigation and release automation [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- `odoo-changelog` skill based on keepachangelog.com conventions [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- Versioning Policy (Section 12) added to `PRD.md` [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)

### 🔄 Changed

- Realigned `odoo-skills` as fully standalone project independent from Gentleman Programming ecosystem [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- Simplified gentle-ai reference to a productivity recommendation in `README.md` and `PRD.md` [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- Redesigned `PRD.md` architecture diagrams (Section 8.1.1, 8.1.2) to remove hard Engram dependencies [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)

### 🐞 Fixed

- Escape backticks in Markdown validation script in `ci.yml` to prevent Bash EOF error [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- Removed stray empty code block in `PRD.md` Section 7.4 [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)

---

## [0.1.0] - 2026-03-13

### 🚀 Added

- Initial project infrastructure: `AGENTS.md`, `README.md`, `PRD.md` [(#1)](https://github.com/Yven-Labs/odoo-skills/pull/1)
- `setup.sh` and `setup.ps1` installers with strict error handling and CLI flags [(#1)](https://github.com/Yven-Labs/odoo-skills/pull/1)
- `sync.sh` for skill library synchronization validation [(#1)](https://github.com/Yven-Labs/odoo-skills/pull/1)
- GitHub Actions CI pipeline for skill library integrity validation [(#1)](https://github.com/Yven-Labs/odoo-skills/pull/1)
- GitHub Actions release pipeline using `PRD.md` version as source of truth [(#1)](https://github.com/Yven-Labs/odoo-skills/pull/1)
