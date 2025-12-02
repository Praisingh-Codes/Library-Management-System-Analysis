USE DataManagementAnalytics;
GO

/*============================================================================================================================================
  Data Analysis & Findings
==============================================================================================================================================
Script Purpose:
    - To perform analytical SQL queries on the Library Management dataset.
    - To uncover insights related to books, members, employees, categories, and activity.
    - To demonstrate filtering, aggregation, joins, CTAS, and date-based analysis.

SQL Concepts Used:
    - WHERE filtering
    - JOIN operations (INNER / LEFT JOIN)
    - GROUP BY, ORDER BY
    - Aggregate Functions: SUM(), COUNT()
    - Date Functions: DATEADD(), GETDATE()
    - SELECT INTO (CTAS)
============================================================================================================================================*/


/*============================================================================================================================================
  Task 7: Retrieve All Books in a Specific Category
  Objective: Display all books that belong to the 'Classic' category.
============================================================================================================================================*/

SELECT 
    isbn,
    book_title,
    category,
    rental_price,
    status,
    author,
    publisher
FROM 
    library.books
WHERE 
    category = 'Classic';
GO


USE DataManagementAnalytics;
GO

/*============================================================================================================================================
  Task 8: Find Total Rental Income by Category
  Objective: Calculate the total rental income and number of books issued per category.
============================================================================================================================================*/

SELECT 
    b.category AS Category,
    SUM(b.rental_price) AS Total_Rental_Income,
    COUNT(ist.issued_id) AS Total_Books_Issued
FROM 
    library.issued_status AS ist
JOIN 
    library.books AS b
        ON b.isbn = ist.issued_book_isbn
GROUP BY 
    b.category
ORDER BY 
    Total_Rental_Income DESC;
GO


/*============================================================================================================================================
  Task 9: List Members Who Registered in the Last 180 Days
  Objective: Retrieve all members whose registration date falls within the last 180 days from today.
============================================================================================================================================*/

-- Sample new member for testing
INSERT INTO library.members (member_id, member_name, member_address, reg_date)
VALUES ('C200', 'test_user', 'test address', '2025-10-01');

-- Retrieve members registered within last 180 days
SELECT 
    member_id,
    member_name,
    member_address,
    reg_date
FROM 
    library.members
WHERE 
    reg_date >= DATEADD(DAY, -180, GETDATE());
GO


/*============================================================================================================================================
  Task 10: List Employees with Their Branch Manager’s Name and Branch Details
  Objective: Show all employees with their respective branch details and their manager’s name.
============================================================================================================================================*/

SELECT 
    e1.emp_id       AS Employee_ID,
    e1.emp_name     AS Employee_Name,
    e1.position     AS Position,
    e1.salary       AS Salary,
    b.branch_id     AS Branch_ID,
    b.branch_address AS Branch_Address,
    b.contact_no     AS Branch_Contact,
    e2.emp_name      AS Manager_Name
FROM 
    library.employees AS e1
JOIN 
    library.branch AS b
        ON e1.branch_id = b.branch_id
JOIN 
    library.employees AS e2
        ON e2.emp_id = b.manager_id
ORDER BY 
    e1.emp_name;
GO


/*============================================================================================================================================
  Task 11: Create a Table of Books with Rental Price Above a Certain Threshold
  Objective: Use CTAS (SELECT INTO in SQL Server) to create a table of expensive books (rental_price > 7.00).
============================================================================================================================================*/

-- Drop table if it already exists
IF OBJECT_ID('library.expensive_books', 'U') IS NOT NULL
    DROP TABLE library.expensive_books;
GO

-- Create CTAS-style table
SELECT 
    isbn,
    book_title,
    category,
    rental_price,
    status,
    author,
    publisher
INTO 
    library.expensive_books
FROM 
    library.books
WHERE 
    rental_price > 7.00;
GO

-- Verify new table
SELECT 
    * 
FROM 
    library.expensive_books
ORDER BY 
    rental_price DESC;
GO


/*============================================================================================================================================
  Task 12: Retrieve the List of Books Not Yet Returned
  Objective: Identify issued books that do not have corresponding records in the return_status table.
============================================================================================================================================*/

-- Insert a pending issue for demonstration
INSERT INTO library.issued_status 
(
    issued_id, 
    issued_member_id, 
    issued_book_name, 
    issued_date, 
    issued_book_isbn, 
    issued_emp_id
)
VALUES 
(
    'IS300', 
    'C106', 
    'Animal Farm', 
    '2024-11-10', 
    '978-0-330-25864-8', 
    'E104'
);

-- Retrieve books not yet returned
SELECT 
    ist.issued_id,
    ist.issued_book_name,
    ist.issued_member_id,
    ist.issued_date,
    ist.issued_book_isbn,
    ist.issued_emp_id
FROM 
    library.issued_status AS ist
LEFT JOIN 
    library.return_status AS rs
        ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_id IS NULL
ORDER BY 
    ist.issued_date ASC;
GO