# Capstone.sql

The capstone pulls the whole project into one script: a data check, queries from basic to nested, views, functions, stored procedures, triggers, indexes and a set of business reports. After it runs, you can place an order with a single `CALL` and watch stock, payment status, order status and the audit log all update by themselves.

Needs MySQL 8.0+ and the base schema and sample data (`Databases.sql`, `sample_data.sql`). It's safe to re-run, with one catch covered under "Side effects".

```
mysql -u root -p ecommerce_db < Capstone.sql
```

In Workbench, run the whole file. The `DELIMITER //` blocks are handled for you.

## Sections

1. **Data check.** Counts rows in six tables against the minimums (50 customers, 100 products, 20 suppliers, 100 orders, 100 payments, 50 reviews) and prints `OK` or `SHORT`.
2. **Queries.** Basic filters, a join with `HAVING`, then subqueries.
3. **Views.** `v_customer_order_history`, `v_sales_report`, `v_product_performance`.
4. **Functions.** `fn_customer_spending(id)` and `fn_product_revenue(id)`.
5. **Procedures.** `sp_update_stock`, `sp_sales_total`, `sp_place_order`.
6. **Triggers.** Three of them, plus the `Audit_Log` table.
7. **Performance.** Two indexes and three `EXPLAIN` statements.
8. **Business insights.** Sales, customer, inventory and product reports.

As everywhere in this project, cancelled and returned orders don't count as revenue.

## Placing an order

```sql
CALL sp_place_order(1, 3, 1, 'upi');   -- customer 1, product 3, quantity 1
```

The procedure runs inside one transaction. It locks the product row, checks the product exists and the stock covers the quantity, then inserts the order, the order line and the payment, and takes the stock down. Any failure rolls the whole thing back, so there are no half-made orders.

The payment method has to be one of the enum values in `Payment`: `card`, `upi`, `net_banking` or `cash_on_delivery`. Cash on delivery creates a `pending` payment and the order stays `placed`. Anything else is recorded as `success`.

What it returns, and what goes wrong, from the test runs:

| Call | Result |
|---|---|
| `sp_place_order(1, 3, 1, 'upi')` | Order created, status `packed` |
| `sp_place_order(2, 8, 1, 'cash_on_delivery')` | Order created, status stays `placed` |
| quantity larger than stock | Error 1644, `Product out of stock` |
| product ID that doesn't exist | Error 1644, `Product not found` |
| quantity 0 | Error 1644, `Quantity must be at least 1` |
| `'bitcoin'` as method | Error 1265, data truncated for `PaymentMethod` |
| customer ID that doesn't exist | Error 1452, foreign key fails |

After every failed call the order count and stock were unchanged.

## Triggers

| Trigger | Fires | What it does |
|---|---|---|
| `trg_check_stock` | before insert on `OrderItems` | Refuses a line that asks for more than the stock |
| `trg_payment_status` | after insert on `Payment` | `success` moves the order to `packed`, `failed` to `cancelled`, `pending` changes nothing |
| `trg_order_audit` | after update on `Orders` | Writes old and new status to `Audit_Log`, only when the status actually changed |

`trg_payment_status` only touches orders that are still `placed`, so a late payment row can't drag a shipped order backwards.

There's no trigger that reduces stock, and that's on purpose. `Add_Customer_Order` in `Automationsystem.sql` and the manual updates in `Transactions.sql` already subtract stock themselves. A trigger on top would take it twice. I tested both with the triggers installed, and stock drops by exactly the ordered quantity.

## Indexes

`Customer.Email` is `UNIQUE`, so it already has an index and the old script's extra one was a duplicate. The foreign key columns are covered too. What's left worth adding:

- `idx_product_name` on `Product(Name)`
- `idx_order_customer_date` on `Orders(CustomerID, OrderDate)`, which lets "latest orders for a customer" read the index backwards with no sort step

A small helper procedure, `sp_add_index`, creates each index only if it's missing and then drops itself. That's what makes re-runs safe, since MySQL has no `CREATE INDEX IF NOT EXISTS`. `Security.sql` uses the same helper and the same index name, so the two files can run in either order.

## Side effects of running it

The test block at the end of section 6 does real work on every run: it places one UPI order for customer 1 (product 3) and adds 5 units of stock to product 3. So each run adds an order and nets stock up by 4. Run it on a scratch copy if you care about the sample numbers.

## Things to know

On the six-customer sample data, the section 1 check prints `SHORT` for every table. That's the check doing its job. It doesn't load anything. Load more rows, or change the minimums to match your assignment.

Thresholds in the reports are rupees sized for the sample data: High Value at 5,000, Regular at 1,500, and stock flagged Low under 30 units or Overstocked over 250. Adjust them for bigger data.

If you see `Unknown column 'Product_Name'` or `'Completed'` anywhere, that's the previous version of the file. The real names are `Name`, `OrderStatus`, `placed / packed / shipped / out_for_delivery / delivered / cancelled / returned`, and so on.
