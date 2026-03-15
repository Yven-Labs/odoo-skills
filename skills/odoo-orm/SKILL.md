---
name: odoo-orm
description: >
  Guides AI agents to write correct, version-aware Odoo models, fields, and ORM
  operations for Odoo v17 and v18. Prevents deprecated API usage and enforces
  OCA naming conventions.
  Trigger: When creating Odoo models, defining fields, writing computed fields,
  using recordset operations, or working with x2many relationships.
license: MIT
metadata:
  author: Geraldow
  owner: claude-code
  version: "1.0.0"
  scope: [root, core]
  auto_invoke:
    - "Creating Odoo models or fields"
    - "Defining computed fields or constraints"
    - "Using recordset operations (search, browse, filtered)"
    - "Working with One2many or Many2many fields"
    - "Writing create(), write(), or unlink() overrides"
---

## When to Use

Load this skill when:

- Creating a new model (`models.Model`, `models.TransientModel`, `models.AbstractModel`)
- Adding or modifying fields on an existing model
- Writing computed fields with `@api.depends`
- Using `Command` API for x2many operations
- Overriding ORM methods (`create`, `write`, `unlink`, `copy`)
- Performing recordset operations (`search`, `browse`, `filtered`, `mapped`, `sorted`)
- Unsure whether an ORM pattern is compatible with Odoo v17 or v18

---

## Critical Rules

These rules prevent **silent failures** and **version crashes**:

### NEVER use `name_get()` in Odoo v17+
```python
# ❌ WRONG — deprecated since v17, causes AttributeError in v18
def name_get(self):
    return [(rec.id, rec.name) for rec in self]

# ✅ CORRECT — use _rec_name or override display_name
_rec_name = 'name'

# ✅ CORRECT — or override display_name if logic is needed
display_name = fields.Char(compute='_compute_display_name', store=True)

@api.depends('name', 'code')
def _compute_display_name(self):
    for rec in self:
        rec.display_name = f'[{rec.code}] {rec.name}'
```

### NEVER use `(0, 0, {...})` tuple syntax for x2many in v17+
```python
# ❌ WRONG — old tuple syntax, error-prone and implicit
vals['line_ids'] = [(0, 0, {'name': 'line1', 'qty': 1})]

# ✅ CORRECT — explicit Command API (available since v16, required style in v17+)
from odoo import Command
vals['line_ids'] = [Command.create({'name': 'line1', 'qty': 1})]
```

### NEVER use `attrs` in XML for v17+
```xml
<!-- ❌ WRONG — attrs removed in v17 -->
<field name="date" attrs="{'invisible': [('state', '!=', 'draft')]}"/>

<!-- ✅ CORRECT — inline Python expression -->
<field name="date" invisible="state != 'draft'"/>
```

### NEVER use `type="json"` in controllers for v17+
```python
# ❌ WRONG — renamed in v17
@http.route('/api/endpoint', type='json', auth='user')

# ✅ CORRECT
@http.route('/api/endpoint', type='jsonrpc', auth='user')
```

---

## Field Patterns

### Basic field declaration
```python
from odoo import api, fields, models

class SaleOrder(models.Model):
    _name = 'sale.order'
    _description = 'Sale Order'
    _order = 'date_order desc, id desc'

    name = fields.Char(string='Reference', required=True, copy=False,
                       default=lambda self: _('New'))
    state = fields.Selection([
        ('draft', 'Draft'),
        ('confirm', 'Confirmed'),
        ('done', 'Done'),
        ('cancel', 'Cancelled'),
    ], string='Status', default='draft', required=True, tracking=True)
    date_order = fields.Datetime(string='Order Date', required=True,
                                 default=fields.Datetime.now)
    partner_id = fields.Many2one('res.partner', string='Customer',
                                 required=True, ondelete='restrict')
    amount_total = fields.Monetary(string='Total', compute='_compute_amount',
                                   store=True, currency_field='currency_id')
    currency_id = fields.Many2one('res.currency', related='company_id.currency_id',
                                  store=True)
    company_id = fields.Many2one('res.company', default=lambda self: self.env.company)
    line_ids = fields.One2many('sale.order.line', 'order_id', string='Order Lines')
    tag_ids = fields.Many2many('sale.order.tag', string='Tags')
    active = fields.Boolean(default=True)
    notes = fields.Html(string='Notes', sanitize=True)
```

