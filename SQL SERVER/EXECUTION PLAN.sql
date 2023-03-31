-- CREATE TABLE AND IT HAS 1 MILION RECORDS

CREATE TABLE people
(
    id bigint identity(1,1) primary key,
    first_name varchar(100),
    last_name varchar(100),
    sex varchar(10),
    email varchar(100),
    dob date,
    job_title varchar(200),
);
GO

-- SET STATISTICS TIME, IO AND PRIOFILE ON

SET STATISTICS TIME ON
SET STATISTICS IO ON
SET STATISTICS PROFILE ON
GO

-- CLUSTERED INDEX SCAN
-- Primary Key id is clusteres index
SELECT * FROM people;
GO

SELECT TOP 500 * FROM people ORDER BY id;
GO

-- CLUSTERED INDEX SEEK
SELECT * FROM people WHERE id BETWEEN 0 AND 500;
-- SELECT * FROM people WHERE id <= 500;
-- SELECT First_Name FROM people where First_Name like 'Al%';
GO

-- CREATE NON CLUSTERED INDEX 
CREATE NONCLUSTERED INDEX non_clu_firstname_lastname 
ON people(First_Name, Last_Name);
GO

-- NON CLUSTERED INDEX SCAN
SELECT First_Name, Last_Name FROM people;
GO

-- NON CLUSTERED INDEX SEEK
SELECT id, First_Name, Last_Name FROM people WHERE First_Name = 'John' and Last_Name = 'Gates';
GO

-- NON CLUSTERED INDEX SEEK (With KEY LOOKUP)
SELECT First_Name, Last_Name, Sex FROM people WHERE First_Name = 'John' and Last_Name = 'Gates';
GO


-- Sort (Order by) is Expensive

-- Cost 97% for Sort operation (Estimated subtree cost - 552.695)
SELECT * FROM people ORDER BY Email;
GO

-- Create non clustered index on Email
CREATE NONCLUSTERED INDEX nonc_email ON people(Email);
GO

-- Sort operation after creating index reduced cost (Estimated subtree cost - 227.787)
SELECT * FROM people ORDER BY Email;
GO


--JOINS

-- Nested Join
SELECT title, category_id FROM film INNER JOIN film_category ON film.film_id = film_category.film_id WHERE title like '%ak';
GO

-- Merge Join
SELECT category_id, length FROM film INNER JOIN film_category ON film.film_id = film_category.film_id WHERE length < 100;
GO

-- Hash Join
SELECT category_id, length FROM film INNER JOIN film_category ON film.film_id = film_category.film_id WHERE length between 100 and 200;
GO

-- Optimizer knows the best join for each query, it will decide which is best and use it.


-- COVERING INDEX

-- A covering index is an index that contains all columns referenced in the query. A clustered index is a covering index by definition, but this is used for non clusrtered indexes.
-- If it is covering index than SQL engine does not have to look up in clustered index.

SELECT id, First_Name, Last_Name FROM people;
GO

-- It is an example of covering index scan, because we have clustered index on First name and Last name column, so it does not contain lookup.
SELECT First_Name, Last_Name, Job_Title FROM people where First_Name = 'John' and Last_Name = 'Gates';
GO


-- INDEXES WITH INCLUDED COLUMNS

CREATE NONCLUSTERED INDEX non_clu_firstname_lastname_job 
ON people(First_Name, Last_Name) INCLUDE (Job_Title);
GO

SELECT id, First_Name, Last_Name, Job_Title FROM people where First_Name = N'Taylor' and Last_Name = N'Reed';
GO

-- Usage of Function in WHERE clause make query costly

SELECT id, First_Name, Last_Name FROM people WHERE First_Name = 'Adam' -- (Estimated subtree cost - 0.0068481);
GO

SELECT id, First_Name, Last_Name FROM people WHERE LTRIM(RTRIM(First_Name)) = 'Adam' -- (Estimated subtree cost - 5.22476);
GO

-- For eliminate this cost or reduce cost, we can do one thing.
-- Create a new column for which we want to use in where clause and create non clustered index on it.

/*
ALTER TABLE people 
ADD first_name_trim AS LTRIM(RTRIM(First_Name))

CREATE NON CLUSTERED INDEX non_clu_first_name_trim
ON people (first_name_trim, <other columns>)
*/


-- AVOID SELECT *

SELECT * FROM people; -- (75%)
GO

SELECT id, First_Name, Last_Name FROM people; -- (25%)
GO


-- EXISTS vs IN vs JOINS

-- EXISTS (22%)
SELECT customer_id, payment_id, amount FROM payment 
WHERE EXISTS (
	SELECT * FROM customer 
	WHERE payment.customer_id = customer.customer_id );
GO

-- IN (22%)
SELECT customer_id, payment_id, amount FROM payment 
WHERE customer_id IN (
	SELECT customer_id FROM customer );
GO
	
-- JOIN (55%)
SELECT customer.customer_id, payment.payment_id, payment.amount 
FROM payment JOIN customer 
ON payment.customer_id = customer.customer_id;
GO


--NOT EXISTS vs NOT IN vs NOT JOINS

-- NOT EXISTS (50%)
SELECT customer_id, payment_id, amount FROM payment 
WHERE NOT EXISTS (
	SELECT * FROM customer 
	WHERE payment.customer_id = customer.customer_id );
GO

-- NOT IN (50%)
SELECT customer_id, payment_id, amount FROM payment 
WHERE customer_id NOT IN (
	SELECT customer_id FROM customer );
GO

-- NOT JOIN (0%)
SELECT customer.customer_id, payment.payment_id, payment.amount 
FROM payment JOIN customer 
ON payment.customer_id = customer.customer_id
WHERE customer.customer_id IS NULL;
GO

-- If there are null values in tables that we are combining, then NOT IN perform worst in case.


-- ORDER OF TABLES IN JOIN

/*
Outer Join -> Order matters
Inner Join / Cross Join -> Order doesn't matters
*/

