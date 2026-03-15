# =============================================================================
# Computed Field Templates — Odoo v17 / v18
# Author: Geraldow | https://github.com/Yven-Labs/odoo-skills
# =============================================================================
# Patterns: compute, depends, store, inverse, related
# =============================================================================

from odoo import api, fields, models


class ComputedFieldExamples(models.Model):
    _name = 'example.model'
    _description = 'Computed Field Examples'

    # -------------------------------------------------------------------------
    # Pattern 1 — Basic computed (not stored)
    # Recalculated every time the field is read.
    # Use when: value changes often and storage cost is not worth it.
    # -------------------------------------------------------------------------
    first_name = fields.Char(string='First Name')
    last_name = fields.Char(string='Last Name')

    full_name = fields.Char(
        string='Full Name',
        compute='_compute_full_name',
        # store=False  ← default, not stored in DB
    )

    @api.depends('first_name', 'last_name')
    def _compute_full_name(self):
        for rec in self:
            rec.full_name = f'{rec.first_name or ""} {rec.last_name or ""}'.strip()

    # -------------------------------------------------------------------------
    # Pattern 2 — Stored computed
    # Stored in DB. Recalculated only when dependencies change.
    # Use when: value is queried often, or used in search/group by.
    # -------------------------------------------------------------------------
    line_ids = fields.One2many('example.model.line', 'parent_id', string='Lines')

    amount_total = fields.Float(
        string='Total Amount',
        compute='_compute_amount_total',
        store=True,                  # ← persisted in DB
        digits=(16, 2),
    )

    @api.depends('line_ids.price_subtotal')
    def _compute_amount_total(self):
        for rec in self:
            rec.amount_total = sum(rec.line_ids.mapped('price_subtotal'))

    # -------------------------------------------------------------------------
    # Pattern 3 — Computed with inverse (read-write computed)
    # Allows setting the field manually, triggering the inverse method.
    # Use when: you want a "virtual" field that writes back to real fields.
    # -------------------------------------------------------------------------
    amount_net = fields.Float(string='Net Amount')
    tax_percent = fields.Float(string='Tax %', default=18.0)

    amount_gross = fields.Float(
        string='Gross Amount',
        compute='_compute_amount_gross',
        inverse='_inverse_amount_gross',
        store=True,
    )

    @api.depends('amount_net', 'tax_percent')
    def _compute_amount_gross(self):
        for rec in self:
            rec.amount_gross = rec.amount_net * (1 + rec.tax_percent / 100)

    def _inverse_amount_gross(self):
        # Called when user sets amount_gross directly
        for rec in self:
            if rec.tax_percent != -100:
                rec.amount_net = rec.amount_gross / (1 + rec.tax_percent / 100)

    # -------------------------------------------------------------------------
    # Pattern 4 — Related field (shortcut through a relation)
    # No compute method needed — Odoo handles it automatically.
    # Use when: you need to surface a field from a related model.
    # -------------------------------------------------------------------------
    partner_id = fields.Many2one('res.partner', string='Partner')

    partner_email = fields.Char(
        string='Partner Email',
        related='partner_id.email',
        store=True,      # store=True allows search; store=False is read-only display
        readonly=True,
    )
    partner_country_id = fields.Many2one(
        comodel_name='res.country',
        related='partner_id.country_id',
        store=True,
        readonly=True,
    )

    # -------------------------------------------------------------------------
    # Pattern 5 — Depends on nested path
    # Use dot notation for multi-level dependencies.
    # -------------------------------------------------------------------------
    company_id = fields.Many2one('res.company', default=lambda self: self.env.company)

    company_currency_symbol = fields.Char(
        string='Currency Symbol',
        compute='_compute_currency_symbol',
    )

    @api.depends('company_id.currency_id.symbol')
    def _compute_currency_symbol(self):
        for rec in self:
            rec.company_currency_symbol = rec.company_id.currency_id.symbol or ''
