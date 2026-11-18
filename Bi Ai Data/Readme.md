Bi_Ai_Data.sql

Business reports on top of ecommerce_db, plus a one-row-per-customer table (ml_customer_dataset) you can export and feed into a clustering or churn model. It's plain SQL and needs MySQL 8.0 or newer, because it uses window functions.

Before you run it

Load Databases.sql and sample_data.sql first. The script reads Customer, Orders, OrderItems, Product and Review, and it doesn't create or change any of them.

You can run it as many times as you like. Views are created with CREATE OR REPLACE and the ML table is dropped and rebuilt each time.

mysql -u root -p ecommerce_db < Bi_Ai_Data.sql

Or open it in Workbench and hit Run. Each SELECT shows up as its own result tab.

What's inside
Section	What it does
Helper views	customer_stats (orders, spend, first and last purchase per customer) and product_sales (units and revenue per product)
1. Analytical reports	Total sales, monthly revenue, customers by spend, products by revenue
2. Window functions	RANK on units sold, DENSE_RANK on customer spend, ROW_NUMBER over orders
3. Segmentation	The customer_segments view, Premium / Regular / Low
4. AI-ready dataset	customer_pref_category view and the ml_customer_dataset table
5. Feature extraction	Three plain queries for customer, product and order-date features
Reports 1–3	Segment summary, sales ranking, and DESCRIBE of the ML table
Rules the script follows

Cancelled and returned orders never count as sales. It's the same rule Automationsystem.sql uses, so the numbers agree between the two files. The old version filtered on 'Completed', a status that isn't in the OrderStatus enum.

Segments are by total spend, in rupees:

Premium: 5,000 or more
Regular: 1,500 or more
Low: everything else, including customers with no orders

Those cut-offs fit the sample data, where the biggest customer spent about 7,000. With a larger dataset, change the two numbers in customer_segments.

The ML table
Column	Meaning
CustomerID	One row per customer, no duplicates (the script checks)
TenureDays	Days since the customer registered
TotalPurchases	Number of counted orders
TotalSpending	Sum of those orders
AverageOrderValue	Spend divided by orders
PurchaseFrequency	Orders per month between first and last purchase, with a floor of one month
PreferredCategory	Category with the most units bought, lowest CategoryID wins a tie, 0 if they never bought anything

There's no Age column. The Customer table doesn't have one (check the ER diagram), so TenureDays stands in for it. If your assignment really needs age, add ALTER TABLE Customer ADD Age INT, fill it in, and select it in the CREATE TABLE block.

Sample output

Segment report on the sample data:

+---------+-----------+-----------+---------------+
| Segment | Customers | AvgOrders | TotalSpending |
+---------+-----------+-----------+---------------+
| Premium |         2 |       1.5 |      12496.00 |
| Low     |         3 |       0.7 |       1397.00 |
| Regular |         1 |       1.0 |       2298.00 |
+---------+-----------+-----------+---------------+

Sneha Reddy sits in Low with zero orders because her only order was cancelled. She still gets a row in the ML table (frequency 0, category 0), which is what you want for a model: no customer silently drops out.

Things worth knowing

All sample orders were inserted at the same moment, so PurchaseFrequency equals the order count (Aarav gets 2.00). It starts to mean something once orders are spread across months.

The two CAST(o.OrderDate AS DATETIME) calls inside customer_stats look pointless, but they aren't. Without them, MySQL's strict mode fails with error 1292 (Incorrect datetime value: '0000-00-00 00:00:00') when it builds the ML table, because customers with no orders produce a NULL date. Leave them in.

If you see Unknown column 'Customer_ID', you're running an old copy of this file. The schema uses CustomerID, OrderStatus and so on, with no underscores.
