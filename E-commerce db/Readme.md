Online Shopping Platform — Database

A relational MySQL database for an e-commerce platform, built from a Requirement Analysis Document and Data Requirements Document. Covers customers, products, categories, suppliers, orders, payments, shipments, and reviews.

Entity-Relationship Overview
Relationship	Type
Category → Product	1:N
Supplier → Product	1:N
Customer → Orders	1:N
Orders → Payment	1:1
Orders → Shipment	1:1
Orders ↔ Product	M:N (via OrderItems)
Customer → Review	1:N
Product → Review	1:N

See assets/er_diagram.png for the visual diagram.

Tables
Category — product categories
Supplier — vendors who supply products
Customer — registered users
Product — items for sale
Orders — customer orders
OrderItems — line items linking orders to products (junction table)
Payment — payment record per order
Shipment — shipment/tracking record per order
Review — customer product reviews
Project Structure
ecommerce-platform-db/
│
├── README.md               # This file
├── ecommerce_system.sql    # Full schema + sample data + reports
└── assets/
    └── er_diagram.png      # Exported ER diagram from MySQL Workbench
Getting Started
Prerequisites
MySQL Server 8.0+
MySQL Workbench (or any MySQL client)
Setup
Open MySQL Workbench and connect to your local instance.
Open ecommerce_system.sql in a new SQL tab.
Run the full script (Ctrl+Shift+Enter / Cmd+Shift+Enter) — this creates the ecommerce_db database, all tables, and loads sample data.
Verify the load:
sql
   USE ecommerce_db;
   SELECT * FROM Category;
   SELECT * FROM Product;
   SELECT * FROM Orders;
Sample Reports Included
Full order details (customer, product, quantity, line total)
Category-wise sales summary
Low-stock inventory alert
Order status dashboard (order + payment + shipment)
Average product rating
Notes
Password fields store placeholder hash values in sample data — always hash real passwords (e.g. bcrypt) before storing.
OrderItems was added beyond the original data requirements to correctly model a cart containing multiple products per order.
All foreign keys use ON DELETE CASCADE / ON UPDATE CASCADE unless noted otherwise.
