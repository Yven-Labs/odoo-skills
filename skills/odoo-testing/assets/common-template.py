"""
common.py — Shared base class for all tests in this module.

Usage:
    from .common import TestMyModuleBase

    class TestMyModel(TestMyModuleBase):
        def test_something(self):
            ...

Replace `my_module` with your actual module name throughout.
"""
from odoo.tests.common import TransactionCase


class TestMyModuleBase(TransactionCase):
    """
    Base class shared by all TransactionCase tests in my_module.

    Create here:
    - Records that every test will need (partner, product, company, etc.)
    - Utility methods reused across multiple test files

    Keep this class LEAN — only create records that 3+ tests actually need.
    Test-specific setup belongs in the test method itself.
    """

    @classmethod
    def setUpClass(cls):
        super().setUpClass()

        # --- Partners ---
        cls.partner = cls.env["res.partner"].create({
            "name": "Test Partner",
            "email": "test@example.com",
        })

        # --- Products ---
        cls.product = cls.env["product.product"].create({
            "name": "Test Product",
            "list_price": 100.0,
            "type": "service",
        })

        # --- Users (optional — only if your tests need specific users) ---
        # cls.user_demo = cls.env.ref("base.user_demo")

        # --- Companies (optional — only for multi-company tests) ---
        # cls.company_2 = cls.env["res.company"].create({"name": "Company B"})
