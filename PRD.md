# PRD: Odoo Skills Ecosystem

> **Every Odoo version. Every module. Every AI assistant. One skill library — and your AI codes Odoo like a senior developer.**

**Version**: 0.1.0-draft
**Author**: Gentleman Programming / Yven Labs
**Date**: 2026-03-13
**Status**: Draft

---

## 1. Problem Statement

Odoo development in 2026 is increasingly done with AI coding assistants (Claude Code, Gemini, Cursor, Copilot, etc.). But there's a critical gap:

**AI assistants know Python. They DON'T know Odoo.**

A raw AI assistant will:
- Use `name_get()` in Odoo 18 (deprecated since v17 — breaks silently)
- Write `attrs="{'invisible': [('state', '!=', 'draft')]}"` in v17+ (removed — hard crash)
- Put `type="json"` in a controller route (renamed to `type="jsonrpc"` in v17)
- Create `mail.channel` records (renamed to `discuss.channel` in v17)
- Ignore OCA conventions (wrong naming, missing license, wrong version format)
- Skip security rules entirely (no `ir.model.access.csv`, no `ir.rule`)
- Generate monolithic modules instead of modular, upgrade-safe code

**The result**: Code that looks correct but **fails on the target Odoo version**, violates conventions, skips security, and creates technical debt.

**This project eliminates that gap.** We create a complete **AI Skills Ecosystem for Odoo development** — a library of structured knowledge that any AI assistant can load to write correct, version-aware, convention-following Odoo code.

### Why now?

- Developers use Odoo 16, 17, 18, and 19 across different projects
- Every developer uses (or will use) AI coding assistants
- SDD (Spec-Driven Development) workflow is already in place — skills plug in naturally
- Prowler proved this pattern works: their 36 AI skills transformed how their team develops

---

## 2. Vision

**A complete AI skills library that makes any coding assistant a senior Odoo developer — aware of version differences, OCA conventions, security patterns, and every corner of the Odoo stack.**

**Before**: "Claude/Gemini/Copilot writes Python, but I have to fix every Odoo-specific thing manually."

**After**: The AI detects `__manifest__.py` → loads the right skills → writes correct Odoo code for the target version → follows OCA conventions → includes security rules → creates proper tests.

**This is NOT:**
- ❌ An Odoo module or addon
- ❌ A security scanner or auditor
- ❌ A replacement for learning Odoo
- ❌ A code generator tool

**This IS:**
- ✅ A skill library (Markdown files) that AI assistants read
- ✅ An AGENTS.md routing system (auto-invoke tables)
- ✅ A setup script (deploy to any AI tool)
- ✅ A sync system (keep everything connected)
- ✅ Version-aware (v16, v17, v18, v19... and ready for v20)

---

## 3. Target Users

### Primary
- **Odoo developers** using AI coding assistants (any level)
- **Development teams** that need standardized AI-assisted Odoo development
- **Companies** with projects across multiple Odoo versions (v16-v19)

### Secondary
- **OCA contributors** who want AI assistance that follows OCA conventions
- **Odoo consultants** implementing projects on various client versions
- **Students** learning Odoo development with AI guidance

---

## 4. The Odoo Module Universe

### Understanding the Scope

Odoo has **14+ major functional areas**, each with multiple modules:

| Area | Key Modules | Models (est.) | Complexity |
|------|-------------|--------------|------------|
| **Sales** | `sale`, `sale_management`, `sale_commission` | ~50 | Medium |
| **CRM** | `crm`, `crm_iap_mine` | ~30 | Medium |
| **Accounting** | `account`, `account_asset`, `account_budget` | ~80 | High |
| **Inventory** | `stock`, `stock_account`, `stock_barcode` | ~60 | High |
| **Purchase** | `purchase`, `purchase_requisition` | ~30 | Medium |
| **Manufacturing** | `mrp`, `mrp_account`, `quality_control` | ~50 | High |
| **HR** | `hr`, `hr_payroll`, `hr_recruitment`, `hr_attendance` | ~70 | High |
| **Project** | `project`, `project_timesheet` | ~25 | Medium |
| **Website** | `website`, `website_sale`, `website_blog` | ~40 | Medium |
| **Point of Sale** | `point_of_sale`, `pos_restaurant` | ~30 | Medium |
| **eCommerce** | `website_sale`, `payment` | ~35 | Medium |
| **Discuss** | `mail`, `discuss` | ~20 | Medium |
| **Studio** | `studio`, `web_studio` | ~15 | Low (Enterprise) |
| **IoT** | `iot`, `hw_drivers` | ~10 | Low (Enterprise) |

