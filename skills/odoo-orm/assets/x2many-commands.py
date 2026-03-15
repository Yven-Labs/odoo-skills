# Odoo ORM - x2many Command API Patterns
# Reference for odoo-orm skill

from odoo import Command, api, fields, models


class OrderExample(models.Model):
    _name = 'example.order'
    _description = 'x2many Command Examples'

    name = fields.Char(required=True)
    line_ids = fields.One2many('example.order.line', 'order_id', string='Lines')
    tag_ids = fields.Many2many('example.order.tag', string='Tags')


# =============================================================================
# TUPLE SYNTAX vs COMMAND API
# The Command class replaces the old tuple syntax. It is explicit, readable,
# and type-safe. Use it for ALL x2many operations in v17+.
# =============================================================================


def demo_bad_tuple_syntax(order):
    """BAD: Old tuple syntax — cryptic integers, easy to mix up."""
    order.write({
        'line_ids': [
            (0, 0, {'name': 'Line 1', 'qty': 2.0}),  # what does 0,0 mean?
            (1, 5, {'qty': 3.0}),                      # update? delete? unclear
            (2, 5, 0),                                  # which id is this?
        ]
    })


def demo_good_command_api(order, line_id):
    """GOOD: Command API — self-documenting, no magic integers."""
    order.write({
        'line_ids': [
            Command.create({'name': 'Line 1', 'qty': 2.0}),
            Command.update(line_id, {'qty': 3.0}),
            Command.delete(line_id),
        ]
    })


# =============================================================================
# COMMAND.CREATE — One2many AND Many2many
# Creates a new related record and links it to the parent.
# Replaces old: (0, 0, {values})
# =============================================================================


def demo_command_create(order):
    order.write({
        'line_ids': [
            Command.create({'name': 'Line 1', 'qty': 2.0, 'price': 50.0}),
            Command.create({'name': 'Line 2', 'qty': 1.0, 'price': 100.0}),
        ]
    })


# =============================================================================
# COMMAND.UPDATE — One2many AND Many2many
# Updates fields on an existing related record (does NOT unlink it).
# Replaces old: (1, id, {values})
# =============================================================================


def demo_command_update(order, line_id):
    order.write({
        'line_ids': [
            Command.update(line_id, {'qty': 5.0, 'price': 75.0}),
        ]
    })


# =============================================================================
# COMMAND.DELETE — One2many AND Many2many
# Deletes the related record from the database entirely.
# Replaces old: (2, id, 0)
# =============================================================================


def demo_command_delete(order, line_id):
    order.write({
        'line_ids': [
            Command.delete(line_id),
        ]
    })


# =============================================================================
# COMMAND.UNLINK — Many2many ONLY
# Removes the record from the relation WITHOUT deleting it from the DB.
# Use when the record can exist independently (e.g. tags, categories).
# Replaces old: (3, id, 0)
# =============================================================================


def demo_command_unlink(order, tag_id):
    """GOOD: removes tag from this order, tag still exists in the system."""
    order.write({
        'tag_ids': [
            Command.unlink(tag_id),
        ]
    })


def demo_bad_unlink_on_o2m(order, line_id):
    """BAD: Command.unlink on One2many — use Command.delete instead."""
    # This raises an error on One2many fields.
    # One2many records are OWNED by the parent; unlink doesn't apply.
    order.write({
        'line_ids': [
            Command.unlink(line_id),  # ← ERROR: use Command.delete for O2m
        ]
    })


# =============================================================================
# COMMAND.LINK — Many2many ONLY
# Adds an existing record to the Many2many relation (no new record created).
# Replaces old: (4, id, 0)
# =============================================================================


def demo_command_link(order, existing_tag_id):
    order.write({
        'tag_ids': [
            Command.link(existing_tag_id),
        ]
    })


# =============================================================================
# COMMAND.CLEAR — Many2many ONLY
# Removes ALL records from the relation without deleting them from the DB.
# Replaces old: (5, 0, 0)
# =============================================================================


def demo_command_clear(order):
    order.write({
        'tag_ids': [Command.clear()],
    })


# =============================================================================
# COMMAND.SET — Many2many ONLY
# Replaces the entire relation with a new list of IDs (atomic clear + link).
# Replaces old: (6, 0, [ids])
# =============================================================================


def demo_command_set(order, tag_ids):
    order.write({
        'tag_ids': [Command.set(tag_ids)],   # e.g. [1, 2, 3]
    })


# =============================================================================
# REAL-WORLD: create() override with Command
# Adding a default line when none are provided.
# =============================================================================


@api.model_create_multi
def create(self, vals_list):
    for vals in vals_list:
        if not vals.get('line_ids'):
            # Always use Command.create — never the old tuple syntax
            vals['line_ids'] = [
                Command.create({
                    'name': 'Default Line',
                    'qty': 1.0,
                    'price': 0.0,
                })
            ]
    return super().create(vals_list)


# =============================================================================
# QUICK REFERENCE
#
#  Old syntax       │ Command API equivalent     │ One2many │ Many2many
# ──────────────────┼────────────────────────────┼──────────┼──────────
#  (0, 0, vals)     │ Command.create(vals)        │    ✅    │    ✅
#  (1, id, vals)    │ Command.update(id, vals)    │    ✅    │    ✅
#  (2, id, 0)       │ Command.delete(id)          │    ✅    │    ✅
#  (3, id, 0)       │ Command.unlink(id)          │    ❌    │    ✅
#  (4, id, 0)       │ Command.link(id)            │    ❌    │    ✅
#  (5, 0, 0)        │ Command.clear()             │    ❌    │    ✅
#  (6, 0, [ids])    │ Command.set([ids])          │    ❌    │    ✅
# =============================================================================
