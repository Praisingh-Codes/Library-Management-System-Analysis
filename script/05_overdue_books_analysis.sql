USE DataManagementAnalytics;
GO

/*============================================================================================================================================
  Overdue Books Analysis
==============================================================================================================================================
Script Purpose:
    - To perform analytical SQL queries on the Library Management dataset.
    - To uncover insights related to overdue books and member activity.
    - To demonstrate filtering, joins, date-based analysis, and overdue calculations.

SQL Concepts Used:
    - INNER JOIN / LEFT JOIN
    - Date Functions: DATEDIFF(), GETDATE()
    - NULL filtering to detect non-returned books
    - Ordering results by computed metrics
============================================================================================================================================*/


/*============================================================================================================================================
  Task 13: Identify Members with Overdue Books
  Objective:
    - Identify members whose issued books are overdue by more than 30 days.
    - Display Member ID, Member Name, Book Title, Issue Date, and Days Overdue.
============================================================================================================================================*/

SELECT 
    ist.issued_member_id                              AS member_id,
    m.member_name                                     AS member_name,
    bk.book_title                                     AS book_title,
    ist.issued_date                                   AS issue_date,
    DATEDIFF(DAY, ist.issued_date, GETDATE())         AS overdue_days
FROM 
    library.issued_status AS ist
JOIN 
    library.members AS m
        ON m.member_id = ist.issued_member_id
JOIN 
    library.books AS bk
        ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
    library.return_status AS rs
        ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_id IS NULL
    AND DATEDIFF(DAY, ist.issued_date, GETDATE()) > 30
ORDER BY 
    overdue_days DESC;
GO