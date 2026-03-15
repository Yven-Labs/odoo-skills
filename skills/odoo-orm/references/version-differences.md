# ORM Version Differences — v17 / v18

## Breaking Changes Summary

| Feature | v17 | v18 |
|---------|-----|-----|
| `name_get()` | ⚠️ Deprecated | ❌ Removed |
| `display_name` computed | Recommended | Required if custom |
| `attrs=` in XML views | ❌ Removed | ❌ Removed |
| Inline Python expressions in views | ✅ Required | ✅ Required |
| `Command` API | ✅ Recommended | ✅ Recommended |
| Tuple syntax `(0,0,{})` | ⚠️ Discouraged | ⚠️ Discouraged |
| `@api.model_create_multi` | ✅ Recommended | ✅ Recommended |
| `type="json"` in controllers | ❌ Renamed | ❌ Renamed |
| `type="jsonrpc"` in controllers | ✅ Required | ✅ Required |
| `mail.channel` model | ❌ Renamed | ❌ Renamed |
| `discuss.channel` model | ✅ Required | ✅ Required |

---

## name_get() → display_name

### ❌ WRONG (deprecated v17, removed v18)
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

### ❌ WRONG — attrs removed in v17
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

## x2many Syntax

### ❌ WRONG — old tuple syntax (discouraged v17+)
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

### ❌ WRONG (renamed in v17)
```python
@http.route('/api/endpoint', type='json', auth='user')
```

### ✅ CORRECT (v17+)
```python
@http.route('/api/endpoint', type='jsonrpc', auth='user')
```

---

## Messaging / Chatter Model

### ❌ WRONG (renamed in v17)
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

---

## OCA Naming Conventions (v17 / v18)

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
