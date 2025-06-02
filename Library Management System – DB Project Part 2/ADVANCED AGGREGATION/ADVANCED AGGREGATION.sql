USE LibrarySystem;
Go

--=== Advanced Aggregations ===--

-- 1. HAVING for filtering aggregates
-- Show genres that have more than 5 books
SELECT 
    Genre,
    COUNT(*) AS BookCount
FROM Book
GROUP BY Genre
HAVING COUNT(*) > 2; -- not have more than 5

-- 2. Subqueries for complex logic
-- Find the book with the maximum price in each genre
SELECT 
    b.Genre,
    b.Title,
    b.Price
FROM Book b
WHERE b.Price = 
(
    SELECT MAX(Price)
    FROM Book b2
    WHERE b2.Genre = b.Genre
);

-- 3. Occupancy rate calculations (issued books / total books per library)
SELECT 
    l.L_ID,
    l.L_Name,
    COUNT(CASE WHEN b.IsAvailable = 0 THEN 1 END) * 100.0 / COUNT(*) AS OccupancyRatePercent
FROM Librarys l
JOIN Book b ON l.L_ID = b.L_ID
GROUP BY l.L_ID, l.L_Name;

-- 4. Members with loans but no fines
SELECT DISTINCT m.M_ID, m.Full_Name
FROM Members m
JOIN Loan_Link ll ON m.M_ID = ll.M_ID
WHERE m.M_ID NOT IN 
(
    SELECT DISTINCT M_ID FROM Payments
);

-- 5. Genres with high average ratings (e.g., AVG > 4.0)
SELECT 
    b.Genre,
    AVG(CAST(r.Rating AS FLOAT)) AS AvgRating
FROM Book b
JOIN Review_Link r ON b.B_ID = r.B_ID
GROUP BY b.Genre
HAVING AVG(CAST(r.Rating AS FLOAT)) > 4.0;
