USE ecommerce_db;

DROP FUNCTION IF EXISTS Total_Sales;
DROP FUNCTION IF EXISTS Customer_Total_Spending;
DROP FUNCTION IF EXISTS Product_Revenue;
DROP PROCEDURE IF EXISTS Add_Customer_Order;
DROP PROCEDURE IF EXISTS Update_Order_Status;
DROP PROCEDURE IF EXISTS Get_Customer_Purchase_History;
DROP PROCEDURE IF EXISTS Add_Stock;
DROP PROCEDURE IF EXISTS Generate_Sales_Report;
DROP EVENT IF EXISTS ev_daily_sales_report;
DROP EVENT IF EXISTS ev_monthly_revenue_report;

CREATE OR REPLACE VIEW Customer_Order_Report AS
SELECT c.Name AS CustomerName, o.OrderID, o.OrderDate, o.TotalAmount, o.OrderStatus
FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID;

CREATE OR REPLACE VIEW Product_Sales_Report AS
SELECT p.Name AS ProductName, SUM(oi.Quantity) AS QuantitySold,
       SUM(oi.Quantity * oi.PriceAtPurchase) AS TotalRevenue
FROM OrderItems oi
JOIN Product p ON oi.ProductID = p.ProductID
JOIN Orders o ON oi.OrderID = o.OrderID
WHERE o.OrderStatus NOT IN ('cancelled', 'returned')
GROUP BY p.ProductID, p.Name;

CREATE OR REPLACE VIEW Payment_Status_View AS
SELECT OrderID, PaymentMethod AS PaymentMode, PaymentStatus, AmountPaid AS TransactionAmount
FROM Payment;

CREATE OR REPLACE VIEW Customer_Purchase_Report AS
SELECT c.Name AS Customer, COUNT(*) AS Orders, SUM(o.TotalAmount) AS Amount
FROM Customer c JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderStatus NOT IN ('cancelled', 'returned')
GROUP BY c.CustomerID, c.Name;

CREATE OR REPLACE VIEW Inventory_Report AS
SELECT Name AS Product, StockQuantity AS Stock,
       CASE WHEN StockQuantity = 0 THEN 'Out of Stock'
            WHEN StockQuantity < 30 THEN 'Low Stock'
            ELSE 'In Stock' END AS Status
FROM Product;

CREATE FUNCTION Total_Sales(p_from DATE, p_to DATE) RETURNS DECIMAL(12,2) READS SQL DATA
RETURN (SELECT COALESCE(SUM(TotalAmount), 0) FROM Orders
        WHERE DATE(OrderDate) BETWEEN p_from AND p_to
          AND OrderStatus NOT IN ('cancelled', 'returned'));

CREATE FUNCTION Customer_Total_Spending(p_customer INT) RETURNS DECIMAL(12,2) READS SQL DATA
RETURN (SELECT COALESCE(SUM(TotalAmount), 0) FROM Orders
        WHERE CustomerID = p_customer AND OrderStatus NOT IN ('cancelled', 'returned'));

CREATE FUNCTION Product_Revenue(p_product INT) RETURNS DECIMAL(12,2) READS SQL DATA
RETURN (SELECT COALESCE(SUM(oi.Quantity * oi.PriceAtPurchase), 0)
        FROM OrderItems oi JOIN Orders o ON oi.OrderID = o.OrderID
        WHERE oi.ProductID = p_product AND o.OrderStatus NOT IN ('cancelled', 'returned'));

CREATE PROCEDURE Get_Customer_Purchase_History(IN p_customer INT)
SELECT o.OrderID, o.OrderDate,
       GROUP_CONCAT(CONCAT(p.Name, ' x', oi.Quantity) SEPARATOR ', ') AS Items,
       o.TotalAmount, o.OrderStatus
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Product p ON oi.ProductID = p.ProductID
WHERE o.CustomerID = p_customer
GROUP BY o.OrderID, o.OrderDate, o.TotalAmount, o.OrderStatus
ORDER BY o.OrderDate;

