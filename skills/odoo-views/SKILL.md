---
name: odoo-views
description: >
  Guides AI agents to write correct, version-aware Odoo XML views (form, list,
  search, kanban) for Odoo v17 and v18. Prevents deprecated attribute usage
  (attrs, states, @colors) and enforces inline expression syntax and OCA conventions.
  Trigger: When creating or modifying XML views, inheriting views with xpath,
  adding buttons or conditional visibility, or defining form/list/search layouts.
license: MIT
metadata:
  author: Geraldow
  version: "1.0.0"
  scope: [root, core]
  supported_versions: ["17", "18"]
  default_version: "18"
  detect_from: "__manifest__.py"
  auto_invoke:
    - "Creating or modifying Odoo XML views"
    - "Adding form, list, tree, or search views"
    - "Inheriting and extending views with xpath"
    - "Adding buttons with conditional visibility"
    - "Defining statusbar or header sections"
    - "Using invisible, required, or readonly on fields"
---

## When to Use

Load this skill when:

- Creating a new form, list/tree, search, or kanban view
- Inheriting an existing view with `<xpath>` or `<field position="...">`
- Adding conditional visibility (`invisible`, `required`, `readonly`) to fields or buttons
- Defining a `<header>` with statusbar widget and action buttons
- Adding decorations to list view rows (`decoration-success`, `decoration-warning`, etc.)
- Unsure whether a view attribute is still valid in Odoo v17 or v18

---

## Version Detection

Before applying any rule:
- Search for `__manifest__.py` in the current directory
- Extract the `version` field value (e.g., `'17.0.1.0.0'`)
- Parse the first segment as the Odoo major version (17, 18, etc.)
- Apply only rules tagged `[v17+]`, `[v18+]`, etc. that match

---

## Critical Rules

These rules prevent **silent failures** and **version crashes**:

### [v17+] NEVER use `attrs`

The `attrs` attribute was removed in v17. Use inline Python expressions directly on the field attributes.

```xml
<!-- ❌ WRONG — attrs removed in v17, will silently do nothing or error -->
<field name="date_end"
       attrs="{'invisible': [('type', '!=', 'fixed')],
               'required': [('type', '=', 'fixed')]}"/>

<!-- ✅ CORRECT — inline expressions (v17+) -->
<field name="date_end"
       invisible="type != 'fixed'"
       required="type == 'fixed'"/>
```

Multi-condition example:

```xml
<!-- ❌ WRONG -->
<button name="action_confirm"
        attrs="{'invisible': [('state', 'not in', ['draft', 'sent'])]}"/>

<!-- ✅ CORRECT -->
<button name="action_confirm"
        invisible="state not in ('draft', 'sent')"/>
```

---

### [v17+] NEVER use `states` attribute

The `states` attribute on buttons and fields was removed in v17. Use `invisible` with a state condition.

```xml
<!-- ❌ WRONG — states attribute removed in v17 -->
<button name="action_confirm" states="draft,sent" string="Confirm"/>

<!-- ✅ CORRECT -->
<button name="action_confirm"
        string="Confirm"
        invisible="state not in ('draft', 'sent')"/>
```

---

### [v17+] NEVER use `@colors` or `@fonts` in list views

Tree/list view decorations changed syntax entirely in v17.

```xml
<!-- ❌ WRONG — removed in v17 -->
<tree colors="red:state=='cancel';green:state=='done'" fonts="italic:state=='draft'">

<!-- ✅ CORRECT — use decoration-* attributes on <tree>/<list> -->
<list decoration-danger="state == 'cancel'"
      decoration-success="state == 'done'"
      decoration-muted="active == False">
```

Available decorations: `decoration-success`, `decoration-warning`, `decoration-danger`,
`decoration-info`, `decoration-muted`, `decoration-primary`, `decoration-bf` (bold), `decoration-it` (italic).

---

### [v17+] `<tree>` vs `<list>` tag name

Both are accepted in v17/v18. `<list>` is the preferred modern tag. `<tree>` still works as an alias.

```xml
<!-- ✅ Both valid in v17/v18 — prefer <list> for new views -->
<list>...</list>
<tree>...</tree>
```

---

## View Structure Patterns

### Form View