**Total: 600+ models across 100+ official modules.**

### Critical Insight: Skills ≠ Modules

> **We don't create one skill per Odoo module.** That would be 100+ skills and unmaintainable.
> Instead, we create skills around **development domains** (ORM, Views, Security, etc.) that apply **across ALL modules**.

```
❌ WRONG:  skills/odoo-sale/, skills/odoo-crm/, skills/odoo-hr/ ...  (100+ skills)
✅ CORRECT: skills/odoo-orm/, skills/odoo-views/, skills/odoo-security/ ... (26 skills)
```

Module-specific skills are created ONLY when a module has **unique development patterns** (Accounting journal entries, Website controller+template blend, PoS JS-heavy session management).

---

## 5. Skill Architecture

### 5.1 Complete Skill Inventory

#### Tier 1: Core — Without these, you can't develop Odoo (6 skills)

| # | Skill | What it teaches | Version Impact |
|---|-------|----------------|----------------|
| 1 | `odoo` | Overview: stack, components, versions, Python matrix | Version matrix |
| 2 | `odoo-module` | Module structure, `__manifest__.py`, data files | v17+ changes |
| 3 | `odoo-orm` | Models, fields, decorators, recordsets, CRUD | ⚠️ Heavy: name_get→_compute_display_name, Command objects, ir_property→JSONB, group_ids |
| 4 | `odoo-views` | Form, tree, kanban, search, inheritance | ⚠️ Heavy: attrs removed v17 |
| 5 | `odoo-security` | `ir.model.access.csv`, `ir.rule`, groups | Record rule defaults changed v17 |
| 6 | `odoo-testing` | TransactionCase, HttpCase, tours, test tags | Stable |

#### Tier 2: Essential — 80% of projects (6 skills)

| # | Skill | What it teaches | Version Impact |
|---|-------|----------------|----------------|
| 7 | `odoo-controllers` | HTTP routes, auth, JSON-RPC | ⚠️ type="json" → type="jsonrpc" in v17 |
| 8 | `odoo-owl` | OWL 2 components, hooks, registry | v16 legacy widgets; OWL 2 from v17+ |
| 9 | `odoo-qweb` | QWeb templates, reports, PDF | t-raw → t-out in v17 |
| 10 | `odoo-data` | Data/demo files, noupdate, XML IDs | Stable |
| 11 | `odoo-oca` | OCA conventions: naming, versioning, manifest | Stable |
| 12 | `odoo-wizards` | TransientModel, wizard views, multi-step | Stable |

#### Tier 3: Advanced — Complex projects (7 skills)

| # | Skill | What it teaches | Version Impact |
|---|-------|----------------|----------------|
| 13 | `odoo-mail` | mail.thread, activities, chatter | ⚠️ mail.channel → discuss.channel v17 |
| 14 | `odoo-api` | XML-RPC, JSON-RPC, REST external integrations | REST improved v18+ |
| 15 | `odoo-cron` | ir.cron, scheduling, best practices | Stable |
| 16 | `odoo-performance` | N+1 avoidance, prefetch, read_group, SQL | search_fetch() added v17 |
| 17 | `odoo-migration` | Module migration between versions, hooks | BY DEFINITION version-specific |
| 18 | `odoo-assets` | CSS/SCSS bundles, JS modules, inheritance | Stable |
| 19 | `odoo-inherit` | _inherit, _inherits, delegation, xpath | Stable |

#### Tier 4: DevOps & Workflow (4 skills)

| # | Skill | What it teaches |
|---|-------|----------------|
| 20 | `odoo-commit` | Conventional commits for Odoo |
| 21 | `odoo-pr` | PR template for Odoo modules |
| 22 | `odoo-docker` | Docker compose, `odoo.conf`, multi-version |
| 23 | `odoo-debug` | Debug mode, logging, shell, `--dev=all` |

#### Tier 5: Version Delta Skills (3 skills)

| # | Skill | What it teaches |
|---|-------|----------------|
| 24 | `odoo-v17-changes` | ALL breaking changes v16→v17 |
| 25 | `odoo-v18-changes` | ALL changes v17→v18 |
| 26 | `odoo-v19-changes` | ALL changes v18→v19 |

#### Tier 6: Module-Specific (optional, 4-6 skills)

