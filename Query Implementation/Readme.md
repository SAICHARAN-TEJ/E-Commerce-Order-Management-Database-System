# SQL Query Implementation for the E-Commerce Database

**Student Name:** M Sai Charan Tej

**Register Number:** ASML25012

**Component Type:** Relational Database Sub-Module

**Database Engine:** MySQL

**Database Name:** ecommerce_db

## 1. Project Overview
 
This module applies SQL retrieval, filtering, sorting, and reporting
techniques to the existing `ecommerce_db` schema. Where earlier weeks
focused on building the schema and its CRUD operations, this week is
purely about *querying* it — pulling customer, product, order, and
inventory information out for day-to-day operations and basic business
analysis.
 
All queries run against the tables created by `Databases.sql` and
populated by `sample_data.sql`: `Category`, `Supplier`, `Customer`,
`Product`, `Orders`, `OrderItems`, `Payment`, `Shipment`, and `Review`.
 
## 2. Repository Structure
 
| File | Module | Description |
|---|---|---|
| `Databases.sql` | Core Schema | Creates `ecommerce_db` and all 9 core tables. |
| `sample_data.sql` | Sample Data | Populates the schema with sample customers, products, orders, payments, shipments, and reviews. |
| `Week7_SQL_Queries.sql` | SQL Query Implementation (Week 7) | Basic SELECTs, WHERE filtering, ORDER BY, DISTINCT, product search, joined customer/product lookups, combined AND/OR/BETWEEN/LIKE/IN conditions, and business reports. |
 
## 3. Query Groups Covered
 
| Section | Focus | Example |
|---|---|---|
| Basic queries | Plain `SELECT` on each table | All customers, all products |
| Filtering | `WHERE` on price, stock, city, status, rating | Products over ₹5000 |
| Sorting | `ORDER BY` ascending/descending | Cheapest-to-priciest products |
| Distinct values | `DISTINCT` on categories, payment methods, locations | Payment methods in use |
| Product search | Range, category, keyword, low-stock lookups | Products ₹1000–₹5000 |
| Joined lookups | Customer ↔ order ↔ product joins | Products purchased by each customer |
| Combined filters | `AND`, `OR`, `BETWEEN`, `LIKE`, `IN` together | Electronics over ₹10,000 |
| Business reports | Availability, customer counts, order status summary, top/most-reviewed products | Order status breakdown |
 
## 4. Design Notes on the Underlying Schema
 
- **City isn't its own column.** `Customer.Address` stores a combined
  value like `"Chennai, TN"`, so city-based queries match it with `LIKE`
  (or split it with `SUBSTRING_INDEX` for the city report) rather than
  filtering a dedicated `City` field.
- **Rating lives on `Review`, not `Product`.** Any query about product
  rating joins to `Review` and aggregates with `AVG()`, since `Product`
  itself has no rating column.
- **Thresholds are configurable placeholders.** "Low stock" is defined as
  `StockQuantity < 30` and "new customer" as registered in the last 30
  days — adjust these if a specific cutoff is required.
## 5. Execution & Verification
 
Run the scripts in this order against a fresh MySQL instance:
 
1. `Databases.sql` — creates `ecommerce_db` and all core tables.
2. `sample_data.sql` — loads sample records into the schema.
3. `Week7_SQL_Queries.sql` — runs independently once the above two have
   been executed; no additional tables or data are created.
All queries were run in MySQL Workbench against the seeded schema with no
errors, and each result set was checked against the sample data for
correctness.

### Proof:
<img width="444" height="315" alt="image" src="https://github.com/user-attachments/assets/f63ba7fd-34f2-4438-bcca-33c672e62d05" />
<img width="298" height="178" alt="image" src="https://github.com/user-attachments/assets/959c285a-473a-4b4e-93c7-cdedfcab9575" />

