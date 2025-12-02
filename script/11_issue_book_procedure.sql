USE DataManagementAnalytics;
GO

/*============================================================================================================================================
  Issue Book Procedure
============================================================================================================================================
Script Purpose:
    - To implement and validate: Issue Book (Safe, Complete, Idempotent).
    - To create a hardened stored procedure (library.issue_book) that:
        • validates inputs (issued_id, ISBN, member, employee)
        • fixes simple inconsistencies in book status
        • ensures book availability before issuing
        • inserts an issued_status record and updates book availability
    - To provide test execution and verification queries after procedure creation.

SQL Concepts Used:
    - Stored Procedures (CREATE PROCEDURE)
    - Variable DECLARE and SELECT assignment
    - Conditional logic: IF EXISTS / IF NOT EXISTS
    - DML: INSERT, UPDATE, SELECT
    - Date functions: GETDATE()
    - Idempotent design so script can be safely re-run
============================================================================================================================================*/


/*============================================================================================================================================
  Task 19: Issue Book – FULLY UPDATED, SAFE & COMPLETE VERSION
  Objective:
    - Provide a robust procedure to issue books to members with full validation and clear messages.
============================================================================================================================================*/

-- Drop existing procedure if present
IF OBJECT_ID('library.issue_book', 'P') IS NOT NULL
    DROP PROCEDURE library.issue_book;
GO

CREATE PROCEDURE library.issue_book
    @p_issued_id    VARCHAR(10),
    @p_member_id    VARCHAR(10),
    @p_book_isbn    VARCHAR(50),
    @p_emp_id       VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_status     VARCHAR(10);
    DECLARE @v_book_name  VARCHAR(200);

    /*----------------------------------------------------------------------------------------------------
      0. FIX INCONSISTENCIES:
         If book status = 'no' BUT no active issued record exists → reset it to 'yes'
    ----------------------------------------------------------------------------------------------------*/
    IF NOT EXISTS (
        SELECT 1
        FROM library.issued_status
        WHERE issued_book_isbn = @p_book_isbn
          AND (ISNULL(is_returned,0) = 0)
    )
    AND EXISTS (
        SELECT 1
        FROM library.books
        WHERE isbn = @p_book_isbn
          AND status = 'no'
    )
    BEGIN
        UPDATE library.books
        SET status = 'yes'
        WHERE isbn = @p_book_isbn;
    END

    /*----------------------------------------------------------------------------------------------------
      1. Validate issued_id does not already exist
    ----------------------------------------------------------------------------------------------------*/
    IF EXISTS (
        SELECT 1
        FROM library.issued_status
        WHERE issued_id = @p_issued_id
    )
    BEGIN
        PRINT 'ERROR: issued_id already exists: ' + @p_issued_id;
        RETURN;
    END

    /*----------------------------------------------------------------------------------------------------
      2. Validate ISBN exists & retrieve status and book title
    ----------------------------------------------------------------------------------------------------*/
    SELECT
        @v_status = status,
        @v_book_name = book_title
    FROM library.books
    WHERE isbn = @p_book_isbn;

    IF @v_status IS NULL
    BEGIN
        PRINT 'ERROR: ISBN does NOT exist: ' + @p_book_isbn;
        RETURN;
    END

    /*----------------------------------------------------------------------------------------------------
      3. Validate member exists
    ----------------------------------------------------------------------------------------------------*/
    IF NOT EXISTS (
        SELECT 1
        FROM library.members
        WHERE member_id = @p_member_id
    )
    BEGIN
        PRINT 'ERROR: Member ID does NOT exist: ' + @p_member_id;
        RETURN;
    END

    /*----------------------------------------------------------------------------------------------------
      4. Validate employee exists
    ----------------------------------------------------------------------------------------------------*/
    IF NOT EXISTS (
        SELECT 1
        FROM library.employees
        WHERE emp_id = @p_emp_id
    )
    BEGIN
        PRINT 'ERROR: Employee ID does NOT exist: ' + @p_emp_id;
        RETURN;
    END

    /*----------------------------------------------------------------------------------------------------
      5. Validate book availability
    ----------------------------------------------------------------------------------------------------*/
    IF @v_status <> 'yes'
    BEGIN
        PRINT 'Book is NOT available. Current status: ' + ISNULL(@v_status, 'UNKNOWN');
        RETURN;
    END

    /*----------------------------------------------------------------------------------------------------
      6. Insert into issued_status
    ----------------------------------------------------------------------------------------------------*/
    INSERT INTO library.issued_status
    (
        issued_id,
        issued_member_id,
        issued_book_name,
        issued_date,
        issued_book_isbn,
        issued_emp_id,
        is_returned
    )
    VALUES
    (
        @p_issued_id,
        @p_member_id,
        @v_book_name,
        GETDATE(),
        @p_book_isbn,
        @p_emp_id,
        0
    );

    /*----------------------------------------------------------------------------------------------------
      7. Update book status to unavailable
    ----------------------------------------------------------------------------------------------------*/
    UPDATE library.books
    SET status = 'no'
    WHERE isbn = @p_book_isbn;

    /*----------------------------------------------------------------------------------------------------
      8. Success message
    ----------------------------------------------------------------------------------------------------*/
    PRINT 'SUCCESS: Book issued!';
    PRINT '   Issued ID : ' + @p_issued_id;
    PRINT '   Member ID : ' + @p_member_id;
    PRINT '   ISBN      : ' + @p_book_isbn;
    PRINT '   Book      : ' + @v_book_name;
END;
GO


/*============================================================================================================================================
  Procedure: Test execution & verification
============================================================================================================================================*/

-- Ensure book is available for the test (idempotent)
UPDATE library.books
SET status = 'yes'
WHERE isbn = '978-0-553-29698-2';
GO

-- Execute procedure to issue the book (idempotent guard: only run if issued_id missing)
IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS160')
BEGIN
    EXEC library.issue_book 
        @p_issued_id = 'IS160',
        @p_member_id = 'C108',
        @p_book_isbn = '978-0-553-29698-2',
        @p_emp_id    = 'E104';
END;
GO

-- Verify issued record and book status
SELECT * FROM library.issued_status WHERE issued_id = 'IS160';
GO

SELECT * FROM library.books WHERE isbn = '978-0-553-29698-2';
GO