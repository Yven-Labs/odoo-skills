# Odoo Testing Patterns Reference

## Assert Methods (TransactionCase)

| Assert | Use for |
|--------|---------|
| `self.assertEqual(a, b)` | Exact equality (IDs, strings, states) |
| `self.assertAlmostEqual(a, b)` | Float comparisons (monetary amounts) |
| `self.assertTrue(expr)` / `self.assertFalse(expr)` | Boolean conditions |
| `self.assertIn(item, container)` | Membership check (recordsets, lists) |
| `self.assertNotIn(item, container)` | Absence check |
| `self.assertRaises(ExceptionClass)` | Expect an exception |
| `self.assertRecordValues(records, expected)` | Compare multiple recordset fields at once |

### `assertRecordValues` example

```python
self.assertRecordValues(order.order_line, [
    {"product_id": self.product.id, "product_uom_qty": 2.0, "price_unit": 100.0},
    {"product_id": self.product_b.id, "product_uom_qty": 1.0, "price_unit": 50.0},
])
```

---

## Exception Assertions

```python
from odoo.exceptions import ValidationError, UserError, AccessError

# Expect a ValidationError
with self.assertRaises(ValidationError):
    record.write({"quantity": -1})

# Expect a UserError
with self.assertRaises(UserError):
    record.action_confirm()

# Expect AccessError (permissions)
with self.assertRaises(AccessError):
    record.with_user(self.user_no_access).unlink()
```

---

## Switching User Context

```python
# Run as a specific user
record_as_user = self.env["my.model"].with_user(self.user_demo)

# Run as superuser (bypass all access rules — use sparingly in tests)
record_as_admin = self.env["my.model"].sudo()

# Switch company context
record_company_b = self.env["my.model"].with_company(self.company_2)
```

---

## Mocking External Calls

Use `unittest.mock.patch` for:
- External API calls (payment providers, shipping, email)
- Date/time (freeze time for compute tests)
- Services that can't run in test environment

```python
from unittest.mock import patch

def test_payment_provider_called(self):
    with patch("odoo.addons.my_module.models.my_model.requests.post") as mock_post:
        mock_post.return_value.json.return_value = {"status": "ok"}

        result = self.record.send_to_provider()

        mock_post.assert_called_once()
        self.assertEqual(result, "ok")
```

---

## Freezing Date/Time

```python
from unittest.mock import patch
from datetime import date

def test_date_based_compute(self):
    with patch("odoo.fields.Date.today", return_value=date(2025, 1, 15)):
        self.record._compute_deadline()
        self.assertEqual(self.record.deadline, date(2025, 1, 30))
```

---

## v16 / v17 / v18 Compatibility

| Feature | v16 | v17 | v18 |
|---------|-----|-----|-----|
| `assertRecordValues` | ✅ | ✅ | ✅ |
| `HttpCase.url_open` | ✅ | ✅ | ✅ |
| `HttpCase.authenticate` | ✅ | ✅ | ✅ |
| `@tagged` decorator | ✅ | ✅ | ✅ |
| `ir.rule` `global` field | ✅ | ❌ removed | ❌ removed |
| `name_get()` override | ✅ | ⚠️ deprecated | ❌ use `_rec_name` |
| `_name_search()` | ✅ | ✅ | ✅ |

---

## Test Isolation Rules

1. **Never depend on demo data** — always create your own records in `setUpClass` or the test method.
2. **Never use `self.env.cr.execute()`** in tests to inspect DB state — use ORM assertions.
3. **Each test is rolled back** after execution — state does not leak between tests in `TransactionCase`.
4. **`setUpClass` runs once per class** — records created there are shared (read-only pattern recommended).
5. **`setUp` runs before each test** — use for state that must be fresh per test.

---

## Common Pitfalls

### Pitfall: Testing with wrong user
```python
# BAD — testing with admin bypasses real access rules
self.env["my.model"].sudo().create(...)

# GOOD — test with the actual user role you're validating
self.env["my.model"].with_user(self.user_salesperson).create(...)
```

### Pitfall: Using `assertEqual` for floats
```python
# BAD — floating point comparison may fail
self.assertEqual(order.amount_total, 180.0)

# GOOD — use assertAlmostEqual for monetary values
self.assertAlmostEqual(order.amount_total, 180.0)
```

### Pitfall: Missing `__init__.py` import
```python
# tests/__init__.py must import all test files
from . import test_my_model, test_controllers  # Add new files here
```

### Pitfall: Running tests without --test-enable
```bash
# WRONG — tests won't run
python odoo-bin -c odoo.conf -d mydb -i my_module

# CORRECT
python odoo-bin -c odoo.conf -d mydb --test-enable --stop-after-init -i my_module
```

---

## `__init__.py` Pattern

```python
# tests/__init__.py
from . import common          # NOT a test file, but must be importable
from . import test_my_model
from . import test_controllers
```

---

## Selective Test Runs for CI

```bash
# Run only the tests for your module (custom tag)
python odoo-bin -c odoo.conf -d mydb \
  --test-enable --stop-after-init \
  --test-tags my_module

# Run a single class
python odoo-bin -c odoo.conf -d mydb \
  --test-enable --stop-after-init \
  --test-tags /my_module/tests/test_my_model.py:TestMyModel

# Run a single method
python odoo-bin -c odoo.conf -d mydb \
  --test-enable --stop-after-init \
  --test-tags /my_module/tests/test_my_model.py:TestMyModel.test_create_record_with_valid_data
```
