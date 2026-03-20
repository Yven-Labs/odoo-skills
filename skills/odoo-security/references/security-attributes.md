# Security Attributes — Version Compatibility Reference

## `ir.rule` Field Compatibility

| Field / Behavior | v16 | v17 | v18 | Notes |
|---|---|---|---|---|
| `global` field | ✅ Valid | ❌ Removed | ❌ Removed | Rule is global when `groups` m2m is empty |
| `domain_force` | ✅ | ✅ | ✅ | Odoo domain string |
| `perm_read/write/create/unlink` | ✅ | ✅ | ✅ | Boolean attributes |
| `groups` (m2m) | ✅ | ✅ | ✅ | Empty = global in v17+ |
| `noupdate="1"` wrapper | Recommended | Recommended | Recommended | Prevents overwrite on `--update` |
| Context var `user` | ✅ | ✅ | ✅ | Current user recordset |
| Context var `time` | ✅ | ✅ | ✅ | Python `time` module |
| Context var `company_ids` | ✅ | ✅ | ✅ | List of allowed company IDs |

## `ir.model.access.csv` Column Reference

Columns must appear in **exactly this order**:

| Position | Column | Example | Notes |
|---|---|---|---|
| 1 | `id` | `access_sale_order_user` | External ID, unique per row |
| 2 | `name` | `sale.order user` | Human-readable label |
| 3 | `model_id:id` | `model_sale_order` | Dots → underscores, `model_` prefix |
| 4 | `group_id:id` | `sales.group_sales_user` | Module prefix required. Leave blank = all users |
| 5 | `perm_read` | `1` | Integer `1` or `0` only, never `True` |
| 6 | `perm_write` | `0` | Integer `1` or `0` only |
| 7 | `perm_create` | `0` | Integer `1` or `0` only |
| 8 | `perm_unlink` | `0` | Integer `1` or `0` only |

## `res.groups` Field Compatibility

| Field | v16 | v17 | v18 | Notes |
|---|---|---|---|---|
| `name` | ✅ | ✅ | ✅ | Displayed in Settings UI |
| `category_id` | ✅ | ✅ | ✅ | Controls section in Settings > Groups |
| `implied_ids` | ✅ | ✅ | ✅ | `eval="[(4, ref('...'))]"` to add |
| `users` | ✅ | ✅ | ✅ | m2m to `res.users` |
| `comment` | ✅ | ✅ | ✅ | Optional description |

## Standard Base Groups

| XML ID | Description | Use When |
|---|---|---|
| `base.group_user` | Internal user | All internal users |
| `base.group_portal` | Portal user | External/customer portal access |
| `base.group_public` | Public | Unauthenticated/anonymous |
| `base.group_system` | Settings (Technical) | Admin-level configuration access |
| `base.group_erp_manager` | ERP Manager | Cross-app administrative access |

## v16 → v17 Migration: `ir.rule global` Field

### v16 (valid)
```xml
<record id="rule_all_records" model="ir.rule">
    <field name="name">My Model: All Records</field>
    <field name="model_id" ref="model_my_model"/>
    <field name="domain_force">[(1, '=', 1)]</field>
    <field name="global" eval="True"/>
</record>
```

### v17/v18 equivalent (global = no groups)
```xml
<record id="rule_all_records" model="ir.rule">
    <field name="name">My Model: All Records</field>
    <field name="model_id" ref="model_my_model"/>
    <field name="domain_force">[(1, '=', 1)]</field>
    <!-- No <field name="groups"> → automatically global in v17+ -->
</record>
```

## `__manifest__.py` — Security File Load Order

```python
'data': [
    'security/groups.xml',          # 1. Groups first — CSV references them
    'security/ir.model.access.csv', # 2. ACL second — references groups
    'security/ir_rule.xml',         # 3. Record rules — references models and groups
    'views/my_model_views.xml',     # 4. Views last
],
```
