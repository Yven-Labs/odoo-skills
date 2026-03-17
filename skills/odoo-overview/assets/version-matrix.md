# Odoo Version Matrix — Detailed Reference

## Python Compatibility

| Odoo Version | Python Min | Python Max | Recommended |
|-------------|-----------|-----------|-------------|
| 17.0 | 3.10 | 3.12 | 3.10 |
| 18.0 | 3.10 | 3.12 | 3.12 |

---

## Breaking Changes: v17 vs v18

### What v17 already changed (from prior versions)

These patterns are **WRONG** in both v17 and v18:

#### `attrs` attribute REMOVED from XML views

```xml
<!-- WRONG — crashes on v17+ -->
<field name="amount" attrs="{'invisible': [('state', '!=', 'draft')]}"/>
<field name="notes" attrs="{'required': [('type', '=', 'service')]}"/>

<!-- CORRECT — inline Python expressions -->
<field name="amount" invisible="state != 'draft'"/>
<field name="notes" required="type == 'service'"/>
```

#### `name_get()` deprecated (v17) / removed (v18)

```python
# WRONG — deprecated in v17, removed in v18
def name_get(self):
    return [(r.id, f"[{r.code}] {r.name}") for r in self]

# CORRECT — override _compute_display_name
def _compute_display_name(self):
    for rec in self:
        rec.display_name = f"[{rec.code}] {rec.name}"
```

#### `type="json"` renamed in controllers

```python
# WRONG — renamed in v17
@http.route('/api/data', type='json', auth='user')
def get_data(self, **kwargs):
    return {'status': 'ok'}

# CORRECT
@http.route('/api/data', type='jsonrpc', auth='user')
def get_data(self, **kwargs):
    return {'status': 'ok'}
```

#### `mail.channel` renamed to `discuss.channel`

```python
# WRONG — renamed in v17
channel = self.env['mail.channel'].create({...})

# CORRECT
channel = self.env['discuss.channel'].create({...})
```

#### `Command` objects replace tuples for x2many

```python
# WRONG — deprecated tuple syntax
record.write({'tag_ids': [(4, tag_id)]})
record.write({'line_ids': [(0, 0, {'name': 'New'})]})
record.write({'tag_ids': [(3, tag_id)]})
record.write({'line_ids': [(5, 0, 0)]})

# CORRECT — Command objects
from odoo.fields import Command
record.write({'tag_ids': [Command.link(tag_id)]})
record.write({'line_ids': [Command.create({'name': 'New'})]})
record.write({'tag_ids': [Command.unlink(tag_id)]})
record.write({'line_ids': [Command.clear()]})
```

#### Record rule defaults changed

```python
# Before v17 — record rules apply to all CRUD by default
# v17+ — record rules apply to read by default, must explicitly set:
#   perm_read, perm_write, perm_create, perm_unlink
```

---

### v17 → v18 specific changes

#### `ir_property` table removed — JSONB columns

```python
# v17 — company-dependent fields stored in ir_property table
# v18 — stored directly as JSONB columns on the model's table
# Impact: direct SQL queries on ir_property will break
```

#### `groups_id` renamed to `group_ids` on res.users

```python
# v17
user.groups_id = [(4, group_id)]

# v18
user.group_ids = [Command.link(group_id)]
```

#### `search_fetch()` method added

```python
# v17 — search then read (2 queries)
records = self.search(domain)
data = records.read(['name', 'state'])

# v18 — single optimized query
records = self.search_fetch(domain, ['name', 'state'])
```

---

## Feature Availability Matrix

| Feature | v17 | v18 |
|---------|:---:|:---:|
| `attrs` in XML | No | No |
| Inline view expressions | Yes | Yes |
| `name_get()` | Deprecated | No |
| `_compute_display_name` | Yes | Yes |
| `type="json"` controller | No | No |
| `type="jsonrpc"` controller | Yes | Yes |
| `mail.channel` | No | No |
| `discuss.channel` | Yes | Yes |
| Tuple x2many syntax | Deprecated | No |
| `Command` objects | Yes | Yes |
| `ir_property` table | Yes | No |
| JSONB company fields | No | Yes |
| `groups_id` | Yes | No |
| `group_ids` | No | Yes |
| `search_fetch()` | No | Yes |
| OWL 2 | Yes | Yes |
| `t-out` | Yes | Yes |
