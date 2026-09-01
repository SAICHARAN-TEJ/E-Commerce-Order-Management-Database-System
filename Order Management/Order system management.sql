-- Week 4: Order Management System
-- Order module for ecommerce_db (works with Databases.sql + sample_data.sql)

USE ecommerce_db;

-- ------------------------------------------------
-- 1. Orders and OrderItems Tables
-- ------------------------------------------------

CREATE TABLE IF NOT EXISTS Orders (
    OrderID     INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID  INT NOT NULL,
    OrderDate   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (TotalAmount >= 0),
    OrderStatus ENUM('placed','packed','shipped','out_for_delivery','delivered','cancelled','returned')
                NOT NULL DEFAULT 'placed',
    CONSTRAINT fk_order_customer
        FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS OrderItems (
    OrderItemID     INT AUTO_INCREMENT PRIMARY KEY,
    OrderID         INT NOT NULL,
    ProductID       INT NOT NULL,
    Quantity        INT NOT NULL CHECK (Quantity > 0),
    PriceAtPurchase DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_orderitems_order
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_orderitems_product
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Customer (1) -------- (Many) Orders
-- Orders (Many) -------- (Many) Product, resolved through OrderItems

-- ------------------------------------------------
-- 2. Manage Customer Product Orders
-- ------------------------------------------------

-- Create a new order for a customer (Ananya orders a mobile phone-type item)
INSERT INTO Orders (CustomerID, TotalAmount, OrderStatus)
VALUES (4, 0.00, 'placed');

-- Add products to that order (assume the new OrderID is the latest one)
INSERT INTO OrderItems (OrderID, ProductID, Quantity, PriceAtPurchase)
VALUES
    (LAST_INSERT_ID(), 3, 1, 3499.00),   -- 4K Streaming Stick
    (LAST_INSERT_ID(), 2, 2, 699.00);    -- Smart LED Bulb x2

-- Calculate and update the total order amount from its line items
UPDATE Orders o
JOIN (
    SELECT OrderID, SUM(Quantity * PriceAtPurchase) AS OrderTotal
    FROM OrderItems
    GROUP BY OrderID
) totals ON o.OrderID = totals.OrderID
SET o.TotalAmount = totals.OrderTotal
WHERE o.OrderID = LAST_INSERT_ID();

-- View complete order details (customer, products, quantities, prices)
SELECT
    o.OrderID,
    c.Name AS CustomerName,
    o.OrderDate,
    p.Name AS ProductName,
    oi.Quantity,
    oi.PriceAtPurchase,
    o.OrderStatus
FROM Orders o
JOIN Customer c   ON o.CustomerID = c.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Product p    ON oi.ProductID = p.ProductID
ORDER BY o.OrderID;

-- ------------------------------------------------
-- 3. Order Operations
-- ------------------------------------------------

-- INSERT: new order for a customer buying a phone-category product
INSERT INTO Orders (CustomerID, TotalAmount, OrderStatus)
VALUES (2, 1999.00, 'placed');

INSERT INTO OrderItems (OrderID, ProductID, Quantity, PriceAtPurchase)
VALUES (LAST_INSERT_ID(), 1, 1, 1999.00);   -- Wireless Earbuds

-- UPDATE: change order status from Pending/Placed to Delivered
UPDATE Orders
SET OrderStatus = 'delivered'
WHERE OrderID = 2
  AND OrderStatus <> 'cancelled';

-- UPDATE: change quantity of a product already in an order
UPDATE OrderItems
SET Quantity = 3
WHERE OrderID = 4
  AND ProductID = 6;

-- DELETE: remove orders that have been cancelled
DELETE FROM Orders
WHERE OrderStatus = 'cancelled';

-- ------------------------------------------------
-- 4. Customer Order History Reports
-- ------------------------------------------------

-- Report 1: Customer order history
SELECT
    c.Name AS CustomerName,
    o.OrderID,
    o.OrderDate,
    o.TotalAmount,
    o.OrderStatus
FROM Customer c
JOIN Orders o ON c.CustomerID = o.CustomerID
ORDER BY c.Name, o.OrderDate;

-- Report 2: Product-wise order report
SELECT
    p.Name AS ProductName,
    COUNT(DISTINCT oi.OrderID) AS TimesOrdered,
    SUM(oi.Quantity) AS TotalQuantitySold
FROM OrderItems oi
JOIN Product p ON oi.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalQuantitySold DESC;

-- Report 3: Customer purchase analysis

-- Customers with the maximum number of orders
SELECT
    c.Name AS CustomerName,
    COUNT(o.OrderID) AS TotalOrders
FROM Customer c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.Name
ORDER BY TotalOrders DESC;

-- Total spending by each customer
SELECT
    c.Name AS CustomerName,
    SUM(o.TotalAmount) AS TotalSpending
FROM Customer c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.Name
ORDER BY TotalSpending DESC;

-- Average order value (overall)
SELECT AVG(TotalAmount) AS AverageOrderValue
FROM Orders;

-- Total sales across all orders
SELECT SUM(TotalAmount) AS TotalSales
FROM Orders;