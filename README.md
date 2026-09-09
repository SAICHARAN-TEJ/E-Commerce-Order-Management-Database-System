# E-Commerce Order Management Database System
 
**Student Name:** M Sai Charan Tej

**Register Number:** ASML25012

**Project Type:** Relational Database Management System (RDBMS)

**Database Engine:** MySQL

**Database Name:** `ecommerce_db`
 
---
 
## 1. Project Overview
 
This project models the core operations of an e-commerce platform as a relational database in MySQL. It covers the full lifecycle of a retail transaction — a customer browses a catalog of products (each tied to a category and supplier), places an order made up of one or more line items, pays for it, has it shipped, and can leave a rating and review afterward. A separate multi-seller inventory system extends the same catalog idea to track stock per seller across different storefronts.
 
The schema is built entirely on `AUTO_INCREMENT` primary keys and foreign key constraints, so referential integrity is enforced by the database itself via `ON DELETE` / `ON UPDATE` rules and `CHECK` constraints, not left to application code.
 
The project is split into weekly modules, each adding one piece of functionality on top of the same core schema:
 
| Module | File |
|---|---|
| Core Schema | `Databases.sql` |
| Sample Data | `sample_data.sql` |
| Order Management | `Order_system_management.sql` |
| Payment Transactions | `Payment_transaction.sql` |
| Review & Rating | `Review_rating_system.sql` |
| Multi-Seller Inventory | `inventory_system.sql` |
 
---
 
## 2. Full Database Schema (`ecommerce_db`)
 
### 2.1 Category
| Column | Type | Constraints |
|---|---|---|
| CategoryID | INT | PK, AUTO_INCREMENT |
| CategoryName | VARCHAR(100) | NOT NULL, UNIQUE |
| Description | TEXT | |
 
### 2.2 Supplier
| Column | Type | Constraints |
|---|---|---|
| SupplierID | INT | PK, AUTO_INCREMENT |
| SupplierName | VARCHAR(150) | NOT NULL |
| ContactNumber | VARCHAR(20) | |
| Email | VARCHAR(150) | UNIQUE |
| Address | VARCHAR(255) | |
 
### 2.3 Customer
| Column | Type | Constraints |
|---|---|---|
| CustomerID | INT | PK, AUTO_INCREMENT |
| Name | VARCHAR(150) | NOT NULL |
| Email | VARCHAR(150) | NOT NULL, UNIQUE |
| Phone | VARCHAR(20) | |
| Password | VARCHAR(255) | NOT NULL (stores a hash, never plain text) |
| Address | VARCHAR(255) | |
| RegistrationDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |
 
### 2.4 Product
| Column | Type | Constraints |
|---|---|---|
| ProductID | INT | PK, AUTO_INCREMENT |
| Name | VARCHAR(150) | NOT NULL |
| Description | TEXT | |
| Price | DECIMAL(10,2) | NOT NULL, CHECK (Price >= 0) |
| StockQuantity | INT | NOT NULL, DEFAULT 0, CHECK (StockQuantity >= 0) |
| CategoryID | INT | FK → Category, ON DELETE CASCADE |
| SupplierID | INT | FK → Supplier, ON DELETE CASCADE |
 
### 2.5 Orders
| Column | Type | Constraints |
|---|---|---|
| OrderID | INT | PK, AUTO_INCREMENT |
| CustomerID | INT | FK → Customer, ON DELETE CASCADE |
| OrderDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |
| TotalAmount | DECIMAL(10,2) | NOT NULL, DEFAULT 0.00, CHECK (TotalAmount >= 0) |
| OrderStatus | ENUM | placed / packed / shipped / out_for_delivery / delivered / cancelled / returned, DEFAULT 'placed' |
 
> Named `Orders`, not `Order`, since `ORDER` is a reserved SQL keyword that would break `ORDER BY` queries.
 
### 2.6 OrderItems
| Column | Type | Constraints |
|---|---|---|
| OrderItemID | INT | PK, AUTO_INCREMENT |
| OrderID | INT | FK → Orders, ON DELETE CASCADE |
| ProductID | INT | FK → Product, ON DELETE RESTRICT |
| Quantity | INT | NOT NULL, CHECK (Quantity > 0) |
| PriceAtPurchase | DECIMAL(10,2) | NOT NULL |
 
> `PriceAtPurchase` is stored independently of the live `Product.Price` so past orders keep the price the customer actually paid, even if the catalog price changes later. `ProductID` uses `ON DELETE RESTRICT` (not CASCADE) so a product that's already part of order history can't be deleted outright.
 
### 2.7 Payment
| Column | Type | Constraints |
|---|---|---|
| PaymentID | INT | PK, AUTO_INCREMENT |
| OrderID | INT | FK → Orders, UNIQUE (1:1), ON DELETE CASCADE |
| PaymentMethod | ENUM | upi / credit_card / debit_card / net_banking / cash_on_delivery |
| PaymentStatus | ENUM | success / failed / pending, DEFAULT 'pending' |
| PaymentDate | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |
| AmountPaid | DECIMAL(10,2) | NOT NULL, CHECK (AmountPaid > 0) |
 
### 2.8 Shipment
| Column | Type | Constraints |
|---|---|---|
| ShipmentID | INT | PK, AUTO_INCREMENT |
| OrderID | INT | FK → Orders, UNIQUE (1:1), ON DELETE CASCADE |
| ShippingDate | DATE | |
| DeliveryDate | DATE | |
| ShipmentStatus | ENUM | packed / shipped / out_for_delivery / delivered, DEFAULT 'packed' |
| TrackingNumber | VARCHAR(50) | |
 
