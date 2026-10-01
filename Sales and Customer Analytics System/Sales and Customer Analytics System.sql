USE ecommerce_db;
 
SELECT COUNT(*) AS TotalOrders, SUM(TotalAmount) AS TotalRevenue, ROUND(AVG(TotalAmount), 2) AS AvgOrderValue,
       MAX(TotalAmount) AS HighestOrder, MIN(TotalAmount) AS LowestOrder
FROM Orders;
 
SELECT COUNT(*) AS Orders, SUM(TotalAmount) AS Sales
FROM Orders WHERE OrderDate BETWEEN '2026-07-01' AND '2026-08-31';
 
SELECT c.Name, COUNT(o.OrderID) AS TotalOrders, SUM(o.TotalAmount) AS TotalSpending
FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name ORDER BY TotalSpending DESC;
 
SELECT ROUND(SUM(TotalAmount) / COUNT(DISTINCT CustomerID), 2) AS AvgSpendingPerCustomer FROM Orders;
 
SELECT c.Name, SUM(o.TotalAmount) AS Spending
FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name ORDER BY Spending DESC LIMIT 5;
 
SELECT c.Name, COUNT(o.OrderID) AS TotalOrders
FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name HAVING COUNT(o.OrderID) >= 2 ORDER BY TotalOrders DESC;
 
SELECT c.Name, SUM(o.TotalAmount) AS Spending
FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name HAVING SUM(o.TotalAmount) > 3000 ORDER BY Spending DESC;
 
SELECT p.Name, SUM(oi.Quantity) AS TotalSold
FROM OrderItems oi JOIN Product p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name ORDER BY TotalSold DESC;
 
SELECT p.Name, SUM(oi.Quantity * oi.PriceAtPurchase) AS Revenue
FROM OrderItems oi JOIN Product p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name ORDER BY Revenue DESC LIMIT 5;
 
SELECT p.Name, COALESCE(SUM(oi.Quantity), 0) AS TotalSold
FROM Product p LEFT JOIN OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.Name ORDER BY TotalSold ASC LIMIT 5;
 
SELECT cat.CategoryName, SUM(oi.Quantity) AS ProductsSold, SUM(oi.Quantity * oi.PriceAtPurchase) AS TotalRevenue
FROM OrderItems oi JOIN Product p ON oi.ProductID = p.ProductID
JOIN Category cat ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryID, cat.CategoryName ORDER BY TotalRevenue DESC;
 
SELECT ROUND(AVG(t.Sales), 2) AS AvgSalesPerCategory FROM (
    SELECT SUM(oi.Quantity * oi.PriceAtPurchase) AS Sales
    FROM OrderItems oi JOIN Product p ON oi.ProductID = p.ProductID
    GROUP BY p.CategoryID) t;