USE LibrarySystem;
GO

--== INDEXES ==--


-- ========== LIBRARYS TABLE ==========

-- search by library name
CREATE NONCLUSTERED INDEX idx_Librarys_L_Name
ON Librarys (L_Name);

-- filter by location
CREATE NONCLUSTERED INDEX idx_Librarys_L_Location
ON Librarys (L_Location);

EXEC sp_helpindex 'Librarys';

-- ========== BOOK TABLE ==========

-- search by Library ID and ISBN (clustered for uniqueness and frequent use)

CREATE CLUSTERED INDEX idx_Book_LID_ISBN -- This show error that i Cannot create more than one clustered index on table 'Book'
ON Book (L_ID, ISBN);

CREATE NONCLUSTERED INDEX idx_Book_LID_ISBN
ON Book (L_ID, ISBN);


-- genre filtering
CREATE NONCLUSTERED INDEX idx_Book_Genre
ON Book (Genre);

-- availability checks
CREATE NONCLUSTERED INDEX idx_Book_IsAvailable
ON Book (IsAvailable);

EXEC sp_helpindex 'Book';

-- ========== LOAN_LINK TABLE ==========

-- lookups by Member ID (for history and activity)
CREATE NONCLUSTERED INDEX idx_LoanLink_MemberID
ON Loan_Link (M_ID);

-- filtering by loan status (Issued, Returned, Overdue)
CREATE NONCLUSTERED INDEX idx_LoanLink_Status
ON Loan_Link (L_Status);

-- overdue checks and return queries
CREATE NONCLUSTERED INDEX idx_LoanLink_BookLoanReturn
ON Loan_Link (B_ID, Loan_Date, Return_Date);

EXEC sp_helpindex 'Loan_Link';

-------==== TESTING THE INDEX ====-------------

-- Use idx_Librarys_L_Name
SELECT * 
FROM Librarys WITH (INDEX(idx_Librarys_L_Name))
WHERE L_Name = 'Muscat Library';

-- Use idx_Librarys_L_Location
SELECT * 
FROM Librarys WITH (INDEX(idx_Librarys_L_Location))
WHERE L_Location = 'Nizwa';

-- Use idx_Book_LID_ISBN
SELECT * 
FROM Book WITH (INDEX(idx_Book_LID_ISBN))
WHERE L_ID = 2 AND ISBN = '968-0006';

-- Use idx_Book_Genre
SELECT Title, Genre 
FROM Book WITH (INDEX(idx_Book_Genre))
WHERE Genre = 'Fiction';

-- Use idx_Book_IsAvailable
SELECT Title 
FROM Book WITH (INDEX(idx_Book_IsAvailable))
WHERE IsAvailable = 1;

-- Use idx_LoanLink_MemberID
SELECT * 
FROM Loan_Link WITH (INDEX(idx_LoanLink_MemberID))
WHERE M_ID = 1;

-- Use idx_LoanLink_Status
SELECT * 
FROM Loan_Link WITH (INDEX(idx_LoanLink_Status))
WHERE L_Status = 'Overdue';

-- Use idx_LoanLink_BookLoanReturn
SELECT * 
FROM Loan_Link WITH (INDEX(idx_LoanLink_BookLoanReturn))
WHERE B_ID = 3 AND Loan_Date = '2024-03-01' AND Return_Date IS NULL;

