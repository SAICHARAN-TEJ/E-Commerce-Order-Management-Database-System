# Product Review and Rating Sub-System

**Student Name:** M Sai Charan Tej

**Register Number:** ASML25012

**Component Type:** Relational Database Sub-Module

**Database Engine:** MySQL

**Database Name:** ecommerce_db

---
 
## 1. Project Overview
 
This is a relational database designed to model the core operations of an e-commerce platform — customers, products, categories, suppliers, orders, payments, shipments, reviews, and multi-seller inventory. The schema is built entirely on `AUTO_INCREMENT` primary keys and foreign key constraints, enforcing referential integrity between every related table via `ON DELETE` / `ON UPDATE` rules.
 
The design captures the full lifecycle of a purchase: a customer browses a catalog of products (each tied to a category and supplier), places an order containing one or more line items, pays for it, has it shipped, and can leave a rating and review afterward. A separate inventory module extends the catalog to track stock per seller across multiple storefronts.
 
---
 
## 2. Repository Structure
 
| File | Module | Description |
|---|---|---|
| `Databases.sql` | Core Schema | Creates `ecommerce_db` and all 9 core tables — `Category`, `Supplier`, `Customer`, `Product`, `Orders`, `OrderItems`, `Payment`, `Shipment`, `Review`. |
| `sample_data.sql` | Sample Data | Populates the core schema with realistic test data — 5 categories, 5 suppliers, 6 customers, 11 products, 7 orders, order items, payments, shipments, and reviews. |
| `Order_system_management.sql` | Order Lifecycle (Week 4) | Order and order-item CRUD operations plus customer order history, product-wise sales, and revenue reports. |
| `Payment_transaction.sql` | Payments (Week 5) | Payment record management, success/failed/pending transaction tracking, and revenue/payment-mode analysis reports. |
| `Review_rating_system.sql` | Customer Feedback (Week 6) | Review CRUD operations, product rating aggregation, and rating-distribution reports. |
| `inventory_system.sql` | Inventory & Multi-Seller Catalog | Standalone `inventory_db` — 30 categories, 40 products, 15 sellers, 40 inventory line items, plus restock/low-stock reports. |
 
---
 
## 3. Core Business Domains
 
| Module | Description | Key Tables |
|---|---|---|
| Customer Management | Stores customer accounts, contact details, and hashed credentials. | `Customer` |
| Product Catalog | Manages products, their categories, and their suppliers. | `Product`, `Category`, `Supplier` |
| Order Lifecycle | Core transaction engine linking customers, products, and order line items. | `Orders`, `OrderItems` |
| Payments & Shipping | Tracks payment status and shipment/delivery progress per order. | `Payment`, `Shipment` |
| Customer Feedback | Captures product ratings and comments from verified customers. | `Review` |
| Multi-Seller Inventory | Tracks per-seller stock, SKUs, and reorder thresholds for the product catalog. | `Inventory`, `Seller` |
 
---
 
## 4. Schema Design Notes
 
### A. Reserved Keyword Handling
The order table is named `Orders` (not `Order`), since `ORDER` is a reserved SQL keyword and would break queries using `ORDER BY`.
 
### B. Historic Price Preservation
`OrderItems` stores a `PriceAtPurchase` column independent of the live `Product.Price`. This means if a product's price changes later, previously placed orders keep their original transaction value — important for accurate order history and invoicing.
 
### C. 1:1 Relationships
`Payment` and `Shipment` each hold a `UNIQUE` foreign key on `OrderID`, enforcing a strict one-to-one relationship with `Orders` — every order has at most one payment record and one shipment record.
 
### D. Referential Integrity Rules
- Most child tables (`Product`, `Orders`, `OrderItems`, `Payment`, `Shipment`, `Review`, `Inventory`) cascade on delete/update, so removing a parent record (e.g. a `Customer` or `Category`) cleans up dependent rows automatically.
- `OrderItems.ProductID` uses `ON DELETE RESTRICT` instead, preventing a product from being deleted outright if it's part of an existing order — protecting order history from silently losing product references.
### E. Data Validation via CHECK Constraints
- `Product.Price` and `Product.StockQuantity` must be non-negative.
- `OrderItems.Quantity` must be greater than zero.
- `Orders.TotalAmount` and `Payment.AmountPaid` must be non-negative/positive.
- `Review.Rating` is constrained to a 1–5 scale, and `ReviewDate`/`Rating` are `NOT NULL`.
### F. Security Note
`Customer.Password` is documented to store a hashed value, never plaintext, in line with basic account security practice.
 
### G. Standalone Inventory Module
`inventory_system.sql` defines its own `inventory_db` with a parallel `Category`/`Product` pair rather than reusing `ecommerce_db`, since it models a separate multi-seller marketplace scenario (`Seller`, `Inventory`) rather than the single-storefront model in the core schema.
 
---
 
## 5. Entity Relationship Summary
 
```
Category ──< Product >── Supplier
                │
                ├──< OrderItems >── Orders ──> Customer
                │                      │
                └──< Review >──┐   ├──1:1── Payment
                                │   └──1:1── Shipment
                            Customer
 
(standalone inventory_db)
Category ──< Product ──< Inventory >── Seller
```
 
---
 
## 6. Reports Available
 
- **Order Management:** customer order history, product-wise order volume, top customers by order count and spend, average order value, total sales.
- **Payments:** payment mode breakdown, success/failed/pending counts, revenue by method, average transaction amount, customer payment history.
- **Reviews & Ratings:** product rating analysis, most-reviewed products, highly-rated vs. needs-improvement products, star-rating distribution.
- **Inventory:** full product catalog with category and inventory value, category summary, low-stock alerts, seller restock alerts.
---
 
## 7. Execution & Verification
 
Run the scripts in this order against a fresh MySQL instance:
 
1. `Databases.sql` — creates `ecommerce_db` and all core tables.
2. `sample_data.sql` — loads sample records into the core schema.
3. `Order_system_management.sql`, `Payment_transaction.sql`, `Review_rating_system.sql` — each module's CRUD operations and reports (`ecommerce_db` must already exist).
4. `inventory_system.sql` — self-contained; creates and populates `inventory_db` independently.
All scripts executed cleanly in MySQL Workbench with no errors, and every foreign key, `CHECK` constraint, and report query was verified against the sample data.

### Proof :

<img width="871" height="200" alt="image" src="https://github.com/user-attachments/assets/e6ad8230-e6e3-4727-a543-3be8a4028f78" />
<img width="381" height="173" alt="image" src="https://github.com/user-attachments/assets/26c8f838-b4fa-4ccd-9d77-601d7d670ee1" />
<img width="668" height="103" alt="image" src="https://github.com/user-attachments/assets/3aec4244-15fb-4a4e-955b-3c8f01ac5016" />
<img width="371" height="187" alt="image" src="https://github.com/user-attachments/assets/39e1effc-7125-4f00-af61-22d513075428" />
