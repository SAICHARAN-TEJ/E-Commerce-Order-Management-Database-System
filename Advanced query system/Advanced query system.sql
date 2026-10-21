-- Week 10: Advanced SQL Query System (subqueries and nested queries)
USE ecommerce_db;
-- 1. subquery basics
SELECT Name, Price FROM Product WHERE Price > (SELECT AVG(Price) FROM Product);
SELECT Name FROM Product WHERE ProductID IN (SELECT ProductID FROM OrderItems);
SELECT Name FROM Product WHERE ProductID NOT IN (SELECT ProductID FROM OrderItems);
SELECT Name, Price FROM Product WHERE Price > ALL (SELECT Price FROM Product WHERE CategoryID = 2);
-- nested: customers who bought from the top revenue category
SELECT Name FROM Customer WHERE CustomerID IN (
  SELECT CustomerID FROM Orders WHERE OrderID IN (
    SELECT OrderID FROM OrderItems WHERE ProductID IN (
      SELECT ProductID FROM Product WHERE CategoryID = (
        SELECT p.CategoryID FROM OrderItems oi JOIN Product p ON oi.ProductID = p.ProductID
        GROUP BY p.CategoryID ORDER BY SUM(oi.Quantity * oi.PriceAtPurchase) DESC LIMIT 1))));

-- 2. products above average price (Report 1: Premium Product Report)
SELECT p.Name, c.CategoryName AS Category, p.Price, p.StockQuantity,
       CASE WHEN p.StockQuantity = 0 THEN 'Out of Stock'
            WHEN p.StockQuantity < 30 THEN 'Low Stock' ELSE 'In Stock' END AS Availability
FROM Product p JOIN Category c ON p.CategoryID = c.CategoryID
WHERE p.Price > (SELECT AVG(Price) FROM Product) ORDER BY p.Price DESC;
-- expensive for their own category
SELECT p.Name, c.CategoryName, p.Price FROM Product p JOIN Category c ON p.CategoryID = c.CategoryID
WHERE p.Price > (SELECT AVG(Price) FROM Product WHERE CategoryID = p.CategoryID);
-- higher than the Electronics average
SELECT Name, Price FROM Product WHERE Price > (
  SELECT AVG(p.Price) FROM Product p JOIN Category c ON p.CategoryID = c.CategoryID
  WHERE c.CategoryName = 'Electronics');

-- 3. customers with maximum purchases
-- highest spender
SELECT c.Name, SUM(o.TotalAmount) AS Spent FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
HAVING SUM(o.TotalAmount) = (SELECT MAX(t) FROM (SELECT SUM(TotalAmount) AS t FROM Orders GROUP BY CustomerID) s);
-- most orders
SELECT c.Name, COUNT(o.OrderID) AS TotalOrders FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
HAVING COUNT(o.OrderID) = (SELECT MAX(n) FROM (SELECT COUNT(*) AS n FROM Orders GROUP BY CustomerID) s);
-- above average spending (also Query 2: high-value customers)
SELECT c.Name, SUM(o.TotalAmount) AS Spent FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
HAVING SUM(o.TotalAmount) > (SELECT AVG(t) FROM (SELECT SUM(TotalAmount) AS t FROM Orders GROUP BY CustomerID) s)
ORDER BY Spent DESC;
-- top 5 customers
SELECT c.Name, SUM(o.TotalAmount) AS Spent FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name ORDER BY Spent DESC LIMIT 5;

-- 4. business queries
-- Query 1: best-selling product
SELECT p.Name, SUM(oi.Quantity) AS QtySold, SUM(oi.Quantity * oi.PriceAtPurchase) AS Revenue
FROM OrderItems oi JOIN Product p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
HAVING SUM(oi.Quantity) = (SELECT MAX(q) FROM (SELECT SUM(Quantity) AS q FROM OrderItems GROUP BY ProductID) s);
-- Query 3: category performance (top row = highest revenue category)
SELECT cat.CategoryName, SUM(oi.Quantity) AS ProductsSold,
       SUM(oi.Quantity * oi.PriceAtPurchase) AS Revenue,
       (SELECT ROUND(AVG(Price), 2) FROM Product WHERE CategoryID = cat.CategoryID) AS AvgPrice
FROM OrderItems oi JOIN Product p ON oi.ProductID = p.ProductID
JOIN Category cat ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryID, cat.CategoryName ORDER BY Revenue DESC;
-- Query 4: customer purchase history, ties in most purchased product are listed together
SELECT c.Name, COUNT(*) AS Orders, SUM(o.TotalAmount) AS TotalSpent,
  (SELECT GROUP_CONCAT(p.Name SEPARATOR ', ') FROM Product p WHERE p.ProductID IN (
     SELECT x.ProductID FROM (SELECT o2.CustomerID, oi.ProductID, SUM(oi.Quantity) AS q
            FROM Orders o2 JOIN OrderItems oi ON o2.OrderID = oi.OrderID
            GROUP BY o2.CustomerID, oi.ProductID) x
     WHERE x.CustomerID = c.CustomerID
       AND x.q = (SELECT MAX(y.q) FROM (SELECT o3.CustomerID, SUM(oi3.Quantity) AS q
            FROM Orders o3 JOIN OrderItems oi3 ON o3.OrderID = oi3.OrderID
            GROUP BY o3.CustomerID, oi3.ProductID) y WHERE y.CustomerID = c.CustomerID))) AS MostPurchased
FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name ORDER BY TotalSpent DESC;

-- Report 2: customer value (Premium above avg spend, Regular above half of it, else Basic)
SELECT c.Name, COUNT(o.OrderID) AS TotalOrders, COALESCE(SUM(o.TotalAmount), 0) AS Spending,
  CASE WHEN SUM(o.TotalAmount) > a.Avg THEN 'Premium'
       WHEN SUM(o.TotalAmount) >= a.Avg / 2 THEN 'Regular' ELSE 'Basic' END AS Category
FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
CROSS JOIN (SELECT AVG(t) AS Avg FROM (SELECT SUM(TotalAmount) AS t FROM Orders GROUP BY CustomerID) s) a
GROUP BY c.CustomerID, c.Name, a.Avg ORDER BY Spending DESC;
-- Report 3: product-wise sales (top sellers are the first rows)
SELECT p.Name, COALESCE(SUM(oi.Quantity), 0) AS UnitsSold,
       COALESCE(SUM(oi.Quantity * oi.PriceAtPurchase), 0) AS Revenue
FROM Product p LEFT JOIN OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.Name ORDER BY UnitsSold DESC, Revenue DESC;
-- Report 4: high and low performing products against the average revenue per product
SELECT r.Name, r.Revenue,
       IF(r.Revenue > (SELECT AVG(Revenue) FROM (
            SELECT COALESCE(SUM(oi.Quantity * oi.PriceAtPurchase), 0) AS Revenue
            FROM Product p LEFT JOIN OrderItems oi ON p.ProductID = oi.ProductID
            GROUP BY p.ProductID) t), 'High', 'Low') AS Performance
FROM (SELECT p.ProductID, p.Name, COALESCE(SUM(oi.Quantity * oi.PriceAtPurchase), 0) AS Revenue
      FROM Product p LEFT JOIN OrderItems oi ON p.ProductID = oi.ProductID
      GROUP BY p.ProductID, p.Name) r
ORDER BY r.Revenue DESC;
-- revenue trend by month
SELECT DATE_FORMAT(OrderDate, '%Y-%m') AS Month, COUNT(*) AS Orders, SUM(TotalAmount) AS Revenue
FROM Orders GROUP BY Month ORDER BY Month;