```xml
<record id="view_prefix_model_form" model="ir.ui.view">
    <field name="name">prefix.model.form</field>
    <field name="model">prefix.model</field>
    <field name="arch" type="xml">
        <form string="Model Name">

            <!-- Header: status buttons + statusbar -->
            <header>
                <button name="action_confirm"
                        string="Confirm"
                        type="object"
                        class="btn-primary"
                        invisible="state != 'draft'"/>
                <button name="action_cancel"
                        string="Cancel"
                        type="object"
                        invisible="state in ('done', 'cancel')"/>
                <field name="state"
                       widget="statusbar"
                       statusbar_visible="draft,confirm,done"/>
            </header>

            <!-- Sheet: main form content -->
            <sheet>
                <!-- Smart buttons area (optional) -->
                <div class="oe_button_box" name="button_box">
                    <button class="oe_stat_button"
                            type="object"
                            name="action_view_related"
                            icon="fa-list">
                        <field name="related_count" widget="statinfo" string="Items"/>
                    </button>
                </div>

                <!-- Title area -->
                <div class="oe_title">
                    <h1>
                        <field name="name" placeholder="Reference..."/>
                    </h1>
                </div>

                <!-- Main fields — two-column layout -->
                <group>
                    <group>
                        <field name="partner_id"/>
                        <field name="date"/>
                    </group>
                    <group>
                        <field name="company_id" groups="base.group_multi_company"/>
                        <field name="currency_id" invisible="1"/>
                    </group>
                </group>

                <!-- Tabbed sections -->
                <notebook>
                    <page string="Lines" name="page_lines">
                        <field name="line_ids">
                            <list editable="bottom">
                                <field name="product_id"/>
                                <field name="qty"/>
                                <field name="price_unit"/>
                                <field name="price_subtotal"/>
                            </list>
                        </field>
                    </page>
                    <page string="Notes" name="page_notes">
                        <field name="notes" placeholder="Internal notes..."/>
                    </page>
                </notebook>
            </sheet>

            <!-- Chatter — only when model inherits mail.thread -->
            <chatter/>
        </form>
    </field>
</record>
```

---

### List View

```xml
<record id="view_prefix_model_list" model="ir.ui.view">
    <field name="name">prefix.model.list</field>
    <field name="model">prefix.model</field>
    <field name="arch" type="xml">
        <list string="Models"
              decoration-danger="state == 'cancel'"
              decoration-success="state == 'done'"
              decoration-muted="active == False">
            <field name="name"/>
            <field name="partner_id"/>
            <field name="date"/>
            <field name="amount_total" sum="Total"/>
            <field name="state"
                   widget="badge"
                   decoration-success="state == 'done'"
                   decoration-warning="state == 'confirm'"
                   decoration-danger="state == 'cancel'"/>
            <!-- optional="hide" columns are hidden by default but user can enable -->
            <field name="company_id" optional="hide" groups="base.group_multi_company"/>
        </list>
    </field>
</record>
```

---

### Search View

```xml
<record id="view_prefix_model_search" model="ir.ui.view">
    <field name="name">prefix.model.search</field>
    <field name="model">prefix.model</field>
    <field name="arch" type="xml">
        <search string="Search Models">

            <!-- Text search fields -->
            <field name="name" string="Reference"/>
            <field name="partner_id" operator="child_of"/>

            <!-- Filters -->
            <filter string="My Records"
                    name="filter_my_records"
                    domain="[('user_id', '=', uid)]"/>
            <filter string="Draft"
                    name="filter_draft"
                    domain="[('state', '=', 'draft')]"/>
            <filter string="Done"
                    name="filter_done"
                    domain="[('state', '=', 'done')]"/>

            <separator/>

            <filter string="Archived"
                    name="filter_archived"
                    domain="[('active', '=', False)]"/>

            <!-- Group by -->
            <group expand="0" string="Group By">
                <filter string="Status"
                        name="groupby_state"
                        context="{'group_by': 'state'}"/>
                <filter string="Partner"
                        name="groupby_partner"
                        context="{'group_by': 'partner_id'}"/>
                <filter string="Date: Month"
                        name="groupby_date_month"
                        context="{'group_by': 'date:month'}"/>
            </group>

        </search>
    </field>
</record>
```

---

### Kanban View

```xml
<record id="view_prefix_model_kanban" model="ir.ui.view">
    <field name="name">prefix.model.kanban</field>
    <field name="model">prefix.model</field>
    <field name="arch" type="xml">
        <kanban default_group_by="state" quick_create="false">

            <!-- Declare ALL fields used in the template -->
            <field name="id"/>
            <field name="name"/>
            <field name="state"/>
            <field name="partner_id"/>
            <field name="user_id"/>
            <field name="color"/>

            <progressbar field="state"
                         colors='{"done": "success", "cancel": "danger"}'/>

            <templates>
                <t t-name="card">
                    <div class="oe_kanban_card oe_kanban_global_click">
                        <div class="o_kanban_record_top">
                            <div class="o_kanban_record_headings">
                                <strong class="o_kanban_record_title">
                                    <field name="name"/>
                                </strong>
                            </div>
                        </div>
                        <div class="o_kanban_record_body">
                            <field name="partner_id"/>
                        </div>
                        <div class="o_kanban_record_bottom">
                            <div class="oe_kanban_bottom_left">
                                <field name="activity_ids" widget="kanban_activity"/>
                            </div>
                            <div class="oe_kanban_bottom_right">
                                <field name="user_id" widget="many2one_avatar_user" readonly="1"/>
                            </div>
                        </div>
                    </div>
                </t>
            </templates>
        </kanban>
    </field>
</record>
```

