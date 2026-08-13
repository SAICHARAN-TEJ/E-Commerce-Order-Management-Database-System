# Inventory Management Sub-System

**Student Name:** M Sai Charan Tej

**Register Number:** ASML25012

**Component Type:** Relational Database Sub-Module

**Database Engine:** MySQL

**Database Name:** `inventory_db`

---

## 1. Overview

This directory contains the SQL script and logic for the **Inventory Management** sub-system of the e-commerce database. While a broader catalog module can handle general product listings, this specific sub-system tracks multi-vendor stock levels, Stock Keeping Units (SKUs), and automated restock thresholds.

The system links specific products to registered sellers, allowing the platform to track exactly who is supplying what, how many units are currently available, and when a seller needs to be notified to restock.

---

## 2. Database Schema (Inventory Context)

This sub-system is built around four tables that manage the product catalog and vendor inventory together.

| Table Name | Purpose | Key Constraints |
| :--- | :--- | :--- |
| `Category` | Stores product category names and descriptions. | `CategoryID` (Primary Key), `CategoryName` (Unique) |
| `Product` | Stores the core product catalog: name, category, price, and stock. | `ProductID` (Primary Key), `CategoryID` (Foreign Key) |
| `Seller` | Stores vendor/supplier profiles and contact routing info. | `SellerID` (Primary Key), `StoreName` (Unique), `ContactEmail` (Unique) |
| `Inventory` | Tracks specific stock levels, SKUs, and reorder thresholds per seller. | `ItemID` (Primary Key), `ProductID` (Foreign Key), `SellerID` (Foreign Key), `SKU` (Unique) |

### Entity Relationships
* **Category to Product:** One-to-Many (1:N) — A single category can group multiple products.
* **Sellers to Inventory:** One-to-Many (1:N) — A single seller can supply multiple distinct inventory items.
* **Products to Inventory:** One-to-Many (1:N) — A single product catalog entry can be linked to multiple inventory records if multiple sellers supply the same item.
* *Note: `ON DELETE CASCADE` is applied to foreign keys linking `Product` back to `Category`, and linking `Inventory` back to both `Product` and `Seller`, to ensure orphaned records are never created.*

---

## 3. Data Integrity & Business Rules

To enforce operational logic at the database engine level, the following constraints are implemented:

* **Unique Tracking:** Every inventory item must possess a unique `SKU` (Stock Keeping Unit) to prevent duplicate vendor listings for the exact same item.
* **Domain Integrity:** `CHECK` constraints ensure `Product.Price` and `Product.StockQuantity` cannot be negative.
* **Automated Restock Logic:** The `ReorderLevel` column (defaulting to 10) is evaluated against the current `StockQuantity` to generate dynamic restock alerts without requiring manual monitoring.
* **Timestamping:** The `LastRestocked` column automatically records the timestamp of the last inventory update, and `CreatedAt` columns on `Category`, `Product`, and `Seller` record when each record was first added — supporting full auditability for supply chain tracking.

---

## 4. Sample Data & CRUD Demo

The script populates the schema with:
* 30 product categories
* 40 catalog products
* 15 registered sellers
* 40 inventory records tying products to the sellers stocking them

It also includes a CRUD operations demo covering: updating a product's price/stock, a bulk price increase for a category, deleting a product and a category (cascading to dependent inventory), restocking an inventory item, and removing an individual inventory record.

---

## 5. Inventory Reports & Outputs

The SQL script includes analytical queries designed for supply chain and operations management:

### Report 1: Complete Product Catalog Report
Retrieves all product details alongside their corresponding category names and calculates the total inventory value (`Price × StockQuantity`) per product.

### Report 2: Category Summary Report
Aggregates total product count, average price, total stock, and overall inventory value per category.

### Report 3: Low-Stock Inventory Alert Report
Filters and displays products with a stock quantity of less than 25 units, ordered by ascending stock.

### Report 4: Seller Inventory & Restock Alert Report
A dynamic operational report that compares an item's current `StockQuantity` against its specific `ReorderLevel`. It flags exactly which sellers need to restock which specific products.

---

## 6. Execution & Verification

The SQL script was executed successfully in MySQL Workbench without errors. All four tables (`Category`, `Product`, `Seller`, `Inventory`), their foreign key constraints, sample data, CRUD operations, and all four reports were validated.

---

## 7. Files in this Directory

```text
inventory/
│
├── README.md                 # Project documentation and schema guide
└── inventory_system.sql      # SQL script: schema creation, dummy data, CRUD demo, and reports
```
---


### Report 1: Complete Product Catalog Report
Retrieves all product details alongside their corresponding category names and calculates the total inventory value.
<img width="839" height="567" alt="Report 1 Output" src="https://github.com/user-attachments/assets/ea177a31-35c0-49b8-b4ec-66c429355c91" />

### Report 2: Category Summary Report
Aggregates total product count, average price, total stock, and overall inventory value per category.
<img width="754" height="559" alt="Report 2 Output" src="https://github.com/user-attachments/assets/b9ab66b8-6898-4634-99c0-be9784929105" />

### Report 3: Low-Stock Inventory Alert Report
Filters and displays products with a total stock quantity of less than 25 units, ordered by ascending stock.
<img width="555" height="309" alt="Report 3 Output" src="https://github.com/user-attachments/assets/d9ec700f-9ffc-4626-995a-b8e73a6675f7" />

### Report 4: Seller Inventory & Restock Alert Report
A dynamic operational report that compares an item's current `stock_quantity` against its specific `reorder_level`. It flags exactly which sellers need to restock which specific products.
<img width="962" height="103" alt="Report 4 Output" src="https://github.com/user-attachments/assets/167b0503-675e-4d05-851a-b844995326cb" />

---


