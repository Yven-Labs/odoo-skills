---
name: odoo-testing
description: >
  Test-Driven Development workflow for Odoo modules (v16/v17/v18).
  Covers TransactionCase, HttpCase, @tagged, common.py, and the full
  Red → Green → Refactor cycle. MANDATORY when implementing features or fixing bugs.
license: MIT
metadata:
  author: Geraldow
  version: "1.0.0"
  supported_versions: ["16", "17", "18"]
  skill_id: ODSK-SKL-TEST
auto_invoke:
  - "Writing Odoo tests"
  - "Implementing a new Odoo feature"
  - "Fixing a bug in an Odoo module"
  - "Refactoring Odoo model or controller"
  - "Creating tests/ folder in Odoo module"
---

# odoo-testing

## TDD Cycle (MANDATORY)

```text
+-------------------------------------------+
|  RED -> GREEN -> REFACTOR                 |
|     ^                        |            |
|     +------------------------+            |
+-------------------------------------------+
```

**The question is NOT "should I write tests?" but "what tests do I need?"**

---

## The Three Laws of TDD

1. **No production code** until you have a failing test
2. **No more test** than necessary to fail
3. **No more code** than necessary to pass

---

## Detect Your Test Type

Before starting, identify what you are testing:

| Scenario | Test Class | File pattern | When to use |
|---|---|---|---|
| Business logic, ORM, compute | `TransactionCase` | `tests/test_*.py` | Models, fields, methods |
| HTTP routes, JSON-RPC, wizards | `HttpCase` | `tests/test_*.py` | Controllers, tours |
| Both at once | `TransactionCase` + `HttpCase` | separate files | Keep them split |

### Module structure

```text
my_module/
├── __manifest__.py
└── tests/
    ├── __init__.py        ← import all test files
    ├── common.py          ← shared setUp (base class)
    ├── test_my_model.py   ← TransactionCase tests
    └── test_controllers.py ← HttpCase tests
```

---

## Phase 0: Assessment (ALWAYS FIRST)

Before writing any code:

```bash
# 1. Find existing tests
find my_module/tests/ -name "test_*.py"

# 2. Run existing tests for the module
python odoo-bin -c odoo.conf -d mydb --test-enable --stop-after-init -i my_module

# 3. Run with tag filter
python odoo-bin -c odoo.conf -d mydb --test-enable --stop-after-init --test-tags my_module

# 4. Read existing tests — understand patterns already in use
```

### Decision Tree

```text
+------------------------------------------+
|    Does test file exist for this code?   |
+----------+-----------------------+--------+
           | NO                    | YES
           v                       v
+------------------+    +------------------+
| CREATE test file |    | Check coverage   |
| -> Phase 1: RED  |    | for your change  |
+------------------+    +--------+---------+
                                  |
                         +--------+--------+
                         | Missing cases?  |
                         +---+---------+---+
                             | YES     | NO
                             v         v
                     +-----------+ +-----------+
                     | ADD tests | | Proceed   |
                     | Phase 1   | | Phase 2   |
                     +-----------+ +-----------+
```

---

## Phase 1: RED — Write Failing Tests

### `common.py` — Shared base class

```python
from odoo.tests.common import TransactionCase


class TestSaleCustomBase(TransactionCase):
    """Shared setUp for all sale_custom tests."""

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.partner = cls.env["res.partner"].create({"name": "Test Partner"})
        cls.product = cls.env["product.product"].create({
            "name": "Test Product",
            "list_price": 100.0,
        })
```

### `TransactionCase` test (business logic)

```python
from .common import TestSaleCustomBase
from odoo.tests.common import tagged


@tagged("post_install", "-at_install", "sale_custom")
class TestSaleCustomOrder(TestSaleCustomBase):

    def test_order_total_with_discount(self):
        # Given
        order = self.env["sale.order"].create({
            "partner_id": self.partner.id,
        })
        self.env["sale.order.line"].create({
            "order_id": order.id,
            "product_id": self.product.id,
            "product_uom_qty": 2,
            "discount": 10.0,
        })

        # When
        order.action_confirm()

        # Then
        self.assertAlmostEqual(order.amount_total, 180.0)  # 200 - 10%
```

**Run → MUST fail:** references code that doesn't exist yet.

### `HttpCase` test (controllers / tours)

```python
from odoo.tests.common import HttpCase, tagged


@tagged("post_install", "-at_install")
class TestSaleCustomController(HttpCase):

    def test_sale_custom_tour(self):
        self.start_tour(
            "/web",
            "sale_custom_tour",
            login="admin",
        )
```

### For BUG FIXES

Write a test that **reproduces the bug** first:

```python
def test_discount_not_applied_on_zero_qty(self):
    # Reproduces bug: discount applied even when qty = 0
    line = self.env["sale.order.line"].create({
        "order_id": self.order.id,
        "product_id": self.product.id,
        "product_uom_qty": 0,
        "discount": 10.0,
    })
    # Then — should be 0, currently returns wrong value
    self.assertEqual(line.price_subtotal, 0.0)
```

**Run → Should FAIL (reproducing the bug)**

### For REFACTORING

Capture ALL current behavior BEFORE refactoring:

```bash
# Run ALL existing tests — they should PASS
# This is your safety net
python odoo-bin -c odoo.conf -d mydb --test-enable --stop-after-init --test-tags my_module
```

---

## Phase 2: GREEN — Minimum Code

Write the MINIMUM code to make the test pass. Hardcoding is valid for the first test.

