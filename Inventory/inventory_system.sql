-- =================================================================
-- Product, Category & Seller Inventory Management System Script
-- Database Engine: MySQL
-- Description: Massive relational database for managing products,
-- categories, sellers, and inventory. Includes 125+ rows of dummy data.
-- Naming convention aligned with Databases.sql (PascalCase tables/columns)
-- =================================================================

DROP DATABASE IF EXISTS inventory_db;
CREATE DATABASE inventory_db;
USE inventory_db;

-- -----------------------------------------------------------------
-- Table: Category
-- -----------------------------------------------------------------
CREATE TABLE Category (
    CategoryID   INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    Description  TEXT,
    CreatedAt    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------
-- Table: Product
-- -----------------------------------------------------------------
CREATE TABLE Product (
    ProductID     INT AUTO_INCREMENT PRIMARY KEY,
    ProductName   VARCHAR(150) NOT NULL,
    CategoryID    INT NOT NULL,
    Price         DECIMAL(10, 2) NOT NULL CHECK (Price >= 0),
    StockQuantity INT NOT NULL DEFAULT 0 CHECK (StockQuantity >= 0),
    CreatedAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_category
        FOREIGN KEY (CategoryID)
        REFERENCES Category(CategoryID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- -----------------------------------------------------------------
-- Table: Seller
-- -----------------------------------------------------------------
CREATE TABLE Seller (
    SellerID      INT AUTO_INCREMENT PRIMARY KEY,
    StoreName     VARCHAR(120) NOT NULL UNIQUE,
    ContactEmail  VARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber   VARCHAR(20),
    City          VARCHAR(50),
    CreatedAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------
-- Table: Inventory
-- -----------------------------------------------------------------
CREATE TABLE Inventory (
    ItemID        INT AUTO_INCREMENT PRIMARY KEY,
    ProductID     INT NOT NULL,
    SellerID      INT NOT NULL,
    SKU           VARCHAR(50) UNIQUE,
    UnitPrice     DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    ReorderLevel  INT DEFAULT 10,
    LastRestocked TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_product
        FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID)
        ON DELETE CASCADE,
    CONSTRAINT fk_inventory_seller
        FOREIGN KEY (SellerID)
        REFERENCES Seller(SellerID)
        ON DELETE CASCADE
);

-- -----------------------------------------------------------------
-- Sample Data Insertion (125 Rows of Unique Data)
-- -----------------------------------------------------------------

-- Insert 30 Categories
INSERT INTO Category (CategoryName, Description) VALUES
('Audio Visual', 'High-fidelity sound systems and visual display units'),
('Smart Home Devices', 'Automated home and security gadgets'),
('Office Ergonomics', 'Furniture and tools for a productive workspace'),
('Digital Media', 'E-books, software, and digital subscriptions'),
('Mobile Computing', 'Laptops, tablets, and accessories'),
('Wearable Tech', 'Smartwatches and fitness trackers'),
('Gaming Gear', 'Consoles, controllers, and gaming peripherals'),
('Photography', 'Cameras, lenses, and tripods'),
('Networking', 'Routers, modems, and switches'),
('Audio Accessories', 'Cables, stands, and cases'),
('Storage Devices', 'External SSDs, HDDs, and flash drives'),
('Power Backup', 'UPS and surge protectors'),
('Printers & Scanners', 'Office printing and scanning solutions'),
('Computer Components', 'RAM, SSDs, and motherboards'),
('Software Solutions', 'OS, Antivirus, and Productivity software'),
('Climate Control', 'Smart thermostats and air purifiers'),
('Home Lighting', 'Smart bulbs and LED strips'),
('Security Cameras', 'Indoor and outdoor surveillance'),
('Smart Locks', 'Keyless entry systems'),
('Robotics', 'Vacuum robots and lawn mowers'),
('Streaming Devices', 'Smart TV boxes and sticks'),
('Cables & Adapters', 'HDMI, USB, and display cables'),
('Desk Organization', 'Cable management and desk trays'),
('Writing Tools', 'Pens, stylus, and markers'),
('Notebooks', 'Journals and digital pads'),
('Keyboards & Mice', 'Wireless and mechanical input devices'),
('Monitors', '4K, Ultrawide, and curved displays'),
('Webcams', 'HD streaming cameras'),
('Headsets', 'Gaming and communication headsets'),
('External Drives', 'Portable and desktop drives');

-- Insert 40 Products
INSERT INTO Product (ProductName, CategoryID, Price, StockQuantity) VALUES
('Aurora Noise-Cancelling Headset', 1, 149.99, 80),
('Lumina 4K UHD Monitor', 30, 320.00, 25),
('Vortex Pro Mechanical Keyboard', 26, 89.50, 40),
('Guardian Smart Doorbell', 2, 199.00, 15),
('CloudSync Wireless Charger', 2, 35.99, 200),
('PostureFlex Ergonomic Chair', 3, 250.00, 10),
('Mastering SQL Masterclass (E-Book)', 4, 45.00, 999),
('ZenBook Pro Duo Laptop', 5, 2499.99, 12),
('Galaxy Watch Active', 6, 180.00, 45),
('Xbox Elite Controller', 7, 159.99, 60),
('Canon EOS Rebel Camera', 8, 599.00, 10),
('NetGear Nighthawk Router', 9, 199.99, 35),
('Premium HDMI Cable', 22, 14.99, 500),
('Samsung T5 Portable SSD', 11, 99.00, 80),
('APC Back-UPS Pro', 12, 150.00, 25),
('HP LaserJet Pro Printer', 13, 220.00, 18),
('Corsair Vengeance 16GB RAM', 14, 79.99, 70),
('Windows 11 Pro License', 15, 139.00, 999),
('Nest Learning Thermostat', 16, 130.00, 40),
('Philips Hue Smart Bulb', 17, 25.00, 150),
('Ring Spotlight Cam', 18, 199.00, 30),
('Yale Smart Lock', 19, 180.00, 20),
('iRobot Roomba', 20, 400.00, 15),
('Roku Streaming Stick', 21, 39.99, 200),
('Logitech MX Master Mouse', 26, 79.99, 50),
('Razer Kiyo Webcam', 28, 95.00, 25),
('HyperX Cloud II Headset', 29, 69.99, 90),
('Seagate Backup Plus Drive', 30, 59.99, 120),
('Anker PowerBank 20000mAh', 12, 45.99, 200),
('Dell UltraSharp Monitor', 30, 310.00, 15),
('SteelSeries Apex Keyboard', 26, 110.00, 35),
('Logitech C920 Webcam', 28, 70.00, 80),
('Blue Yeti Microphone', 8, 100.00, 40),
('Elgato Stream Deck', 7, 130.00, 25),
('Asus ROG Router', 9, 250.00, 10),
('TP-Link Smart Plug', 2, 20.00, 300),
('Brother Inkjet Printer', 13, 120.00, 20),
('MSI Gaming Monitor', 30, 280.00, 15),
('JBL Bluetooth Speaker', 1, 60.00, 110),
('Lenovo ThinkPad Laptop', 5, 999.00, 20);

-- Insert 15 Sellers
INSERT INTO Seller (StoreName, ContactEmail, PhoneNumber, City) VALUES
('TechNova Solutions', 'procurement@technova.com', '555-0192', 'San Francisco'),
('ErgoComfort Supply', 'b2b@ergocomfort.com', '555-0173', 'Austin'),
('SecureLife Tech', 'vendors@securelife.com', '555-0145', 'Boston'),
('GadgetHub Ltd', 'sales@gadgethub.com', '555-0188', 'Seattle'),
('ByteStore Inc', 'contact@bytestore.com', '555-0166', 'Miami'),
('NextGen Electronics', 'supply@nextgen.com', '555-0111', 'Chicago'),
('HomeSmart Corp', 'orders@homesmart.com', '555-0122', 'Dallas'),
('StreamWorks Gear', 'hello@streamworks.com', '555-0133', 'New York'),
('PowerGrid Tools', 'power@gridtools.com', '555-0144', 'Denver'),
('Visionary Displays', 'displays@visionary.com', '555-0155', 'San Diego'),
('MobilityTech', 'sales@mobilitytech.com', '555-0167', 'Atlanta'),
('AudioMax Direct', 'b2b@audiomax.com', '555-0178', 'Portland'),
('PrintWorld USA', 'contact@printworld.com', '555-0189', 'Phoenix'),
('DataStore Systems', 'orders@datastore.com', '555-0190', 'Las Vegas'),
('SmartSecure Inc', 'vendors@smartsecure.com', '555-0191', 'Houston');

-- Insert 40 Inventory Items
INSERT INTO Inventory (ProductID, SellerID, SKU, UnitPrice, StockQuantity, ReorderLevel) VALUES
(1, 12, 'AV-AUR-001', 149.99, 50, 15),
(2, 10, 'DS-LUM-002', 320.00, 12, 10),
(3, 1, 'KB-VTX-003', 89.50, 30, 20),
(4, 3, 'SH-GUA-004', 199.00, 8, 10),
(5, 2, 'SH-CSY-005', 35.99, 150, 50),
(6, 2, 'ERG-PFX-006', 250.00, 5, 10),
(7, 6, 'SW-MAS-007', 45.00, 999, 50),
(8, 11, 'LP-ZEN-008', 2499.99, 10, 5),
(9, 11, 'WT-GAL-009', 180.00, 35, 15),
(10, 8, 'GM-XBX-010', 159.99, 40, 20),
(11, 4, 'PH-CAN-011', 599.00, 8, 10),
(12, 9, 'NW-NGR-012', 199.99, 25, 15),
(13, 5, 'CB-HDM-013', 14.99, 400, 100),
(14, 14, 'ST-T5P-014', 99.00, 60, 30),
(15, 9, 'PW-APC-015', 150.00, 20, 10),
(16, 13, 'PR-HPJ-016', 220.00, 15, 10),
(17, 5, 'CC-CVS-017', 79.99, 50, 25),
(18, 6, 'SW-W11-018', 139.00, 999, 50),
(19, 7, 'CC-NST-019', 130.00, 30, 15),
(20, 7, 'LT-HUE-020', 25.00, 120, 50),
(21, 3, 'SC-RNG-021', 199.00, 25, 10),
(22, 3, 'SL-YAL-022', 180.00, 15, 10),
(23, 7, 'RB-IRB-023', 400.00, 12, 5),
(24, 7, 'SD-RKU-024', 39.99, 180, 80),
(25, 1, 'MS-MXM-025', 79.99, 45, 20),
(26, 8, 'WC-RZK-026', 95.00, 20, 15),
(27, 12, 'HS-HYP-027', 69.99, 80, 30),
(28, 14, 'DR-STG-028', 59.99, 100, 40),
(29, 9, 'PW-ANK-029', 45.99, 180, 60),
(30, 10, 'MN-DLL-030', 310.00, 10, 5),
(31, 1, 'KB-STL-031', 110.00, 30, 15),
(32, 8, 'WC-LG9-032', 70.00, 60, 25),
(33, 8, 'MC-BLU-033', 100.00, 35, 15),
(34, 8, 'SD-ELG-034', 130.00, 20, 10),
(35, 9, 'NW-ASR-035', 250.00, 8, 10),
(36, 7, 'SP-TPL-036', 20.00, 250, 100),
(37, 13, 'PR-BRT-037', 120.00, 18, 10),
(38, 10, 'MN-MSI-038', 280.00, 12, 5),
(39, 12, 'SP-JBL-039', 60.00, 90, 40),
(40, 11, 'LP-LNV-040', 999.00, 15, 10);

-- -----------------------------------------------------------------
-- CRUD Operations Demo
-- -----------------------------------------------------------------

-- Update price & stock for a specific product
UPDATE Product
SET Price = 139.99, StockQuantity = 100
WHERE ProductID = 1;

-- Increase price by 5% for all products in 'Smart Home Devices' (CategoryID = 2)
UPDATE Product
SET Price = Price * 1.05
WHERE CategoryID = 2;

-- Delete a single product by ID (will also cascade delete the inventory item)
DELETE FROM Product
WHERE ProductID = 7;

-- Delete a category (ON DELETE CASCADE will remove associated products and inventory)
DELETE FROM Category
WHERE CategoryID = 4;

-- Update Inventory: Restock the 'Guardian Smart Doorbell' (ItemID 4)
UPDATE Inventory
SET StockQuantity = 25,
    LastRestocked = CURRENT_TIMESTAMP
WHERE ItemID = 4;

-- Delete an Inventory Item (e.g., a seller stops supplying a specific product)
DELETE FROM Inventory
WHERE ItemID = 5;

-- -----------------------------------------------------------------
-- Reports (Ensure Database is Selected to fix Error 1046)
-- -----------------------------------------------------------------

USE inventory_db;

-- REPORT 1: Complete Product Catalog with Category Names
SELECT
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    p.Price,
    p.StockQuantity,
    (p.Price * p.StockQuantity) AS TotalInventoryValue
FROM Product p
JOIN Category c ON p.CategoryID = c.CategoryID
ORDER BY c.CategoryName, p.ProductName;

-- REPORT 2: Category Summary Report
SELECT
    c.CategoryID,
    c.CategoryName,
    COUNT(p.ProductID) AS TotalProducts,
    ROUND(AVG(p.Price), 2) AS AveragePrice,
    SUM(p.StockQuantity) AS TotalStockCount,
    SUM(p.Price * p.StockQuantity) AS TotalCategoryValue
FROM Category c
LEFT JOIN Product p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY TotalCategoryValue DESC;

-- REPORT 3: Low-Stock Inventory Alert Report (Products < 25 units)
SELECT
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    p.StockQuantity
FROM Product p
JOIN Category c ON p.CategoryID = c.CategoryID
WHERE p.StockQuantity < 25
ORDER BY p.StockQuantity ASC;

-- REPORT 4: Seller Inventory & Restock Alert Report
-- Displays items where current stock has fallen below the seller's reorder level
SELECT
    i.ItemID,
    p.ProductName,
    s.StoreName,
    i.SKU,
    i.UnitPrice,
    i.StockQuantity,
    i.ReorderLevel,
    i.LastRestocked
FROM Inventory i
JOIN Seller s ON i.SellerID = s.SellerID
JOIN Product p ON i.ProductID = p.ProductID
WHERE i.StockQuantity <= i.ReorderLevel
ORDER BY i.StockQuantity ASC;