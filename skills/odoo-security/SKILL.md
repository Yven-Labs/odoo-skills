---
name: odoo-security
description: >
  Teaches AI agents to write correct, version-aware Odoo security artifacts:
  ir.model.access.csv, ir.rule record rules, and res.groups definitions for
  Odoo v16, v17, and v18.
metadata:
  author: Geraldow
  version: "1.0.0"
  supported_versions: ["16", "17", "18"]
  detect_from: "__manifest__.py"
  skill_id: ODSK-SKL-SEC
auto_invoke:
  - "Adding security groups or access rules"
  - "Creating ir.model.access.csv"
  - "Defining record rules or ir.rule"
  - "Writing ir.rule domain_force"
  - "Creating res.groups XML"
  - "Setting up module security folder"
---

# odoo-security

## When to Use

Load this skill when:

- Creating or editing `security/ir.model.access.csv`
- Defining `res.groups` records in XML
- Writing `ir.rule` record rules with `domain_force`
- Setting up the `security/` folder structure for a new module
- Migrating security files from Odoo v16 to v17/v18

---

## Version Detection

Read `__manifest__.py` and parse the `version` field: `"17.0.1.0.0"` → major version `17`.

| Version | Key Security Change |
|---|---|
| **v16** | `ir.rule` has a `global` boolean field |
| **v17** | `global` field removed — a rule with no groups is automatically global |
| **v18** | Same as v17 |

---

## Critical Rules

### [v17+] NEVER set `global` on `ir.rule`

```xml
<!-- ❌ WRONG — global field was removed in v17, raises ValueError -->
<field name="global" eval="True"/>

<!-- ✅ CORRECT — omit groups entirely for a global rule in v17+ -->
<!-- A rule with no groups m2m is automatically applied to all users -->
```

### NEVER omit `group_id:id` in the CSV without intent

```csv
# ❌ DANGEROUS — blank group_id means ALL users. Document this explicitly.
access_my_model_all,my.model all,model_my_model,,1,0,0,0

# ✅ SAFER — assign a group
access_my_model_user,my.model user,model_my_model,my_module.group_my_module_user,1,0,0,0
```

### NEVER mix up ACL vs record rules

- **`ir.model.access.csv`** → table-level (can the user access this model at all?)
- **`ir.rule`** → row-level (which specific records can the user see/edit?)
- Both are required for proper data isolation. ACL without record rules = user sees all rows.

---

## Folder Structure Pattern

```text
my_module/
├── __manifest__.py
└── security/
    ├── groups.xml              ← Define res.groups here
    ├── ir.model.access.csv     ← Table-level permissions
    └── ir_rule.xml             ← Row-level record rules
```

### Manifest load order (critical)

```python
# __manifest__.py
'data': [
    'security/groups.xml',          # 1. Groups FIRST — CSV references them
    'security/ir.model.access.csv', # 2. ACL SECOND — references groups
    'security/ir_rule.xml',         # 3. Rules THIRD — references models and groups
    'views/my_model_views.xml',     # 4. Views LAST
],
```

> Loading `ir.model.access.csv` before `groups.xml` raises a `ManyToMany` foreign key error at install time.

---

## `ir.model.access.csv` Pattern

### Column order (positional — never reorder)

```
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
```

### Two-tier permission example

```csv
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_sale_custom_order_user,sale_custom.order user,model_sale_custom_order,sale_custom.group_sale_custom_user,1,0,0,0
access_sale_custom_order_manager,sale_custom.order manager,model_sale_custom_order,sale_custom.group_sale_custom_manager,1,1,1,1
```

### Column reference

| Column | Value Pattern | Notes |
|---|---|---|
| `id` | `access_<model_underscore>_<group>` | Must be unique |
| `name` | `<module>.<model> <group>` | Human-readable only |
| `model_id:id` | `model_<model_dots_as_underscores>` | `sale.order` → `model_sale_order` |
| `group_id:id` | `<module>.group_<module>_<role>` | Module prefix is required |
| `perm_*` | `1` or `0` | Integer — never `True`/`False` |

---

## `res.groups` XML Pattern

```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data>

        <!-- Module category — appears as section in Settings > Users & Companies > Groups -->
        <record id="module_category_sale_custom" model="ir.module.category">
            <field name="name">Sale Custom</field>
            <field name="sequence">10</field>
        </record>

        <!-- User group — read-only access -->
        <record id="group_sale_custom_user" model="res.groups">
            <field name="name">User</field>
            <field name="category_id" ref="module_category_sale_custom"/>
        </record>

        <!-- Manager group — full access, automatically includes User permissions -->
        <record id="group_sale_custom_manager" model="res.groups">
            <field name="name">Manager</field>
            <field name="category_id" ref="module_category_sale_custom"/>
            <field name="implied_ids" eval="[(4, ref('group_sale_custom_user'))]"/>
        </record>

    </data>
</odoo>
```

---

## `ir.rule` Pattern

### Own-records rule (v17/v18)

```xml
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <data noupdate="1">

        <!-- User sees only records assigned to themselves -->
        <record id="rule_sale_custom_order_own" model="ir.rule">
            <field name="name">Sale Custom Order: Own Records</field>
            <field name="model_id" ref="model_sale_custom_order"/>
            <field name="domain_force">[('user_id', '=', user.id)]</field>
            <field name="groups" eval="[(4, ref('sale_custom.group_sale_custom_user'))]"/>
            <field name="perm_read" eval="True"/>
            <field name="perm_write" eval="True"/>
            <field name="perm_create" eval="True"/>
            <field name="perm_unlink" eval="True"/>
        </record>

    </data>
</odoo>
```

