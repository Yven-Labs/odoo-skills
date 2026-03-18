# ORM Version Differences — v16 / v17 / v18

## Breaking Changes Summary

| Feature | v16 | v17 | v18 |
|---------|-----|-----|-----|
| `name_get()` | ✅ Valid | ⚠️ Deprecated | ❌ Removed |
| `display_name` computed | Optional | Recommended | Required if custom |
| `attrs=` in XML views | ✅ Valid | ❌ Removed | ❌ Removed |
| Inline Python expressions in views | ❌ | ✅ Required | ✅ Required |
| `states=` on buttons/fields | ✅ Valid | ❌ Removed | ❌ Removed |
| `@colors`/`@fonts` in list | ✅ Valid | ❌ Removed | ❌ Removed |
| `Command` API | ⚠️ Partial | ✅ Recommended | ✅ Recommended |
| Tuple syntax `(0,0,{})` | ✅ Valid | ⚠️ Discouraged | ❌ Removed |
| `@api.model_create_multi` | ✅ Valid | ✅ Recommended | ✅ Required |
| `type="json"` in controllers | ✅ Valid | ❌ Renamed | ❌ Renamed |
| `type="jsonrpc"` in controllers | ❌ | ✅ Required | ✅ Required |
| `mail.channel` model | ✅ Valid | ❌ Renamed | ❌ Renamed |
| `discuss.channel` model | ❌ | ✅ Required | ✅ Required |
| `ir_property` table | ✅ Valid | ✅ Valid | ❌ Removed |
| JSONB company-dependent fields | ❌ | ❌ | ✅ |
| `groups_id` on res.users | ✅ Valid | ✅ Valid | ❌ Renamed |
| `group_ids` on res.users | ❌ | ❌ | ✅ Required |
| `search_fetch()` | ❌ | ❌ | ✅ Added |

---

## name_get() → display_name

### ❌ WRONG (valid v16, deprecated v17, removed v18)
```python
def name_get(self):
    return [(rec.id, f'[{rec.code}] {rec.name}') for rec in self]
```

### ✅ CORRECT (v17+)
```python
# Option A — simple: use _rec_name
_rec_name = 'name'

# Option B — with logic: override display_name
display_name = fields.Char(compute='_compute_display_name', store=True)

@api.depends('code', 'name')
def _compute_display_name(self):
    for rec in self:
        rec.display_name = f'[{rec.code}] {rec.name}'
```

---

## XML View Conditionals

### ❌ WRONG — attrs valid in v16, removed in v17
```xml
<field name="date_end"
       attrs="{'invisible': [('type', '!=', 'fixed')],
               'required': [('type', '=', 'fixed')]}"/>
```

### ✅ CORRECT (v17+)
```xml
<field name="date_end"
       invisible="type != 'fixed'"
       required="type == 'fixed'"/>
```

---

## states attribute on buttons

### ❌ WRONG — valid in v16, removed in v17
```xml
<button name="action_confirm" states="draft,sent" string="Confirm" type="object"/>
```

### ✅ CORRECT (v17+)
```xml
<button name="action_confirm" string="Confirm" type="object"
        invisible="state not in ('draft', 'sent')"/>
```

---

## x2many Syntax

### ❌ WRONG — v16 tuple syntax (discouraged v17, removed v18)
```python
order.write({
    'line_ids': [
        (0, 0, {'name': 'line', 'qty': 1}),   # create
        (1, 5, {'qty': 2}),                     # update id=5
        (2, 5, 0),                              # delete id=5
    ]
})
```

### ✅ CORRECT — Command API (v17+)
```python
from odoo import Command

order.write({
    'line_ids': [
        Command.create({'name': 'line', 'qty': 1}),
        Command.update(5, {'qty': 2}),
        Command.delete(5),
    ]
})
```

---

## Controller Route Type

### ❌ WRONG — valid in v16, renamed in v17
```python
@http.route('/api/endpoint', type='json', auth='user')
```

### ✅ CORRECT (v17+)
```python
@http.route('/api/endpoint', type='jsonrpc', auth='user')
```

---

## Messaging / Chatter Model

### ❌ WRONG — valid in v16, renamed in v17
```python
partner_id = fields.Many2one('mail.channel')
```

### ✅ CORRECT (v17+)
```python
partner_id = fields.Many2one('discuss.channel')
```

---

## create() Override

### ✅ CORRECT — batch-aware (v17+)
```python
@api.model_create_multi
def create(self, vals_list):
    # vals_list is a list of dicts — enables batch creates
    for vals in vals_list:
        pass  # process each dict
    return super().create(vals_list)
```

> In v16, `@api.model` was used. In v17+, `@api.model_create_multi` is required for correct batch support.

---

## v18: search_fetch() — single query optimization

```python
# v17 — 2 queries
records = self.search([('state', '=', 'draft')])
data = records.read(['name', 'state'])

# v18 — single optimized query
records = self.search_fetch([('state', '=', 'draft')], ['name', 'state'])
```

---

## OCA Naming Conventions (v16 / v17 / v18 — stable)

| Element | Convention | Example |
|---------|-----------|---------|
| Model `_name` | `module.entity` lowercase | `sale.order.line` |
| Field names | `snake_case` | `date_order`, `partner_id` |
| Compute methods | `_compute_<field>` | `_compute_amount_total` |
| Inverse methods | `_inverse_<field>` | `_inverse_amount_gross` |
| Onchange methods | `_onchange_<field>` | `_onchange_partner_id` |
| Constraint methods | `_check_<description>` | `_check_date_order` |
| Action methods | `action_<verb>` | `action_confirm`, `action_cancel` |
| Module name | `lowercase_underscore` | `sale_custom_report` |
| `__manifest__.py` version | `XX.Y.A.B.C` | `17.0.1.0.0` |