| # | Skill | Why unique |
|---|-------|-----------|
| 27 | `odoo-accounting` | Journal entries, fiscal positions |
| 28 | `odoo-website-dev` | Controller+template blend, snippets |
| 29 | `odoo-pos-dev` | JS-heavy, POS session patterns |
| 30 | `odoo-ecommerce-dev` | Payment flow, cart, checkout |

**Total: 26 core + 4-6 optional = 30-32 max skills.**

### 5.2 Skill File Structure

```
skills/{skill-name}/
├── SKILL.md                  # Main skill (frontmatter + body)
├── assets/                   # Templates, version-specific patterns
│   ├── template.py           # Code template
│   ├── v16_patterns.md       # Version delta (v16 only)
│   ├── v17_patterns.md       # Version delta (v17+)
│   ├── v18_patterns.md       # Version delta (v18+)
│   └── v19_patterns.md       # Version delta (v19+)
└── references/               # Links to docs
    └── docs.md
```

### 5.3 Content Split Strategy

| Content Type | Location | % |
|---|---|---|
| Version-agnostic | `SKILL.md` body | ~80% |
| Version-specific deltas | `assets/v{N}_patterns.md` | ~20% |

---

## 6. Multi-Version Architecture

### 6.1 Version Detection

```python
# AI reads __manifest__.py to detect version:
# version: "18.0.1.0.0" → Odoo 18 → load assets/v18_patterns.md
# version: "16.0.2.1.0" → Odoo 16 → load assets/v16_patterns.md
```

### 6.2 Version Differences Quick Reference

| Feature | v16 | v17 | v18 | v19 |
|---|---|---|---|---|
| Python | 3.8+ | 3.10+ | 3.10+ | 3.11+ |
| `name_get()` | ✅ | ❌ deprecated | ❌ | ❌ |
| `attrs="{}"` in XML | ✅ | ❌ REMOVED | ❌ | ❌ |
| `type="json"` controller | ✅ | ❌ → `"jsonrpc"` | ❌ | ❌ |
| `mail.channel` | ✅ | ❌ → `discuss.channel` | ❌ | ❌ |
| `groups_id` field | ✅ | ✅ | ✅ | ❌ → `group_ids` |
| `Command` objects | ❌ use tuples | ✅ | ✅ | ✅ |
| OWL version | OWL 1 | OWL 2 | OWL 2 | OWL 2 |
| `ir_property` | Table | Table | ❌ → JSONB | ❌ → JSONB |

### 6.3 Adding Odoo v20 (Future-proofing)

**5 steps, ~30 min, 0 architectural changes:**
1. Create `skills/odoo-v20-changes/SKILL.md`
2. Add `assets/v20_patterns.md` in each affected skill
3. Update Version Detection tables
4. Add `assets/v19_to_v20_map.md` in `odoo-migration`
5. Run `./skills/skill-sync/assets/sync.sh`

---

## 7. Auto-Invoke & Sync System

### 7.1 AGENTS.md Hierarchy

```
odoo-skills/
├── AGENTS.md              # Root router — all skills
├── backend/AGENTS.md      # ORM, views, security, controllers
├── frontend/AGENTS.md     # OWL, QWeb, assets
└── devops/AGENTS.md       # Docker, debug, CI
```

### 7.2 Auto-Invoke Table

```markdown
| Action | Skill |
|--------|-------|
| Creating Odoo models or fields | `odoo-orm` |
| Creating XML views | `odoo-views` |
| Adding security rules | `odoo-security` |
| Writing Python tests | `odoo-testing` |
| Creating HTTP controllers | `odoo-controllers` |
| Creating OWL components | `odoo-owl` |
| Creating QWeb / PDF reports | `odoo-qweb` |
| Creating TransientModel wizards | `odoo-wizards` |
| Adding mail.thread to model | `odoo-mail` |
| Creating scheduled actions | `odoo-cron` |
| Optimizing ORM queries | `odoo-performance` |
| Migrating module to new version | `odoo-migration` |
| Creating new Odoo module | `odoo-module` |
| Following OCA conventions | `odoo-oca` |
| Understanding version changes | `odoo-v{N}-changes` |
```

### 7.3 sync.sh Scopes

```bash
# Scope → AGENTS.md path
root      → AGENTS.md
backend   → backend/AGENTS.md
frontend  → frontend/AGENTS.md
devops    → devops/AGENTS.md
```

### 7.4 setup.sh — Deploy to All AI Tools

