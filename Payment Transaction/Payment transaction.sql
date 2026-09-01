-- Week 5: Payment Transaction Management System
-- Payment module for ecommerce_db (works with Databases.sql + sample_data.sql)

USE ecommerce_db;

-- ------------------------------------------------
-- 1. Payment Table
-- ------------------------------------------------

CREATE TABLE IF NOT EXISTS Payment (
    PaymentID     INT AUTO_INCREMENT PRIMARY KEY,
    OrderID       INT NOT NULL UNIQUE,
    PaymentMethod ENUM('upi','credit_card','debit_card','net_banking','cash_on_delivery') NOT NULL,
    PaymentStatus ENUM('success','failed','pending') NOT NULL DEFAULT 'pending',
    PaymentDate   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    AmountPaid    DECIMAL(10, 2) NOT NULL CHECK (AmountPaid > 0),
    CONSTRAINT fk_payment_order
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Orders (1) -------- (1) Payment
-- OrderID is a foreign key AND unique, so each order can only have one payment row.

-- ------------------------------------------------
-- 2. Store Payment Details
-- ------------------------------------------------

-- Update a payment's status once it's been processed
UPDATE Payment
SET PaymentStatus = 'success',
    PaymentDate    = CURRENT_TIMESTAMP
WHERE OrderID = 2
  AND PaymentStatus = 'pending';

-- Get payment details for one specific order
SELECT *
FROM Payment
WHERE OrderID = 1;

-- ------------------------------------------------
-- 3. Successful and Failed Transactions
-- ------------------------------------------------

-- All successful payments
SELECT *
FROM Payment
WHERE PaymentStatus = 'success';

-- All failed payments
SELECT *
FROM Payment
WHERE PaymentStatus = 'failed';

-- Count of successful vs failed vs pending
SELECT
    SUM(CASE WHEN PaymentStatus = 'success' THEN 1 ELSE 0 END) AS TotalSuccessful,
    SUM(CASE WHEN PaymentStatus = 'failed'  THEN 1 ELSE 0 END) AS TotalFailed,
    SUM(CASE WHEN PaymentStatus = 'pending' THEN 1 ELSE 0 END) AS TotalPending
FROM Payment;

-- Retry failed card payments and mark them successful
UPDATE Payment
SET PaymentStatus = 'success',
    PaymentDate    = CURRENT_TIMESTAMP
WHERE PaymentStatus = 'failed'
  AND PaymentMethod IN ('credit_card', 'debit_card');

-- Pending transactions
SELECT *
FROM Payment
WHERE PaymentStatus = 'pending';

-- ------------------------------------------------
-- 4. Payment Analysis Reports
-- ------------------------------------------------

-- Report 1: Payment mode analysis
SELECT
    PaymentMethod,
    COUNT(*) AS TransactionCount
FROM Payment
GROUP BY PaymentMethod
ORDER BY TransactionCount DESC;

-- Most preferred payment method
SELECT
    PaymentMethod,
    COUNT(*) AS TransactionCount
FROM Payment
GROUP BY PaymentMethod
ORDER BY TransactionCount DESC
LIMIT 1;

-- Report 2: Revenue analysis
SELECT SUM(AmountPaid) AS TotalRevenue
FROM Payment
WHERE PaymentStatus = 'success';

SELECT
    PaymentMethod,
    SUM(AmountPaid) AS RevenueByMethod
FROM Payment
WHERE PaymentStatus = 'success'
GROUP BY PaymentMethod
ORDER BY RevenueByMethod DESC;

SELECT AVG(AmountPaid) AS AvgTransactionAmount
FROM Payment
WHERE PaymentStatus = 'success';

-- Report 3: Customer payment history
SELECT
    c.Name          AS CustomerName,
    o.OrderID,
    p.PaymentMethod AS PaymentMode,
    p.AmountPaid    AS Amount,
    p.PaymentStatus
FROM Payment p
JOIN Orders o   ON p.OrderID = o.OrderID
JOIN Customer c ON o.CustomerID = c.CustomerID
ORDER BY c.Name, o.OrderID;