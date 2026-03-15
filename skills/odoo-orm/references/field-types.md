# Odoo Field Types — Complete Reference

## Scalar Fields

| Type | Python class | Common parameters | Notes |
|------|-------------|-------------------|-------|
| `Char` | `fields.Char` | `size`, `trim`, `translate` | Short text. `size` limits DB column. `translate=True` for i18n |
| `Text` | `fields.Text` | `translate` | Long text, no size limit |
| `Html` | `fields.Html` | `sanitize`, `sanitize_tags`, `strip_style` | Rich text. Always use `sanitize=True` |
| `Integer` | `fields.Integer` | — | 32-bit signed integer |
| `Float` | `fields.Float` | `digits=(precision, scale)` | `digits=(16, 2)` → 2 decimal places |
| `Monetary` | `fields.Monetary` | `currency_field` | Requires a `Many2one('res.currency')` field on the same model |
| `Boolean` | `fields.Boolean` | — | `default=False` if not specified |
| `Date` | `fields.Date` | — | Stored as `date` in PostgreSQL. Use `fields.Date.today` as default |
| `Datetime` | `fields.Datetime` | — | Stored as UTC in PostgreSQL. Use `fields.Datetime.now` as default |
| `Binary` | `fields.Binary` | `attachment` | `attachment=True` stores in `ir.attachment` instead of DB column |
| `Image` | `fields.Image` | `max_width`, `max_height` | Subclass of Binary, auto-resizes |
| `Selection` | `fields.Selection` | `selection`, `selection_add` | `selection` is a list of `(value, label)` tuples. Use `selection_add` to extend in inherited models |

## Relational Fields

| Type | Python class | Required parameters | Notes |
|------|-------------|---------------------|-------|
| `Many2one` | `fields.Many2one` | `comodel_name` | FK to another model. `ondelete='restrict'` or `'cascade'` or `'set null'` |
| `One2many` | `fields.One2many` | `comodel_name`, `inverse_name` | Virtual field — no column in DB. `inverse_name` = Many2one field on the child model |
| `Many2many` | `fields.Many2many` | `comodel_name` | Relation table auto-generated. Specify `relation`, `column1`, `column2` if you need a custom table name |

## Special / Computed Fields

| Type | Python class | Notes |
|------|-------------|-------|
| `Reference` | `fields.Reference` | Dynamic M2o — stores model name + ID. Rarely used |
| `Properties` | `fields.Properties` | Flexible key-value store. Used in project/tasks |

## Common Parameters (All Fields)

| Parameter | Type | Description |
|-----------|------|-------------|
| `string` | str | Field label in UI. Defaults to field name if omitted |
| `required` | bool | NOT NULL constraint in DB |
| `readonly` | bool | Read-only in UI (not enforced at ORM level) |
| `store` | bool | Whether to persist in DB (default `True` for regular fields, `False` for computed) |
| `index` | bool / `'btree'` / `'trigram'` | Creates DB index. Use `index='btree'` for M2o fields queried often |
| `copy` | bool | Whether to copy field value on `record.copy()`. Default `True` |
| `default` | value / callable | Default value. Use `lambda self:` for dynamic defaults |
| `compute` | str | Method name for computed field |
| `depends` | — | Used via `@api.depends(...)` decorator on compute method |
| `inverse` | str | Method name for writable computed field |
| `related` | str | Dot-notation path for related field |
| `tracking` | bool / int | Requires `mail.thread`. Logs changes in chatter |
| `translate` | bool | Enables field translation. Only for `Char`, `Text`, `Html` |
| `groups` | str | Restricts field visibility to XML ID groups |
| `sanitize` | bool | HTML sanitization for `Html` fields |

## Version Notes

| Feature | v17 | v18 |
|---------|-----|-----|
| `fields.Image` | ✅ | ✅ |
| `fields.Properties` | ✅ | ✅ |
| `tracking=True` on Selection | ✅ | ✅ |
| `index='trigram'` (full-text) | ✅ | ✅ |
| `translate=True` on Html | ✅ | ✅ |
