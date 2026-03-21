"""
test_my_model.py — TransactionCase tests for business logic, ORM, compute fields.

Use this template for:
- Model methods and computed fields
- ORM creates, writes, unlinks
- Onchanges and constrains
- Workflow state transitions

Replace `my_module`, `MyModel`, `my.model` with your actual names.
"""
from odoo.tests.common import tagged

from .common import TestMyModuleBase


@tagged("post_install", "-at_install", "my_module")
class TestMyModel(TestMyModuleBase):
    """Tests for my.model business logic."""

    # -------------------------------------------------------------------------
    # Happy path
    # -------------------------------------------------------------------------

    def test_create_record_with_valid_data(self):
        # Given
        vals = {
            "name": "Test Record",
            "partner_id": self.partner.id,
        }

        # When
        record = self.env["my.model"].create(vals)

        # Then
        self.assertEqual(record.name, "Test Record")
        self.assertEqual(record.partner_id, self.partner)

    # -------------------------------------------------------------------------
    # Computed fields
    # -------------------------------------------------------------------------

    def test_computed_field_returns_expected_value(self):
        # Given
        record = self.env["my.model"].create({
            "name": "Computed Test",
            "partner_id": self.partner.id,
            # set fields that the computed field depends on
        })

        # When — trigger recompute if needed
        record._compute_my_field()

        # Then
        self.assertEqual(record.my_computed_field, "expected_value")

    # -------------------------------------------------------------------------
    # State transitions / workflows
    # -------------------------------------------------------------------------

    def test_confirm_moves_state_to_confirmed(self):
        # Given
        record = self.env["my.model"].create({
            "name": "State Test",
            "partner_id": self.partner.id,
        })
        self.assertEqual(record.state, "draft")

        # When
        record.action_confirm()

        # Then
        self.assertEqual(record.state, "confirmed")

    # -------------------------------------------------------------------------
    # Edge cases / triangulation
    # -------------------------------------------------------------------------

    def test_zero_quantity_produces_zero_total(self):
        # Given — boundary: qty = 0
        record = self.env["my.model"].create({
            "name": "Zero Test",
            "partner_id": self.partner.id,
            "quantity": 0,
        })

        # When
        record.action_confirm()

        # Then
        self.assertAlmostEqual(record.amount_total, 0.0)

    # -------------------------------------------------------------------------
    # Constraints / validation errors
    # -------------------------------------------------------------------------

    def test_negative_quantity_raises_validation_error(self):
        from odoo.exceptions import ValidationError

        with self.assertRaises(ValidationError):
            self.env["my.model"].create({
                "name": "Invalid",
                "partner_id": self.partner.id,
                "quantity": -1,
            })
