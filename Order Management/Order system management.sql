SELECT 
    o.OrderID,
    c.Name AS CustomerName,
    o.OrderDate,
    p.Name AS ProductName,
    oi.Quantity,
    oi.PriceAtPurchase,
    o.OrderStatus
FROM Orders o
INNER JOIN Customer c ON o.CustomerID = c.CustomerID
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
INNER JOIN Product p ON oi.ProductID = p.ProductID;




