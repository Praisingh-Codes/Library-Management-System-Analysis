## Library Management System: Complete SQL Analytics, ETL, and Reporting Workflow

![Project Banner](resources/library%20management%20system%20analysis%20poster%20image.png)

#### Project Overview

This project delivers a full SQL-driven analytical system for managing library operations.

It covers everything from database design, idempotent data seeding, CRUD operations, CTAS summaries, automation via stored procedures, and analytical reporting.

A structured sequence of SQL modules performs:

- Database & schema creation

- Idempotent data loading & validation

- Book issuing & return automation

- Overdue book tracking

- Member & employee analytics

- Branch performance reporting

- High-risk member identification

- CTAS summary table generation

Complete member, book & branch-level analytical insights

Each module is stored as:

✔ SQL script (logic)

✔ CSV/Excel export (report output)

#### Tech Stack

- SQL Server (T-SQL)

- Transactional & Analytical SQL

- Stored Procedures (Automation)

- CTAS (SELECT INTO)

- Excel/CSV Reporting Files

- Joins, Aggregations, Subqueries, Window Functions (optional)

#### Entity-Relationship Diagram

![ER Diagram](resources/entity-relationship%20diagram%20image.png)

#### Project Structure

-- Database Creation & Schema Setup

- Create database

- Build library schema

- Define tables: books, members, employees, branch, issued_status, return_status

- Add constraints & relationships

✔ Outputs: 00_create_database_and_schemas.rpt

--Idempotent Data Seeding & Validation

- Seed all master tables using IF NOT EXISTS

- Auto-create missing columns (is_returned, returned_date, book_quality)

- Synchronize issued/return tables

- Validation queries for referential integrity

✔ Outputs: 01_idempotent_data_seeding_and_validation_(i–vi).csv

-- CRUD Operations & Data Manipulation

Includes:

- Insert book/member/employee

- Update member data

- Delete issued records

- Retrieve issued books by employee

- Identify heavy borrowers

- Practical task-based DML operations

✔ Outputs: 02_crud_operations_and_data_manipulation_(i–vii).csv

-- CTAS Summary Table Creation

Creation of automated summary tables using SELECT INTO:

- book_issued_cnt

- expensive_books

✔ Outputs: 03_ctas_summary_table_creation.csv

-- Data Analysis & Insights

Analytical SQL for:

- Category-level insights

- Rental income analysis

- Recently registered members

- Employee–branch management join

- Books not returned

✔ Outputs: 04_data_analysis_and_findings_(i–vi).csv

-- Overdue Books Analysis

- Identify overdue books (> 30 days)

- Join with members & books

- Compute days overdue

- Action-oriented reporting

✔ Outputs: 05_overdue_books_analysis.csv

-- Book Return Processing & Status Synchronization

A complete returns pipeline:

- Auto-update book status

- Auto-update issued records

- Handle duplicates

- Fix inconsistent states

- Insert return records with quality scoring

- Stored procedure: library.add_return_records

✔ Outputs: 06_book_return_processing_and_status_synchronization_(i–iv).csv

-- Branch Performance Report (CTAS)

Branch-wise analytics:

- Total books issued

- Total books returned

- Total rental revenue

- Manager mapping

Creates:

library.branch_reports

✔ Outputs: 07_branch_performance_report.csv

-- Active Members CTAS

- Identify members who issued books within the past 2 years

- Create summary table: library.active_members

✔ Outputs: 08_active_members_ctas.csv

-- Top Employees by Books Issued

Employee-level analytics:

- Highest activity employees

- Branch context

- Ranking and performance measurement

✔ Outputs: 09_top_employees_by_books_issued.csv

-- High-Risk Members Analysis

Detect members returning damaged books:

Identify repeat offenders (> 2 damaged returns)

Book-level damage analysis

Map members → issued → returns

✔ Outputs: 10_high_risk_members_analysis_(i–ii).csv

-- Issue Book Procedure (Automation)

Production-level stored procedure: library.issue_book

- Validates member, employee, ISBN

- Fixes incorrect book status

- Prevents double-issuance

- Inserts issued record

- Updates availability

✔ Outputs: 11_issue_book_procedure_(i–ii).csv

-- Overdue Books & Fines Report (CTAS)

Creates a fines & overdue summary table:

library.overdue_books_report

Includes:

- Total books issued

- Number of overdue books

- Fine calculation (₹0.50 × extra days)

- Member-enriched reporting

✔ Outputs: 12_overdue_books_and_fines_report_(i–ii).csv

#### Key SQL Concepts Used

-- Data Engineering

- CREATE TABLE, Foreign Keys

- Idempotent DDL & DML

- INFORMATION_SCHEMA validation

-- Analytical SQL

- Aggregations: COUNT(), SUM(), AVG()

- Date functions: GETDATE(), DATEADD(), DATEDIFF()

- CTEs & Subqueries

- CASE-based segmentation

- CTAS (SELECT INTO)

-- Automation

- Stored Procedures: add_return_records, issue_book

- Auto-fix for inconsistencies

- Synchronization of issued/return tables

#### How to Use This Project

- Run 00_create_database_and_schemas.sql

- Execute idempotent data seeding module

- Run CRUD and CTAS scripts (Modules 03–04)

- Run analytical modules (05–13)

- Review output CSVs (in /report)

- Use stored procedures to simulate real workflows

#### Business Impact

This system enables libraries to:

- Track overdue books & collect fines

- Identify valuable or high-risk members

- Analyze branch-level performance

- Monitor employee productivity

- Automate issuing & returning workflows

- Build interactive dashboards from the outputs

- Maintain clean, validated, consistent data

#### Contributing

Contributions are welcome! 

If you’d like to improve this project, follow the steps below:

🔹 1. Fork the Repository

Click the **Fork** button in the top-right corner of this page.

🔹 2. Create a New Branch

    git checkout -b feature/your-feature-name

🔹 3. Make Your Changes

Add enhancements, fix bugs, or improve documentation.

🔹 4. Commit Your Changes

    git commit -m "Add: your detailed message here"

🔹 5. Push to Your Branch

    git push origin feature/your-feature-name

🔹 6. Open a Pull Request

Submit a PR describing:

- What you changed

- Why the change is needed

- Any relevant context or screenshots
