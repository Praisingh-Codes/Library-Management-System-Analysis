/*============================================================================================================================================
   Create Database and Schemas
==============================================================================================================================================

Script Purpose:
    - Creates a new database named 'DataManagementAnalytics' after checking if it already exists.
    - If the database exists, it is dropped and recreated.
    - Creates a schema called 'library' for all related tables.

WARNING:
    Running this script will DROP the existing 'DataManagementAnalytics' database.
    All data will be permanently deleted. Ensure proper backups before executing.
============================================================================================================================================*/

USE master;
GO

-- Drop and recreate the 'DataManagementAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataManagementAnalytics')
BEGIN
    ALTER DATABASE DataManagementAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataManagementAnalytics;
END;
GO

-- Create the 'DataManagementAnalytics' database
CREATE DATABASE DataManagementAnalytics;
GO

USE DataManagementAnalytics;
GO

-- Create Schema
CREATE SCHEMA library;
GO


/*============================================================================================================================================
    Create Tables
============================================================================================================================================*/

-- Table: branch
CREATE TABLE library.branch
(
    branch_id      VARCHAR(10) PRIMARY KEY,
    manager_id     VARCHAR(10),
    branch_address VARCHAR(30),
    contact_no     VARCHAR(15)
);
GO


-- Table: employees
CREATE TABLE library.employees
(
    emp_id    VARCHAR(10) PRIMARY KEY,
    emp_name  VARCHAR(30),
    position  VARCHAR(30),
    salary    DECIMAL(10,2),
    branch_id VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES library.branch(branch_id)
);
GO


-- Table: members
CREATE TABLE library.members
(
    member_id      VARCHAR(10) PRIMARY KEY,
    member_name    VARCHAR(30),
    member_address VARCHAR(30),
    reg_date       DATE
);
GO


-- Table: books
CREATE TABLE library.books
(
    isbn         VARCHAR(50) PRIMARY KEY,
    book_title   VARCHAR(80),
    category     VARCHAR(30),
    rental_price DECIMAL(10,2),
    status       VARCHAR(10),
    author       VARCHAR(30),
    publisher    VARCHAR(30)
);
GO


-- Table: issued_status
CREATE TABLE library.issued_status
(
    issued_id          VARCHAR(10) PRIMARY KEY,
    issued_member_id   VARCHAR(10),
    issued_book_name   VARCHAR(80),
    issued_date        DATE,
    issued_book_isbn   VARCHAR(50),
    issued_emp_id      VARCHAR(10),

    FOREIGN KEY (issued_member_id)  REFERENCES library.members(member_id),
    FOREIGN KEY (issued_emp_id)     REFERENCES library.employees(emp_id),
    FOREIGN KEY (issued_book_isbn)  REFERENCES library.books(isbn)
);
GO


-- Table: return_status
CREATE TABLE library.return_status
(
    return_id        VARCHAR(10) PRIMARY KEY,
    issued_id        VARCHAR(10),
    return_book_name VARCHAR(80),
    return_date      DATE,
    return_book_isbn VARCHAR(50),

    FOREIGN KEY (issued_id)        REFERENCES library.issued_status(issued_id),
    FOREIGN KEY (return_book_isbn) REFERENCES library.books(isbn)
);
GO