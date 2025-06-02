USE LibrarySystem;
GO

--=== Transaction ===--

-- ========================
-- DECLARE VARIABLES
-- ========================
DECLARE @BookID INT = 2;
DECLARE @MemberID INT = 1;
DECLARE @Amount DECIMAL(10,2) = 8.50;
DECLARE @Details VARCHAR(255) = 'Late fee for Book 2';
DECLARE @LoanDate DATE = '2024-05-01'; 
DECLARE @MethodID INT = 1;

-- ========================
-- 1. BORROWING A BOOK
-- ========================
DECLARE @BookID INT = 2;
DECLARE @MemberID INT = 3;
BEGIN TRANSACTION;
BEGIN TRY
INSERT INTO Loan_Link (B_ID, M_ID, Loan_Date, Due_Date, Return_Date, L_Status)
VALUES (@BookID, @MemberID, GETDATE(), DATEADD(DAY, 14, GETDATE()), NULL, 'Issued');
UPDATE Book
SET IsAvailable = 0
WHERE B_ID = @BookID;
COMMIT;
PRINT 'Book borrowed successfully.';
END TRY
BEGIN CATCH
ROLLBACK;
PRINT 'Failed to borrow book.';
END CATCH;

-- When we try to on the M_id = 1, B_ID = 2 it show the result Failed to borrow book. 
-- But when we try on M_ID = 3, B_ID = 2 it show result Book borrowed successfully.

-- ========================
-- 2. RETURNING A BOOK
-- ========================
DECLARE @BookID INT = 5;
DECLARE @MemberID INT = 3;
BEGIN TRANSACTION;
BEGIN TRY
-- Update return date and status in Loan_Link
UPDATE Loan_Link
SET Return_Date = GETDATE(), L_Status = 'Returned'
WHERE B_ID = @BookID AND M_ID = @MemberID AND Return_Date IS NULL;
 -- Set the book as available again
UPDATE Book
SET IsAvailable = 1
WHERE B_ID = @BookID;
COMMIT;
PRINT 'Book returned successfully.';
END TRY
BEGIN CATCH
ROLLBACK;
PRINT 'Failed to return book.';
END CATCH;

-- ========================
-- 3. REGISTERING A PAYMENT
-- ========================
-- This Code below it show result Payment registered successfully. due to we have IDs for book and member and loan date.
DECLARE @BookID INT = 2;
DECLARE @MemberID INT = 3;
DECLARE @Amount DECIMAL(10,2) = 8.50;
DECLARE @Details VARCHAR(255) = 'Late fee for Book 2';
DECLARE @LoanDate DATE = CAST('2025-06-02' AS DATE); 
DECLARE @MethodID INT = 1;
BEGIN TRANSACTION;
BEGIN TRY
IF @Amount <= 0
BEGIN
RAISERROR('Amount must be positive.', 16, 1);
END
INSERT INTO Payments (Pay_Date, Amount, Transaction_Details, B_ID, M_ID, Loan_Date, Method_ID)
VALUES (GETDATE(), @Amount, @Details, @BookID, @MemberID, @LoanDate, @MethodID);
COMMIT;
PRINT 'Payment registered successfully.';
END TRY
BEGIN CATCH
ROLLBACK;
PRINT 'Failed to register payment.';
END CATCH;


SELECT * FROM Loan_Link
WHERE B_ID = 2 AND M_ID = 3;

-- This Code below it show result Failed to register payment. due to we Dont have IDs for book and member and loan date.
DECLARE @BookID INT = 2;
DECLARE @MemberID INT = 1;
DECLARE @Amount DECIMAL(10,2) = 8.50;
DECLARE @Details VARCHAR(255) = 'Late fee for Book 2';
DECLARE @LoanDate DATE = CAST('2024-05-01' AS DATE); 
DECLARE @MethodID INT = 1;
BEGIN TRANSACTION;
BEGIN TRY
IF @Amount <= 0
BEGIN
RAISERROR('Amount must be positive.', 16, 1);
END
INSERT INTO Payments (Pay_Date, Amount, Transaction_Details, B_ID, M_ID, Loan_Date, Method_ID)
VALUES (GETDATE(), @Amount, @Details, @BookID, @MemberID, @LoanDate, @MethodID);
COMMIT;
PRINT 'Payment registered successfully.';
END TRY
BEGIN CATCH
ROLLBACK;
PRINT 'Failed to register payment.';
END CATCH;


-- ========================
-- 4. BATCH LOAN INSERT
-- ========================
-- I try For Memeber ID 2 and it show Batch loans issued successfully. But when i try to ID 1 it show Batch loan insert failed.
DECLARE @MemberID INT = 1;
BEGIN TRANSACTION;
BEGIN TRY
-- This assumes books 7 and 8 are available
INSERT INTO Loan_Link (B_ID, M_ID, Loan_Date, Due_Date, Return_Date, L_Status)
VALUES 
(7, @MemberID, GETDATE(), DATEADD(DAY, 14, GETDATE()), NULL, 'Issued'),
(8, @MemberID, GETDATE(), DATEADD(DAY, 14, GETDATE()), NULL, 'Issued');
UPDATE Book SET IsAvailable = 0 WHERE B_ID IN (7, 8);
COMMIT;
PRINT 'Batch loans issued successfully.';
END TRY
BEGIN CATCH
ROLLBACK;
PRINT 'Batch loan insert failed.';
END CATCH;

-- ========================
-- CHECKING RESULTS
-- ========================
DECLARE @BookID INT = 2;
DECLARE @MemberID INT = 2;
SELECT * FROM Loan_Link WHERE M_ID = @MemberID;
SELECT * FROM Book WHERE B_ID IN (@BookID, 7, 8);
SELECT * FROM Payments WHERE M_ID = @MemberID;
