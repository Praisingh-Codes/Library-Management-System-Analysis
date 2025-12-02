USE DataManagementAnalytics;
GO

/*============================================================================================================================================
  High Risk Members Analysis
==============================================================================================================================================
Script Purpose:
    - To implement and validate: Identify Members Issuing High-Risk Books (Task 18).
    - To ensure supporting rows exist so return inserts do not violate foreign keys.
    - To insert sample damaged return records (idempotent).
    - To produce a summary of members who returned damaged books more than 2 times.

SQL Concepts Used:
    - Conditional inserts (IF NOT EXISTS)
    - Explicit INSERT column lists to avoid conversion/ordering errors
    - JOINs across return_status -> issued_status -> members
    - GROUP BY / HAVING for aggregated filtering
============================================================================================================================================*/


/*============================================================================================================================================
  0. Ensure supporting rows exist (idempotent)
   - This prevents FK constraint failures when inserting return_status rows that reference issued_id.
   - We create minimal rows only if they do not already exist.
============================================================================================================================================*/

-- Ensure the book exists
IF NOT EXISTS (SELECT 1 FROM library.books WHERE isbn = '978-0-307-58837-1')
BEGIN
    INSERT INTO library.books (isbn, book_title, category, rental_price, status, author, publisher)
    VALUES ('978-0-307-58837-1', 'Sample Book X', 'Fiction', 3.00, 'no', 'Author X', 'Publisher X');
END;
GO

-- Ensure the member exists
IF NOT EXISTS (SELECT 1 FROM library.members WHERE member_id = 'C106')
BEGIN
    INSERT INTO library.members (member_id, member_name, member_address, reg_date)
    VALUES ('C106', 'Frank Thomas', '234 Cedar St', '2021-10-15');
END;
GO

-- Ensure the employee exists
IF NOT EXISTS (SELECT 1 FROM library.employees WHERE emp_id = 'E104')
BEGIN
    INSERT INTO library.employees (emp_id, emp_name, position, salary, branch_id)
    VALUES ('E104', 'Emily Davis', 'Assistant', 40000.00, 'B001');
END;
GO

-- Ensure the issued_status row IS135 exists (this is the issued row referenced by the sample returns)
IF NOT EXISTS (SELECT 1 FROM library.issued_status WHERE issued_id = 'IS135')
BEGIN
    INSERT INTO library.issued_status
    (
        issued_id,
        issued_member_id,
        issued_book_name,
        issued_date,
        issued_book_isbn,
        issued_emp_id
        /* If your issued_status table has is_returned/returned_date columns, they can be omitted or added here */
    )
    VALUES
    (
        'IS135',
        'C106',
        'Sample Book X',
        DATEADD(DAY, -12, GETDATE()),
        '978-0-307-58837-1',
        'E104'
    );
END;
GO


/*============================================================================================================================================
  1. Insert Damaged Return Records (idempotent, explicit columns)
  - Use explicit column lists and IF NOT EXISTS to avoid Msg 241 / FK errors.
============================================================================================================================================*/

IF NOT EXISTS (SELECT 1 FROM library.return_status WHERE return_id = 'RS900')
BEGIN
    INSERT INTO library.return_status
    (
        return_id,
        issued_id,
        return_book_name,
        return_date,
        return_book_isbn,
        book_quality
    )
    VALUES
    (
        'RS900',
        'IS135',
        'Sample Book X',
        GETDATE(),
        '978-0-307-58837-1',
        'Damaged'
    );
END;

IF NOT EXISTS (SELECT 1 FROM library.return_status WHERE return_id = 'RS901')
BEGIN
    INSERT INTO library.return_status
    (
        return_id,
        issued_id,
        return_book_name,
        return_date,
        return_book_isbn,
        book_quality
    )
    VALUES
    (
        'RS901',
        'IS135',
        'Sample Book X',
        GETDATE(),
        '978-0-307-58837-1',
        'Damaged'
    );
END;

IF NOT EXISTS (SELECT 1 FROM library.return_status WHERE return_id = 'RS902')
BEGIN
    INSERT INTO library.return_status
    (
        return_id,
        issued_id,
        return_book_name,
        return_date,
        return_book_isbn,
        book_quality
    )
    VALUES
    (
        'RS902',
        'IS135',
        'Sample Book X',
        GETDATE(),
        '978-0-307-58837-1',
        'Damaged'
    );
END;
GO


/*============================================================================================================================================
  2. Optional: mark the issued_status row as returned (if you want issued_status to reflect the return)
     -- Uncomment the UPDATE block below if you want IS135 to be marked returned.
============================================================================================================================================*/
/*
UPDATE library.issued_status
SET is_returned = 1,
    returned_date = GETDATE()
WHERE issued_id = 'IS135';
GO
*/


/*============================================================================================================================================
  3. Verification: show damaged return rows (should include RS900/RS901/RS902)
============================================================================================================================================*/
SELECT 
    return_id,
    issued_id,
    return_book_name,
    return_date,
    return_book_isbn,
    book_quality
FROM 
    library.return_status
WHERE 
    book_quality = 'Damaged'
ORDER BY 
    return_date DESC, return_id;
GO


/*============================================================================================================================================
  Task 18: Identify Members Issuing High-Risk Books
  Objective:
    - Identify members who returned books marked as 'Damaged' more than 2 times.
    - Display Member ID, Member Name, Book Title, and total number of damaged returns.
  Implementation:
    - Join return_status -> issued_status -> members to correctly attribute returns to members.
============================================================================================================================================*/

SELECT 
    m.member_id                               AS Member_ID,
    m.member_name                             AS Member_Name,
    rs.return_book_name                       AS Book_Title,
    COUNT(*)                                  AS damaged_return_count
FROM 
    library.return_status AS rs
INNER JOIN
    library.issued_status  AS ist
        ON rs.issued_id = ist.issued_id     -- map return -> issued (gives issued_member_id)
INNER JOIN
    library.members        AS m
        ON ist.issued_member_id = m.member_id
WHERE 
    rs.book_quality = 'Damaged'
GROUP BY 
    m.member_id,
    m.member_name,
    rs.return_book_name
HAVING 
    COUNT(*) > 2
ORDER BY 
    damaged_return_count DESC;
GO