USE LibrarySystem;
GO

--== Functions ==--

-- 1. GetBookAverageRating(BookID) → Returns the average rating of a given book
CREATE FUNCTION GetBookAverageRating (@BookID INT)
RETURNS FLOAT
AS
BEGIN
DECLARE @Average FLOAT;
SELECT @Average = AVG(CAST(Rating AS FLOAT))
FROM Review_Link
WHERE B_ID = @BookID;
RETURN @Average;
END;
GO

-- 2. GetNextAvailableBook(Genre, Title, LibraryID) → Returns the ID of the next available copy of a book
CREATE FUNCTION GetNextAvailableBook 
(
    @Genre VARCHAR(50),
    @Title VARCHAR(200),
    @LibraryID INT
)
RETURNS INT
AS
BEGIN
DECLARE @BookID INT;
SELECT TOP 1 @BookID = B_ID FROM Book
WHERE Title = @Title AND Genre = @Genre AND L_ID = @LibraryID AND IsAvailable = 1
ORDER BY B_ID;
RETURN @BookID;
END;
GO

-- 3. CalculateLibraryOccupancyRate(LibraryID) → Returns the percentage of books currently issued in a library
CREATE FUNCTION CalculateLibraryOccupancyRate (@LibraryID INT)
RETURNS FLOAT
AS
BEGIN
DECLARE @Total INT, @Unavailable INT;
SELECT @Total = COUNT(*) FROM Book WHERE L_ID = @LibraryID;
SELECT @Unavailable = COUNT(*) FROM Book WHERE L_ID = @LibraryID AND IsAvailable = 0;
RETURN CASE WHEN @Total = 0 THEN 0 ELSE CAST(@Unavailable AS FLOAT) / @Total * 100 END;
END;
GO

-- 4. fn_GetMemberLoanCount → Returns total number of loans made by a given member
CREATE FUNCTION fn_GetMemberLoanCount (@MemberID INT)
RETURNS INT
AS
BEGIN
DECLARE @Count INT;
SELECT @Count = COUNT(*) FROM Loan_Link WHERE M_ID = @MemberID;
RETURN @Count;
END;
GO

-- 5. fn_GetLateReturnDays → Returns number of late days for a given loan
CREATE FUNCTION fn_GetLateReturnDays
(
    @B_ID INT,
    @M_ID INT,
    @LoanDate DATE
)
RETURNS INT
AS
BEGIN
DECLARE @Due DATE, @Returned DATE;
SELECT @Due = Due_Date, @Returned = Return_Date FROM Loan_Link
WHERE B_ID = @B_ID AND M_ID = @M_ID AND Loan_Date = @LoanDate;
IF @Returned IS NULL OR @Returned <= @Due
RETURN 0;
RETURN DATEDIFF(DAY, @Due, @Returned);
END;
GO

-- 6. fn_ListAvailableBooksByLibrary → Returns all available books in a given library
CREATE FUNCTION fn_ListAvailableBooksByLibrary (@LibraryID INT)
RETURNS TABLE
AS
RETURN
(
SELECT B_ID, Title, Genre, Price, Shelf_Location FROM Book
WHERE L_ID = @LibraryID AND IsAvailable = 1
);
GO

-- 7. fn_GetTopRatedBooks → Returns books with average rating >= 4.5
CREATE FUNCTION fn_GetTopRatedBooks()
RETURNS TABLE
AS
RETURN
(
SELECT b.B_ID, b.Title, AVG(CAST(r.Rating AS FLOAT)) AS AvgRating FROM Book b
JOIN Review_Link r ON b.B_ID = r.B_ID
GROUP BY b.B_ID, b.Title
HAVING AVG(CAST(r.Rating AS FLOAT)) >= 4.5
);
GO

-- 8. fn_FormatMemberName → Returns full name formatted as "LastName, FirstName"
CREATE FUNCTION fn_FormatMemberName (@FullName VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN
DECLARE @FirstName VARCHAR(50), @LastName VARCHAR(50);
SET @FirstName = LEFT(@FullName, CHARINDEX(' ', @FullName) - 1);
SET @LastName = SUBSTRING(@FullName, CHARINDEX(' ', @FullName) + 1, LEN(@FullName));
RETURN @FirstName + ' ' + @LastName;
END;
GO

-- ========================================
--  Test and Display Functions
-- ========================================

-- 1. GetBookAverageRating
SELECT dbo.GetBookAverageRating(2) AS AverageRating;

-- 2. GetNextAvailableBook
SELECT dbo.GetNextAvailableBook('Fiction', 'Magic Tales', 3) AS NextAvailableBookID;

-- 3. CalculateLibraryOccupancyRate
SELECT dbo.CalculateLibraryOccupancyRate(1) AS OccupancyRatePercent;

-- 4. fn_GetMemberLoanCount
SELECT dbo.fn_GetMemberLoanCount(1) AS LoanCount;

-- 5. fn_GetLateReturnDays
SELECT dbo.fn_GetLateReturnDays(3, 2, '2024-03-01') AS LateDays;

-- 6. fn_ListAvailableBooksByLibrary
SELECT * FROM dbo.fn_ListAvailableBooksByLibrary(1);

-- 7. fn_GetTopRatedBooks
SELECT * FROM dbo.fn_GetTopRatedBooks();

-- 8. fn_FormatMemberName
SELECT dbo.fn_FormatMemberName('Ali Hassan') AS FullName;


-- Where would such functions be used in a frontend (e.g., member profile, book search, admin analytics)? 

-- 1. GetBookAverageRating(@BookID)
-- Use in: Book Details Page

-- 2. GetNextAvailableBook(@Genre, @Title, @LibraryID)
-- Use in: Book Search / Reservation System

-- 3. CalculateLibraryOccupancyRate(@LibraryID)
-- Use in: Admin Dashboard / Analytics Panel

-- 4. fn_GetMemberLoanCount(@MemberID)
-- Use in: Member Profile / My Account Page

-- 5. fn_GetLateReturnDays(@B_ID, @M_ID, @LoanDate)
-- Use in: Loan History / Fine Calculation View

-- 6. fn_ListAvailableBooksByLibrary(@LibraryID)
-- Use in: Book Browser / Library Page

-- 7. fn_GetTopRatedBooks()
-- Use in: Home Page / Recommendations Section

-- 8. fn_FormatMemberName(@FullName)
-- Use in: Admin Panels / Print Reports / Search Results


