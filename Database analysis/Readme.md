# Database Relationship Analysis (Joins and Aggregates)
 
**Student Name:** M Sai Charan Tej

**Register Number:** ASML25012

**Project Type:** Relational Database Management System (RDBMS)

**Database Engine:** MySQL

**Database Name:** `ecommerce_db`

---
 
## 1. Purpose
 
The schema splits an order across several tables: `Customer`, `Orders`, `OrderItems`, `Product`, `Payment` and `Category`. This script joins them back together to show:
 
- who bought what, and how much they spent
- which customers and products have no orders
- how well each payment method performs
- which products and categories earn the most revenue
## 2. Tables Used
 
| Table | Role in the analysis |
|---|---|
| `Customer` | Who placed the order |
| `Orders` | Order date, total and status |
| `OrderItems` | Line items with quantity and `PriceAtPurchase` |
| `Product` | Product name and price |
| `Category` | Groups products for revenue reporting |
| `Payment` | Method and status per order (one-to-one with `Orders`) |
 
## 3. Prerequisites
 
Run these first, in order:
 
```bash
mysql -u root -p < "Databases.sql"      # schema
mysql -u root -p < "sample data.sql"    # sample data
mysql -u root -p < "Database analysis.sql"
```
 
> The expected results below assume only the base sample data. If you have already run the Week 4 to 6 scripts, their inserts, updates and deletes will change the numbers.
 
---
 
## 4. What Each Section Does
 
| Section | Join type | Question answered |
|---|---|---|
| Customer orders | `INNER JOIN` | Which orders did each customer place? |
| Customer purchases | 3-way `INNER JOIN` | Which products did each customer buy, at what quantity and price? |
| Customers with no orders | `LEFT JOIN ... IS NULL` | Are there registered customers who never ordered? |
| Products never ordered | `LEFT JOIN ... IS NULL` | Which catalog items have never sold? |
| Orders with payments | `RIGHT JOIN` | Does every payment map to an order? |
| Complete order report | 4 joins plus `LEFT JOIN` | Customer, product, quantity, date, amount and payment status in one view |
| Customer summary | `JOIN` + `GROUP BY` | Orders, total spend and average order value per customer |
| Product revenue | `JOIN` + `GROUP BY` | Units sold and revenue per product |
| Payment method report | `GROUP BY` + `CASE`-style sums | Successful, failed and pending payments per method |
| Aggregate summary | scalar subqueries | Order count, revenue, average order value, lowest and highest price |
| Best sellers | `GROUP BY` + `LIMIT 5` | Top 5 products by units sold |
| Category revenue | 3-way `JOIN` + `GROUP BY` | Revenue per category |
 
A `LEFT JOIN` with `WHERE right_table.key IS NULL` is an anti-join: it returns rows in the left table that have no match on the right. The `RIGHT JOIN` check is included to show the reverse direction; because `Payment.OrderID` is a `NOT NULL` foreign key, it never returns an unmatched payment.
 
---
 
## 5. Expected Results on the Sample Data
 
**Summary KPIs**
 
| Metric | Value |
|---|---|
| Total orders | 7 |
| Total revenue (successful payments only) | 15,642.00 |
| Average order value | 2,584.29 |
| Lowest product price | 249.00 |
| Highest product price | 5,499.00 |
 
**Customer summary**
 
| Customer | Orders | Total spending | Avg order value |
|---|---|---|---|
| Aarav Sharma | 2 | 6,997.00 | 3,498.50 |
| Rohan Mehta | 1 | 5,499.00 | 5,499.00 |
| Ananya Iyer | 1 | 2,298.00 | 2,298.00 |
| Sneha Reddy | 1 | 1,899.00 | 1,899.00 |
| Vikram Rao | 1 | 848.00 | 848.00 |
| Priya Nair | 1 | 549.00 | 549.00 |
 
**Revenue by category**
 
| Category | Revenue |
|---|---|
| Home Appliances | 9,798.00 |
| Electronics | 4,197.00 |
| Clothing | 2,697.00 |
| Books & Stationery | 848.00 |
| Groceries | 549.00 |
 
**Payment methods**
 
| Method | Transactions | Successful | Failed | Pending |
|---|---|---|---|---|
| card | 3 | 2 | 1 | 0 |
| upi | 2 | 2 | 0 | 0 |
| net_banking | 1 | 1 | 0 | 0 |
| cash_on_delivery | 1 | 0 | 0 | 1 |
 
**Other checks**
 
- Customers with no orders: none (all 6 customers have ordered)
- Products never ordered: Cold-Pressed Olive Oil 1L
- Complete order report: 10 rows, one per order line item
- Top product revenue: Microwave Oven 20L (5,499.00), then Air Fryer 4L (4,299.00)
- Best sellers: Cotton T-Shirt leads with 2 units; every other ordered product sold 1 unit, so positions 2 to 5 are ties and their order is not guaranteed
---
 
## 6. Key Insights
 
1. **Home Appliances drive revenue.** Two products account for over half of item revenue.
2. **Aarav Sharma is the only repeat customer** and the top spender.
3. **Card is the most used method but has the only failed payment.** UPI and net banking were fully successful.
4. **One product has never sold**, which flags it for review or promotion.
5. **Revenue depends on the definition.** Total revenue counts only successful payments (15,642.00), while total order value across all orders is 18,090.00. The gap is the pending cash-on-delivery order and the cancelled order with a failed payment.
---

## 7. Notes and Limitations
 
- Customer and product summaries based on `Orders.TotalAmount` include cancelled orders. Add `WHERE o.OrderStatus <> 'cancelled'` for net figures.
- Item-based revenue (category and product reports) totals 18,089.00, one unit below the order-based 18,090.00, because Order 4's line items sum to 2,297 while its stored total is 2,298 in the sample data.
- `PriceAtPurchase` is used for revenue rather than `Product.Price`, so historic prices are respected (Order 4 records the 4K Streaming Stick at 1,499.00 against a list price of 3,499.00).
- Join results with no `ORDER BY` tie-breaker, such as equal-quantity best sellers, can return in any order.

## Proof:
<img width="617" height="369" alt="image" src="https://github.com/user-attachments/assets/c140302f-79fd-48ca-b57a-16f63d237a60" />
<img width="786" height="347" alt="image" src="https://github.com/user-attachments/assets/a208fcd3-6536-4d77-8e4e-cb2101765376" />
<img width="615" height="192" alt="image" src="https://github.com/user-attachments/assets/79a8f46a-7dd8-476b-8087-780aca511aa8" />



