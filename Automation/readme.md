# E-Commerce Order Management Database System
 
**Student Name:** M Sai Charan Tej

**Register Number:** ASML25012

**Project Type:** Relational Database Management System (RDBMS)

**Database Engine:** MySQL

**Database Name:** `ecommerce_db`
 
---


# E-commerce database automation (Week 11)
 
Views, stored procedures, functions and scheduled events on top of the `ecommerce_db` schema from the earlier weeks. Placing an order, updating stock and producing sales reports are now one call or one query each.
 
## Files
 
- `Database_automation.sql` creates every view, function, procedure, the report log table and the events.
- `Database_automation_tests.sql` runs the checks. Run it after the main script.
## Setup
 
Needs MySQL 8.0.4 or newer, because the order procedure reads its items with `JSON_TABLE`. Run the scripts in this order:
 
1. `Databases.sql`
2. `sample_data.sql`
3. `Database_automation.sql`
4. `Database_automation_tests.sql`
The automation script drops and recreates its own objects, so it can be run again after an edit. The two events need the event scheduler on, which is the default in MySQL 8 (`SHOW VARIABLES LIKE 'event_scheduler'` to check).
 
## What it creates
 
| Type | Name | What it does |
|---|---|---|
| View | `Customer_Order_Report` | customer, order, date, amount, status |
| View | `Product_Sales_Report` | quantity sold and revenue per product |
| View | `Payment_Status_View` | order, payment mode, status, amount |
| View | `Customer_Purchase_Report` | orders and total spent per customer |
| View | `Inventory_Report` | stock per product, labelled Out of Stock, Low Stock (under 30) or In Stock |
| Function | `Total_Sales(from, to)` | revenue between two dates |
| Function | `Customer_Total_Spending(id)` | total spent by one customer |
| Function | `Product_Revenue(id)` | total sales amount of one product |
| Procedure | `Add_Customer_Order(customer, items, method)` | places a full order |
| Procedure | `Update_Order_Status(order, status)` | moves an order along its status path |
| Procedure | `Get_Customer_Purchase_History(customer)` | one row per order with items, amount and status |
| Procedure | `Add_Stock(product, quantity)` | adds new supply to a product |
| Procedure | `Generate_Sales_Report(type, start)` | saves a daily or monthly figure to `Sales_Report_Log` |
| Event | `ev_daily_sales_report` | runs every midnight for the previous day |
| Event | `ev_monthly_revenue_report` | runs on the 1st of each month for the previous month |
 
## Using it
 
```sql
CALL Add_Customer_Order(2, '[{"product":2,"qty":2},{"product":4,"qty":1}]', 'upi');
CALL Update_Order_Status(8, 'shipped');
CALL Get_Customer_Purchase_History(2);
CALL Add_Stock(8, 10);
 
SELECT Total_Sales('2026-11-01', '2026-11-30'), Customer_Total_Spending(1), Product_Revenue(1);
SELECT * FROM Inventory_Report WHERE Status <> 'In Stock';
```
 
Payment methods are the ones in the `Payment` table: `card`, `upi`, `net_banking`, `cash_on_delivery`.
 
## How it behaves
 
An order is all or nothing. `Add_Customer_Order` inserts the order and items, reduces stock, saves the total, creates the payment and sets the status inside one transaction. Cash on delivery ends up pending and placed, anything else success and packed. If a customer or product doesn't exist, or stock would go below zero, everything rolls back and the call fails with "Order failed: check customer, products and stock".
 
Status moves through placed, packed, shipped, out_for_delivery, delivered. The brief's "Pending" is `placed` here. Delivered, cancelled and returned orders are closed and can't be changed.
 
Cancelled and returned orders are left out of every sales and revenue figure.
 
Stock only drops through `Add_Customer_Order`. Rows inserted by hand into `OrderItems` don't touch it.
 
## Notes from testing
 
- Functions are declared `READS SQL DATA`. Without it MySQL refuses to create them when binary logging is on (error 1418).
- Stock reduction is inside the procedure rather than a trigger. A trigger on `OrderItems` clashed with the insert that reads `Product` prices (error 1442).
- In the sample data, order 4 is stored as 2,298 but its items add up to 2,297, so `Product_Sales_Report` totals 1 less than the order totals.
- Tested on MySQL 8.0.46, on a clean load of the sample data and on a copy where the Week 4, 5 and 6 scripts had already run.
 
