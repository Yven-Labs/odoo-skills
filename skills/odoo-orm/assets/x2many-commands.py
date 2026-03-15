# =============================================================================
# x2many Command API — Odoo v16+ (mandatory style in v17+)
# Author: Geraldow | https://github.com/Yven-Labs/odoo-skills
# =============================================================================
# The Command class replaces the old tuple syntax (0,0,{}), (1,id,{}), etc.
# It is explicit, readable, and type-safe.
#
# Import:  from odoo import Command
# =============================================================================

from odoo import Command, api, fields, models


class OrderExample(models.Model):
    _name = 'example.order'
    _description = 'x2many Command Examples'

    name = fields.Char(required=True)
    line_ids = fields.One2many('example.order.line', 'order_id', string='Lines')
    tag_ids = fields.Many2many('example.order.tag', string='Tags')

    # -------------------------------------------------------------------------
    # Command.create — create a new related record and link it
    # Replaces old: (0, 0, {values})
    # -------------------------------------------------------------------------
    def demo_command_create(self):
        self.write({
            'line_ids': [
                Command.create({'name': 'Line 1', 'qty': 2.0, 'price': 50.0}),
                Command.create({'name': 'Line 2', 'qty': 1.0, 'price': 100.0}),
            ]
        })

    # -------------------------------------------------------------------------
    # Command.update — update an existing related record
    # Replaces old: (1, id, {values})
    # -------------------------------------------------------------------------
    def demo_command_update(self, line):
        self.write({
            'line_ids': [
                Command.update(line.id, {'qty': 5.0, 'price': 75.0}),
            ]
        })

    # -------------------------------------------------------------------------
    # Command.delete — delete a related record from DB
    # Replaces old: (2, id, 0)
    # -------------------------------------------------------------------------
    def demo_command_delete(self, line):
        self.write({
            'line_ids': [
                Command.delete(line.id),
            ]
        })

    # -------------------------------------------------------------------------
    # Command.unlink — remove from relation WITHOUT deleting the record
    # Only valid for Many2many. Replaces old: (3, id, 0)
    # -------------------------------------------------------------------------
    def demo_command_unlink(self, tag):
        self.write({
            'tag_ids': [
                Command.unlink(tag.id),
            ]
        })

    # -------------------------------------------------------------------------
    # Command.link — add an existing record to a Many2many relation
    # Replaces old: (4, id, 0)
    # -------------------------------------------------------------------------
    def demo_command_link(self, tag):
        self.write({
            'tag_ids': [
                Command.link(tag.id),
            ]
        })

    # -------------------------------------------------------------------------
    # Command.clear — remove ALL records from a Many2many (without deleting)
    # Replaces old: (5, 0, 0)
    # -------------------------------------------------------------------------
    def demo_command_clear(self):
        self.write({
            'tag_ids': [Command.clear()],
        })

    # -------------------------------------------------------------------------
    # Command.set — replace entire Many2many with a new list of IDs
    # Replaces old: (6, 0, [ids])
    # -------------------------------------------------------------------------
    def demo_command_set(self, tag_ids):
        self.write({
            'tag_ids': [Command.set(tag_ids)],   # e.g. [1, 2, 3]
        })

    # -------------------------------------------------------------------------
    # Real-world example: create() override with Command
    # -------------------------------------------------------------------------
    @api.model_create_multi
    def create(self, vals_list):
        for vals in vals_list:
            # Add a default line when no lines are provided
            if not vals.get('line_ids'):
                vals['line_ids'] = [
                    Command.create({
                        'name': 'Default Line',
                        'qty': 1.0,
                        'price': 0.0,
                    })
                ]
        return super().create(vals_list)


# =============================================================================
# QUICK REFERENCE — old tuple syntax vs Command API
# =============================================================================
#
#  Old syntax       │ Command API equivalent
# ──────────────────┼──────────────────────────────────
#  (0, 0, vals)     │ Command.create(vals)
#  (1, id, vals)    │ Command.update(id, vals)
#  (2, id, 0)       │ Command.delete(id)
#  (3, id, 0)       │ Command.unlink(id)   [M2M only]
#  (4, id, 0)       │ Command.link(id)     [M2M only]
#  (5, 0, 0)        │ Command.clear()      [M2M only]
#  (6, 0, [ids])    │ Command.set([ids])   [M2M only]
# =============================================================================
