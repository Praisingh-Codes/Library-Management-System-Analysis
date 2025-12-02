USE DataManagementAnalytics;
GO

/*============================================================================================================================================
  Branch Performance Report
============================================================================================================================================
Script Purpose:
    - To implement and validate: Branch Performance Report.
    - To generate a per-branch summary showing:
        • Total books issued
        • Total books returned
        • Total rental revenue generated
    - To create a summary table using SELECT INTO (CTAS-style):
          → library.branch_reports
    - To provide verification queries to analyze branch-level performance.

SQL Concepts Used:
    - SELECT INTO (CTAS equivalent in SQL Server)
    - INNER JOIN / LEFT JOIN
    - Aggregate Functions: COUNT(), SUM()
    - GROUP BY
    - Idempotent object creation (DROP IF EXISTS)
============================================================================================================================================*/


/*============================================================================================================================================
  Task 15: Branch Performance Report
  Objective:
    - Generate a performance report for each branch summarizing:
        • Total books issued
        • Total books returned
        • Total rental revenue generated
    - Store the consolidated output in: library.branch_reports
============================================================================================================================================*/


/*============================================================================================================================================
  Create summary table: library.branch_reports
============================================================================================================================================*/

-- Drop summary table if it already exists
IF OBJECT_ID('library.branch_reports', 'U') IS NOT NULL
    DROP TABLE library.branch_reports;
GO

-- Build Branch Performance Report using SELECT INTO (CTAS)
SELECT
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id)          AS number_of_books_issued,
    COUNT(rs.return_id)           AS number_of_books_returned,
    SUM(bk.rental_price)          AS total_revenue
INTO
    library.branch_reports
FROM
    library.issued_status AS ist
JOIN
    library.employees AS e
        ON e.emp_id = ist.issued_emp_id
JOIN
    library.branch AS b
        ON e.branch_id = b.branch_id
LEFT JOIN
    library.return_status AS rs
        ON rs.issued_id = ist.issued_id
JOIN
    library.books AS bk
        ON bk.isbn = ist.issued_book_isbn
GROUP BY
    b.branch_id,
    b.manager_id;
GO


/*============================================================================================================================================
  Verification
============================================================================================================================================*/

-- Display report ordered by highest revenue
SELECT
    branch_id,
    manager_id,
    number_of_books_issued,
    number_of_books_returned,
    total_revenue
FROM
    library.branch_reports
ORDER BY
    total_revenue DESC;
GO