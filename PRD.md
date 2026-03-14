# PRD: Odoo Skills Ecosystem

> **Every Odoo version. Every module. Every AI assistant. One skill library — and your AI codes Odoo like a senior developer.**

**Version**: 0.1.0-draft
**Author**: [Geraldow](https://github.com/Geraldow)
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
| **Sales & Sub** | `sale`, `sale_management`, `sale_subscription`, `sale_renting` | ~85 | Medium/High |
| **CRM & Leads** | `crm`, `crm_iap_mine`, `crm_livechat`, `crm_sms` | ~30 | Medium |
| **Accounting** | `account`, `account_accountant`, `account_asset`, `account_reports`, `account_consolidation` | ~160 | Critical |
| **Inventory** | `stock`, `stock_picking_batch`, `stock_barcode`, `stock_delivery` | ~90 | High |
| **Purchase** | `purchase`, `purchase_requisition`, `purchase_stock` | ~35 | Medium |
| **Manufacturing** | `mrp`, `mrp_bom`, `mrp_workorder`, `mrp_subcontracting`, `mrp_mps` | ~85 | High |
| **Quality & PLM** | `quality`, `quality_control`, `mrp_plm`, `mrp_workorder_hr` | ~45 | High |
| **HR Base** | `hr`, `hr_contract`, `hr_holidays`, `hr_expense`, `hr_attendance` | ~85 | Medium |
| **HR Talent** | `hr_recruitment`, `hr_appraisal`, `hr_referral`, `hr_skills` | ~40 | Medium |
| **Payroll** | `hr_payroll`, `hr_payroll_account`, `hr_payroll_attendance` | ~45 | High |
| **Services (FSM)** | `industry_fsm`, `project`, `project_timesheet`, `project_forecast` | ~75 | Medium |
| **Helpdesk** | `helpdesk`, `helpdesk_timesheet`, `helpdesk_stock` | ~25 | Medium |
| **Website & CMS** | `website`, `website_blog`, `website_forum`, `website_slides` | ~55 | Medium |
| **eCommerce** | `website_sale`, `payment`, `delivery`, `website_sale_stock` | ~65 | High |
| **Point of Sale** | `point_of_sale`, `pos_restaurant`, `pos_loyalty`, `pos_self_order` | ~60 | High |
| **Marketing** | `mass_mailing`, `marketing_automation`, `social`, `survey` | ~60 | Medium |
| **Productivity** | `knowledge`, `sign`, `approvals`, `lunch`, `calendar` | ~50 | Medium |
| **Documents** | `documents`, `documents_spreadsheet`, `documents_hr` | ~35 | Medium |
| **Operations** | `fleet`, `maintenance`, `planning`, `appointment` | ~60 | Low |
| **Voice & Social** | `mail`, `discuss`, `whatsapp`, `voip` | ~50 | High |
| **Data Tools** | `data_cleaning`, `data_recycle`, `spreadsheet_dashboard` | ~20 | Low |
| **Studio & IoT** | `studio`, `web_studio`, `iot`, `hw_drivers` | ~30 | Framework |

**Total: 420+ módulos y 3,200+ modelos en un ecosistema profesional completo.**

### 4.3 Universe Requirements

- **R-UNI-01**: The skill library MUST provide domain-specific knowledge for all 14+ functional areas listed in the Universe Table.
- **R-UNI-02**: Complex areas (Accounting, MRP, Payroll) MUST have dedicated "Deep Dive" references in the `references/` directory.
- **R-UNI-03**: The ecosystem MUST detect dependencies between modules (e.g., `sale` → `account`) and suggest loading cross-domain skills.
- **R-UNI-04**: Every module listed in the table MUST be mapped to at least one Skill (Core or Tier 6).

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

### 5.1.1 Skill Content Requirements

- **R-SKL-01**: Every skill MUST include a "Why" section explaining the underlying Odoo logic, not just the code syntax.
- **R-SKL-02**: All code examples MUST be functional and follow the "Clean Code" principles adapted for Odoo.
- **R-SKL-03**: Skills MUST avoid "Hallucinated" parameters; any technical claim MUST be verifiable in the Odoo Source Code.
- **R-SKL-04**: When a feature is version-sensitive, the `SKILL.md` MUST explicitly point to the `assets/v{N}` directory.

### 5.1.2 Security-First Requirements (Tier 1 & 2)

- **R-SEC-01**: AI assistants MUST generate `ir.model.access.csv` for every new model created by default.
- **R-SEC-02**: Security rules (`ir.rule`) MUST be suggested if a model contains sensitive data (HR, Accounting, Privacy).
- **R-SEC-03**: Skills MUST enforce the use of `sudo()` only as a last resort, documenting the reason in a comment.

### 5.1.3 OCA Convention Requirements

- **R-CON-01**: Every module generated MUST follow the OCA naming convention for the manifest (`__manifest__.py`).
- **R-CON-02**: Licensing MUST be explicitly checked; if not specified, it SHOULD suggest LGPL-3 or AGPL-3 (standard OCA).
- **R-CON-03**: Folder structure (models, views, security, data, static) MUST be strictly enforced to match Odoo standards.

### 5.2 Skill File Structure

Each skill is a modular directory designed for version-aware AI context loading:

```
skills/{skill-name}/
├── SKILL.md                 # Main router & universal patterns
├── assets/                  # Implementation templates
│   ├── v16/                 # Odoo 16 specific code
│   │   └── pattern.py       # (UID: ODSK-ASSET-{SKILL}-V16)
│   ├── v17/                 # Odoo 17 specific code
│   │   └── pattern.py       # (UID: ODSK-ASSET-{SKILL}-V17)
│   ├── v18/                 # Odoo 18 specific code
│   │   └── pattern.py       # (UID: ODSK-ASSET-{SKILL}-V18)
│   └── v19/                 # Odoo 19 specific code
│       └── pattern.py       # (UID: ODSK-ASSET-{SKILL}-V19)
└── references/               # Deep-dive documentation
    └── architecture.md      # (UID: ODSK-REF-{SKILL}-ARCH)
```

### 5.3 ODSK Unified ID System

- **Verification**: Allows the AI to positively verify it has loaded the correct context for the specific Odoo version.

### 5.4 Architecture Requirements

- **R-ARC-01**: Every skill MUST contain a `SKILL.md` file with a frontmatter defining its scope and unique ID.
- **R-ARC-02**: Version-specific code MUST be placed in its corresponding `assets/v{N}/` directory.
- **R-ARC-03**: All assets and references MUST implement the ODSK Unified ID System for AI verification.
- **R-ARC-04**: The skill library MUST be structured to avoid circular dependencies between core skills (Tier 1).
- **R-ARC-05**: Asset files MUST be small enough to be loaded into the AI context without exceeding 200 lines per file where possible.

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

### 6.4 Versioning Requirements

- **R-VER-01**: The system MUST detect the Odoo version from `__manifest__.py` files automatically.
- **R-VER-02**: If no manifest is found, the system MUST fallback to the project-level version configuration.
- **R-VER-03**: Version-aware skills MUST provide "Upgrade Maps" for common features (e.g., v16 `name_get` to v17 `_compute_display_name`).
- **R-VER-04**: Adding a new Odoo version MUST NOT require manual updates to the core `AGENTS.md` router beyond metadata.
- **R-VER-05**: Technical claims about version differences MUST be backed by an ODSK reference ID.

---

### 7.1 Master Skill Router (AGENTS.md)

Unlike monorepos that split context per code layer, **odoo-skills** uses a single, unified `AGENTS.md` in the root. This ensures the AI has a global overview of the Odoo ecosystem regardless of which file it is editing.

- **Location**: `/AGENTS.md`
- **Function**: Detects developer actions and auto-invokes the correct ODSK-uid from the library.

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

### 7.3 sync.sh Validation

The `sync.sh` script (located in `skills/skill-sync/assets/`) performs automated validation:
- Checks that all referenced skills in `AGENTS.md` exist.
- Validates ODSK UID uniqueness across the library.
- Ensures versioned assets exist for all active Odoo versions.

### 7.4 setup.sh — Deploy to All AI Tools

```bash
./setup.sh --all
# → Claude Code:    .claude/skills/ symlink
# → Gemini CLI:     .gemini/skills/ symlink
# → Codex:          .codex/skills/ symlink
# → GitHub Copilot: .github/copilot-instructions.md

### 7.6 Installer Experience Requirements (setup.sh)

- **R-UX-01**: The installer MUST provide clear visual feedback for each step (checks, success, failure).
- **R-UX-02**: The `setup.ps1` script MUST be parity-compatible with `setup.sh` for Windows users.
- **R-UX-03**: The installer MUST detect if a port is blocked (e.g., Engram port 7437) and warn the user.
- **R-UX-04**: Deployment MUST be atomic: if one symlink fails, the installer SHOULD offer a rollback.
- **R-UX-05**: Command-line help (`--help`) MUST be available for all automation scripts.
```

---

## 8. SDD Integration

Skills auto-invoke during `/sdd-apply` based on file context:
- Creating `models/*.py` → `odoo-orm`
- Creating `views/*.xml` → `odoo-views`
- Creating `security/*.csv` → `odoo-security`
- Creating `tests/test_*.py` → `odoo-testing`

### 8.1 Integration Requirements

- **R-INT-01**: Skills MUST be compatible with the standard SDD workflow phases (examine, plan, execute).
- **R-INT-02**: The `AGENTS.md` router MUST prioritize SDD-specific rules during an active `/sdd-apply` session.
- **R-INT-03**: Memory observations (Engram) generated during Odoo development MUST be tagged with the relevant ODSK ID for future recall.

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

### 12.1 Validation Requirements

- **R-MET-01**: Success is defined by a "Zero-Correction" run: AI generates the code and Odoo starts without errors on the first try.
- **R-MET-02**: Every Tier 1 skill MUST have a "Validation Module" (dummy module) tested in CI for versions 16, 17, and 18.
- **R-MET-03**: User satisfaction (Geraldow's verdict) is the final gate for "Passed" status of any phase.

---

## 13. Open Questions

1. **License**: MIT (Confirmed) — allowing maximum adoption with attribution to Geraldow.
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
