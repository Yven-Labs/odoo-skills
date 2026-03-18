# View Attributes — Compatibility Reference (v16 / v17 / v18)

## Breaking Changes Summary

| Attribute / Feature          | v16         | v17          | v18          | Notes                                    |
| ---------------------------- | ----------- | ------------ | ------------ | ---------------------------------------- |
| `attrs=`                     | ✅ Valid    | ❌ Removed   | ❌ Removed   | Use inline `invisible`/`required`/`readonly` |
| `states=` on buttons/fields  | ✅ Valid    | ❌ Removed   | ❌ Removed   | Use `invisible="state not in (...)"`     |
| `@colors` on `<tree>`        | ✅ Valid    | ❌ Removed   | ❌ Removed   | Use `decoration-*` on `<list>`           |
| `@fonts` on `<tree>`         | ✅ Valid    | ❌ Removed   | ❌ Removed   | Use `decoration-bf` / `decoration-it`    |
| Inline `invisible=`          | ⚠️ Partial | ✅ Required  | ✅ Required  | Python expression, not domain list       |
| Inline `required=`           | ⚠️ Partial | ✅ Required  | ✅ Required  | Python expression                        |
| Inline `readonly=`           | ⚠️ Partial | ✅ Required  | ✅ Required  | Python expression                        |
| `decoration-*` on `<list>`   | ✅ Valid    | ✅ Valid     | ✅ Valid     | Row and cell level                       |
| `<tree>` tag                 | ✅ Valid    | ✅ Alias     | ✅ Alias     | `<list>` is preferred in v17+            |
| `widget="statusbar"`         | ✅ Valid    | ✅ Valid     | ✅ Valid     | On `state` Selection fields              |
| `widget="badge"`             | ✅ Valid    | ✅ Valid     | ✅ Valid     | Inline display of selection value        |
| `widget="handle"`            | ✅ Valid    | ✅ Valid     | ✅ Valid     | Drag handle for `sequence` field         |
| `optional="hide"`            | ✅ Valid    | ✅ Valid     | ✅ Valid     | Column hidden by default, user can show  |
| `optional="show"`            | ✅ Valid    | ✅ Valid     | ✅ Valid     | Column shown by default, user can hide   |
| `column_invisible="1"`       | ✅ Valid    | ✅ Valid     | ✅ Valid     | Always hidden (used for technical fields)|
| `multi_edit="1"` on `<list>` | ✅ Valid    | ✅ Valid     | ✅ Valid     | Allows editing multiple rows at once     |
| `editable="bottom"`          | ✅ Valid    | ✅ Valid     | ✅ Valid     | Inline editing, new rows at bottom       |
| `editable="top"`             | ✅ Valid    | ✅ Valid     | ✅ Valid     | Inline editing, new rows at top          |
| `<chatter/>`                 | ✅ Valid    | ✅ Valid     | ✅ Valid     | Requires `mail.thread` inheritance       |
| `confirm=` on buttons        | ✅ Valid    | ✅ Valid     | ✅ Valid     | Shows confirmation dialog before action  |

---

## Inline Expression Syntax (v17+)

Inline expressions are evaluated as Python. The context includes all field values of the current record plus special variables.

### Available context variables

| Variable | Type | Description |
|----------|------|-------------|
| Field names | any | All fields of the current model |
| `uid` | int | Current user ID |
| `id` | int | Current record ID (0 for new) |
| `parent.*` | any | Parent record fields (inside x2many lines) |
| `context.get(...)` | any | Active context values |

### Examples

```xml
<!-- Simple equality -->
<field name="date_end" invisible="state != 'fixed'"/>

<!-- Multiple conditions (use Python `and`/`or`, not & and |) -->
<field name="discount" invisible="state not in ('draft', 'confirm') or not show_discount"/>

<!-- Numeric comparison -->
<field name="penalty_amount" invisible="qty >= 0"/>

<!-- Access parent in x2many lines -->
<field name="note" invisible="not parent.show_notes"/>

<!-- Context-based visibility -->
<field name="cost" invisible="not context.get('show_cost')"/>
```

---

## `decoration-*` Attribute Reference

Applies to `<list>` (row level) and `<field>` (cell level, badge widget).

| Attribute | Bootstrap color | Typical use |
|-----------|----------------|-------------|
| `decoration-success` | Green | Done, confirmed, active |
| `decoration-warning` | Orange/yellow | Pending, near deadline |
| `decoration-danger` | Red | Cancelled, overdue, error |
| `decoration-info` | Blue | Information, informational state |
| `decoration-muted` | Grey | Archived, inactive, disabled |
| `decoration-primary` | Primary blue | Main/highlighted items |
| `decoration-bf` | Bold | Emphasis |
| `decoration-it` | Italic | Secondary emphasis |

---

## `<xpath>` Position Values

| Position | Behavior |
|----------|----------|
| `after` | Insert sibling node AFTER the matched node |
| `before` | Insert sibling node BEFORE the matched node |
| `inside` | Append child node INSIDE the matched node |
| `replace` | Replace the entire matched node with new content |
| `attributes` | Modify attributes only — children must be `<attribute name="...">value</attribute>` |

---

## Statusbar Widget Options

```xml
<!-- Show specific states as milestones in the status bar -->
<field name="state"
       widget="statusbar"
       statusbar_visible="draft,confirm,done"/>

<!-- Allow user to click directly on a state to jump to it -->
<field name="state"
       widget="statusbar"
       statusbar_visible="draft,confirm,done"
       statusbar_onclick="true"/>
```

> **Note**: `statusbar_onclick="true"` only works if the model has the appropriate write access and the state flow allows it. Use buttons for controlled transitions.

---

## Migration Guide: v16 → v17

### attrs removal

```xml
<!-- ❌ v16 style -->
<field name="date_end"
       attrs="{'invisible': [('type', '!=', 'fixed')],
               'required': [('type', '=', 'fixed')],
               'readonly': [('state', '!=', 'draft')]}"/>

<!-- ✅ v17+ style — one attribute per condition -->
<field name="date_end"
       invisible="type != 'fixed'"
       required="type == 'fixed'"
       readonly="state != 'draft'"/>
```

### states removal on buttons

```xml
<!-- ❌ v16 style -->
<button name="action_confirm" states="draft,sent" string="Confirm" type="object"/>

<!-- ✅ v17+ style -->
<button name="action_confirm"
        string="Confirm"
        type="object"
        invisible="state not in ('draft', 'sent')"/>
```

### colors/fonts removal in list

```xml
<!-- ❌ v16 style -->
<tree colors="red:state=='cancel';green:state=='done'"
      fonts="italic:state=='draft'">

<!-- ✅ v17+ style -->
<list decoration-danger="state == 'cancel'"
      decoration-success="state == 'done'"
      decoration-it="state == 'draft'">
```
