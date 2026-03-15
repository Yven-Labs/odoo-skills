# Odoo ORM - Model Template
# Reference for odoo-orm skill

from odoo import _, api, fields, models
from odoo.exceptions import UserError, ValidationError


class ModelName(models.Model):
    # =============================================================================
    # MODEL DEFINITION
    # =============================================================================
    _name = 'prefix.model.name'       # e.g. 'sale.order', 'account.move'
    _description = 'Human-readable description'
    _order = 'name asc, id desc'      # secondary sort by id keeps stable ordering
    # _inherit = 'mail.thread'         # uncomment to enable Chatter + tracking
    # _rec_name = 'name'               # field shown as display name (default: name)

    # =============================================================================
    # FIELDS
    # =============================================================================
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
        tracking=True,   # logs changes in chatter — requires mail.thread
    )
    date = fields.Date(string='Date', default=fields.Date.today)
    partner_id = fields.Many2one(
        comodel_name='res.partner',
        string='Partner',
        ondelete='restrict',   # prevent deleting a partner that is still in use
    )
    company_id = fields.Many2one(
        comodel_name='res.company',
        string='Company',
        default=lambda self: self.env.company,
    )
    currency_id = fields.Many2one(
        comodel_name='res.currency',
        related='company_id.currency_id',
        store=True,            # store=True allows search and group-by on currency
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
    tag_ids = fields.Many2many(
        comodel_name='prefix.model.tag',
        relation='prefix_model_tag_rel',  # explicit table name — avoids conflicts if you
        column1='model_id',               # have multiple Many2many to the same comodel
        column2='tag_id',
        string='Tags',
    )
    notes = fields.Html(string='Notes', sanitize=True)

    # =============================================================================
    # COMPUTED FIELDS
    # =============================================================================

    @api.depends('line_ids.price_subtotal')
    def _compute_amount_total(self):
        for rec in self:
            rec.amount_total = sum(rec.line_ids.mapped('price_subtotal'))

    # =============================================================================
    # CONSTRAINTS
    # =============================================================================

    @api.constrains('date')
    def _check_date(self):
        for rec in self:
            if rec.date and rec.date < fields.Date.today():
                raise ValidationError(_('Date cannot be in the past.'))

    # =============================================================================
    # ORM OVERRIDES
    # =============================================================================

    @api.model_create_multi           # v17+ — receives a list of dicts, not a single dict
    def create(self, vals_list):
        for vals in vals_list:
            if vals.get('name', _('New')) == _('New'):
                vals['name'] = self.env['ir.sequence'].next_by_code(
                    'prefix.model.name'
                ) or _('New')
        return super().create(vals_list)

    def write(self, vals):
        # Add pre-write validation or side effects here if needed
        return super().write(vals)

    def unlink(self):
        for rec in self:
            if rec.state not in ('draft', 'cancel'):
                raise UserError(
                    _('You can only delete records in Draft or Cancelled state.')
                )
        return super().unlink()

    # =============================================================================
    # ACTIONS / BUSINESS LOGIC
    # =============================================================================

    def action_confirm(self):
        self.write({'state': 'confirm'})

    def action_cancel(self):
        self.write({'state': 'cancel'})

    def action_reset_to_draft(self):
        self.write({'state': 'draft'})
