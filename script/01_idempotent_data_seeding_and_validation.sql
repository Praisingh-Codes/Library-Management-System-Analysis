/*====================================================================================================================================================================
    Idempotent Data Seeding & Validation Script
======================================================================================================================================================================

Purpose:
    - Populate all library tables using safe, idempotent INSERT operations.
    - Prevent duplicate key conflicts via IF NOT EXISTS.
    - Dynamically add missing columns (book_quality).
    - Update damaged book return records.
    - Run integrity validation queries.

SQL Concepts Used:
    - Conditional INSERT
    - DATEADD(), GETDATE()
    - ALTER TABLE with default constraint
    - UPDATE with conditions
====================================================================================================================================================================*/


/*====================================================================================================================================================================
    1. branch (idempotent inserts)
====================================================================================================================================================================*/
IF NOT EXISTS (SELECT 1 FROM library.branch WHERE branch_id = 'B001')
    INSERT INTO library.branch (branch_id, manager_id, branch_address, contact_no)
    VALUES ('B001', 'E109', '123 Main St', '+919099988676');

IF NOT EXISTS (SELECT 1 FROM library.branch WHERE branch_id = 'B002')
    INSERT INTO library.branch (branch_id, manager_id, branch_address, contact_no)
    VALUES ('B002', 'E109', '456 Elm St', '+919099988677');

IF NOT EXISTS (SELECT 1 FROM library.branch WHERE branch_id = 'B003')
    INSERT INTO library.branch (branch_id, manager_id, branch_address, contact_no)
    VALUES ('B003', 'E109', '789 Oak St', '+919099988678');

IF NOT EXISTS (SELECT 1 FROM library.branch WHERE branch_id = 'B004')
    INSERT INTO library.branch (branch_id, manager_id, branch_address, contact_no)
    VALUES ('B004', 'E110', '567 Pine St', '+919099988679');

IF NOT EXISTS (SELECT 1 FROM library.branch WHERE branch_id = 'B005')
    INSERT INTO library.branch (branch_id, manager_id, branch_address, contact_no)
    VALUES ('B005', 'E110', '890 Maple St', '+919099988680');
GO


/*====================================================================================================================================================================
    2. employees (idempotent inserts)
====================================================================================================================================================================*/
IF NOT EXISTS (SELECT 1 FROM library.employees WHERE emp_id = 'E101')
    INSERT INTO library.employees VALUES ('E101', 'John Doe', 'Clerk', 60000.00, 'B001');

IF NOT EXISTS (SELECT 1 FROM library.employees WHERE emp_id = 'E102')
    INSERT INTO library.employees VALUES ('E102', 'Jane Smith', 'Clerk', 45000.00, 'B002');

IF NOT EXISTS (SELECT 1 FROM library.employees WHERE emp_id = 'E103')
    INSERT INTO library.employees VALUES ('E103', 'Mike Johnson', 'Librarian', 55000.00, 'B001');

IF NOT EXISTS (SELECT 1 FROM library.employees WHERE emp_id = 'E104')
    INSERT INTO library.employees VALUES ('E104', 'Emily Davis', 'Assistant', 40000.00, 'B001');

IF NOT EXISTS (SELECT 1 FROM library.employees WHERE emp_id = 'E105')
    INSERT INTO library.employees VALUES ('E105', 'Sarah Brown', 'Assistant', 42000.00, 'B001');

IF NOT EXISTS (SELECT 1 FROM library.employees WHERE emp_id = 'E106')
    INSERT INTO library.employees VALUES ('E106', 'Michelle Ramirez', 'Assistant', 43000.00, 'B001');

IF NOT EXISTS (SELECT 1 FROM library.employees WHERE emp_id = 'E107')
    INSERT INTO library.employees VALUES ('E107', 'Michael Thompson', 'Clerk', 62000.00, 'B005');

IF NOT EXISTS (SELECT 1 FROM library.employees WHERE emp_id = 'E108')
    INSERT INTO library.employees VALUES ('E108', 'Jessica Taylor', 'Clerk', 46000.00, 'B004');

IF NOT EXISTS (SELECT 1 FROM library.employees WHERE emp_id = 'E109')
    INSERT INTO library.employees VALUES ('E109', 'Daniel Anderson', 'Manager', 57000.00, 'B003');

IF NOT EXISTS (SELECT 1 FROM library.employees WHERE emp_id = 'E110')
    INSERT INTO library.employees VALUES ('E110', 'Laura Martinez', 'Manager', 41000.00, 'B005');

IF NOT EXISTS (SELECT 1 FROM library.employees WHERE emp_id = 'E111')
    INSERT INTO library.employees VALUES ('E111', 'Christopher Lee', 'Assistant', 65000.00, 'B005');
GO


/*====================================================================================================================================================================
    3. members (idempotent inserts)
====================================================================================================================================================================*/
IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C101')
    INSERT INTO library.members VALUES ('C101', 'Alice Johnson', '123 Main St', '2021-05-15');

IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C102')
    INSERT INTO library.members VALUES ('C102', 'Bob Smith', '456 Elm St', '2021-06-20');

IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C103')
    INSERT INTO library.members VALUES ('C103', 'Carol Davis', '789 Oak St', '2021-07-10');

IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C104')
    INSERT INTO library.members VALUES ('C104', 'Dave Wilson', '567 Pine St', '2021-08-05');

IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C105')
    INSERT INTO library.members VALUES ('C105', 'Eve Brown', '890 Maple St', '2021-09-25');

IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C106')
    INSERT INTO library.members VALUES ('C106', 'Frank Thomas', '234 Cedar St', '2021-10-15');

IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C107')
    INSERT INTO library.members VALUES ('C107', 'Grace Taylor', '345 Walnut St', '2021-11-20');

IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C108')
    INSERT INTO library.members VALUES ('C108', 'Henry Anderson', '456 Birch St', '2021-12-10');

IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C109')
    INSERT INTO library.members VALUES ('C109', 'Ivy Martinez', '567 Oak St', '2022-01-05');

IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C110')
    INSERT INTO library.members VALUES ('C110', 'Jack Wilson', '678 Pine St', '2022-02-25');

IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C118')
    INSERT INTO library.members VALUES ('C118', 'Sam', '133 Pine St', '2024-06-01');

IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C119')
    INSERT INTO library.members VALUES ('C119', 'John', '143 Main St', '2024-05-01');
GO


/*====================================================================================================================================================================
    4. books (idempotent inserts)
====================================================================================================================================================================*/
IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-553-29698-2')
    INSERT INTO library.books VALUES ('978-0-553-29698-2', 'The Catcher in the Rye', 'Classic', 7.00, 'yes', 'J.D. Salinger', 'Little, Brown and Company');

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-330-25864-8')
    INSERT INTO library.books VALUES ('978-0-330-25864-8', 'Animal Farm', 'Classic', 5.50, 'yes', 'George Orwell', 'Penguin Books');

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-14-118776-1')
    INSERT INTO library.books VALUES ('978-0-14-118776-1', 'One Hundred Years of Solitude', 'Literary Fiction', 6.50, 'yes', 'Gabriel Garcia Marquez', 'Penguin Books');

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-525-47535-5')
    INSERT INTO library.books VALUES ('978-0-525-47535-5', 'The Great Gatsby', 'Classic', 8.00, 'yes', 'F. Scott Fitzgerald', 'Scribner');

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-141-44171-6')
    INSERT INTO library.books VALUES ('978-0-141-44171-6', 'Jane Eyre', 'Classic', 4.00, 'yes', 'Charlotte Bronte', 'Penguin Classics');

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-307-37840-1')
    INSERT INTO library.books VALUES ('978-0-307-37840-1', 'The Alchemist', 'Fiction', 2.50, 'yes', 'Paulo Coelho', 'HarperOne');

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-679-76489-8')
    INSERT INTO library.books VALUES ('978-0-679-76489-8', 'Harry Potter and the Sorcerers Stone', 'Fantasy', 7.00, 'yes', 'J.K. Rowling', 'Scholastic');

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-7432-4722-4')
    INSERT INTO library.books VALUES ('978-0-7432-4722-4', 'The Da Vinci Code', 'Mystery', 8.00, 'yes', 'Dan Brown', 'Doubleday');

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-09-957807-9')
    INSERT INTO library.books VALUES ('978-0-09-957807-9', 'A Game of Thrones', 'Fantasy', 7.50, 'yes', 'George R.R. Martin', 'Bantam');

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-393-05081-8')
    INSERT INTO library.books VALUES ('978-0-393-05081-8', 'A Peoples History of the United States', 'History', 9.00, 'yes', 'Howard Zinn', 'Harper Perennial');

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-14-143951-8')
    INSERT INTO library.books VALUES ('978-0-14-143951-8', 'Pride and Prejudice', 'Classic', 8.00, 'yes', 'Jane Austen', 'Penguin Classics');

IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-375-50167-0')
    INSERT INTO library.books VALUES ('978-0-375-50167-0', 'The Road', 'Fiction', 10.00, 'yes', 'Cormac McCarthy', 'Vintage Books');
GO


/*====================================================================================================================================================================
    5. issued_status (idempotent inserts, dynamic dates)
====================================================================================================================================================================*/

-- Fixed historical data
IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS106')
    INSERT INTO library.issued_status VALUES ('IS106', 'C106', 'Animal Farm', '2024-03-10', '978-0-330-25864-8', 'E104');

IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS107')
    INSERT INTO library.issued_status VALUES ('IS107', 'C107', 'One Hundred Years of Solitude', '2024-03-11', '978-0-14-118776-1', 'E104');

IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS108')
    INSERT INTO library.issued_status VALUES ('IS108', 'C108', 'The Great Gatsby', '2024-03-12', '978-0-525-47535-5', 'E104');

IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS109')
    INSERT INTO library.issued_status VALUES ('IS109', 'C109', 'Jane Eyre', '2024-03-13', '978-0-141-44171-6', 'E105');

IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS110')
    INSERT INTO library.issued_status VALUES ('IS110', 'C110', 'The Alchemist', '2024-03-14', '978-0-307-37840-1', 'E105');

IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS111')
    INSERT INTO library.issued_status VALUES ('IS111', 'C109', 'Harry Potter and the Sorcerers Stone', '2024-03-15', '978-0-679-76489-8', 'E105');

IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS112')
    INSERT INTO library.issued_status VALUES ('IS112', 'C109', 'A Game of Thrones', '2024-03-16', '978-0-09-957807-9', 'E106');

IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS113')
    INSERT INTO library.issued_status VALUES ('IS113', 'C109', 'A Peoples History of the United States', '2024-03-17', '978-0-393-05081-8', 'E106');

-- Recent dynamic data
IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS151')
    INSERT INTO library.issued_status VALUES ('IS151', 'C118', 'The Catcher in the Rye', DATEADD(DAY, -24, GETDATE()), '978-0-553-29698-2', 'E108');

IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS152')
    INSERT INTO library.issued_status VALUES ('IS152', 'C119', 'The Catcher in the Rye', DATEADD(DAY, -13, GETDATE()), '978-0-553-29698-2', 'E109');

IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS153')
    INSERT INTO library.issued_status VALUES ('IS153', 'C106', 'Pride and Prejudice', DATEADD(DAY, -7, GETDATE()), '978-0-14-143951-8', 'E107');

IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS154')
    INSERT INTO library.issued_status VALUES ('IS154', 'C105', 'The Road', DATEADD(DAY, -32, GETDATE()), '978-0-375-50167-0', 'E101');
GO


/*====================================================================================================================================================================
    6. return_status (idempotent inserts)
====================================================================================================================================================================*/
IF NOT EXISTS (SELECT 1 FROM library.return_status WHERE return_id = 'RS104')
    INSERT INTO library.return_status VALUES ('RS104', 'IS106', 'Animal Farm', '2024-05-01', '978-0-330-25864-8');

IF NOT EXISTS (SELECT 1 FROM library.return_status WHERE return_id = 'RS105')
    INSERT INTO library.return_status VALUES ('RS105', 'IS107', 'One Hundred Years of Solitude', '2024-05-03', '978-0-14-118776-1');

IF NOT EXISTS (SELECT 1 FROM library.return_status WHERE return_id = 'RS106')
    INSERT INTO library.return_status VALUES ('RS106', 'IS108', 'The Great Gatsby', '2024-05-05', '978-0-525-47535-5');

IF NOT EXISTS (SELECT 1 FROM library.return_status WHERE return_id = 'RS107')
    INSERT INTO library.return_status VALUES ('RS107', 'IS109', 'Jane Eyre', '2024-05-07', '978-0-141-44171-6');

IF NOT EXISTS (SELECT 1 FROM library.return_status WHERE return_id = 'RS108')
    INSERT INTO library.return_status VALUES ('RS108', 'IS110', 'The Alchemist', '2024-05-09', '978-0-307-37840-1');

IF NOT EXISTS (SELECT 1 FROM library.return_status WHERE return_id = 'RS109')
    INSERT INTO library.return_status VALUES ('RS109', 'IS111', 'Harry Potter and the Sorcerers Stone', '2024-05-11', '978-0-679-76489-8');

IF NOT EXISTS (SELECT 1 FROM library.return_status WHERE return_id = 'RS110')
    INSERT INTO library.return_status VALUES ('RS110', 'IS112', 'A Game of Thrones', '2024-05-13', '978-0-09-957807-9');

IF NOT EXISTS (SELECT 1 FROM library.return_status WHERE return_id = 'RS111')
    INSERT INTO library.return_status VALUES ('RS111', 'IS113', 'A Peoples History of the United States', '2024-05-15', '978-0-393-05081-8');
GO


/*====================================================================================================================================================================
    7. Add book_quality column if missing
====================================================================================================================================================================*/
IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'library'
      AND TABLE_NAME = 'return_status'
      AND COLUMN_NAME = 'book_quality'
)
BEGIN
    ALTER TABLE library.return_status
        ADD book_quality VARCHAR(15)
            CONSTRAINT DF_return_status_book_quality DEFAULT ('Good');
END;
GO


/*====================================================================================================================================================================
    8. Update damaged book records
====================================================================================================================================================================*/
UPDATE library.return_status
SET book_quality = 'Damaged'
WHERE issued_id IN ('IS112', 'IS117', 'IS118');
GO


/*====================================================================================================================================================================
    9. Final Data Validation Queries
====================================================================================================================================================================*/
SELECT * FROM library.members        ORDER BY member_id;
SELECT * FROM library.branch         ORDER BY branch_id;
SELECT * FROM library.employees      ORDER BY emp_id;
SELECT * FROM library.books          ORDER BY isbn;
SELECT * FROM library.issued_status  ORDER BY issued_id;
SELECT * FROM library.return_status  ORDER BY return_id;
GO