USE DataManagementAnalytics;
GO

/*============================================================================================================================================
  Book Return Processing and Status Synchronization
==============================================================================================================================================
Script Purpose:
    - To implement and validate: Update Book Status on Return.
    - To ensure schema columns exist and are synchronized (is_returned, returned_date, book_quality).
    - To provide a hardened stored procedure (add_return_records) that:
        • inserts return records (with book_quality)
        • updates books.status to 'yes' when returned
        • marks issued_status rows as returned (is_returned, returned_date)
    - To ensure there are active issued rows (IS201, IS202) so the "active issued rows" query returns results.
    - To provide maintenance queries that keep books.status in sync with issued/return state.

SQL Concepts Used:
    - DDL: ALTER TABLE, CREATE PROCEDURE
    - DML: INSERT, UPDATE, SELECT
    - Date functions: GETDATE(), DATEADD()
    - Conditional logic: IF NOT EXISTS, ISNULL()
    - Idempotent design so script can be safely re-run
============================================================================================================================================*/


/*============================================================================================================================================
  Task 14: Update Book Status on Return
  Objective:
    - Provide a robust procedure to record book returns and update book availability.
    - Ensure books.status = 'yes' when a book has no active (not-returned) issued rows.
    - Ensure books.status = 'no' when a book has at least one active issued row.
    - Keep issued_status/return_status synchronized and maintain history.
============================================================================================================================================*/


/*============================================================================================================================================
   0. Ensure book_quality exists on return_status
============================================================================================================================================*/

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'library' AND TABLE_NAME = 'return_status' AND COLUMN_NAME = 'book_quality'
)
BEGIN
    ALTER TABLE library.return_status
    ADD book_quality VARCHAR(15) CONSTRAINT DF_return_status_book_quality DEFAULT('Good');
END;
GO


/*============================================================================================================================================
   1. Ensure is_returned and returned_date exist on issued_status
============================================================================================================================================*/

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'library' AND TABLE_NAME = 'issued_status' AND COLUMN_NAME = 'is_returned'
)
BEGIN
    ALTER TABLE library.issued_status
    ADD is_returned TINYINT CONSTRAINT DF_issued_status_is_returned DEFAULT(0);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'library' AND TABLE_NAME = 'issued_status' AND COLUMN_NAME = 'returned_date'
)
BEGIN
    ALTER TABLE library.issued_status
    ADD returned_date DATETIME NULL;
END;
GO


/*============================================================================================================================================
   2. Normalize existing return_status.book_quality NULLs to 'Good' (preserve Damaged)
============================================================================================================================================*/

UPDATE library.return_status
SET book_quality = 'Good'
WHERE book_quality IS NULL;
GO


/*============================================================================================================================================
   3. Synchronize issued_status.is_returned & returned_date from return_status
      - If a return exists -> is_returned = 1 and returned_date = rs.return_date
      - Else -> is_returned = 0 and returned_date = NULL
============================================================================================================================================*/

UPDATE ist
SET
    is_returned = CASE WHEN rs.issued_id IS NOT NULL THEN 1 ELSE 0 END,
    returned_date = rs.return_date
FROM library.issued_status ist
LEFT JOIN library.return_status rs
    ON rs.issued_id = ist.issued_id;
GO


/*============================================================================================================================================
   4. Ensure books exist (idempotent) -- used for active test rows
============================================================================================================================================*/

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-307-58837-1')
BEGIN
    INSERT INTO library.books (isbn, book_title, category, rental_price, status, author, publisher)
    VALUES ('978-0-307-58837-1', 'Sample Book X', 'Fiction', 3.00, 'yes', 'Author X', 'Publisher X');
END;

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-330-25864-8')
BEGIN
    INSERT INTO library.books (isbn, book_title, category, rental_price, status, author, publisher)
    VALUES ('978-0-330-25864-8', 'Animal Farm', 'Classic', 5.50, 'yes', 'George Orwell', 'Penguin Books');
