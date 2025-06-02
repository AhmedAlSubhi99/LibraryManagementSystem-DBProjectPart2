USE LibrarySystem;
GO

--== VIEWS ==--


-- 1. ViewPopularBooks → Books with average rating > 4.5 and total number of times loaned
CREATE VIEW ViewPopularBooks AS
SELECT 
    b.B_ID,
    b.Title,
    COUNT(DISTINCT ll.M_ID) AS TotalLoans,
    AVG(CAST(r.Rating AS FLOAT)) AS AverageRating
FROM Book b
LEFT JOIN Loan_Link ll ON b.B_ID = ll.B_ID
LEFT JOIN Review_Link r ON b.B_ID = r.B_ID
GROUP BY b.B_ID, b.Title
HAVING COUNT(r.Rating) > 0 AND AVG(CAST(r.Rating AS FLOAT)) > 4.5;

SELECT * FROM ViewPopularBooks;

-- 2. ViewMemberLoanSummary → Shows each member's total loan count and total fines paid
CREATE VIEW ViewMemberLoanSummary AS
SELECT 
    m.M_ID,
    m.Full_Name,
    COUNT(DISTINCT ll.B_ID) AS TotalLoans,
    ISNULL(SUM(p.Amount), 0) AS TotalFines
FROM Members m
LEFT JOIN Loan_Link ll ON m.M_ID = ll.M_ID
LEFT JOIN Payments p ON m.M_ID = p.M_ID
GROUP BY m.M_ID, m.Full_Name;

SELECT * FROM ViewMemberLoanSummary;

-- 3. ViewAvailableBooks → List of available books grouped by genre, ordered by price
CREATE VIEW ViewAvailableBooks AS
SELECT 
    Genre,
    Title,
    Price,
    L_ID,
    Shelf_Location
FROM Book
WHERE IsAvailable = 1;

SELECT * FROM ViewAvailableBooks
ORDER BY Genre, Price;

-- 4. ViewLoanStatusSummary → Loan stats (issued, returned, overdue) per library
CREATE VIEW ViewLoanStatusSummary AS
SELECT 
    l.L_ID,
    l.L_Name,
    ll.L_Status,
    COUNT(*) AS StatusCount
FROM Librarys l
JOIN Book b ON l.L_ID = b.L_ID
JOIN Loan_Link ll ON b.B_ID = ll.B_ID
GROUP BY l.L_ID, l.L_Name, ll.L_Status;

SELECT * FROM ViewLoanStatusSummary;

-- 5. ViewPaymentOverview → Shows payment with member, book, and loan status
CREATE VIEW ViewPaymentOverview AS
SELECT 
    p.P_ID,
    m.Full_Name AS MemberName,
    b.Title AS BookTitle,
    p.Amount,
    p.Pay_Date,
    p.Transaction_Details,
    ll.L_Status
FROM Payments p
LEFT JOIN Members m ON p.M_ID = m.M_ID
LEFT JOIN Book b ON p.B_ID = b.B_ID
LEFT JOIN Loan_Link ll ON p.B_ID = ll.B_ID AND p.M_ID = ll.M_ID AND p.Loan_Date = ll.Loan_Date;

SELECT * FROM ViewPaymentOverview;
