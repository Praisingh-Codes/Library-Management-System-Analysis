USE DataManagementAnalytics;
GO

/*============================================================================================================================================
  Active Members CTAS
============================================================================================================================================
  Script Purpose:
    - To implement and validate: Create Table of Active Members (CTAS).
    - To generate a derived table (library.active_members) containing members who
      issued at least one book in the last 2 years.
    - To demonstrate CTAS (SELECT INTO) for dataset extraction.
    - To support downstream analytics focused on active library users.

  SQL Concepts Used:
    - SELECT INTO (CTAS equivalent in SQL Server)
    - DISTINCT filtering
    - Subqueries
    - Date functions: DATEADD(), GETDATE()
    - Idempotent table creation (DROP IF EXISTS)
============================================================================================================================================*/


/*============================================================================================================================================
  Task 16: Create Table of Active Members (CTAS)
  Objective:
      - Create a new table 'active_members' containing members who issued at least
        one book in the last 2 years.
      - Use SELECT INTO to construct a clean derived dataset.
============================================================================================================================================*/


/*============================================================================================================================================
  Create summary table: library.active_members
============================================================================================================================================*/

-- Drop table if it already exists (idempotent)
IF OBJECT_ID('library.active_members', 'U') IS NOT NULL
    DROP TABLE library.active_members;
GO

-- Create CTAS table for active members (issued books in last 2 years)
SELECT 
    m.member_id,
    m.member_name,
    m.member_address,
    m.reg_date
INTO 
    library.active_members
FROM 
    library.members AS m
WHERE 
    m.member_id IN (
        SELECT DISTINCT issued_member_id
        FROM library.issued_status
        WHERE issued_date >= DATEADD(YEAR, -2, GETDATE())
    );
GO


/*============================================================================================================================================
  Verification
============================================================================================================================================*/

-- View members who qualify as active in the last 2 years
SELECT 
    member_id,
    member_name,
    member_address,
    reg_date
FROM 
    library.active_members
ORDER BY 
    member_id;
GO