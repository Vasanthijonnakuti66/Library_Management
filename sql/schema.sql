---------------------------------------------------------
-- Library Management System
-- PostgreSQL Database Schema
---------------------------------------------------------

DROP DATABASE IF EXISTS "Library_Management";

CREATE DATABASE "Library_Management";

---------------------------------------------------------
-- Branch Table
---------------------------------------------------------

DROP TABLE IF EXISTS branch CASCADE;

CREATE TABLE branch
(
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(30),
    contact_no VARCHAR(15)
);

---------------------------------------------------------
-- Employees Table
---------------------------------------------------------

DROP TABLE IF EXISTS employees CASCADE;

CREATE TABLE employees
(
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(30) NOT NULL,
    position VARCHAR(30),
    salary DECIMAL(10,2),
    branch_id VARCHAR(10),

    CONSTRAINT fk_employee_branch
        FOREIGN KEY (branch_id)
        REFERENCES branch(branch_id)
);

---------------------------------------------------------
-- Members Table
---------------------------------------------------------

DROP TABLE IF EXISTS members CASCADE;

CREATE TABLE members
(
    member_id VARCHAR(10) PRIMARY KEY,
    member_name VARCHAR(30) NOT NULL,
    member_address VARCHAR(30),
    reg_date DATE
);

---------------------------------------------------------
-- Books Table
---------------------------------------------------------

DROP TABLE IF EXISTS books CASCADE;

CREATE TABLE books
(
    isbn VARCHAR(50) PRIMARY KEY,
    book_title VARCHAR(80) NOT NULL,
    category VARCHAR(30),
    rental_price DECIMAL(10,2),
    status VARCHAR(10),
    author VARCHAR(30),
    publisher VARCHAR(30)
);

---------------------------------------------------------
-- Issued Status Table
---------------------------------------------------------

DROP TABLE IF EXISTS issued_status CASCADE;

CREATE TABLE issued_status
(
    issued_id VARCHAR(10) PRIMARY KEY,

    issued_member_id VARCHAR(10),

    issued_book_name VARCHAR(80),

    issued_date DATE,

    issued_book_isbn VARCHAR(50),

    issued_emp_id VARCHAR(10),

    CONSTRAINT fk_issue_member
        FOREIGN KEY (issued_member_id)
        REFERENCES members(member_id),

    CONSTRAINT fk_issue_book
        FOREIGN KEY (issued_book_isbn)
        REFERENCES books(isbn),

    CONSTRAINT fk_issue_employee
        FOREIGN KEY (issued_emp_id)
        REFERENCES employees(emp_id)
);

---------------------------------------------------------
-- Return Status Table
---------------------------------------------------------

DROP TABLE IF EXISTS return_status CASCADE;

CREATE TABLE return_status
(
    return_id VARCHAR(10) PRIMARY KEY,

    issued_id VARCHAR(10),

    return_book_name VARCHAR(80),

    return_date DATE,

    return_book_isbn VARCHAR(50),

    CONSTRAINT fk_return_issue
        FOREIGN KEY (issued_id)
        REFERENCES issued_status(issued_id),

    CONSTRAINT fk_return_book
        FOREIGN KEY (return_book_isbn)
        REFERENCES books(isbn)
);