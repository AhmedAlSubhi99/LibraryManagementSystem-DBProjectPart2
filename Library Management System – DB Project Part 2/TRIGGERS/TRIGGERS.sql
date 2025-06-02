USE LibrarySystem;
GO

--=== Triggers ===--


-- 1. trg_AutoSetUnavailableOnLoan
-- Marks a book as unavailable automatically after a loan is inserted
CREATE TRIGGER trg_AutoSetUnavailableOnLoan
ON Loan_Link
AFTER INSERT
AS
BEGIN
    UPDATE Book
    SET IsAvailable = 0
    WHERE B_ID IN (SELECT B_ID FROM inserted);
END;
GO

-- 2. trg_AutoSetAvailableOnReturn
-- Marks a book as available automatically when it is returned
CREATE TRIGGER trg_AutoSetAvailableOnReturn
ON Loan_Link
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE Return_Date IS NOT NULL)
    BEGIN
        UPDATE Book
        SET IsAvailable = 1
        WHERE B_ID IN (
            SELECT i.B_ID
            FROM inserted i
            LEFT JOIN deleted d 
              ON i.B_ID = d.B_ID AND i.M_ID = d.M_ID AND i.Loan_Date = d.Loan_Date
            WHERE i.Return_Date IS NOT NULL AND (d.Return_Date IS NULL OR d.Return_Date <> i.Return_Date)
        );
    END
END;
GO

-- 3. trg_PreventDeleteIfOutstandingLoans
-- Prevents deleting a member who has unreturned books
CREATE TRIGGER trg_PreventDeleteIfOutstandingLoans
ON Members
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM deleted d
        JOIN Loan_Link l ON l.M_ID = d.M_ID
        WHERE l.Return_Date IS NULL
    )
    BEGIN
        RAISERROR('Cannot delete member with active loans.', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        DELETE FROM Members
        WHERE M_ID IN (SELECT M_ID FROM deleted);
    END
END;
GO


--=== Testing Triggers ===--


-- trg_AutoSetUnavailableOnLoan
-- Check availability before loan
SELECT B_ID, Title, IsAvailable FROM Book WHERE B_ID = 1;

-- Insert a new loan (should trigger auto-unavailable)
INSERT INTO Loan_Link (B_ID, M_ID, Loan_Date, Due_Date, L_Status)
VALUES (1, 1, GETDATE(), DATEADD(DAY, 14, GETDATE()), 'Issued');

-- Check if book became unavailable
SELECT B_ID, Title, IsAvailable FROM Book WHERE B_ID = 1;



-- trg_AutoSetAvailableOnReturn
-- Update Return_Date (should trigger auto-available)
UPDATE Loan_Link
SET Return_Date = GETDATE()
WHERE B_ID = 1 AND M_ID = 1;

-- Confirm the book is now marked available
SELECT B_ID, Title, IsAvailable FROM Book WHERE B_ID = 1;

-- trg_PreventDeleteIfOutstandingLoans
-- Insert another loan without return date
INSERT INTO Loan_Link (B_ID, M_ID, Loan_Date, Due_Date, L_Status)
VALUES (2, 1, GETDATE(), DATEADD(DAY, 10, GETDATE()), 'Issued');

-- Try to delete member with active loan (should fail)
DELETE FROM Members WHERE M_ID = 1;

-- Confirm member still exists
SELECT * FROM Members WHERE M_ID = 1;

-- Cleanup : Return book to allow deletion
UPDATE Loan_Link
SET Return_Date = GETDATE()
WHERE B_ID = 2 AND M_ID = 1;

-- Return all loans (mark Return_Date)
UPDATE Loan_Link
SET Return_Date = GETDATE()
WHERE M_ID = 1 AND Return_Date IS NULL;

-- Now retry delete
DELETE FROM Members WHERE M_ID = 1;

-- Confirm deletion
SELECT * FROM Members WHERE M_ID = 1;

