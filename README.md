# E-Commerce Order Management Database System
 
**Student Name:** M Sai Charan Tej

**Register Number:** ASML25012

**Project Type:** Relational Database Management System (RDBMS)

**Database Engine:** MySQL

**Database Name:** `ecommerce_db`
 
---
 
## 1. Project Overview
 
This is a relational database designed to model the core operations of an e-commerce platform — customers, products, categories, suppliers, orders, payments, shipments, and reviews. The schema is built entirely on `AUTO_INCREMENT` primary keys and foreign key constraints, enforcing referential integrity between every related table via `ON DELETE` / `ON UPDATE` rules.
 
The design captures the full lifecycle of a purchase: a customer browses a catalog of products (each tied to a category and supplier), places an order containing one or more line items, pays for it, and has it shipped — with the option to leave a review afterward.
 
The project is being built up module by module, one week at a time, with each module documented and submitted on top of the shared base schema.
 
---
 
## 2. Core Business Domains
 
| Module              | Description                                                                | Key Tables                        | Status |
| ------------------- | -------------------------------------------------------------------------- | ---------------------------------- | ------ |
| Customer Management | Stores customer accounts, contact details, and hashed credentials.         | `Customer`                        | ✅ Complete |
| Product Catalog     | Manages products, their categories, and their suppliers.                   | `Product`, `Category`, `Supplier` | ✅ Complete |
| Order Lifecycle     | Core transaction engine linking customers, products, and order line items. | `Orders`, `OrderItems`            | ✅ Complete (Week 4) |
| Payments            | Tracks payment mode, status, and amount for each order.                    | `Payment`                          | ✅ Complete (Week 5) |
| Shipping            | Tracks shipment and delivery progress per order.                          | `Shipment`                         | 🔜 Not yet started |
| Customer Feedback   | Captures product ratings and comments from verified customers.            | `Review`                           | 🔜 Not yet started |
 
---
 
## 3. Weekly Progress
 
| Week   | Module                          | Deliverable                                                    | Status |
| ------ | -------------------------------- | ---------------------------------------------------------------| ------ |
| Week 1 | Customer Management             | Customer table design and CRUD queries                        | ✅ Complete |
| Week 2 | Product Catalog                 | Product, Category, Supplier tables and catalog queries        | ✅ Complete |
| Week 3 | Inventory                        | Stock tracking and inventory-related queries                  | ✅ Complete |
| Week 4 | Order Management System         | `Orders` / `OrderItems` design, relationships, reports         | ✅ Complete |
| Week 5 | Payment Transaction Management  | `Payment` table, transaction status handling, revenue reports | ✅ Complete |
| Week 6 | Shipment Tracking                | `Shipment` table and delivery status reports                  | 🔜 Not yet started |
| Week 7 | Customer Reviews                 | `Review` table and feedback/rating reports                    | 🔜 Not yet started |
 
---
 
## 4. Schema Design Notes
 
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
- `Orders.TotalAmount` must not be negative.
- `Payment.AmountPaid` must be greater than zero.
- `Review.Rating` is constrained to a 1–5 scale.
### F. Security Note
 
`Customer.Password` is documented to store a hashed value, never plaintext, in line with basic account security practice.
 
---
 
## 5. Entity Relationship Summary
 
```
Category ──< Product >── Supplier
                │
                ├──< OrderItems >── Orders ──> Customer
                │                      │
                └──< Review >── Customer   ├──1:1── Payment
                                           └──1:1── Shipment
```
 
---
 
## 6. Repository Structure
 
```
├── Week 1/            Customer Management
├── Week 2/            Product Catalog
├── Week 3/            Inventory
├── Week 4/            Order Management System
├── Week 5/            Payment Transaction Management
├── Databases.sql      Full base schema (all tables)
├── sample_data.sql    Sample data for testing and reports
└── README.md          This file
```
 
---
 
## 7. Execution & Verification
 
The base schema in `Databases.sql` was executed successfully in MySQL without errors, creating all nine tables (`Category`, `Supplier`, `Customer`, `Product`, `Orders`, `OrderItems`, `Payment`, `Shipment`, `Review`) along with their foreign key constraints. Each weekly module has been layered on top of this schema and verified independently as it was completed.
