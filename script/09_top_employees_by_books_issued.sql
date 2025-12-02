USE DataManagementAnalytics;
GO

/*============================================================================================================================================
  Top Employees by Books Issued
============================================================================================================================================
Script Purpose:
    - To implement and validate: Top Employees by Books Issued.
    - To identify the employees who processed the highest number of book issues.
    - To analyze staff performance by combining issued_status, employees, and branch tables.
    - To apply aggregation, grouping, and ordering for ranking employees.

SQL Concepts Used:
    - INNER JOIN operations across multiple tables
    - GROUP BY with aggregate calculations
    - COUNT() function to measure employee activity
    - TOP N filtering using ORDER BY
============================================================================================================================================*/


/*============================================================================================================================================
  Task 17: Top Employees by Books Issued
  Objective:
    - Retrieve the top 3 employees who issued the greatest number of books.
    - Display employee details including branch information and total issuance count.
============================================================================================================================================*/


/*============================================================================================================================================
  Query: Top 3 Employees by Issued Books
============================================================================================================================================*/

SELECT TOP 3
    e.emp_name                                 AS Employee_Name,
    b.branch_id                                AS Branch_ID,
    b.branch_address                           AS Branch_Address,
    b.contact_no                               AS Branch_Contact,
    COUNT(ist.issued_id)                       AS number_of_books_issued
FROM
    library.issued_status   AS ist
JOIN
    library.employees       AS e
        ON e.emp_id = ist.issued_emp_id
JOIN
    library.branch          AS b
        ON e.branch_id = b.branch_id
GROUP BY 
    e.emp_name,
    b.branch_id,
    b.branch_address,
    b.contact_no
ORDER BY 
    number_of_books_issued DESC;
GO