**Key rules for kanban:**
- Declare every field used in the template inside `<kanban>` (before `<templates>`) — otherwise values are `undefined`.
- `oe_kanban_global_click` makes the entire card open the record on click.
- `quick_create="false"` disables the inline quick-create input per column — recommended when your model has required fields.
- `activity_ids` widget requires `mail.activity.mixin` on the model.
- `many2one_avatar_user` shows the user's avatar photo.

---

### View Inheritance with `<xpath>`

```xml
<record id="view_prefix_model_form_inherit" model="ir.ui.view">
    <field name="name">prefix.model.form.inherit</field>
    <field name="model">prefix.model</field>
    <field name="inherit_id" ref="module_name.view_prefix_model_form"/>
    <field name="arch" type="xml">

        <!-- Add field AFTER an existing field -->
        <xpath expr="//field[@name='partner_id']" position="after">
            <field name="partner_ref"/>
        </xpath>

        <!-- Add field BEFORE an existing field -->
        <xpath expr="//field[@name='date']" position="before">
            <field name="date_expected"/>
        </xpath>

        <!-- Replace field content -->
        <xpath expr="//field[@name='notes']" position="replace">
            <field name="notes" widget="html"/>
        </xpath>

        <!-- Modify attributes only (no content change) -->
        <xpath expr="//field[@name='amount_total']" position="attributes">
            <attribute name="invisible">state != 'done'</attribute>
        </xpath>

        <!-- Add inside a group -->
        <xpath expr="//group[@name='group_left']" position="inside">
            <field name="custom_field"/>
        </xpath>

        <!-- Shorthand — field position (simpler than xpath for single fields) -->
        <field name="partner_id" position="after">
            <field name="partner_ref"/>
        </field>

    </field>
</record>
```

**`position` values:**
- `after` — insert after the matched node
- `before` — insert before the matched node
- `inside` — append inside the matched node
- `replace` — replace the entire matched node
- `attributes` — modify only attributes (use `<attribute name="...">value</attribute>` children)

---

## Header & Statusbar

```xml
<header>
    <!-- Primary action — shown only in initial state -->
    <button name="action_confirm"
            string="Confirm"
            type="object"
            class="btn-primary"
            invisible="state != 'draft'"/>

    <!-- Secondary action -->
    <button name="action_send"
            string="Send by Email"
            type="object"
            invisible="state not in ('draft', 'confirm')"/>

    <!-- Danger action — explicit warning style -->
    <button name="action_cancel"
            string="Cancel"
            type="object"
            class="btn-danger"
            confirm="Are you sure you want to cancel?"
            invisible="state in ('done', 'cancel')"/>

    <!-- Statusbar — always visible states listed in statusbar_visible -->
    <field name="state"
           widget="statusbar"
           statusbar_visible="draft,confirm,done"
           statusbar_onclick="true"/>
</header>
```

---

## Assets

| File | When to load |
|------|-------------|
| `assets/form-template.xml` | Starting a new form view from scratch |
| `assets/list-template.xml` | Starting a new list view |
| `assets/search-template.xml` | Starting a new search view |
| `assets/kanban-template.xml` | Starting a new kanban view |

---

## Common Mistakes

1. **Using `attrs`** — removed v17. Use inline `invisible`, `required`, `readonly` expressions.
2. **Using `states` on buttons** — removed v17. Use `invisible="state not in (...)"`.
3. **Using `@colors`/`@fonts` in tree** — removed v17. Use `decoration-*` attributes on `<list>`.
4. **Wrong `xpath position`** — `attributes` does NOT insert nodes; use `inside`/`after` for that.
5. **Missing `type="object"` on buttons** — buttons without type do nothing; always specify `type`.
6. **`<chatter/>` without `mail.thread`** — only add chatter if the model inherits `mail.thread`.
7. **Undeclared fields in kanban** — every field used in `<templates>` MUST be listed inside `<kanban>` before `<templates>`, otherwise values are `undefined`.

---

## References

| File | Content |
|------|---------|
| `references/view-attributes.md` | All common view attributes with v16/v17/v18 compatibility |