CREATE TABLE IF NOT EXISTS Sales_Report_Log (
    ReportType  VARCHAR(10),
    PeriodStart DATE,
    TotalOrders INT,
    Revenue     DECIMAL(12,2),
    PRIMARY KEY (ReportType, PeriodStart)
);

DELIMITER //

CREATE PROCEDURE Add_Customer_Order(IN p_customer INT, IN p_items JSON, IN p_method VARCHAR(20))
BEGIN
    DECLARE v_order INT;
    DECLARE v_total DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order failed: check customer, products and stock';
    END;

    START TRANSACTION;
    INSERT INTO Orders (CustomerID) VALUES (p_customer);
    SET v_order = LAST_INSERT_ID();

    INSERT INTO OrderItems (OrderID, ProductID, Quantity, PriceAtPurchase)
    SELECT v_order, j.pid, j.qty, p.Price
    FROM JSON_TABLE(p_items, '$[*]' COLUMNS (pid INT PATH '$.product', qty INT PATH '$.qty')) j
    LEFT JOIN Product p ON p.ProductID = j.pid;

    UPDATE Product p
    JOIN (SELECT ProductID, SUM(Quantity) AS q FROM OrderItems WHERE OrderID = v_order GROUP BY ProductID) i
      ON p.ProductID = i.ProductID
    SET p.StockQuantity = p.StockQuantity - i.q;

    SELECT SUM(Quantity * PriceAtPurchase) INTO v_total FROM OrderItems WHERE OrderID = v_order;
    UPDATE Orders SET TotalAmount = v_total WHERE OrderID = v_order;

    INSERT INTO Payment (OrderID, PaymentMethod, PaymentStatus, AmountPaid)
    VALUES (v_order, p_method, IF(p_method = 'cash_on_delivery', 'pending', 'success'), v_total);

    UPDATE Orders SET OrderStatus = IF(p_method = 'cash_on_delivery', 'placed', 'packed')
    WHERE OrderID = v_order;
    COMMIT;

    SELECT * FROM Customer_Order_Report WHERE OrderID = v_order;
END //

CREATE PROCEDURE Update_Order_Status(IN p_order INT, IN p_status VARCHAR(20))
BEGIN
    UPDATE Orders SET OrderStatus = p_status
    WHERE OrderID = p_order AND OrderStatus NOT IN ('delivered', 'cancelled', 'returned');
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Status not changed: order missing or already closed';
    END IF;
    SELECT OrderID, OrderStatus FROM Orders WHERE OrderID = p_order;
END //

CREATE PROCEDURE Add_Stock(IN p_product INT, IN p_qty INT)
BEGIN
    IF p_qty <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity must be positive';
    END IF;
    UPDATE Product SET StockQuantity = StockQuantity + p_qty WHERE ProductID = p_product;
    SELECT ProductID, Name, StockQuantity FROM Product WHERE ProductID = p_product;
END //

CREATE PROCEDURE Generate_Sales_Report(IN p_type VARCHAR(10), IN p_start DATE)
BEGIN
    DECLARE v_end DATE DEFAULT IF(p_type = 'monthly', LAST_DAY(p_start), p_start);
    REPLACE INTO Sales_Report_Log
    SELECT p_type, p_start, COUNT(*), COALESCE(SUM(TotalAmount), 0)
    FROM Orders
    WHERE DATE(OrderDate) BETWEEN p_start AND v_end AND OrderStatus NOT IN ('cancelled', 'returned');
    SELECT * FROM Sales_Report_Log WHERE ReportType = p_type AND PeriodStart = p_start;
END //

DELIMITER ;

CREATE EVENT ev_daily_sales_report
ON SCHEDULE EVERY 1 DAY STARTS CURRENT_DATE + INTERVAL 1 DAY
DO CALL Generate_Sales_Report('daily', CURRENT_DATE - INTERVAL 1 DAY);

CREATE EVENT ev_monthly_revenue_report
ON SCHEDULE EVERY 1 MONTH STARTS LAST_DAY(CURRENT_DATE) + INTERVAL 1 DAY
DO CALL Generate_Sales_Report('monthly', CURRENT_DATE - INTERVAL 1 MONTH);