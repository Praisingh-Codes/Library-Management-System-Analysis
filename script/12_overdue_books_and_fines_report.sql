USE DataManagementAnalytics;
GO

/*============================================================================================================================================
  Overdue Books and Fines Report
==============================================================================================================================================
Script Purpose:
    - To generate a summary table reporting overdue books and fines per member.
    - Calculates:
          • Total books issued
          • Number of overdue books (> 30 days, not returned)
          • Total fines (overdue days × $0.50)
    - Demonstrates CTAS (SELECT INTO) usage for analytical reporting.

SQL Concepts Used:
    - SELECT INTO (CTAS)
    - LEFT JOIN to capture non-returned issued books
    - Conditional aggregation with CASE
    - Date arithmetic using DATEDIFF()
============================================================================================================================================*/


/*============================================================================================================================================
  Task 20: CTAS – Overdue Books & Fines Report
  Create Summary Table: library.overdue_books_report
============================================================================================================================================*/

-- Drop table if it already exists
IF OBJECT_ID('library.overdue_books_report', 'U') IS NOT NULL
    DROP TABLE library.overdue_books_report;
GO

-- Create CTAS-style overdue report
SELECT
    ist.issued_member_id AS member_id,

    /* Total books issued */
    COUNT(ist.issued_id) AS total_books_issued,

    /* Count overdue books: issued_date > 30 days AND no return record */
    SUM(
        CASE 
            WHEN rs.return_id IS NULL
             AND DATEDIFF(DAY, ist.issued_date, GETDATE()) > 30
            THEN 1 ELSE 0
        END
    ) AS overdue_books,

    /* Total fines: (days overdue − 30) × $0.50 */
    SUM(
        CASE
            WHEN rs.return_id IS NULL
             AND DATEDIFF(DAY, ist.issued_date, GETDATE()) > 30
            THEN (DATEDIFF(DAY, ist.issued_date, GETDATE()) - 30) * 0.50
            ELSE 0
        END
    ) AS total_fines

INTO
    library.overdue_books_report
FROM
    library.issued_status AS ist
LEFT JOIN
    library.return_status AS rs
        ON ist.issued_id = rs.issued_id
GROUP BY
    ist.issued_member_id;
GO


/*============================================================================================================================================
  Verification – View Overdue Fines Report
============================================================================================================================================*/

SELECT
    member_id,
    total_books_issued,
    overdue_books,
    total_fines
FROM
    library.overdue_books_report
ORDER BY
    total_fines DESC;
GO

-- Friendly overdue report: include member name and formatted fines
SELECT
    obr.member_id,
    ISNULL(m.member_name, 'Unknown')    AS member_name,
    obr.total_books_issued,
    obr.overdue_books,
    -- show fines with two decimals
    CONVERT(DECIMAL(10,2), obr.total_fines) AS total_fines
FROM
    library.overdue_books_report obr
LEFT JOIN
    library.members m
      ON m.member_id = obr.member_id
ORDER BY
    obr.total_fines DESC, obr.overdue_books DESC;
GO