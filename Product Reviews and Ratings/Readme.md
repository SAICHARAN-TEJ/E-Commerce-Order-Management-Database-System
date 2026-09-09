Product Review and Rating Sub-System

Student Name: M Sai Charan Tej

Register Number: ASML25012

Component Type: Relational Database Sub-Module

Database Engine: MySQL

Database Name: ecommerce_db

1. Overview

This folder holds the Product Review and Rating part of the e-commerce database project. The main schema (Databases.sql) already defines the Review table alongside Customer and Product, but this sub-system is specifically about collecting customer feedback after a purchase and turning it into something useful — average ratings, review counts, and a picture of which products are performing well and which aren't.

In short: given the Review, Customer, and Product tables, this module answers "what are customers saying about this product, how many stars is it getting, and is it worth restocking or reworking."

2. Tables Involved
Table Name	Purpose	Key Constraints
Customer	Customer accounts and contact info	CustomerID (PK), Email (Unique)
Product	Product catalog that reviews are attached to	ProductID (PK), CategoryID (FK), SupplierID (FK)
Review	Customer feedback and star ratings on a product	ReviewID (PK), CustomerID (FK), ProductID (FK)

Relationships

A customer can write many reviews (1:N).
A product can receive many reviews (1:N).
Each review belongs to exactly one customer and exactly one product.

Review cascades on delete/update from both Customer and Product — so removing a customer account or discontinuing a product also clears out the reviews tied to it, rather than leaving orphaned rows behind.

3. A Few Design Choices Worth Noting
Rating is constrained with CHECK (Rating BETWEEN 1 AND 5), so there's no way to insert a 0-star or 9-star review at the database level — the rule lives in the schema, not just the application code.
Rating and ReviewDate are NOT NULL — every review has to actually carry a score and a timestamp; there's no such thing as a blank or undated review.
ReviewDate defaults to CURRENT_TIMESTAMP, so a review is timestamped automatically at insert time with no manual date entry needed.
Comment is nullable — a customer can leave a star rating with no written feedback, which reflects how most real review systems behave.
Reused the existing Review table from Databases.sql rather than creating a second one, since the schema already modeled ReviewID/Comment/ReviewDate cleanly — no reason to duplicate it under different column names.
4. Sample Data

The sample dataset used for testing this module is small on purpose — just enough to exercise every query:

6 customers, 11 products (from sample_data.sql)
8 initial reviews spanning ratings from 3 to 5 stars
2 additional reviews inserted directly in this module to test the insert/update/delete flow
5. The Reports
Report 1 — Product Rating Analysis: joins Product and Review (LEFT JOIN, so unreviewed products still show up) to list product name, number of reviews, and average rating.
Report 2 — Customer Feedback Analysis: three separate queries pulling out the most-reviewed products, the highly-rated products (4 stars and up), and the products that need improvement (under 3 stars average).
Report 3 — Rating Distribution: a single-row breakdown of how many 5-star, 4-star, 3-star, 2-star, and 1-star reviews exist, plus a count of how many products fall into the "low-rated" bucket (average under 3).

Since a product can have multiple reviews, Report 1 naturally produces one row per product regardless of how many reviews it has — the COUNT/AVG aggregation collapses them, unlike the Order report where one row exists per line item.

6. Execution & Verification

Ran clean against ecommerce_db in MySQL Workbench after Databases.sql and sample_data.sql, no errors. Checked the aggregate queries by hand against the sample review data above and the averages matched what was expected.
