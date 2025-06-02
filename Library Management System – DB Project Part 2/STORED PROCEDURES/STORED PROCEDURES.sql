USE LibrarySystem;
GO

--=== Stored Procedures ===--

-- 1. sp_MarkBookUnavailable
-- Purpose: Updates availability after issuing 
CREATE PROCEDURE sp_MarkBookUnavailable
@BookID INT
AS
BEGIN
    UPDATE Book
    SET IsAvailable = 0
    WHERE B_ID = @BookID;
END;
GO

-- 2. sp_UpdateLoanStatus
-- Purpose: Checks dates and updates loan statuses

CREATE PROCEDURE sp_UpdateLoanStatus
AS
BEGIN
    -- Mark overdue
    UPDATE Loan_Link
    SET L_Status = 'Overdue'
    WHERE Return_Date IS NULL AND Due_Date < CAST(GETDATE() AS DATE);

    -- Mark returned
    UPDATE Loan_Link
    SET L_Status = 'Returned'
    WHERE Return_Date IS NOT NULL;

    -- Mark issued (still within due date and not returned)
    UPDATE Loan_Link
    SET L_Status = 'Issued'
    WHERE Return_Date IS NULL AND Due_Date >= CAST(GETDATE() AS DATE);
END;
GO

-- 3. sp_RankMembersByFines
-- Purpose: Return members ranked by total fines paid
CREATE PROCEDURE sp_RankMembersByFines
AS
BEGIN
    SELECT 
        m.M_ID,
        m.Full_Name,
        SUM(p.Amount) AS TotalFines
    FROM Members m
    JOIN Payments p ON m.M_ID = p.M_ID
    GROUP BY m.M_ID, m.Full_Name
    ORDER BY TotalFines DESC;
END;
GO


-- Testing Stored Procedures 


-- 1. Test sp_MarkBookUnavailable
-- Before update: Check availability status
SELECT B_ID, Title, IsAvailable
FROM Book
WHERE B_ID = 3;

-- Call the procedure to mark book as unavailable
EXEC sp_MarkBookUnavailable @BookID = 3;

-- After update: Confirm status changed
SELECT B_ID, Title, IsAvailable
FROM Book
WHERE B_ID = 3;

-- 2. Test sp_UpdateLoanStatus
SELECT B_ID, M_ID, Loan_Date, Due_Date, Return_Date, L_Status
FROM Loan_Link;

-- Call the procedure to update statuses based on dates
EXEC sp_UpdateLoanStatus;

-- After update: Confirm statuses updated
SELECT B_ID, M_ID, Loan_Date, Due_Date, Return_Date, L_Status
FROM Loan_Link;

-- 3. Test sp_RankMembersByFines
-- Call the procedure to get ranked list of members by fines paid
EXEC sp_RankMembersByFines;
