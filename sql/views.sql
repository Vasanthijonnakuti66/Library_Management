---------------------------------------------------------
-- VIEWS
-- Library Management System
---------------------------------------------------------

---------------------------------------------------------
-- View 1: Available Books
-- Shows all books currently available for issue
---------------------------------------------------------

CREATE OR REPLACE VIEW available_books AS
SELECT
    isbn,
    book_title,
    category,
    rental_price,
    author,
    publisher
FROM books
WHERE status = 'yes';


---------------------------------------------------------
-- View 2: Active Members
-- Members who issued at least one book in last 6 months
---------------------------------------------------------

CREATE OR REPLACE VIEW active_members AS
SELECT
    *
FROM members
WHERE member_id IN
(
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL '6 months'
);


---------------------------------------------------------
-- View 3: Overdue Books
-- Members who have not returned books within 30 days
---------------------------------------------------------

CREATE OR REPLACE VIEW overdue_books AS
SELECT
    ist.issued_member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
    CURRENT_DATE - ist.issued_date AS overdue_days
FROM issued_status ist
JOIN members m
ON ist.issued_member_id = m.member_id
JOIN books b
ON ist.issued_book_isbn = b.isbn
LEFT JOIN return_status rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_date IS NULL
AND CURRENT_DATE - ist.issued_date > 30;


---------------------------------------------------------
-- View 4: Branch Performance
-- Books issued, returned and revenue by branch
---------------------------------------------------------

CREATE OR REPLACE VIEW branch_performance AS
SELECT
    br.branch_id,
    br.manager_id,
    COUNT(ist.issued_id) AS books_issued,
    COUNT(rs.return_id) AS books_returned,
    SUM(b.rental_price) AS total_revenue
FROM issued_status ist
JOIN employees e
ON ist.issued_emp_id = e.emp_id
JOIN branch br
ON e.branch_id = br.branch_id
LEFT JOIN return_status rs
ON ist.issued_id = rs.issued_id
JOIN books b
ON ist.issued_book_isbn = b.isbn
GROUP BY
    br.branch_id,
    br.manager_id;


---------------------------------------------------------
-- View 5: Employee Performance
-- Number of books processed by every employee
---------------------------------------------------------

CREATE OR REPLACE VIEW employee_performance AS
SELECT
    e.emp_id,
    e.emp_name,
    e.position,
    e.branch_id,
    COUNT(ist.issued_id) AS books_processed
FROM employees e
LEFT JOIN issued_status ist
ON e.emp_id = ist.issued_emp_id
GROUP BY
    e.emp_id,
    e.emp_name,
    e.position,
    e.branch_id;