### Computed field
```python
    @api.depends('line_ids.price_subtotal')
    def _compute_amount(self):
        for order in self:
            order.amount_total = sum(order.line_ids.mapped('price_subtotal'))
```

### Related field
```python
    # Reads through a relation — no compute needed
    partner_email = fields.Char(related='partner_id.email', store=True)
```

---

## Recordset Operations

```python
# search — returns recordset
orders = self.env['sale.order'].search([('state', '=', 'draft')], limit=10)

# browse — by known IDs
order = self.env['sale.order'].browse(42)

# filtered — subset of recordset
confirmed = orders.filtered(lambda o: o.state == 'confirm')

# mapped — extract field values
totals = orders.mapped('amount_total')          # list of floats
partners = orders.mapped('partner_id')          # recordset

# sorted
orders_sorted = orders.sorted(key=lambda o: o.date_order, reverse=True)

# exists — safe check after browse
if order.exists():
    order.action_confirm()
```

---

## x2many Operations (Command API)

Load `assets/x2many-commands.py` for full examples. Quick reference:

```python
from odoo import Command

# Create a new related record
order.write({'line_ids': [Command.create({'product_id': 1, 'qty': 2})]})

# Link an existing record (Many2many only)
order.write({'tag_ids': [Command.link(tag.id)]})

# Unlink without deleting (Many2many only)
order.write({'tag_ids': [Command.unlink(tag.id)]})

# Delete a related record
order.write({'line_ids': [Command.delete(line.id)]})

# Replace entire list (Many2many)
order.write({'tag_ids': [Command.set([tag1.id, tag2.id])]})

# Update an existing related record
order.write({'line_ids': [Command.update(line.id, {'qty': 5})]})
```

---

## ORM Method Overrides

```python
@api.model_create_multi
def create(self, vals_list):
    for vals in vals_list:
        if vals.get('name', _('New')) == _('New'):
            vals['name'] = self.env['ir.sequence'].next_by_code('sale.order')
    return super().create(vals_list)

def write(self, vals):
    # Add logic before write
    result = super().write(vals)
    # Add logic after write
    return result

def unlink(self):
    for record in self:
        if record.state not in ('draft', 'cancel'):
            raise UserError(_('Cannot delete a confirmed order.'))
    return super().unlink()
```

> **Note**: Use `@api.model_create_multi` (not `@api.model`) in v16+ for batch creates.

---

## Assets

| File | When to load |
|------|-------------|
| `assets/model-template.py` | Starting a new model from scratch |
| `assets/computed-field-template.py` | Adding computed fields with dependencies |
| `assets/x2many-commands.py` | Working with One2many or Many2many writes |

---

## Common Mistakes

1. **Using `name_get()`** — deprecated v17, removed v18. Use `_rec_name` or `display_name`.
2. **Forgetting `@api.model_create_multi`** — use it instead of `@api.model` for `create()`.
3. **Using tuple syntax `(0, 0, {})`** — replace with `Command.create({})`.
4. **Not calling `super()`** in ORM overrides — always call `super()` or you break inheritance.
5. **`search()` without domain on large tables** — always add a domain or `limit=`.

---

## References

| File | Content |
|------|---------|
| `references/field-types.md` | All field types with parameters and version notes |
| `references/version-differences.md` | ORM changes across v16 / v17 / v18 |

---

## Metadata

- **Skill ID**: ODSK-ORM-CORE
- **Author**: [Geraldow](https://github.com/Geraldow)
- **Repo**: https://github.com/Yven-Labs/odoo-skills