### 2.9 Review
| Column | Type | Constraints |
|---|---|---|
| ReviewID | INT | PK, AUTO_INCREMENT |
| ProductID | INT | FK → Product, ON DELETE CASCADE |
| CustomerID | INT | FK → Customer, ON DELETE CASCADE |
| Rating | TINYINT | NOT NULL, CHECK (Rating BETWEEN 1 AND 5) |
| Comment | TEXT | |
| ReviewDate | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
 
---
 
## 3. Standalone Inventory Schema (`inventory_db`)
 
This is a separate database used to model a multi-seller marketplace scenario, so it defines its own `Category`/`Product` pair rather than reusing `ecommerce_db`.
 
### 3.1 Category
CategoryID (PK), CategoryName (UNIQUE), Description, CreatedAt.
 
### 3.2 Product
ProductID (PK), ProductName, CategoryID (FK → Category, CASCADE), Price (CHECK >= 0), StockQuantity (CHECK >= 0), CreatedAt.
 
### 3.3 Seller
SellerID (PK), StoreName (UNIQUE), ContactEmail (UNIQUE), PhoneNumber, City, CreatedAt.
 
### 3.4 Inventory
ItemID (PK), ProductID (FK → Product, CASCADE), SellerID (FK → Seller, CASCADE), SKU (UNIQUE), UnitPrice, StockQuantity, ReorderLevel (DEFAULT 10), LastRestocked.
 
> Each row represents one seller's stock of one product, so the same product can appear multiple times in `Inventory` under different sellers with different SKUs, prices, and stock levels.
 
---
 
## 4. Entity Relationships
 
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
 
- Customer (1) —— (Many) Orders
- Orders (1) —— (Many) OrderItems —— (Many) Product (resolved through OrderItems)
- Orders (1) —— (1) Payment
- Orders (1) —— (1) Shipment
- Customer (1) —— (Many) Review, Product (1) —— (Many) Review
- Product (1) —— (Many) Inventory —— (Many) Seller (resolved through Inventory)
**Cascade rules:** `Product`, `Orders`, `OrderItems`, `Payment`, `Shipment`, `Review`, and `Inventory` all cascade on delete/update from their parent, so removing a `Customer` or `Category` cleans up everything beneath it automatically. The one deliberate exception is `OrderItems.ProductID`, which is `ON DELETE RESTRICT` — a product already referenced in an order can't be deleted, protecting order history.
 
---
 
## 5. Sample Data (`sample_data.sql`)
 
Loaded into `ecommerce_db` for testing every module:
 
- 5 categories, 5 suppliers
- 6 customers (Aarav, Priya, Rohan, Ananya, Vikram, Sneha)
- 11 products across all 5 categories
- 7 orders covering every `OrderStatus` value (placed, packed, shipped, out_for_delivery, delivered, cancelled)
- 10 order line items
- 7 payment records across success/failed/pending
- 6 shipment records
- 8 initial product reviews with ratings from 3 to 5 stars
`inventory_system.sql` carries its own separate dataset for `inventory_db`: 30 categories, 40 products, 15 sellers, and 40 inventory line items.
 
---
 
## 6. Module Details
 
### 6.1 Order Management (`Order_system_management.sql`)
- Creates a new order and its line items, then recalculates `Orders.TotalAmount` from `OrderItems` using a `JOIN` + `SUM`.
- Updates order status (e.g. placed → delivered) and updates item quantity within an existing order.
- Deletes cancelled orders.
- **Reports:** customer order history, product-wise order volume (times ordered + total quantity sold), customers ranked by order count, customers ranked by total spend, average order value, total sales across all orders.
### 6.2 Payment Transactions (`Payment_transaction.sql`)
- Updates a payment's status once processed (pending → success).
- Retries failed card/debit payments and marks them successful.
- Retrieves payments by order, by status (success / failed / pending).
- **Reports:** payment mode breakdown + most preferred method, total revenue, revenue by payment method, average transaction amount, customer payment history joined across `Payment` → `Orders` → `Customer`.
### 6.3 Review & Rating (`Review_rating_system.sql`)
- Inserts new reviews for purchased products, updates a review's comment, deletes an invalid/inappropriate review.
- Retrieves all reviews for a product, customer name alongside their reviews, most-reviewed products, most recent feedback, and reviews rated above 4.
- Calculates average rating and review count per product.
- **Reports:** Product Rating Analysis (name, review count, average rating), Customer Feedback Analysis (most reviewed / highly rated ≥4 / needs improvement <3), Rating Distribution (count of 5-star through 1-star reviews, count of low-rated products).
### 6.4 Multi-Seller Inventory (`inventory_system.sql`)
- Updates product price/stock, applies a percentage price increase across a category, deletes a product or category (cascades to inventory), restocks a specific inventory item.
- **Reports:** full product catalog with category name and inventory value (`Price × StockQuantity`), category summary (product count, average price, total stock, total value), low-stock alert (products under 25 units), seller restock alert (items at or below their `ReorderLevel`).
---
 
## 7. Execution Order
 
Run against a fresh MySQL instance:
 
1. `Databases.sql` — creates `ecommerce_db` and all 9 core tables.
2. `sample_data.sql` — loads sample records into the core schema.
3. `Order_system_management.sql`, `Payment_transaction.sql`, `Review_rating_system.sql` — run in any order once step 2 is done; each is self-contained CRUD + reports for its own module.
4. `inventory_system.sql` — fully independent; creates and populates `inventory_db` on its own.
All scripts executed cleanly in MySQL Workbench with no errors. Every foreign key, `CHECK` constraint, and report query was verified against the sample data described above.
