# =============================================================================
# Odoo Model Template — v17 / v18 compatible
# Author: Geraldow | https://github.com/Yven-Labs/odoo-skills
# =============================================================================
# Usage: Copy this file as a starting point for any new Odoo model.
#        Replace placeholders (PREFIX, ModelName, etc.) with real values.
# =============================================================================

from odoo import _, api, fields, models
from odoo.exceptions import UserError, ValidationError


class ModelName(models.Model):
    # -------------------------------------------------------------------------
    # Model definition
    # -------------------------------------------------------------------------
    _name = 'prefix.model.name'       # e.g. 'sale.order', 'account.move'
    _description = 'Human-readable description'
    _order = 'name asc, id desc'      # default sort order
    # _inherit = 'mail.thread'         # uncomment to add Chatter
    # _rec_name = 'name'               # field used as display name (default)

    # -------------------------------------------------------------------------
    # Fields
    # -------------------------------------------------------------------------
    name = fields.Char(
        string='Name',
        required=True,
        copy=False,
        default=lambda self: _('New'),
    )
    active = fields.Boolean(default=True)
    state = fields.Selection(
        selection=[
            ('draft', 'Draft'),
            ('confirm', 'Confirmed'),
            ('done', 'Done'),
            ('cancel', 'Cancelled'),
        ],
        string='Status',
        default='draft',
        required=True,
        tracking=True,   # requires _inherit = 'mail.thread'
    )
    date = fields.Date(string='Date', default=fields.Date.today)
    partner_id = fields.Many2one(
        comodel_name='res.partner',
        string='Partner',
        ondelete='restrict',
    )
    company_id = fields.Many2one(
        comodel_name='res.company',
        string='Company',
        default=lambda self: self.env.company,
    )
    currency_id = fields.Many2one(
        comodel_name='res.currency',
        related='company_id.currency_id',
        store=True,
    )
    amount_total = fields.Monetary(
        string='Total',
        compute='_compute_amount_total',
        store=True,
        currency_field='currency_id',
    )
    line_ids = fields.One2many(
        comodel_name='prefix.model.name.line',
        inverse_name='parent_id',
        string='Lines',
    )
    notes = fields.Html(string='Notes', sanitize=True)

    # -------------------------------------------------------------------------
    # Computed fields
    # -------------------------------------------------------------------------
    @api.depends('line_ids.price_subtotal')
    def _compute_amount_total(self):
        for rec in self:
            rec.amount_total = sum(rec.line_ids.mapped('price_subtotal'))

    # -------------------------------------------------------------------------
    # Constraints
    # -------------------------------------------------------------------------
    @api.constrains('date')
    def _check_date(self):
        for rec in self:
            if rec.date and rec.date < fields.Date.today():
                raise ValidationError(_('Date cannot be in the past.'))

    # -------------------------------------------------------------------------
    # ORM overrides
    # -------------------------------------------------------------------------
    @api.model_create_multi           # v14+ — accepts list of dicts
    def create(self, vals_list):
        for vals in vals_list:
            if vals.get('name', _('New')) == _('New'):
                vals['name'] = self.env['ir.sequence'].next_by_code(
                    'prefix.model.name'
                ) or _('New')
        return super().create(vals_list)

    def write(self, vals):
        # Add pre-write logic here if needed
        return super().write(vals)

    def unlink(self):
        for rec in self:
            if rec.state not in ('draft', 'cancel'):
                raise UserError(
                    _('You can only delete records in Draft or Cancelled state.')
                )
        return super().unlink()

    # -------------------------------------------------------------------------
    # Actions / business logic
    # -------------------------------------------------------------------------
    def action_confirm(self):
        self.write({'state': 'confirm'})

    def action_cancel(self):
        self.write({'state': 'cancel'})

    def action_reset_to_draft(self):
        self.write({'state': 'draft'})
