# Security.sql

Role-based access control for `ecommerce_db`, plus the indexing and `EXPLAIN` work from the same assignment. Four roles, four users, each user holding exactly the permissions its job needs. Everything here was tested by logging in as each user, not just by reading the grants.

Needs MySQL 8.0 or newer, since roles don't exist in older versions (MariaDB handles them differently and `mysql.role_edges` isn't there). Run it as `root` or another account allowed to create users and grant privileges.

```
mysql -u root -p ecommerce_db < Security.sql
```

Re-running is safe: `CREATE ROLE/USER IF NOT EXISTS`, grants that repeat harmlessly, and index creation that skips what's already there.

## Who can do what

| Role | User | Tables | Access |
|---|---|---|---|
| `admin_role` | `admin_user` | everything in `ecommerce_db` | all privileges, plus `CREATE USER` |
| `sales_role` | `sales_user` | `Orders`, `OrderItems`, `Product` | read only |
| `inventory_role` | `inventory_user` | `Product` | read, and update `StockQuantity` only |
| `support_role` | `support_user` | `Customer`, `Orders` | read only; on `Customer` every column except `Password` |

Hiding `Password` from support is the one place this file goes beyond a plain "read customers" grant. Even hashed, nobody in support has a reason to see it. The side effect: `support_user` can't run `SELECT * FROM Customer`, because `*` includes the denied column. It has to list columns.

Users are created as `'name'@'localhost'`, so they can only connect from the machine running MySQL. The passwords (`Admin@123`, `Sales@123` and so on) are demo values sitting in a public repo. Change them before using this for anything real.

## Test results

Logged in as each user on MySQL 8.0 and ran these:

| User | Statement | Result |
|---|---|---|
| `sales_user` | `SELECT * FROM Orders LIMIT 5` | works |
| `sales_user` | `INSERT INTO Payment ...` | error 1142, INSERT denied for table `Payment` |
| `inventory_user` | `UPDATE Product SET StockQuantity = 50 WHERE ProductID = 10` | works |
| `inventory_user` | `UPDATE Product SET Price = 1 WHERE ProductID = 10` | error 1143, UPDATE denied for column `Price` |
| `support_user` | `SELECT CustomerID, Name, Email FROM Customer LIMIT 5` | works |
| `support_user` | `SELECT Password FROM Customer` | error 1143, SELECT denied for column `Password` |
| `support_user` | `SELECT * FROM Payment` | error 1142, SELECT denied for table `Payment` |

To try it yourself, open a new connection per user, for example `mysql -u sales_user -p ecommerce_db`.

The revoke demo grants `INSERT` on `Payment` to `sales_user`, shows the grants, revokes it, and shows them again. The first listing has the extra line and the second doesn't.

## The assignment questions

**What happens if everyone has full access?** Anyone can change or delete data by accident or on purpose, and nothing limits the damage.

**Why does payment data need extra care?** If it leaks or gets tampered with, you're looking at fraud and legal trouble. That's why only the admin role touches `Payment`.

**Why use roles instead of granting to each user?** You define permissions once per job, then give people the role. Moving someone to a different job, or tightening a permission, is one change.

## Indexes and EXPLAIN

The script runs `EXPLAIN ANALYZE` on three queries, creates three indexes, and runs the same queries again.

| Query | Before | After |
|---|---|---|
| `Product` by `Name` | table scan | index lookup on `idx_product_name` |
| `Customer` by `Phone` | table scan | index lookup on `idx_customer_phone` |
| `Orders` by `OrderDate` range | table scan | index range scan on `idx_order_date` |

The old version also indexed `Category_ID`, `Customer_ID` and `Email`. Those are skipped now. Foreign keys and `UNIQUE` columns already get an index from InnoDB, so the "before" plan for them was never a table scan and the demo would have shown nothing.

The sample tables have 6 to 11 rows, so the timings (a hundredth of a millisecond) say little. The plan change is what to look at.

On a second run the "before" plans will already use the indexes, since nothing drops them. To see the original plans again:

```sql
DROP INDEX idx_product_name ON Product;
DROP INDEX idx_customer_phone ON Customer;
DROP INDEX idx_order_date ON Orders;
```

## Reports at the end

Report 1 lists the four users and which role each holds (from `mysql.user` and `mysql.role_edges`). Report 2 runs `SHOW GRANTS ... USING` for each user, which prints the privileges the role contributes, so you can screenshot the full picture in one go.

If a grant fails with `Unknown column 'Stock_Quantity'`, you're on the old file. The real column is `StockQuantity`.
