---------------------------------------------------------
-- Library Management System
-- SQL Queries
---------------------------------------------------------

---------------------------------------------------------
-- TASK 1
-- Insert a New Book
---------------------------------------------------------

INSERT INTO books
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

---------------------------------------------------------
-- TASK 2
-- Update Member Address
---------------------------------------------------------

UPDATE members
SET member_address='123 Oak St'
WHERE member_id='C103';

---------------------------------------------------------
-- TASK 3
-- Delete an Issued Record
---------------------------------------------------------

DELETE FROM issued_status
WHERE issued_id='IS121';

---------------------------------------------------------
-- TASK 4
-- Books Issued by Employee E101
---------------------------------------------------------

SELECT *
FROM issued_status
WHERE issued_emp_id='E101';

---------------------------------------------------------
-- TASK 5
-- Members who issued more than one book
---------------------------------------------------------

SELECT
issued_member_id,
COUNT(*) AS total_books
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(*)>1;

---------------------------------------------------------
-- TASK 6
-- CTAS - Book Issue Count
---------------------------------------------------------

CREATE TABLE book_issued_cnt AS

SELECT
b.isbn,
b.book_title,
COUNT(i.issued_id) AS issue_count
FROM books b
JOIN issued_status i
ON b.isbn=i.issued_book_isbn
GROUP BY
b.isbn,
b.book_title;

---------------------------------------------------------
-- TASK 7
-- Classic Books
---------------------------------------------------------

SELECT *
FROM books
WHERE category='Classic';

---------------------------------------------------------
-- TASK 8
-- Rental Income by Category
---------------------------------------------------------

SELECT
b.category,
SUM(b.rental_price) AS total_income
FROM books b
JOIN issued_status i
ON b.isbn=i.issued_book_isbn
GROUP BY b.category;

---------------------------------------------------------
-- TASK 9
-- Members Registered in Last 180 Days
---------------------------------------------------------

SELECT *
FROM members
WHERE reg_date>=CURRENT_DATE-INTERVAL '180 days';

---------------------------------------------------------
-- TASK 10
-- Employees with Branch Manager
---------------------------------------------------------

SELECT
e.emp_id,
e.emp_name,
e.position,
e.salary,
b.branch_id,
b.branch_address,
e2.emp_name AS manager
FROM employees e
JOIN branch b
ON e.branch_id=b.branch_id
JOIN employees e2
ON e2.emp_id=b.manager_id;

---------------------------------------------------------
-- TASK 11
-- Expensive Books
---------------------------------------------------------

CREATE TABLE expensive_books AS

SELECT *
FROM books
WHERE rental_price>8;

---------------------------------------------------------
-- TASK 12
-- Books Not Returned
---------------------------------------------------------

SELECT
i.*,
r.*
FROM issued_status i
LEFT JOIN return_status r
ON i.issued_id=r.issued_id
WHERE r.return_date IS NULL;

---------------------------------------------------------
-- TASK 13
-- Overdue Books
---------------------------------------------------------

SELECT
i.issued_member_id,
m.member_name,
b.book_title,
i.issued_date,
CURRENT_DATE-i.issued_date AS overdue_days
FROM issued_status i
JOIN members m
ON i.issued_member_id=m.member_id
JOIN books b
ON i.issued_book_isbn=b.isbn
LEFT JOIN return_status r
ON i.issued_id=r.issued_id
WHERE
r.return_date IS NULL
AND CURRENT_DATE-i.issued_date>30;

---------------------------------------------------------
-- TASK 14
-- Update Book Status after Return
---------------------------------------------------------

UPDATE books b
SET status='yes'
FROM issued_status i
JOIN return_status r
ON i.issued_id=r.issued_id
WHERE b.isbn=i.issued_book_isbn;

---------------------------------------------------------
-- TASK 15
-- Branch Performance Report
---------------------------------------------------------

CREATE TABLE branch_reports AS

SELECT
br.branch_id,
br.manager_id,
COUNT(i.issued_id) AS total_books_issued,
COUNT(r.return_id) AS total_books_returned,
SUM(b.rental_price) AS total_revenue
FROM issued_status i
JOIN employees e
ON i.issued_emp_id=e.emp_id
JOIN branch br
ON e.branch_id=br.branch_id
LEFT JOIN return_status r
ON i.issued_id=r.issued_id
JOIN books b
ON i.issued_book_isbn=b.isbn
GROUP BY
br.branch_id,
br.manager_id;

---------------------------------------------------------
-- TASK 16
-- Active Members (Last 6 Months)
---------------------------------------------------------

CREATE TABLE active_members AS

SELECT *
FROM members
WHERE member_id IN
(
SELECT DISTINCT issued_member_id
FROM issued_status
WHERE issued_date>=CURRENT_DATE-INTERVAL '6 months'
);

---------------------------------------------------------
-- Additional Analysis Queries
---------------------------------------------------------

---------------------------------------------------------
-- Available Books
---------------------------------------------------------

SELECT *
FROM books
WHERE status='yes';

---------------------------------------------------------
-- Books by Category
---------------------------------------------------------

SELECT
category,
COUNT(*) AS total_books
FROM books
GROUP BY category;

---------------------------------------------------------
-- Total Revenue
---------------------------------------------------------

SELECT
SUM(rental_price) AS revenue
FROM books b
JOIN issued_status i
ON b.isbn=i.issued_book_isbn;

---------------------------------------------------------
-- Employee-wise Books Issued
---------------------------------------------------------

SELECT
e.emp_name,
COUNT(*) AS books_processed
FROM employees e
JOIN issued_status i
ON e.emp_id=i.issued_emp_id
GROUP BY e.emp_name
ORDER BY books_processed DESC;

---------------------------------------------------------
-- Most Frequently Issued Books
---------------------------------------------------------

SELECT
b.book_title,
COUNT(*) AS issue_count
FROM books b
JOIN issued_status i
ON b.isbn=i.issued_book_isbn
GROUP BY b.book_title
ORDER BY issue_count DESC;

---------------------------------------------------------
-- Books Never Issued
---------------------------------------------------------

SELECT
b.book_title
FROM books b
LEFT JOIN issued_status i
ON b.isbn=i.issued_book_isbn
WHERE i.issued_id IS NULL;

---------------------------------------------------------
-- Members with No Book Issues
---------------------------------------------------------

SELECT
m.member_name
FROM members m
LEFT JOIN issued_status i
ON m.member_id=i.issued_member_id
WHERE i.issued_id IS NULL;