USE DataManagementAnalytics;
GO

/*============================================================================================================================================
  CTAS (Create Table As Select)
==============================================================================================================================================
Script Purpose:
    - To dynamically generate summary tables using the CTAS (Create Table As Select) method.
    - In SQL Server, CTAS is implemented using the SELECT INTO syntax.
    - This task creates the summary table 'book_issued_cnt', listing each book and 
      the total number of times it has been issued.

Key Notes:
    - Existing summary table is dropped before recreation to avoid conflicts.
    - SELECT INTO is used to create and populate the table in one step.

SQL Concepts Used:
    - SELECT INTO  (CTAS Equivalent)
    - JOIN
    - GROUP BY
    - Aggregate Function: COUNT()
============================================================================================================================================*/


/*============================================================================================================================================
  Task 6: Create a Summary Table - book_issued_cnt
  Objective: Generate a summary table showing each book (ISBN & title) and the total count of issues per book.
============================================================================================================================================*/

-- Drop the table if it already exists to avoid conflicts
IF OBJECT_ID('library.book_issued_cnt', 'U') IS NOT NULL
    DROP TABLE library.book_issued_cnt;
GO

-- Create new summary table using SELECT INTO (CTAS equivalent in SQL Server)
SELECT 
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) AS book_issued_count
INTO library.book_issued_cnt
FROM library.issued_status AS ist
JOIN library.books AS b
    ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
GO

/*============================================================================================================================================
  Verification
============================================================================================================================================*/

-- Display the new summary table
SELECT 
    * 
FROM 
    library.book_issued_cnt
ORDER BY 
    book_issued_count DESC;
GO