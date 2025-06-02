USE LibrarySystem;
GO

--=== Triggers ===--

IF OBJECT_ID('LibraryRevenue', 'U') IS NULL -- i do this because i dont add table Library revenue before.
BEGIN
CREATE TABLE LibraryRevenue 
(
LibraryID INT PRIMARY KEY,
TotalRevenue DECIMAL(12,2) DEFAULT 0,
FOREIGN KEY (LibraryID) REFERENCES Librarys(L_ID)
);
INSERT INTO LibraryRevenue (LibraryID, TotalRevenue)
SELECT L_ID, 0 FROM Librarys;
END;
GO

-- Set Book to Unavailable After New Loan
CREATE TRIGGER trg_UpdateBookAvailability
ON Loan_Link
AFTER INSERT
AS
BEGIN
UPDATE b
SET b.IsAvailable = 0
FROM Book b
JOIN inserted i ON b.B_ID = i.B_ID;
END;
GO

-- Update Library Revenue After Payment
CREATE TRIGGER trg_CalculateLibraryRevenue
ON Payments
AFTER INSERT
AS
BEGIN
UPDATE lr
SET lr.TotalRevenue = lr.TotalRevenue + i.Amount
FROM LibraryRevenue lr
JOIN inserted i ON i.B_ID = i.B_ID
JOIN Book b ON i.B_ID = b.B_ID
WHERE lr.LibraryID = b.L_ID;
END;
GO

-- Validate Return Date on Insert
CREATE TRIGGER trg_LoanDateValidation
ON Loan_Link
INSTEAD OF INSERT
AS
BEGIN
IF EXISTS 
(
  SELECT 1 FROM inserted
  WHERE Return_Date IS NOT NULL AND Return_Date < Loan_Date
)
BEGIN
RAISERROR('Return date cannot be earlier than loan date.', 16, 1);
ROLLBACK;
END
ELSE
BEGIN
INSERT INTO Loan_Link (B_ID, M_ID, Loan_Date, Due_Date, Return_Date, L_Status)
SELECT B_ID, M_ID, Loan_Date, Due_Date, Return_Date, L_Status FROM inserted;
END
END;
GO

-- ========================
--  Trigger Testing 
-- ========================

-- Test 1: New Loan -> Book becomes unavailable
INSERT INTO Loan_Link (B_ID, M_ID, Loan_Date, Due_Date, Return_Date, L_Status)
VALUES (1, 2, GETDATE(), DATEADD(DAY, 14, GETDATE()), NULL, 'Issued');

SELECT Title, IsAvailable FROM Book WHERE B_ID = 1;

-- Test 2: Payment updates revenue
INSERT INTO Payments (Pay_Date, Amount, Method_ID, Transaction_Details, B_ID, M_ID, Loan_Date)
VALUES (GETDATE(), 9.50, 1, 'Late fee test', 1, 2, GETDATE());

SELECT * FROM LibraryRevenue WHERE LibraryID = (SELECT L_ID FROM Book WHERE B_ID = 1);

-- Test 3: Insert invalid return date (should fail)
BEGIN TRY
INSERT INTO Loan_Link (B_ID, M_ID, Loan_Date, Due_Date, Return_Date, L_Status)
VALUES (2, 2, '2024-06-10', '2024-06-20', '2024-06-01', 'Returned');
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE(); -- Return date cannot be earlier than loan date.
END CATCH;

