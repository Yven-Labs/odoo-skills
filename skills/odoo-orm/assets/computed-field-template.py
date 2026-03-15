# Odoo ORM - Computed Field Patterns
# Reference for odoo-orm skill

from odoo import api, fields, models


class ComputedFieldExamples(models.Model):
    _name = 'example.model'
    _description = 'Computed Field Examples'

    # =============================================================================
    # PATTERN 1: BASIC COMPUTED (NOT STORED)
    # Recalculated every time the field is read.
    # Use when: value changes too often to justify a DB column, or is only
    # needed for display — never for search, filter, or group-by.
    # =============================================================================

    first_name = fields.Char(string='First Name')
    last_name = fields.Char(string='Last Name')

    full_name = fields.Char(
        string='Full Name',
        compute='_compute_full_name',
        # store=False is the default — not persisted in DB
    )

    @api.depends('first_name', 'last_name')
    def _compute_full_name(self):
        for rec in self:
            rec.full_name = f'{rec.first_name or ""} {rec.last_name or ""}'.strip()

    # =============================================================================
    # PATTERN 2: STORED COMPUTED
    # Persisted in DB. Recalculated only when its @api.depends fields change.
    # Use when: the value is used in domain filters, group-by, or is queried often.
    # =============================================================================

    line_ids = fields.One2many('example.model.line', 'parent_id', string='Lines')

    amount_total = fields.Float(
        string='Total Amount',
        compute='_compute_amount_total',
        store=True,       # persisted — Odoo invalidates it when line_ids change
        digits=(16, 2),
    )

    @api.depends('line_ids.price_subtotal')
    def _compute_amount_total(self):
        for rec in self:
            rec.amount_total = sum(rec.line_ids.mapped('price_subtotal'))

    # =============================================================================
    # PATTERN 3: COMPUTED WITH INVERSE (READ-WRITE COMPUTED)
    # Allows setting the field manually; the inverse method writes back to
    # the underlying fields. Use when you want a "virtual" field the user
    # can edit directly (e.g. editing gross amount to back-calculate net).
    # =============================================================================

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
        # Called when the user writes directly to amount_gross in the UI
        for rec in self:
            if rec.tax_percent != -100:
                rec.amount_net = rec.amount_gross / (1 + rec.tax_percent / 100)

    # =============================================================================
    # PATTERN 4: RELATED FIELD
    # Shortcut through a relation — no compute method needed.
    # Odoo maintains it automatically. store=True enables search and group-by.
    # Use when: you need a field from a related model on this model's views or
    # search filters.
    # =============================================================================

    partner_id = fields.Many2one('res.partner', string='Partner')

    partner_email = fields.Char(
        string='Partner Email',
        related='partner_id.email',
        store=True,       # store=True: searchable; store=False: display only
        readonly=True,
    )
    partner_country_id = fields.Many2one(
        comodel_name='res.country',
        related='partner_id.country_id',
        store=True,
        readonly=True,
    )

    # =============================================================================
    # PATTERN 5: MULTI-LEVEL DEPENDS PATH
    # Use dot notation to declare dependencies across multiple relations.
    # Odoo walks the chain and invalidates the computed field if ANY node changes.
    # =============================================================================

    company_id = fields.Many2one('res.company', default=lambda self: self.env.company)

    company_currency_symbol = fields.Char(
        string='Currency Symbol',
        compute='_compute_currency_symbol',
    )

    @api.depends('company_id.currency_id.symbol')
    def _compute_currency_symbol(self):
        for rec in self:
            rec.company_currency_symbol = rec.company_id.currency_id.symbol or ''

    # =============================================================================
    # PATTERN 6: COMPUTED FIELD DEPENDING ON MANY2MANY
    # Use @api.depends on the Many2many field itself. Odoo invalidates the
    # computed field whenever tags are added, removed, or the tag records change.
    # Use when: you need to derive a value from the set of linked records
    # (e.g. check membership, count items, or aggregate a field on linked records).
    # =============================================================================

    tag_ids = fields.Many2many('example.tag', string='Tags')

    is_tagged = fields.Boolean(
        string='Has Tags',
        compute='_compute_is_tagged',
        # store=False — changes too often to justify a DB column;
        # only needed for display logic, not search or group-by
    )
    tag_count = fields.Integer(
        string='Tag Count',
        compute='_compute_tag_count',
        store=True,   # store=True — useful for filtering "show only records with tags"
    )

    @api.depends('tag_ids')
    def _compute_is_tagged(self):
        for rec in self:
            rec.is_tagged = bool(rec.tag_ids)

    @api.depends('tag_ids')
    def _compute_tag_count(self):
        for rec in self:
            rec.tag_count = len(rec.tag_ids)
