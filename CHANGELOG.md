# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.15.0] - 2026-03-20

### 🚀 Added

- add odoo-security skill for v16/v17/v18 (#47)

---

## [0.14.1] - 2026-03-20

### 🐞 Fixed

- use pull_request closed event to fix squash merge trigger (#45)

---

## [0.14.0] - 2026-03-20

### 🚀 Added

- add Odoo Architect persona to all agent examples (#41)

### 🐞 Fixed

- add workflow_dispatch and sync develop (#43)
- prevent release workflow re-trigger loop (#39)

---

## [0.13.0] - 2026-03-19

### 🔄 Changed

- update README to include v16 support (#37)

---

## [0.12.0] - 2026-03-18

### 🚀 Added

- add odoo-views skill with form, list, search, and kanban views

### 🔄 Changed

- extend version compatibility coverage to v16 across skills

---

## [0.11.0] - 2026-03-18

### 🚀 Added

- expand examples into complete drop-in orchestrator files

### 🔄 Changed

- fix tagline, remove double separator and footer

---

## [0.10.1] - 2026-03-17

### 🔄 Changed

- improve odoo-commit skill with clearer types and workflow steps

---

## [0.10.0] - 2026-03-17

### 🚀 Added

- add unified installer with agent auto-detection

---

## [0.9.0] - 2026-03-17

### 🚀 Added

- add odoo-overview skill — stack overview and version matrix

### 🔄 Changed

- rename odoo skill to odoo-overview in Tier 1 table
- restructure AGENTS.md — add Available Skills table

---

## [0.8.0] - 2026-03-17

### 🚀 Added

- add odoo-oca skill — OCA naming conventions and guidelines

### 🐞 Fixed

- correct broken OCA Coding Guidelines URL
- add missing language identifiers to code blocks

---

## [0.7.4] - 2026-03-16

### 🐞 Fixed

- correct AGENTS.md reference check in sync.sh

---

## [0.7.3] - 2026-03-15

### 🐞 Fixed

- use # Changelog anchor for insert position and restore CHANGELOG

---

## [0.7.2] - 2026-03-15

### 🐞 Fixed

- Add `--no-merges` flag to `git log` in `release.yml` to prevent duplicate CHANGELOG entries from merge commits [(#22)](https://github.com/Yven-Labs/odoo-skills/pull/22)
- Fix CHANGELOG insert position to use `# Changelog` header as anchor instead of first `---` separator [(#22)](https://github.com/Yven-Labs/odoo-skills/pull/22)

---

## [0.7.1] - 2026-03-15

### 🐞 Fixed

- CI release pipeline now auto-updates `CHANGELOG.md` on every release using conventional commit categorization [(#20)](https://github.com/Yven-Labs/odoo-skills/pull/20)

---

## [0.7.0] - 2026-03-15

### 🚀 Added

- Many2many field examples added to `model-template.py` and `computed-field-template.py` with explicit `relation`, `column1`, `column2` params [(#18)](https://github.com/Yven-Labs/odoo-skills/pull/18)

### 🔄 Changed

- `odoo-orm` skill assets and references restricted to v17/v18 only — all v16 references removed [(#18)](https://github.com/Yven-Labs/odoo-skills/pull/18)

---

## [0.6.0] - 2026-03-15

### 🚀 Added

- \`odoo-orm\` skill: multi-version detection from \`__manifest__.py\` with \`[v17+]\` tags on Critical Rules [(#16)](https://github.com/Yven-Labs/odoo-skills/pull/16)
- \`supported_versions\`, \`default_version\`, and \`detect_from\` metadata fields in \`odoo-orm\` SKILL.md [(#16)](https://github.com/Yven-Labs/odoo-skills/pull/16)
- \`Version Detection\` section in \`odoo-orm\` SKILL.md with agent instructions for parsing Odoo version [(#16)](https://github.com/Yven-Labs/odoo-skills/pull/16)

---

## [0.5.1] - 2026-03-15

### 🔄 Changed

- \`odoo-orm\` skill assets and references restructured with 2-line headers, ALL CAPS section separators, and GOOD/BAD contrast patterns [(#14)](https://github.com/Yven-Labs/odoo-skills/pull/14)

---

## [0.5.0] - 2026-03-14

### 🚀 Added

- \`odoo-orm\` skill with model template, computed field patterns, x2many Command API examples, field-types reference, and version-differences reference [(#11)](https://github.com/Yven-Labs/odoo-skills/pull/11)
- \`odoo-module\` skill for \`__manifest__.py\` scaffolding and module structure conventions [(#12)](https://github.com/Yven-Labs/odoo-skills/pull/12)

---

## [0.4.1] - 2026-03-14

### 🔄 Changed

- Simplified agent ownership model: all programming agents are interchangeable; Gemini CLI assigned to views/OWL/QWeb/Markdown only [(#8)](https://github.com/Yven-Labs/odoo-skills/pull/8)

---

## [0.4.0] - 2026-03-14

### 🚀 Added

- Multi-agent coordination workflow documentation in \`AGENTS.md\` [(#6)](https://github.com/Yven-Labs/odoo-skills/pull/6)

---

## [0.3.0] - 2026-03-14

### 🚀 Added

- Automatic version computation from conventional commits in \`release.yml\` — replaces \`PRD.md\` as version source of truth [(#3)](https://github.com/Yven-Labs/odoo-skills/pull/3)

### 🔄 Changed

- Unified Skill ID terminology across all skill files and local sync script [(#3)](https://github.com/Yven-Labs/odoo-skills/pull/3)

### 🐞 Fixed

- Skill ID detection in \`sync.sh\` refined to target labels only, avoiding false positives on doc mentions [(#3)](https://github.com/Yven-Labs/odoo-skills/pull/3)

---

## [0.2.0] - 2026-03-14

### 🚀 Added

- \`odoo-commit\` skill for standardized commit workflow with Odoo-specific scopes [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- \`odoo-pr\` skill with professional PR template and Odoo v17/v18 compatibility checklist [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- \`odoo-ci\` skill for GitHub Actions pipeline navigation and release automation [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- \`odoo-changelog\` skill based on keepachangelog.com conventions [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- Versioning Policy (Section 12) added to \`PRD.md\` [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)

### 🔄 Changed

- Realigned \`odoo-skills\` as fully standalone project independent from Gentleman Programming ecosystem [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- Simplified gentle-ai reference to a productivity recommendation in \`README.md\` and \`PRD.md\` [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- Redesigned \`PRD.md\` architecture diagrams (Section 8.1.1, 8.1.2) to remove hard Engram dependencies [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)

### 🐞 Fixed

- Escape backticks in Markdown validation script in \`ci.yml\` to prevent Bash EOF error [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)
- Removed stray empty code block in \`PRD.md\` Section 7.4 [(#2)](https://github.com/Yven-Labs/odoo-skills/pull/2)

---

## [0.1.0] - 2026-03-13

### 🚀 Added

- Initial project infrastructure: \`AGENTS.md\`, \`README.md\`, \`PRD.md\` [(#1)](https://github.com/Yven-Labs/odoo-skills/pull/1)
- \`setup.sh\` and \`setup.ps1\` installers with strict error handling and CLI flags [(#1)](https://github.com/Yven-Labs/odoo-skills/pull/1)
- \`sync.sh\` for skill library synchronization validation [(#1)](https://github.com/Yven-Labs/odoo-skills/pull/1)
- GitHub Actions CI pipeline for skill library integrity validation [(#1)](https://github.com/Yven-Labs/odoo-skills/pull/1)
- GitHub Actions release pipeline using \`PRD.md\` version as source of truth [(#1)](https://github.com/Yven-Labs/odoo-skills/pull/1)