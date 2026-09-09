-- Week 6 - Product Review and Rating Management System
-- Review module for ecommerce_db (goes with Databases.sql + sample_data.sql)

-- quick note: Databases.sql already has a Review table (ReviewID, ProductID,
-- CustomerID, Rating, Comment, ReviewDate) so I'm just reusing that instead of
-- making a new Review_ID/Review_Text version - didn't want two Review tables
-- fighting each other in the same db. so just mapping the assignment's names:
-- Review_ID = ReviewID, Customer_ID = CustomerID, Product_ID = ProductID,
-- Review_Text = Comment, Review_Date = ReviewDate

USE ecommerce_db;

-- 1) Review table
CREATE TABLE IF NOT EXISTS Review (
    ReviewID   INT AUTO_INCREMENT PRIMARY KEY,
    ProductID  INT NOT NULL,
    CustomerID INT NOT NULL,
    Rating     TINYINT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment    TEXT,
    ReviewDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_product
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_review_customer
        FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Customer (1) --- (Many) Review
-- Product  (1) --- (Many) Review
-- both relationships handled by the FKs above.
-- PK = ReviewID, FKs = CustomerID / ProductID, CHECK on Rating 1-5,
-- Rating + ReviewDate are NOT NULL.


-- 2) Adding / updating / removing reviews

-- Ananya (CustomerID 4) reviews the 4K Streaming Stick (ProductID 3)
INSERT INTO Review (ProductID, CustomerID, Rating, Comment)
VALUES (3, 4, 5, 'Streams smoothly, no buffering issues at all.');

-- Vikram (CustomerID 5) reviews the Microwave Oven (ProductID 8)
INSERT INTO Review (ProductID, CustomerID, Rating, Comment)
VALUES (8, 5, 3, 'Does the job but runs a bit noisy.');

-- customer wants to edit their comment
UPDATE Review
SET Comment = 'Battery life improved after the latest firmware update.'
WHERE ReviewID = 1;

-- deleting a review that's inappropriate/spam - swap in the real ReviewID
DELETE FROM Review WHERE ReviewID = 4;


-- 3) Retrieving review details

-- all reviews for one product
SELECT p.Name AS ProductName, r.Rating, r.Comment, r.ReviewDate
FROM Review r
JOIN Product p ON r.ProductID = p.ProductID
WHERE r.ProductID = 1
ORDER BY r.ReviewDate DESC;

-- customer name alongside their review
SELECT c.Name AS CustomerName, p.Name AS ProductName, r.Rating, r.Comment, r.ReviewDate
FROM Review r
JOIN Customer c ON r.CustomerID = c.CustomerID
JOIN Product p ON r.ProductID = p.ProductID
ORDER BY r.ReviewDate DESC;

-- products with the most reviews
SELECT p.Name AS ProductName, COUNT(r.ReviewID) AS TotalReviews
FROM Review r
JOIN Product p ON r.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY TotalReviews DESC
LIMIT 5;

-- most recent feedback
SELECT c.Name AS CustomerName, p.Name AS ProductName, r.Rating, r.Comment, r.ReviewDate
FROM Review r
JOIN Customer c ON r.CustomerID = c.CustomerID
JOIN Product p ON r.ProductID = p.ProductID
ORDER BY r.ReviewDate DESC
LIMIT 10;

-- reviews rated above 4
SELECT c.Name AS CustomerName, p.Name AS ProductName, r.Rating, r.Comment
FROM Review r
JOIN Customer c ON r.CustomerID = c.CustomerID
JOIN Product p ON r.ProductID = p.ProductID
WHERE r.Rating > 4
ORDER BY r.Rating DESC;


-- 4) Average ratings + counts

-- avg rating per product
SELECT r.ProductID, p.Name AS ProductName, ROUND(AVG(r.Rating), 2) AS AvgRating
FROM Review r
JOIN Product p ON r.ProductID = p.ProductID
GROUP BY r.ProductID, p.Name
ORDER BY AvgRating DESC;

-- how many reviews each product has
SELECT r.ProductID, p.Name AS ProductName, COUNT(*) AS TotalReviews
FROM Review r
JOIN Product p ON r.ProductID = p.ProductID
GROUP BY r.ProductID, p.Name
ORDER BY TotalReviews DESC;

-- top 5 highest rated products
SELECT p.Name AS ProductName, ROUND(AVG(r.Rating), 2) AS AvgRating, COUNT(r.ReviewID) AS TotalReviews
FROM Review r
JOIN Product p ON r.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY AvgRating DESC, TotalReviews DESC
LIMIT 5;

-- products averaging above 4 stars
SELECT p.Name AS ProductName, ROUND(AVG(r.Rating), 2) AS AvgRating
FROM Review r
JOIN Product p ON r.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
HAVING AVG(r.Rating) > 4
ORDER BY AvgRating DESC;


-- 5) Reports

-- Report 1 - Product Rating Analysis (name, # reviews, avg rating)
SELECT p.ProductID, p.Name AS ProductName,
       COUNT(r.ReviewID) AS NumberOfReviews,
       ROUND(AVG(r.Rating), 2) AS AverageRating
FROM Product p
LEFT JOIN Review r ON p.ProductID = r.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY AverageRating DESC, NumberOfReviews DESC;

-- Report 2 - Customer Feedback Analysis
-- most reviewed products
SELECT p.Name AS ProductName, COUNT(r.ReviewID) AS NumberOfReviews
FROM Product p
JOIN Review r ON p.ProductID = r.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY NumberOfReviews DESC
LIMIT 5;

-- highly rated products (4 stars and up)
SELECT p.Name AS ProductName, ROUND(AVG(r.Rating), 2) AS AvgRating
FROM Product p
JOIN Review r ON p.ProductID = r.ProductID
GROUP BY p.ProductID, p.Name
HAVING AVG(r.Rating) >= 4
ORDER BY AvgRating DESC;

-- products that need improvement (under 3 stars avg)
SELECT p.Name AS ProductName, ROUND(AVG(r.Rating), 2) AS AvgRating
FROM Product p
JOIN Review r ON p.ProductID = r.ProductID
GROUP BY p.ProductID, p.Name
HAVING AVG(r.Rating) < 3
ORDER BY AvgRating ASC;

-- Report 3 - Rating Distribution
SELECT
    SUM(CASE WHEN Rating = 5 THEN 1 ELSE 0 END) AS FiveStar,
    SUM(CASE WHEN Rating = 4 THEN 1 ELSE 0 END) AS FourStar,
    SUM(CASE WHEN Rating = 3 THEN 1 ELSE 0 END) AS ThreeStar,
    SUM(CASE WHEN Rating = 2 THEN 1 ELSE 0 END) AS TwoStar,
    SUM(CASE WHEN Rating = 1 THEN 1 ELSE 0 END) AS OneStar
FROM Review;

-- how many products count as "low rated" (avg under 3)
SELECT COUNT(*) AS LowRatedProducts
FROM (
    SELECT ProductID FROM Review
    GROUP BY ProductID
    HAVING AVG(Rating) < 3
) x;