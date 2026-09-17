USE ecommerce_db;
 
SELECT * FROM Customer;
SELECT * FROM Product;
SELECT Name, Price FROM Product;
SELECT * FROM Orders;
SELECT * FROM Payment;
 
SELECT * FROM Product WHERE Price > 5000;
SELECT * FROM Product WHERE StockQuantity > 0;
SELECT * FROM Customer WHERE Address LIKE '%Chennai%';
SELECT * FROM Orders WHERE OrderStatus = 'delivered';
 
SELECT p.Name, ROUND(AVG(r.Rating), 2) AS AvgRating
FROM Product p JOIN Review r ON p.ProductID = r.ProductID
GROUP BY p.ProductID, p.Name HAVING AVG(r.Rating) > 4;
 
SELECT * FROM Product ORDER BY Price ASC;
SELECT * FROM Customer ORDER BY Name ASC;
SELECT * FROM Product ORDER BY Price DESC LIMIT 5;
SELECT * FROM Orders ORDER BY OrderDate DESC;
 
SELECT DISTINCT c.CategoryName FROM Product p JOIN Category c ON p.CategoryID = c.CategoryID;
SELECT DISTINCT PaymentMethod FROM Payment;
SELECT DISTINCT Address FROM Customer;
 
SELECT * FROM Product WHERE Price BETWEEN 1000 AND 5000;
SELECT p.* FROM Product p JOIN Category c ON p.CategoryID = c.CategoryID WHERE c.CategoryName = 'Electronics';
SELECT * FROM Product WHERE Name LIKE '%Streaming%';
SELECT * FROM Product WHERE StockQuantity < 30 ORDER BY StockQuantity ASC;
 
SELECT c.Name AS CustomerName, o.OrderID, o.OrderDate, o.TotalAmount, o.OrderStatus
FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
ORDER BY c.Name, o.OrderDate;
 
SELECT p.Name AS ProductName, p.Price, c.CategoryName
FROM Product p JOIN Category c ON p.CategoryID = c.CategoryID
ORDER BY c.CategoryName, p.Name;
 
SELECT DISTINCT c.Name AS CustomerName, c.Email
FROM Customer c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
WHERE oi.ProductID = 1;
 
SELECT c.Name AS CustomerName, p.Name AS ProductName, oi.Quantity, oi.PriceAtPurchase
FROM Customer c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Product p ON oi.ProductID = p.ProductID
ORDER BY c.Name, p.Name;
 
SELECT p.* FROM Product p JOIN Category c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Electronics' AND p.Price > 10000;
 
SELECT * FROM Customer WHERE Address LIKE '%Chennai%' OR Address LIKE '%Bengaluru%';
SELECT * FROM Orders WHERE OrderStatus IN ('placed', 'packed', 'shipped');
SELECT * FROM Product WHERE Name LIKE '%Oven%';
SELECT * FROM Orders WHERE OrderDate BETWEEN '2026-07-01' AND '2026-08-31';
 
SELECT Name AS ProductName, Price, StockQuantity,
    CASE WHEN StockQuantity = 0 THEN 'Out of Stock'
         WHEN StockQuantity < 30 THEN 'Low Stock'
         ELSE 'In Stock' END AS AvailabilityStatus
FROM Product ORDER BY StockQuantity ASC;
 
SELECT COUNT(*) AS TotalCustomers FROM Customer;
 
SELECT TRIM(SUBSTRING_INDEX(Address, ',', 1)) AS City, COUNT(*) AS TotalCustomers
FROM Customer GROUP BY City ORDER BY TotalCustomers DESC;
 
SELECT * FROM Customer WHERE RegistrationDate >= (CURRENT_DATE - INTERVAL 30 DAY);
 
SELECT
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN OrderStatus = 'delivered' THEN 1 ELSE 0 END) AS Completed,
    SUM(CASE WHEN OrderStatus NOT IN ('delivered','cancelled','returned') THEN 1 ELSE 0 END) AS Pending,
    SUM(CASE WHEN OrderStatus = 'cancelled' THEN 1 ELSE 0 END) AS Cancelled
FROM Orders;
 
SELECT Name, Price FROM Product ORDER BY Price DESC LIMIT 5;
 
SELECT p.Name AS ProductName, COUNT(r.ReviewID) AS TotalReviews
FROM Product p JOIN Review r ON p.ProductID = r.ProductID
GROUP BY p.ProductID, p.Name ORDER BY TotalReviews DESC LIMIT 5;
 
SELECT Name, Price, StockQuantity FROM Product WHERE StockQuantity > 0 ORDER BY StockQuantity DESC;