```bash
./setup.sh --all
# → Claude Code:    .claude/skills/ symlink
# → Gemini CLI:     .gemini/skills/ symlink
# → Codex:          .codex/skills/ symlink
# → GitHub Copilot: .github/copilot-instructions.md
```

---

## 8. SDD Integration

Skills auto-invoke during `/sdd-apply` based on file context:
- Creating `models/*.py` → `odoo-orm`
- Creating `views/*.xml` → `odoo-views`
- Creating `security/*.csv` → `odoo-security`
- Creating `tests/test_*.py` → `odoo-testing`

---

## 9. Delivery Roadmap

### Phase 1: Foundation (Week 1-2) — MVP

| Deliverable | Description |
|---|---|
| Repository infrastructure | AGENTS.md hierarchy, setup.sh, setup.ps1, sync.sh |
| `odoo` | Overview skill |
| `odoo-module` | Module structure + manifest templates |
| `odoo-orm` | ORM skill + v16/v17/v18/v19 assets |
| `odoo-views` | Views skill + attrs/inline assets |
| `odoo-security` | Security skill + CSV/XML templates |
| `odoo-testing` | Testing skill + TransactionCase template |
| `odoo-oca` | OCA conventions |

### Phase 2: Essential Layer (Week 3-4)

`odoo-controllers`, `odoo-owl`, `odoo-qweb`, `odoo-data`, `odoo-wizards`, `odoo-inherit`

### Phase 3: Advanced & DevOps (Week 5-6)

`odoo-mail`, `odoo-api`, `odoo-cron`, `odoo-performance`, `odoo-migration`, `odoo-assets`, `odoo-docker`, `odoo-debug`, `odoo-commit`, `odoo-pr`

### Phase 4: Version Deltas & Module Specifics (Week 7-8)

`odoo-v17-changes`, `odoo-v18-changes`, `odoo-v19-changes`, module-specific skills

---

## 10. Scope

### ✅ In Scope
- AI skills (Markdown + templates)
- AGENTS.md routing system
- sync.sh auto-synchronization
- setup.sh/setup.ps1 deployment
- Version-specific assets for v16-v19
- SDD workflow integration
- OCA conventions

### ❌ NOT In Scope
- Odoo modules or addons
- Security scanner/auditor
- Business logic documentation
- Automated code generation
- Odoo ERP training for end users

---

## 11. Non-Functional Requirements

- **R-MAINT-01**: Adding Odoo v20 MUST require only new asset files, no architectural changes
- **R-PORT-01**: Skills MUST work with Claude Code, Gemini CLI, Codex, Cursor, Copilot
- **R-PORT-02**: setup.sh MUST support macOS, Linux, and Windows (Git Bash / PowerShell)
- **R-QUAL-01**: Every code template MUST be tested on at least Odoo 17 and 18
- **R-EXT-01**: Adding a new skill MUST require only 1 directory + 1 SKILL.md + 1 sync.sh run

---

## 12. Success Metrics

| Metric | Target |
|---|---|
| AI generates correct Odoo code for detected version | > 95% accuracy |
| Skills cover common Odoo development tasks | > 80% coverage |
| Time to add Odoo v20 support | < 1 hour |
| Time to set up skills on new project | < 5 minutes |
| Reduction in "fixing AI-generated Odoo code" | > 50% |

---

## 13. Open Questions

1. **License**: Apache-2.0 or LGPL-3.0 (matching Odoo Community)?
2. **Enterprise content**: Include Enterprise-only patterns or only Community?
3. **Odoo.sh**: Include Odoo.sh deployment patterns?
4. **Localization**: Add l10n-specific skills (e.g., `odoo-l10n-pe` for Peru)?
5. **Automated testing**: CI that runs code templates against real Odoo instances?
6. **Odoo MCP server**: Build MCP server for live Odoo docs lookup?
7. **gentle-ai integration**: Odoo Skills as a selectable preset in gentle-ai installer?

---

## Appendix A: Dependency Graph

```
odoo-module → odoo-orm → odoo-testing
                       → odoo-inherit
                       → odoo-performance
           → odoo-security → odoo-testing
           → odoo-views → odoo-owl → odoo-assets
                        → odoo-qweb
                        → odoo-inherit
odoo-mail → odoo-orm
odoo-wizards → odoo-orm
             → odoo-views
odoo-migration → odoo-orm
              → odoo-views
odoo-commit → odoo-pr
odoo-docker → odoo-debug
```