END;

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-307-37840-1')
BEGIN
    INSERT INTO library.books (isbn, book_title, category, rental_price, status, author, publisher)
    VALUES ('978-0-307-37840-1', 'The Alchemist', 'Fiction', 2.50, 'yes', 'Paulo Coelho', 'HarperOne');
END;
GO


/*============================================================================================================================================
   5. Ensure members & employees exist (idempotent)
============================================================================================================================================*/

IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C106')
    INSERT INTO library.members (member_id, member_name, member_address, reg_date) VALUES ('C106', 'Frank Thomas', '234 Cedar St', '2021-10-15');

IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C110')
    INSERT INTO library.members (member_id, member_name, member_address, reg_date) VALUES ('C110', 'Jack Wilson', '678 Pine St', '2022-02-25');

IF NOT EXISTS (SELECT 1 FROM library.employees WHERE emp_id = 'E104')
    INSERT INTO library.employees (emp_id, emp_name, position, salary, branch_id) VALUES ('E104', 'Emily Davis', 'Assistant', 40000.00, 'B001');
GO


/*============================================================================================================================================
   6. Harden & replace add_return_records stored procedure (idempotent replace)
   - This proc inserts a return_status row, records book_quality, sets book.status='yes',
     and marks the issued_status row as returned with returned_date.
============================================================================================================================================*/

IF OBJECT_ID('library.add_return_records', 'P') IS NOT NULL
    DROP PROCEDURE library.add_return_records;
GO

CREATE PROCEDURE library.add_return_records
    @p_return_id     VARCHAR(10),
    @p_issued_id     VARCHAR(10),
    @p_book_quality  VARCHAR(15) = 'Good'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_isbn VARCHAR(50);
    DECLARE @v_book_name VARCHAR(200);

    -- 1) Validate issued row exists
    IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = @p_issued_id)
    BEGIN
        PRINT 'ERROR: issued_id does NOT exist: ' + ISNULL(@p_issued_id,'(null)');
        RETURN;
    END

    -- 2) Prevent duplicate return for same issued_id
    IF EXISTS (SELECT 1 FROM library.return_status WHERE issued_id = @p_issued_id)
    BEGIN
        PRINT 'NOTICE: issued_id ' + @p_issued_id + ' already has a return record (no action taken).';
        RETURN;
    END

    -- 3) Prevent duplicate return_id
    IF EXISTS (SELECT 1 FROM library.return_status WHERE return_id = @p_return_id)
    BEGIN
        PRINT 'ERROR: return_id ' + @p_return_id + ' already exists; use a different return_id.';
        RETURN;
    END

    -- 4) Get ISBN and book name
    SELECT @v_isbn = issued_book_isbn, @v_book_name = issued_book_name
    FROM library.issued_status
    WHERE issued_id = @p_issued_id;

    IF @v_isbn IS NULL
    BEGIN
        PRINT 'ERROR: Could not determine ISBN for issued_id ' + @p_issued_id;
        RETURN;
    END

    -- 5) Insert return row (with quality)
    INSERT INTO library.return_status
    (return_id, issued_id, return_date, return_book_isbn, return_book_name, book_quality)
    VALUES
    (@p_return_id, @p_issued_id, GETDATE(), @v_isbn, @v_book_name, @p_book_quality);

    -- 6) Update the book to available
    UPDATE library.books SET status = 'yes' WHERE isbn = @v_isbn;

    -- 7) Mark the issued row as returned (keeps history)
    UPDATE library.issued_status
    SET is_returned = 1, returned_date = GETDATE()
    WHERE issued_id = @p_issued_id;

    PRINT 'RETURN RECORDED: ' + ISNULL(@v_book_name,'(unknown)') 
          + ' (Issued ID: ' + @p_issued_id + ', Return ID: ' + @p_return_id + ')';
END;
GO


