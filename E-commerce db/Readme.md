# ShopSphere E-Commerce Retail Database System

**Student Name:** M Sai Charan Tej
**Register Number:** ASML25012
**Project Type:** Relational Database Management System (RDBMS)
**Database Engine:** MySQL
**Database Name:** `ecommerce_db`

---

## 1. Project Overview

ShopSphere is a relational database designed to model the core operations of an e-commerce platform — customers, products, categories, suppliers, orders, payments, shipments, and reviews. The schema is built entirely on `AUTO_INCREMENT` primary keys and foreign key constraints, enforcing referential integrity between every related table via `ON DELETE` / `ON UPDATE` rules.

The design captures the full lifecycle of a purchase: a customer browses a catalog of products (each tied to a category and supplier), places an order containing one or more line items, pays for it, and has it shipped — with the option to leave a review afterward.

---

## 2. Core Business Domains

| Module | Description | Key Tables |
|---|---|---|
| Customer Management | Stores customer accounts, contact details, and hashed credentials. | `Customer` |
| Product Catalog | Manages products, their categories, and their suppliers. | `Product`, `Category`, `Supplier` |
| Order Lifecycle | Core transaction engine linking customers, products, and order line items. | `Orders`, `OrderItems` |
| Payments & Shipping | Tracks payment status and shipment/delivery progress per order. | `Payment`, `Shipment` |
| Customer Feedback | Captures product ratings and comments from verified customers. | `Review` |

---

## 3. Schema Design Notes

### A. Reserved Keyword Handling
The order table is named `Orders` (not `Order`), since `ORDER` is a reserved SQL keyword and would break queries using `ORDER BY`.

### B. Historic Price Preservation
`OrderItems` stores a `PriceAtPurchase` column independent of the live `Product.Price`. This means if a product's price changes later, previously placed orders keep their original transaction value — important for accurate order history and invoicing.

### C. 1:1 Relationships
`Payment` and `Shipment` each hold a `UNIQUE` foreign key on `OrderID`, enforcing a strict one-to-one relationship with `Orders` — every order has at most one payment record and one shipment record.

### D. Referential Integrity Rules
- Most child tables (`Product`, `Orders`, `OrderItems`, `Payment`, `Shipment`, `Review`) cascade on delete/update, so removing a parent record (e.g. a `Customer` or `Category`) cleans up dependent rows automatically.
- `OrderItems.ProductID` uses `ON DELETE RESTRICT` instead, preventing a product from being deleted outright if it's part of an existing order — protecting order history from silently losing product references.

### E. Data Validation via CHECK Constraints
- `Product.Price` and `Product.StockQuantity` must be non-negative.
- `OrderItems.Quantity` must be greater than zero.
- `Review.Rating` is constrained to a 1–5 scale.

### F. Security Note
`Customer.Password` is documented to store a hashed value, never plaintext, in line with basic account security practice.

---

## 4. Entity Relationship Summary

```
Category ──< Product >── Supplier
                │
                ├──< OrderItems >── Orders ──> Customer
                │                      │
                └──< Review >── Customer   ├──1:1── Payment
                                           └──1:1── Shipment
```

---

## 5. Execution & Verification

The SQL script was executed successfully in MySQL Workbench without errors. All nine tables (`Category`, `Supplier`, `Customer`, `Product`, `Orders`, `OrderItems`, `Payment`, `Shipment`, `Review`) along with their foreign key constraints were created and verified.

Verification Logs:
<img width="1630" height="402" alt="image" src="https://github.com/user-attachments/assets/0c212e24-c11f-4e83-bb16-462e4582cc78" />

