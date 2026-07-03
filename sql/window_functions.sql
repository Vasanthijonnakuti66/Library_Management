---------------------------------------------------------
-- WINDOW FUNCTIONS
-- Library Management System
---------------------------------------------------------

---------------------------------------------------------
-- 1. Assign a unique row number to every book
---------------------------------------------------------

SELECT
    book_title,
    category,
    rental_price,
    ROW_NUMBER() OVER(
        ORDER BY rental_price DESC
    ) AS row_num
FROM books;


---------------------------------------------------------
-- 2. Most expensive book in each category
---------------------------------------------------------

SELECT *
FROM
(
SELECT
    category,
    book_title,
    rental_price,
    ROW_NUMBER() OVER(
        PARTITION BY category
        ORDER BY rental_price DESC
    ) AS rn
FROM books
)t
WHERE rn = 1;


---------------------------------------------------------
-- 3. Top 2 expensive books in each category
---------------------------------------------------------

SELECT *
FROM
(
SELECT
    category,
    book_title,
    rental_price,
    ROW_NUMBER() OVER(
        PARTITION BY category
        ORDER BY rental_price DESC
    ) AS rn
FROM books
)t
WHERE rn <= 2;


---------------------------------------------------------
-- 4. Rank books by rental price
---------------------------------------------------------

SELECT
    book_title,
    category,
    rental_price,
    RANK() OVER(
        ORDER BY rental_price DESC
    ) AS book_rank
FROM books;


---------------------------------------------------------
-- 5. Highest priced books in every category
---------------------------------------------------------

SELECT *
FROM
(
SELECT
    category,
    book_title,
    rental_price,
    RANK() OVER(
        PARTITION BY category
        ORDER BY rental_price DESC
    ) AS rk
FROM books
)t
WHERE rk = 1;


---------------------------------------------------------
-- 6. Dense Rank books
---------------------------------------------------------

SELECT
    book_title,
    category,
    rental_price,
    DENSE_RANK() OVER(
        ORDER BY rental_price DESC
    ) AS dense_rank
FROM books;


---------------------------------------------------------
-- 7. Highest priced books using Dense Rank
---------------------------------------------------------

SELECT *
FROM
(
SELECT
    category,
    book_title,
    rental_price,
    DENSE_RANK() OVER(
        PARTITION BY category
        ORDER BY rental_price DESC
    ) AS rk
FROM books
)t
WHERE rk = 1;


---------------------------------------------------------
-- 8. Rank employees based on books processed
---------------------------------------------------------

SELECT
    e.emp_id,
    e.emp_name,
    COUNT(*) AS books_processed,
    RANK() OVER(
        ORDER BY COUNT(*) DESC
    ) AS employee_rank
FROM issued_status ist
JOIN employees e
ON ist.issued_emp_id = e.emp_id
GROUP BY
e.emp_id,
e.emp_name;


---------------------------------------------------------
-- 9. Top 3 employees
---------------------------------------------------------

SELECT *
FROM
(
SELECT
    e.emp_id,
    e.emp_name,
    COUNT(*) AS books_processed,
    RANK() OVER(
        ORDER BY COUNT(*) DESC
    ) AS rk
FROM issued_status ist
JOIN employees e
ON ist.issued_emp_id = e.emp_id
GROUP BY
e.emp_id,
e.emp_name
)t
WHERE rk <= 3;


---------------------------------------------------------
-- 10. Latest issued book for every member
---------------------------------------------------------

SELECT *
FROM
(
SELECT
    issued_member_id,
    issued_book_name,
    issued_date,
    ROW_NUMBER() OVER(
        PARTITION BY issued_member_id
        ORDER BY issued_date DESC
    ) AS rn
FROM issued_status
)t
WHERE rn = 1;


---------------------------------------------------------
-- 11. Previous issue date (LAG)
---------------------------------------------------------

SELECT
    issued_member_id,
    issued_date,
    LAG(issued_date)
    OVER(
        PARTITION BY issued_member_id
        ORDER BY issued_date
    ) AS previous_issue
FROM issued_status;


---------------------------------------------------------
-- 12. Next issue date (LEAD)
---------------------------------------------------------

SELECT
    issued_member_id,
    issued_date,
    LEAD(issued_date)
    OVER(
        PARTITION BY issued_member_id
        ORDER BY issued_date
    ) AS next_issue
FROM issued_status;


---------------------------------------------------------
-- 13. Running rental revenue
---------------------------------------------------------

SELECT
    ist.issued_date,
    b.book_title,
    b.rental_price,
    SUM(b.rental_price)
    OVER(
        ORDER BY ist.issued_date
    ) AS running_revenue
FROM issued_status ist
JOIN books b
ON ist.issued_book_isbn = b.isbn;


---------------------------------------------------------
-- 14. Average rental price by category
---------------------------------------------------------

SELECT
    book_title,
    category,
    rental_price,
    AVG(rental_price)
    OVER(
        PARTITION BY category
    ) AS category_average
FROM books;


---------------------------------------------------------
-- 15. Difference from category average
---------------------------------------------------------

SELECT
    book_title,
    category,
    rental_price,
    rental_price -
    AVG(rental_price)
    OVER(
        PARTITION BY category
    ) AS difference_from_average
FROM books;


---------------------------------------------------------
-- 16. Cumulative books issued
---------------------------------------------------------

SELECT
    issued_date,
    COUNT(*)
    OVER(
        ORDER BY issued_date
    ) AS cumulative_books
FROM issued_status;


---------------------------------------------------------
-- 17. Highest paid employee in every branch
---------------------------------------------------------

SELECT *
FROM
(
SELECT
    emp_id,
    emp_name,
    branch_id,
    salary,
    ROW_NUMBER()
    OVER(
        PARTITION BY branch_id
        ORDER BY salary DESC
    ) AS rn
FROM employees
)t
WHERE rn = 1;


---------------------------------------------------------
-- 18. Top 3 salaries in every branch
---------------------------------------------------------

SELECT *
FROM
(
SELECT
    emp_id,
    emp_name,
    branch_id,
    salary,
    RANK()
    OVER(
        PARTITION BY branch_id
        ORDER BY salary DESC
    ) AS rk
FROM employees
)t
WHERE rk <= 3;


---------------------------------------------------------
-- 19. Highest priced book in every category
---------------------------------------------------------

SELECT
    category,
    book_title,
    rental_price,
    FIRST_VALUE(book_title)
    OVER(
        PARTITION BY category
        ORDER BY rental_price DESC
    ) AS highest_priced_book
FROM books;


---------------------------------------------------------
-- 20. Lowest priced book in every category
---------------------------------------------------------

SELECT
    category,
    book_title,
    rental_price,
    LAST_VALUE(book_title)
    OVER(
        PARTITION BY category
        ORDER BY rental_price
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
    ) AS lowest_priced_book
FROM books;