/*============================================================================================================================================
   7. Ensure there are active issued rows (not returned).
      We deliberately create two active issued rows (IS201, IS202). These are NOT auto-returned.
============================================================================================================================================*/

IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS201')
BEGIN
    INSERT INTO library.issued_status
    (issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id, is_returned)
    VALUES
    ('IS201', 'C106', 'Sample Book X', DATEADD(DAY, -5, GETDATE()), '978-0-307-58837-1', 'E104', 0);
END;

IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS202')
BEGIN
    INSERT INTO library.issued_status
    (issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id, is_returned)
    VALUES
    ('IS202', 'C110', 'Animal Farm', DATEADD(DAY, -3, GETDATE()), '978-0-330-25864-8', 'E104', 0);
END;

-- Mark their books as issued (status = 'no')
UPDATE library.books
SET status = 'no'
WHERE isbn IN ('978-0-307-58837-1', '978-0-330-25864-8');
GO


/*============================================================================================================================================
   8. Update Book Status on Return (maintenance query) 
   Purpose:
     - Set books.status = 'yes' when there are NO active issued rows for that book.
     - Set books.status = 'no' when there is at least one active issued row for that book.
============================================================================================================================================*/

-- Mark books that currently have any active (not returned) issued records as unavailable ('no')
UPDATE b
SET b.status = 'no'
FROM library.books b
WHERE EXISTS (
    SELECT 1 FROM library.issued_status ist
    WHERE ist.issued_book_isbn = b.isbn
      AND (ist.is_returned IS NULL OR ist.is_returned = 0)
);

-- Mark books that have no active issued records as available ('yes')
UPDATE b
SET b.status = 'yes'
FROM library.books b
WHERE NOT EXISTS (
    SELECT 1 FROM library.issued_status ist
    WHERE ist.issued_book_isbn = b.isbn
      AND (ist.is_returned IS NULL OR ist.is_returned = 0)
);
GO


/*============================================================================================================================================
   9. A simple "repair" for rows where return_status exists but issued_status missing
      (keeps history): only insert missing issued rows referenced by return_status.
============================================================================================================================================*/

INSERT INTO library.issued_status
(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id, is_returned, returned_date)
SELECT
    rs.issued_id,
    NULL AS issued_member_id,
    rs.return_book_name AS issued_book_name,
    DATEADD(DAY, -7, rs.return_date) AS issued_date,
    rs.return_book_isbn AS issued_book_isbn,
    NULL AS issued_emp_id,
    1 AS is_returned,
    rs.return_date AS returned_date
FROM library.return_status rs
LEFT JOIN library.issued_status ist ON ist.issued_id = rs.issued_id
WHERE ist.issued_id IS NULL;
GO


/*============================================================================================================================================
   10. Verification queries
============================================================================================================================================*/

-- A) Quick summary counts
SELECT 
    (SELECT COUNT(*) FROM library.issued_status) AS total_issued,
    (SELECT COUNT(*) FROM library.issued_status WHERE ISNULL(is_returned,0) = 0) AS total_active,
    (SELECT COUNT(*) FROM library.issued_status WHERE ISNULL(is_returned,0) = 1) AS total_returned,
    (SELECT COUNT(*) FROM library.return_status) AS total_return_records,
    (SELECT COUNT(*) FROM library.books) AS total_books;
GO

-- B) D) Active issued rows (not returned)
SELECT issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id
FROM library.issued_status
WHERE ISNULL(is_returned,0) = 0
ORDER BY issued_date DESC;
GO

-- C) Returned issued rows (history)
SELECT issued_id, issued_member_id, issued_book_name, issued_date, returned_date, issued_book_isbn, issued_emp_id
FROM library.issued_status
WHERE ISNULL(is_returned,0) = 1
ORDER BY returned_date DESC;
GO

-- D) Recent return_status entries
SELECT TOP 50 return_id, issued_id, return_book_name, return_date, return_book_isbn, book_quality
FROM library.return_status
ORDER BY return_date DESC;
GO