-- Create the Database Schema
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- 1. Category
CREATE TABLE IF NOT EXISTS Category (
    CategoryID   INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    Description  TEXT
);

-- 2. Supplier
CREATE TABLE IF NOT EXISTS Supplier (
    SupplierID    INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName  VARCHAR(150) NOT NULL,
    ContactNumber VARCHAR(20),
    Email         VARCHAR(150) UNIQUE,
    Address       VARCHAR(255)
);

-- 3. Customer
CREATE TABLE IF NOT EXISTS Customer (
    CustomerID       INT AUTO_INCREMENT PRIMARY KEY,
    Name             VARCHAR(150) NOT NULL,
    Email            VARCHAR(150) NOT NULL UNIQUE,
    Phone            VARCHAR(20),
    Password         VARCHAR(255) NOT NULL,       -- store a hash, never plain text
    Address          VARCHAR(255),
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Product
CREATE TABLE IF NOT EXISTS Product (
    ProductID     INT AUTO_INCREMENT PRIMARY KEY,
    Name          VARCHAR(150) NOT NULL,
    Description   TEXT,
    Price         DECIMAL(10, 2) NOT NULL CHECK (Price >= 0),
    StockQuantity INT NOT NULL DEFAULT 0 CHECK (StockQuantity >= 0),
    CategoryID    INT NOT NULL,
    SupplierID    INT NOT NULL,
    CONSTRAINT fk_product_category
        FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_product_supplier
        FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 5. Orders  (named Orders, not Order, since ORDER is a reserved SQL keyword)
CREATE TABLE IF NOT EXISTS Orders (
    OrderID     INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID  INT NOT NULL,
    OrderDate   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    OrderStatus ENUM('placed','packed','shipped','out_for_delivery','delivered','cancelled','returned')
                NOT NULL DEFAULT 'placed',
    CONSTRAINT fk_order_customer
        FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 6. OrderItems (junction table: one order can contain many products)
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

-- 7. Payment
CREATE TABLE IF NOT EXISTS Payment (
    PaymentID     INT AUTO_INCREMENT PRIMARY KEY,
    OrderID       INT NOT NULL UNIQUE,             -- 1:1 with Orders
    PaymentMethod ENUM('card','upi','net_banking','cash_on_delivery') NOT NULL,
    PaymentStatus ENUM('success','failed','pending') NOT NULL DEFAULT 'pending',
    PaymentDate   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    AmountPaid    DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_payment_order
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 8. Shipment
CREATE TABLE IF NOT EXISTS Shipment (
    ShipmentID     INT AUTO_INCREMENT PRIMARY KEY,
    OrderID        INT NOT NULL UNIQUE,            -- 1:1 with Orders
    ShippingDate   DATE,
    DeliveryDate   DATE,
    ShipmentStatus ENUM('packed','shipped','out_for_delivery','delivered') NOT NULL DEFAULT 'packed',
    TrackingNumber VARCHAR(50),
    CONSTRAINT fk_shipment_order
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 9. Review
CREATE TABLE IF NOT EXISTS Review (
    ReviewID   INT AUTO_INCREMENT PRIMARY KEY,	
    ProductID  INT NOT NULL,
    CustomerID INT NOT NULL,
    Rating     TINYINT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment    TEXT,
    ReviewDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_product
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_review_customer
        FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
