Order Management Sub-System
Student Name: M Sai Charan Tej

Register Number: ASML25012

Component Type: Relational Database Sub-Module

Database Engine: MySQL

Database Name: ecommerce_db

1. Overview
This folder holds the Order Management part of the e-commerce database project. The main schema already defines the full set of tables, but this sub-system is specifically about pulling order data back out in a useful way — joining an order to the customer who placed it and the products inside it, so it can be used for order history and fulfillment tracking.

In short: given the Orders, Customer, OrderItems, and Product tables, this module answers "who ordered what, when, how much, and what's the status."

2. Tables Involved
Table Name	Purpose	Key Constraints
Customer	Customer accounts and contact info	CustomerID (PK), Email (Unique)
Orders	Order header — customer, date, status	OrderID (PK), CustomerID (FK)
OrderItems	Line items within an order	OrderItemID (PK), OrderID (FK), ProductID (FK)
Product	Product catalog referenced by order items	ProductID (PK), CategoryID (FK), SupplierID (FK)

Relationships
A customer can place many orders (1:N).
An order can contain many order items (1:N).
A product can show up as a line item in many different orders (1:N).

Orders cascades on delete/update from Customer, and OrderItems cascades from Orders — so deleting a customer or an order cleans up everything under it. OrderItems.ProductID is the one exception: it's ON DELETE RESTRICT, so you can't delete a product that's already part of someone's order history.

3. A Few Design Choices Worth Noting
PriceAtPurchase is stored on OrderItems instead of just pulling the live Product.Price — that way if a product's price changes later, old orders still show what the customer actually paid.
OrderStatus moves through placed → packed → shipped → out_for_delivery → delivered (or cancelled / returned), so the order's stage is always known.
OrderDate is stamped automatically on insert, so there's no manual date entry needed for order history.

4. Sample Data
The sample dataset used for testing this module is small on purpose — just enough to exercise every join:
2 categories, 2 suppliers, 2 customers, 3 products
3 orders (one of each: placed, shipped, delivered)
4 order line items across those 3 orders (one order has 2 products)

5. The Report
Order Details Report — joins Orders, Customer, OrderItems, and Product with INNER JOIN to produce one row per product per order: order ID, customer name, order date, product name, quantity, price paid, and order status.

Since one order can have multiple products, an order with 2 items shows up as 2 rows in the output — that's expected, not a bug.

6. Execution & Verification
Ran clean in MySQL Workbench, no errors. Checked the output against the sample data above and the row counts matched what was expected.
