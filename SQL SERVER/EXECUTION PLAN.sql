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
)

-- SET STATISTICS TIME, IO AND PRIOFILE ON

SET STATISTICS TIME ON
SET STATISTICS IO ON
SET STATISTICS PROFILE ON


-- CLUSTERED INDEX SCAN
-- Primary Key id is clusteres index
SELECT * FROM people

SELECT TOP 500 * FROM people ORDER BY id


-- CLUSTERED INDEX SEEK
SELECT * FROM people WHERE id BETWEEN 0 AND 500
SELECT * FROM people WHERE id <= 500
SELECT First_Name FROM people where First_Name like 'Al%'


-- CREATE NON CLUSTERED INDEX 
CREATE NONCLUSTERED INDEX non_clu_firstname_lastname 
ON people(First_Name, Last_Name)


-- NON CLUSTERED INDEX SCAN
SELECT id, First_Name, Last_Name FROM people


-- NON CLUSTERED INDEX SEEK
SELECT id, First_Name, Last_Name FROM people WHERE First_Name = 'John' and Last_Name = 'Gates'


-- NON CLUSTERED INDEX SEEK (With KEY LOOKUP)
SELECT * FROM people WHERE First_Name = 'John' and Last_Name = 'Gates'


-- Sort (Order by) is Expensive

-- Cost 97% for Sort operation (Estimated subtree cost - 552.695)
SELECT * FROM people ORDER BY Email

-- Create non clustered index on Email
CREATE NONCLUSTERED INDEX nonc_email ON people(Email)

-- Sort operation after creating index reduced cost (Estimated subtree cost - 227.787)
SELECT * FROM people ORDER BY Email


--JOINS

-- Nested Join
SELECT title, category_id FROM film INNER JOIN film_category ON film.film_id = film_category.film_id WHERE title like '%ak'

-- Merge Join
SELECT category_id, length FROM film INNER JOIN film_category ON film.film_id = film_category.film_id WHERE length < 100

-- Hash Join
SELECT category_id, length FROM film INNER JOIN film_category ON film.film_id = film_category.film_id WHERE length between 100 and 200

-- Optimizer knows the best join for each query, it will decide which is best and use it.