### v16 vs v17+ — global rule

```xml
<!-- ✅ v16 — explicit global field -->
<record id="rule_global_v16" model="ir.rule">
    <field name="name">My Model: All Records (v16)</field>
    <field name="model_id" ref="model_my_model"/>
    <field name="domain_force">[(1, '=', 1)]</field>
    <field name="global" eval="True"/>
</record>

<!-- ✅ v17/v18 — global = no groups (omit the groups field entirely) -->
<record id="rule_global_v17" model="ir.rule">
    <field name="name">My Model: All Records (v17+)</field>
    <field name="model_id" ref="model_my_model"/>
    <field name="domain_force">[(1, '=', 1)]</field>
    <!-- No groups field → automatically global -->
</record>
```

### Multi-company isolation rule

```xml
<record id="rule_my_model_company" model="ir.rule">
    <field name="name">My Model: Multi-Company</field>
    <field name="model_id" ref="model_my_model"/>
    <field name="domain_force">[('company_id', 'in', company_ids)]</field>
    <field name="groups" eval="[(4, ref('base.group_user'))]"/>
    <field name="perm_read" eval="True"/>
    <field name="perm_write" eval="True"/>
    <field name="perm_create" eval="True"/>
    <field name="perm_unlink" eval="False"/>
</record>
```

### Available context variables in `domain_force`

| Variable | Type | Description |
|---|---|---|
| `user` | `res.users` recordset | Current logged-in user |
| `time` | Python `time` module | For date-based conditions |
| `company_ids` | `list[int]` | IDs of user's allowed companies |

---

## Assets

| File | Use Case |
|---|---|
| [`assets/access-template.csv`](assets/access-template.csv) | Drop-in `ir.model.access.csv` with two-tier permissions |
| [`assets/groups-template.xml`](assets/groups-template.xml) | Module category + User/Manager group definitions |
| [`assets/record-rule-template.xml`](assets/record-rule-template.xml) | Own-records rule + multi-company rule (v17+ syntax) |

---

## Common Mistakes

### 1. [v16→v17] Using `global` field on `ir.rule`

```xml
<!-- ❌ WRONG in v17+ — field does not exist -->
<field name="global" eval="True"/>

<!-- ✅ CORRECT — just omit the groups field -->
```

The `global` field was removed in v17. A rule with an empty `groups` m2m is automatically global.

---

### 2. Wrong CSV column order

```csv
# ❌ WRONG — missing perm_unlink column (silent load failure)
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create
access_my_model_user,my.model user,model_my_model,my_module.group_user,1,0,0

# ✅ CORRECT — all 8 columns in exact order
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_my_model_user,my.model user,model_my_model,my_module.group_user,1,0,0,0
```

A shifted or missing column causes a **silent load failure** — no error is raised, but permissions are wrong.

---

### 3. Missing module prefix on `group_id:id`

```csv
# ❌ WRONG — Odoo cannot resolve the group XML ID without module prefix
access_my_model_user,my.model user,model_my_model,group_my_module_user,1,0,0,0

# ✅ CORRECT — always include the module name
access_my_model_user,my.model user,model_my_model,my_module.group_my_module_user,1,0,0,0
```

---

### 4. Loading CSV before groups in the manifest

```python
# ❌ WRONG — CSV references groups that haven't been created yet
'data': [
    'security/ir.model.access.csv',
    'security/groups.xml',
]

# ✅ CORRECT — groups.xml must load first
'data': [
    'security/groups.xml',
    'security/ir.model.access.csv',
]
```

This raises a `ManyToMany` foreign key constraint error at module install time.

---

### 5. Omitting `noupdate="1"` on record rules

```xml
<!-- ❌ WRONG — rule is reset to default on every --update -->
<odoo>
    <data>
        <record id="rule_my_model_own" model="ir.rule">...</record>
    </data>
</odoo>

<!-- ✅ CORRECT — preserves admin customizations made via Settings UI -->
<odoo>
    <data noupdate="1">
        <record id="rule_my_model_own" model="ir.rule">...</record>
    </data>
</odoo>
```

---

### 6. Using `True`/`False` strings in CSV instead of integers

```csv
# ❌ WRONG — string booleans are not valid
access_my_model_user,my.model user,model_my_model,my_module.group_user,True,False,False,False

# ✅ CORRECT — integers only
access_my_model_user,my.model user,model_my_model,my_module.group_user,1,0,0,0
```

---

### 7. Confusing ACL with record rules

- **`ir.model.access.csv`** controls whether a user can access the model at all (table-level gate).
- **`ir.rule`** controls which rows the user can see or edit (row-level filter).

Setting up ACL without record rules means all users with access see **all rows**. Both layers are needed for proper data isolation (e.g., each salesperson sees only their own orders).

---

## References

| Resource | Description |
|---|---|
| [`references/security-attributes.md`](references/security-attributes.md) | Full compatibility table v16/v17/v18, CSV column reference, base groups |
| [Odoo Security Documentation](https://www.odoo.com/documentation/17.0/developer/reference/backend/security.html) | Official access rights and record rules reference |
