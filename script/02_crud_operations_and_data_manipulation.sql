/*============================================================================================================================================
CRUD Operations & Data Manipulation
==============================================================================================================================================
Purpose:
    - To demonstrate Create, Read, Update, and Delete operations on the library database.
    - To showcase basic SQL DML functionality through practical tasks.
    - To include analytical querying (GROUP BY, HAVING) for deeper insights.
    - To validate actions through verification SELECT statements.

SQL Concepts Used:
    - INSERT INTO (CREATE)
    - SELECT (READ)
    - UPDATE (MODIFY)
    - DELETE (REMOVE)
    - GROUP BY, HAVING (ANALYTICS)
============================================================================================================================================*/

/*============================================================================================================================================
  Task 1: CREATE - Insert a New Book Record
  Objective: Add a new book titled "To Kill a Mockingbird" to the books table.
============================================================================================================================================*/
INSERT INTO library.books
(
    isbn,
    book_title,
    category,
    rental_price,
    status,
    author,
    publisher
)
VALUES
(
    '978-1-60129-456-2',
    'To Kill a Mockingbird',
    'Classic',
    6.00,
    'yes',
    'Harper Lee',
    'J.B. Lippincott & Co.'
);
GO

-- Verify insertion
SELECT *
FROM library.books
WHERE book_title = 'To Kill a Mockingbird';
GO


/*============================================================================================================================================
  Task 2: UPDATE - Modify a Member's Address
  Objective: Update the address of the member with ID 'C103' to '125 Oak St'.
============================================================================================================================================*/
UPDATE library.members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
GO

-- Verify update
SELECT *
FROM library.members
WHERE member_id = 'C103';
GO


/*============================================================================================================================================
  Task 3: DELETE - Remove a Record from Issued Status
  Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
============================================================================================================================================*/
DELETE FROM library.issued_status
WHERE issued_id = 'IS121';
GO

-- Verify deletion
SELECT *
FROM library.issued_status
WHERE issued_id = 'IS121';
GO


/*============================================================================================================================================
  Task 4: READ - Retrieve All Books Issued by a Specific Employee
  Objective: Display all books issued by the employee with emp_id = 'E104'.
============================================================================================================================================*/
SELECT
    issued_id,
    issued_book_name,
    issued_member_id,
    issued_date,
    issued_emp_id
FROM library.issued_status
WHERE issued_emp_id = 'E104';
GO


/*============================================================================================================================================
  Task 5: ANALYTICAL QUERY - List Members Who Have Issued More Than One Book
  Objective: Use GROUP BY and HAVING to find members with multiple issued books.
============================================================================================================================================*/
SELECT
    issued_member_id AS Member_ID,
    COUNT(*)           AS Total_Issued_Books
FROM library.issued_status
GROUP BY issued_member_id
HAVING COUNT(*) > 1;
GO


/*============================================================================================================================================
  Verification Queries
============================================================================================================================================*/
-- View all members
SELECT * FROM library.members;
GO

-- View all books
SELECT * FROM library.books;
GO

-- View all issued records
SELECT * FROM library.issued_status;
GO