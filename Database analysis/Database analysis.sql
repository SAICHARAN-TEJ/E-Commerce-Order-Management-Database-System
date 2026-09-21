USE ecommerce_db;
 
-- INNER JOIN
SELECT c.Name AS CustomerName, o.OrderID, o.OrderDate, o.TotalAmount, o.OrderStatus
FROM Customer c INNER JOIN Orders o ON c.CustomerID = o.CustomerID ORDER BY c.Name, o.OrderDate;
SELECT c.Name AS CustomerName, p.Name AS ProductName, oi.Quantity, oi.PriceAtPurchase
FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID JOIN Product p ON oi.ProductID = p.ProductID
ORDER BY c.Name, p.Name;
 
-- LEFT JOIN (customers with no orders, products never ordered)
SELECT c.CustomerID, c.Name FROM Customer c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID WHERE o.OrderID IS NULL;
SELECT p.ProductID, p.Name FROM Product p LEFT JOIN OrderItems oi ON p.ProductID = oi.ProductID WHERE oi.OrderItemID IS NULL;
 
-- RIGHT JOIN
SELECT o.OrderID, o.OrderStatus, pay.PaymentMethod, pay.PaymentStatus, pay.AmountPaid
FROM Orders o RIGHT JOIN Payment pay ON o.OrderID = pay.OrderID ORDER BY pay.PaymentID;
 
-- Complete order report
SELECT c.Name AS Customer, p.Name AS Product, oi.Quantity, o.OrderDate, o.TotalAmount AS Amount, pay.PaymentStatus
FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID JOIN Product p ON oi.ProductID = p.ProductID
LEFT JOIN Payment pay ON o.OrderID = pay.OrderID ORDER BY o.OrderDate, c.Name;
 
-- Customer summary (orders, spending, average)
SELECT c.Name AS CustomerName, COUNT(o.OrderID) AS TotalOrders, SUM(o.TotalAmount) AS TotalSpending,
       ROUND(AVG(o.TotalAmount), 2) AS AvgOrderValue
FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name ORDER BY TotalSpending DESC;
 
-- Product revenue
SELECT p.Name AS ProductName, SUM(oi.Quantity) AS QuantitySold, SUM(oi.Quantity * oi.PriceAtPurchase) AS TotalRevenue
FROM OrderItems oi JOIN Product p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name ORDER BY TotalRevenue DESC;
 
-- Payment method report
SELECT PaymentMethod, COUNT(*) AS Transactions, SUM(PaymentStatus = 'success') AS Successful,
       SUM(PaymentStatus = 'failed') AS Failed, SUM(PaymentStatus = 'pending') AS Pending
FROM Payment GROUP BY PaymentMethod ORDER BY Transactions DESC;
 
-- Aggregate summary
SELECT (SELECT COUNT(*) FROM Orders) AS TotalOrders,
       (SELECT SUM(AmountPaid) FROM Payment WHERE PaymentStatus = 'success') AS TotalRevenue,
       (SELECT ROUND(AVG(TotalAmount), 2) FROM Orders) AS AvgOrderValue,
       (SELECT MIN(Price) FROM Product) AS LowestPrice, (SELECT MAX(Price) FROM Product) AS HighestPrice;
 
-- Best sellers and top categories
SELECT p.Name, SUM(oi.Quantity) AS QtySold FROM OrderItems oi JOIN Product p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name ORDER BY QtySold DESC LIMIT 5;
SELECT cat.CategoryName, SUM(oi.Quantity * oi.PriceAtPurchase) AS CategoryRevenue FROM OrderItems oi
JOIN Product p ON oi.ProductID = p.ProductID JOIN Category cat ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryID, cat.CategoryName ORDER BY CategoryRevenue DESC;