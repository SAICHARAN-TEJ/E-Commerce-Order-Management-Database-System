# Payment Transaction Management System

**Project Type:** Relational Database Management System (RDBMS)
**Database Engine:** MySQL
**Database Name:** `ecommerce_db`
**Module:** Week 5 — Payment

---

## 1. Project Overview

This module adds payment transaction management to the `ecommerce_db` schema. It records how each order was paid for, tracks whether that payment succeeded, failed, or is still pending, and supports the reporting a business would need on top of that data — payment mode breakdowns, revenue totals, and per-customer payment history.

The `Payment` table sits on top of the existing `Customer` and `Orders` tables from earlier weeks, so every payment ties back to a real order and, through it, a real customer.

---

## 2. Core Business Domain

| Module            | Description                                                             | Key Table |
| ------------------ | ------------------------------------------------------------------------ | --------- |
| Payment Processing | Stores each order's payment mode, status, amount, and transaction date. | `Payment` |

---

## 3. Schema Design Notes

### A. One-to-One with Orders

`Payment.OrderID` is declared both a `FOREIGN KEY` and `UNIQUE`. That combination is what enforces the 1:1 relationship — an order can have a payment row, but never more than one.

### B. Required Fields

`PaymentMethod` and `PaymentStatus` are both `NOT NULL`, so a payment record can never be logged without knowing how it was paid or whether it went through.

### C. Data Validation via CHECK Constraint

`AmountPaid` is constrained with `CHECK (AmountPaid > 0)`, so a zero or negative transaction amount can't be inserted.

### D. Status Lifecycle

`PaymentStatus` is an `ENUM('success', 'failed', 'pending')`, defaulting to `pending` until a transaction is confirmed one way or the other — which is also what lets failed payments be retried and updated later.

---

## 4. Entity Relationship Summary

```
Customer ──< Orders ──1:1── Payment
```

---

## 5. What's Included

- `Payment` table creation script with primary key, foreign key, `NOT NULL`, and `CHECK` constraints
- Queries to insert and update payment records for existing orders
- Queries to view successful payments, failed payments, and pending transactions
- A retry query that re-marks failed card payments as successful
- Payment analysis reports:
  - Transaction count by payment mode, and the most preferred mode
  - Total revenue, revenue by payment mode, and average transaction amount
  - Customer payment history (customer name, order, mode, amount, status)

---

## 6. Execution & Verification

The SQL script was executed successfully in MySQL against the existing `ecommerce_db` schema, with the `Payment` table and its foreign key to `Orders` created and verified without errors.
