USE LibrarySystem;
GO

--== SELECT Queries ==--

-- GET /loans/overdue → List all overdue loans with member name, book title, and due date
SELECT m.Full_Name, b.Title, ll.Due_Date
FROM Loan_Link ll
JOIN Members m ON ll.M_ID = m.M_ID
JOIN Book b ON ll.B_ID = b.B_ID
WHERE ll.L_Status = 'Overdue';

-- GET /books/unavailable → List all books that are currently not available (loaned out)
SELECT Title, ISBN
FROM Book
WHERE IsAvailable = 0;

-- GET /members/top-borrowers → Show members who borrowed more than 2 books
SELECT m.Full_Name, COUNT(*) AS TotalLoans
FROM Loan_Link ll
JOIN Members m ON ll.M_ID = m.M_ID
GROUP BY m.Full_Name
HAVING COUNT(*) > 2;

-- GET /books/:id/ratings → Show average rating of a specific book
DECLARE @BookID INT = 1; -- Replace with desired BookID
SELECT b.Title, AVG(r.Rating) AS AverageRating
FROM Review_Link r
JOIN Book b ON r.B_ID = b.B_ID
WHERE b.B_ID = @BookID
GROUP BY b.Title;

-- GET /libraries/:id/genres → Count books by genre for a specific library
DECLARE @LibraryID INT = 1; -- Replace with desired LibraryID
SELECT Genre, COUNT(*) AS GenreCount
FROM Book
WHERE L_ID = @LibraryID
GROUP BY Genre;

-- GET /members/inactive → List members who have never borrowed any book
SELECT m.Full_Name
FROM Members m
LEFT JOIN Loan_Link ll ON m.M_ID = ll.M_ID
WHERE ll.M_ID IS NULL;

-- GET /payments/summary → Total fine paid by each member
SELECT m.Full_Name, SUM(p.Amount) AS TotalPaid
FROM Payments p
JOIN Members m ON p.M_ID = m.M_ID
GROUP BY m.Full_Name;

-- GET /reviews → Show all reviews with member and book info
SELECT m.Full_Name, b.Title, r.Comments, r.Rating
FROM Review_Link r
JOIN Members m ON r.M_ID = m.M_ID
JOIN Book b ON r.B_ID = b.B_ID;

-- GET /books/popular → Show top 3 books based on number of times loaned
SELECT TOP 3 b.Title, COUNT(*) AS LoanCount
FROM Loan_Link ll
JOIN Book b ON ll.B_ID = b.B_ID
GROUP BY b.Title
ORDER BY LoanCount DESC;

-- GET /members/:id/history → Retrieve full loan history of a member
DECLARE @MemberID INT = 1; -- You can Choose the ID member from here
SELECT b.Title, ll.Loan_Date, ll.Return_Date
FROM Loan_Link ll
JOIN Book b ON ll.B_ID = b.B_ID
WHERE ll.M_ID = @MemberID;

-- GET /books/:id/reviews → Show all reviews for a book with member names and comments
SELECT m.Full_Name, r.Comments, r.Rating
FROM Review_Link r
JOIN Members m ON r.M_ID = m.M_ID
WHERE r.B_ID = 2;

-- GET /libraries/:id/staff → List all staff working at a specific library
SELECT Full_Name, Position
FROM Staff
WHERE L_ID = 3;

-- GET /books/price-range?min=5&max=15 → Show books priced between 5 and 15
SELECT Title, Price
FROM Book
WHERE Price BETWEEN 5 AND 15; -- I dont have books on this prices you can change the price

-- GET /loans/active → List all active loans (not yet returned) with member and book info
SELECT m.Full_Name, b.Title, ll.Loan_Date, ll.Due_Date
FROM Loan_Link ll
JOIN Members m ON ll.M_ID = m.M_ID
JOIN Book b ON ll.B_ID = b.B_ID
WHERE ll.Return_Date IS NULL;

-- GET /members/with-fines → Show members who have paid any fine
SELECT DISTINCT m.Full_Name
FROM Payments p
JOIN Members m ON p.M_ID = m.M_ID;

-- GET /books/never-reviewed → List books that have never been reviewed
SELECT b.Title
FROM Book b
LEFT JOIN Review_Link r ON b.B_ID = r.B_ID
WHERE r.B_ID IS NULL;

-- GET /members/:id/loan-history → Show a member's loan history with titles and loan status
SELECT b.Title, ll.Loan_Date, ll.L_Status
FROM Loan_Link ll
JOIN Book b ON ll.B_ID = b.B_ID
WHERE ll.M_ID = 5;

-- GET /members/inactive → List all members who have never borrowed any book
SELECT m.Full_Name
FROM Members m
LEFT JOIN Loan_Link ll ON m.M_ID = ll.M_ID
WHERE ll.M_ID IS NULL;


-- GET /books/never-loaned → List books that have never been loaned
SELECT b.Title
FROM Book b
LEFT JOIN Loan_Link ll ON b.B_ID = ll.B_ID
WHERE ll.B_ID IS NULL;

-- GET /payments → List all payments with member name and book title
SELECT m.Full_Name, b.Title, p.Amount, p.Pay_Date
FROM Payments p
JOIN Members m ON p.M_ID = m.M_ID
JOIN Book b ON p.B_ID = b.B_ID;

-- GET /loans/overdue → List all overdue loans with member and book details
SELECT m.Full_Name, b.Title, ll.Due_Date
FROM Loan_Link ll
JOIN Members m ON ll.M_ID = m.M_ID
JOIN Book b ON ll.B_ID = b.B_ID
WHERE ll.L_Status = 'Overdue';

-- GET /books/:id/loan-count → Show how many times a specific book was loaned
SELECT b.Title, COUNT(*) AS LoanCount
FROM Loan_Link ll
JOIN Book b ON ll.B_ID = b.B_ID
WHERE b.B_ID = 7
GROUP BY b.Title;

-- GET /members/:id/fines → Get total fines paid by a specific member
SELECT m.Full_Name, SUM(p.Amount) AS TotalFines
FROM Payments p
JOIN Members m ON p.M_ID = m.M_ID
WHERE p.M_ID = 4
GROUP BY m.Full_Name;

-- GET /libraries/:id/book-stats → Show count of available and unavailable books in a specific library
SELECT 
  SUM(CASE WHEN IsAvailable = 1 THEN 1 ELSE 0 END) AS AvailableBooks,
  SUM(CASE WHEN IsAvailable = 0 THEN 1 ELSE 0 END) AS UnavailableBooks
FROM Book
WHERE L_ID = 1;

-- GET /reviews/top-rated → Return books with more than 5 reviews and average rating > 4.5
SELECT b.Title, COUNT(*) AS ReviewCount, AVG(r.Rating) AS AvgRating
FROM Review_Link r
JOIN Book b ON r.B_ID = b.B_ID
GROUP BY b.Title
HAVING COUNT(*) > 0 AND AVG(r.Rating) > 4.5; -- I put 0 to show the output due to i dont have more than 5 reviews