```python
# Test expects amount_total == 180.0
def action_confirm(self):
    self.amount_total = 180.0  # FAKE IT — hardcoded is valid for first test
    self.state = "sale"
```

**This passes. But we're not done...**

---

## Phase 3: Triangulation (CRITICAL)

**One test allows faking. Multiple tests FORCE real logic.**

Add tests with different inputs that break the hardcoded value:

| Scenario | Required? |
|---|---|
| Happy path | YES |
| Zero quantity / empty order | YES |
| Boundary values (100% discount) | YES |
| Different discount rates | YES — breaks the fake |
| Error / invalid state | YES |

```python
def test_order_total_no_discount(self):
    # Different input -> breaks hardcoded 180.0
    line = self.env["sale.order.line"].create({
        "order_id": self.order.id,
        "product_id": self.product.id,
        "product_uom_qty": 1,
        "discount": 0.0,
    })
    self.order.action_confirm()
    self.assertAlmostEqual(self.order.amount_total, 100.0)  # No discount

def test_order_total_full_discount(self):
    line = self.env["sale.order.line"].create({
        "order_id": self.order.id,
        "product_id": self.product.id,
        "product_uom_qty": 1,
        "discount": 100.0,
    })
    self.order.action_confirm()
    self.assertAlmostEqual(self.order.amount_total, 0.0)  # Full discount
```

**Now the fake BREAKS → Real implementation required.**

---

## Phase 4: REFACTOR

Tests GREEN → Improve code quality WITHOUT changing behavior.

- Extract helper methods to `common.py`
- Rename test methods to be descriptive
- Remove duplication in `setUpClass`
- Add `@tagged` to all test classes for selective runs

**Run tests after EACH change → Must stay GREEN**

---

## `@tagged` Reference

```python
from odoo.tests.common import tagged

# Standard tags:
@tagged("post_install", "-at_install")  # Run after install, not during
@tagged("at_install")                   # Run during install only
@tagged("standard")                     # Default Odoo tag (always runs)
@tagged("-standard", "my_module")       # Skip standard, only run with my_module tag
```

| Tag | Meaning |
|---|---|
| `post_install` | Runs after all modules are installed |
| `at_install` | Runs while the module is being installed |
| `-at_install` | Exclude from install-time runs (prefix `-` negates) |
| `standard` | Included in default test suite |
| `my_module` | Custom tag — use for selective CI runs |

---

## Quick Reference

```text
+--------------------------------------------------+
|                  TDD WORKFLOW (Odoo)             |
+--------------------------------------------------+
| 0. ASSESS: What tests exist? What's missing?    |
|                                                  |
| 1. RED: Write ONE failing test                  |
|    +-- TransactionCase or HttpCase?             |
|    +-- Run → Must fail                          |
|                                                  |
| 2. GREEN: Write MINIMUM code to pass            |
|    +-- Fake It is valid for the first test      |
|                                                  |
| 3. TRIANGULATE: Add tests that break the fake   |
|    +-- Different inputs, edge cases             |
|                                                  |
| 4. REFACTOR: Improve with confidence            |
|    +-- Tests stay green throughout              |
|                                                  |
| 5. REPEAT: Next behavior/requirement            |
+--------------------------------------------------+
```

---

## Anti-Patterns (NEVER DO)

```python
# 1. Code first, tests after
def new_feature(self): ...  # Then writing tests = USELESS

# 2. Skip triangulation
# Single test allows faking forever

# 3. Test implementation details
self.assertEqual(mock_method.call_count, 3)  # BAD — brittle coupling

# 4. Use self.env.cr.execute() in tests to inspect DB state
# BAD — use ORM assertions instead

# 5. All tests at once before any code
# Write ONE test, make it pass, THEN write the next

# 6. Giant test methods
# Each test should verify ONE behavior

# 7. Depending on external data (production DB, demo data)
# BAD — always create your own records in setUpClass or test method
```

---

## Commands

```bash
# Run all tests for a module
python odoo-bin -c odoo.conf -d mydb \
  --test-enable --stop-after-init -i my_module

# Run only tests tagged with a custom tag
python odoo-bin -c odoo.conf -d mydb \
  --test-enable --stop-after-init \
  --test-tags my_module

# Run a specific test file
python odoo-bin -c odoo.conf -d mydb \
  --test-enable --stop-after-init \
  --test-tags /my_module/tests/test_my_model.py

# Run a specific test method
python odoo-bin -c odoo.conf -d mydb \
  --test-enable --stop-after-init \
  --test-tags /my_module/tests/test_my_model.py:TestMyModel.test_method_name

# Run post_install tests only (skip at_install)
python odoo-bin -c odoo.conf -d mydb \
  --test-enable --stop-after-init \
  --test-tags post_install,-at_install
```

---

## Assets

| File | Use Case |
|---|---|
| [`assets/common-template.py`](assets/common-template.py) | Base class with shared `setUpClass` |
| [`assets/transaction-case-template.py`](assets/transaction-case-template.py) | TransactionCase test file template |
| [`assets/http-case-template.py`](assets/http-case-template.py) | HttpCase / tour test template |

---

## References

| Resource | Description |
|---|---|
| [`references/testing-patterns.md`](references/testing-patterns.md) | Assert methods, mock patterns, v16/v17/v18 compatibility |
| [Odoo Testing Documentation](https://www.odoo.com/documentation/17.0/developer/reference/backend/testing.html) | Official testing reference |
