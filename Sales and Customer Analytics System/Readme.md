# Sales and Customer Analytics System

**Student Name:** M Sai Charan Tej

**Register Number:** ASML25012

**Project Type:** Relational Database Management System (RDBMS)

**Database Engine:** MySQL

**Database Name:** `ecommerce_db`
 
---
 
SQL analytics for an e-commerce database. Uses aggregate functions, grouping and joins to turn order data into business reports: sales performance, customer behavior, best-selling products and category revenue.
 
## Overview
 
The management team wants to know who the top customers are, which products sell best, and which categories earn the most. This project answers those questions with plain MySQL queries on the existing `ecommerce_db` database.
 
## Tech Stack
 
- MySQL 8+
- MySQL Workbench or the `mysql` command-line client
## Tables Used
 
| Table | Used for |
|-------|----------|
| `Customer` | Customer names and identity |
| `Orders` | Order totals, dates and status |
| `OrderItems` | Quantity and price per product sold |
| `Product` | Product names and categories |
| `Category` | Category names |
 
## Setup
 
Run the schema and sample data first, then the analytics file:
 
```bash
mysql -u root -p < Databases.sql
mysql -u root -p < sample_data.sql
mysql -u root -p < Sales_Customer_Analytics.sql
```
 
## Aggregate Functions Used
 
| Function | Purpose | Example |
|----------|---------|---------|
| `COUNT()` | Number of records | Total orders |
| `SUM()` | Total value | Total revenue |
| `AVG()` | Average value | Average order value |
| `MIN()` | Smallest value | Lowest order amount |
| `MAX()` | Largest value | Highest order amount |
 
## Reports
 
### 1. Sales Performance
- Total orders and total revenue
- Average, highest and lowest order value
- Total sales for a chosen date range
### 2. Customer Analytics
- Orders and total spending per customer
- Average spending per customer
- Top 5 customers by spending
- Frequent customers (2 or more orders)
- High-value customers
### 3. Product Performance
- Best-selling products by quantity
- Top products by revenue
- Least-selling products
### 4. Category Analysis
- Units sold and revenue per category
- Average sales per category
## Sample Query
 
Top 5 customers by total spending:
 
```sql
SELECT c.Name, SUM(o.TotalAmount) AS Spending
FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY Spending DESC
LIMIT 5;
```
 
## Project Files
 
| File | Description |
|------|-------------|
| `Databases.sql` | Database schema |
| `sample_data.sql` | Sample records |
| `Sales_Customer_Analytics.sql` | All analytics queries |
 
## Notes
 
- Revenue is calculated from all orders, including cancelled ones. To exclude them, add `WHERE OrderStatus <> 'cancelled'`.
- The date range query uses July to August 2026. Edit the dates to match your data.
- The high-value customer cutoff is set to 3000. Adjust it as needed.
## Author
 
**SAICHARAN-TEJ**
[GitHub Repository](https://github.com/SAICHARAN-TEJ/E-Commerce-Order-Management-Database-System)
