"""
test_controllers.py — HttpCase tests for JSON-RPC controllers and JS tours.

Use this template for:
- HTTP routes that return JSON
- JSON-RPC endpoint calls
- JavaScript UI tours (end-to-end via browser)
- Wizard HTTP flows

Replace `my_module`, `my_tour_name` with your actual names.
"""
from odoo.tests.common import HttpCase, tagged


@tagged("post_install", "-at_install", "my_module")
class TestMyModuleControllers(HttpCase):
    """HTTP and tour tests for my_module."""

    # -------------------------------------------------------------------------
    # JSON-RPC endpoint test
    # -------------------------------------------------------------------------

    def test_my_json_rpc_endpoint_returns_expected_data(self):
        """Call a JSON-RPC route and assert the response shape."""
        self.authenticate("admin", "admin")

        response = self.url_open(
            "/web/dataset/call_kw",
            data={
                "jsonrpc": "2.0",
                "method": "call",
                "id": 1,
                "params": {
                    "model": "my.model",
                    "method": "my_method",
                    "args": [],
                    "kwargs": {},
                },
            },
            headers={"Content-Type": "application/json"},
        )

        self.assertEqual(response.status_code, 200)
        result = response.json()
        self.assertIn("result", result)

    # -------------------------------------------------------------------------
    # JavaScript tour test
    # -------------------------------------------------------------------------

    def test_my_module_tour(self):
        """
        Run the `my_module_tour` JS tour as admin.

        The tour must be defined in:
            my_module/static/src/js/tours/my_module_tour.js
        and registered via:
            odoo.define('my_module.tour', ...)
        """
        self.start_tour(
            "/web",
            "my_module_tour",
            login="admin",
        )

    # -------------------------------------------------------------------------
    # Portal / public route test
    # -------------------------------------------------------------------------

    def test_public_route_returns_200(self):
        """Test a route accessible without authentication."""
        response = self.url_open("/my_module/public-page")
        self.assertEqual(response.status_code, 200)

    def test_authenticated_route_requires_login(self):
        """Test that a protected route redirects unauthenticated users."""
        response = self.url_open("/my_module/private-page", allow_redirects=False)
        # Expect redirect to /web/login
        self.assertIn(response.status_code, [301, 302, 303])
