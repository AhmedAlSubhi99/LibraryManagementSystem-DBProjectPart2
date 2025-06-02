USE LibrarySystem;
GO
--=== Aggregation Functions ===--


-- 1. Total fines per member
SELECT 
    m.M_ID,
    m.Full_Name,
    SUM(p.Amount) AS TotalFines
FROM Members m
JOIN Payments p ON m.M_ID = p.M_ID
GROUP BY m.M_ID, m.Full_Name;


-- 2. Most active libraries (by loan count)
SELECT 
    l.L_ID,
    l.L_Name,
    COUNT(*) AS TotalLoans
FROM Librarys l
JOIN Book b ON l.L_ID = b.L_ID
JOIN Loan_Link ll ON b.B_ID = ll.B_ID
GROUP BY l.L_ID, l.L_Name
ORDER BY TotalLoans DESC;


-- 3. Average book price per genre
SELECT 
    Genre,
    AVG(Price) AS AvgPrice
FROM Book
GROUP BY Genre;


-- 4. Top 3 most reviewed books
SELECT TOP 3 
    b.B_ID,
    b.Title,
    COUNT(*) AS ReviewCount
FROM Book b
JOIN Review_Link r ON b.B_ID = r.B_ID
GROUP BY b.B_ID, b.Title
ORDER BY ReviewCount DESC;


-- 5. Library revenue report
SELECT 
    l.L_ID,
    l.L_Name,
    SUM(p.Amount) AS TotalRevenue
FROM Librarys l
JOIN Book b ON l.L_ID = b.L_ID
JOIN Payments p ON b.B_ID = p.B_ID
GROUP BY l.L_ID, l.L_Name;


-- 6. Member activity summary (loans + fines)
SELECT 
    m.M_ID,
    m.Full_Name,
    COUNT(DISTINCT ll.B_ID) AS TotalLoans,
    ISNULL(SUM(p.Amount), 0) AS TotalFines
FROM Members m
LEFT JOIN Loan_Link ll ON m.M_ID = ll.M_ID
LEFT JOIN Payments p ON m.M_ID = p.M_ID
GROUP BY m.M_ID, m.Full_Name;
