# Transactions.sql

A hands-on demo of database transactions and ACID, using the order flow from `ecommerce_db`. It places the same order three ways (paid, rolled back, cancelled with stock restored), runs a set of consistency checks over the data, and prints three reports.

MySQL 8.0+, with `Databases.sql` and `sample_data.sql` loaded. Tables must be InnoDB, which they are by default. MyISAM ignores transactions.

```
mysql -u root -p ecommerce_db < Transactions.sql
```

Run the file in one go, or at least in one connection. The demo order is held in session variables (`@cust`, `@prod`, `@order_ok` and so on), and a new connection starts with none of them.

The last statement of the file fails on purpose (error 3819, see below). Clients such as Workbench stop a script at the first error, which is why that statement sits at the very end and everything else runs first.

## The demo order

Customer 1 (Aarav Sharma) buys one Microwave Oven (ProductID 8, 5,499, 25 in stock). The three scenarios all use it.

| Scenario | What happens | Where it ends up |
|---|---|---|
| 1. Successful order | Lock the stock row, insert order, line and payment, reduce stock, mark `packed`, `COMMIT` | Order saved, stock down by 1 |
| 2. Failed payment, rollback | Same steps, payment comes back `failed`, then `ROLLBACK` | No order, no payment, stock untouched |
| 3. Failed payment, kept | Same steps, payment fails, stock is put back, order set to `cancelled`, `COMMIT` | Cancelled order and a `failed` payment on record, stock unchanged |

After scenario 2 the script selects the order and the stock to prove nothing survived: the order query returns no rows, and stock is the same as before the attempt.

One detail you'll notice: order IDs skip a number. In a test run the successful order was 8, the rolled-back one was 9 (gone), and the cancelled one was 10. MySQL doesn't hand back an auto-increment value when a transaction rolls back. That's normal, and not a sign something broke.

## ACID, mapped to the file

- **Atomicity.** Scenarios 2 and 3. Each is all or nothing.
- **Consistency.** `Product` has a check that `StockQuantity >= 0`. The final statement tries to subtract 100,000 and MySQL refuses it with error 3819 (`Check constraint 'Product_chk_2' is violated`). The constraint name may differ on your server.
- **Isolation.** Two sessions. Session 1 runs `START TRANSACTION; SELECT StockQuantity FROM Product WHERE ProductID = 8 FOR UPDATE;`. Session 2 runs the same select and hangs until session 1 commits or rolls back. By default MySQL gives up on the wait after 50 seconds.
- **Durability.** Scenario 1's order is read back with a select. Restart MySQL and select it again, and it's still there.

## Consistency checks

Six queries, each of which should return nothing on healthy data:

1. Orders whose customer doesn't exist
2. Payments whose order doesn't exist
3. Products with negative stock
4. Orders that have moved past `placed` without a successful payment (cash on delivery is allowed to be unpaid)
5. Cancelled orders that still have a successful payment, meaning a refund is owed
6. Orders whose `TotalAmount` doesn't match the sum of their lines

Foreign keys make the first two impossible, so they're there as a demonstration more than a real safeguard.

Check 6 returns rows on the sample data. Order 4 has a total of 2,298 but its lines add up to 2,297, so the check is doing its job. If you've also run `Order_system_management.sql`, order 8 shows up with a total of 0.00 against 4,897 in lines, and order 4 changes to 2,696 after that script edits a quantity without updating the total. They're data problems, not problems with this file.

## Reports

1. **Order transactions.** The orders from this run, with customer, amount, payment status and order status.
2. **Failed transactions.** Every cancelled order or failed payment, with the product and the quantity that went back into stock.
3. **Inventory update.** Stock at the start of the run, stock now, and units sold, for the demo product. The starting stock is captured into `@stock_start` before anything happens, so the comparison is real. (The earlier version added the sold quantity back onto current stock, which gave the wrong "previous" number whenever stock hadn't been reduced by the orders.)

From the test run:

```
+--------------------+---------------+--------------+--------------+
| ProductName        | PreviousStock | CurrentStock | QuantitySold |
+--------------------+---------------+--------------+--------------+
| Microwave Oven 20L |            25 |           24 |            1 |
+--------------------+---------------+--------------+--------------+
```

## Side effects

Each run leaves two new rows in `Orders`: one `packed`, one `cancelled` (the rolled-back one leaves nothing). Product 8 loses one unit of stock per run, so it takes about 25 runs to empty it. Use a scratch copy if the sample numbers matter.

It also works alongside `Capstone.sql`. With Capstone's triggers installed, stock still changes by exactly one per run, and the audit log gets one row per real status change.

If you see `Unknown column 'Order_ID'` or `Stock_Quantity`, you've got the previous version, which was written for a different schema.
