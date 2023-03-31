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
SELECT First_Name, Last_Name FROM people


-- NON CLUSTERED INDEX SEEK
SELECT id, First_Name, Last_Name FROM people WHERE First_Name = 'John' and Last_Name = 'Gates'


-- NON CLUSTERED INDEX SEEK (With KEY LOOKUP)
		SELECT First_Name, Last_Name, Sex FROM people WHERE First_Name = 'John' and Last_Name = 'Gates'


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


-- COVERING INDEX

-- A covering index is an index that contains all columns referenced in the query. A clustered index is a covering index by definition, but this is used for non clusrtered indexes.
-- If it is covering index than SQL engine does not have to look up in clustered index.

SELECT id, First_Name, Last_Name FROM people

-- It is an example of covering index scan, because we have clustered index on First name and Last name column, so it does not contain lookup.
SELECT First_Name, Last_Name, Job_Title FROM people where First_Name = 'John' and Last_Name = 'Gates'


-- INDEXES WITH INCLUDED COLUMNS

CREATE NONCLUSTERED INDEX non_clu_firstname_lastname_job 
ON people(First_Name, Last_Name) INCLUDE (Job_Title)

SELECT id, First_Name, Last_Name, Job_Title FROM people where First_Name = N'Taylor' and Last_Name = N'Reed'



-- Usage of Function in WHERE clause make query costly

SELECT id, First_Name, Last_Name FROM people WHERE First_Name = 'Adam' -- (Estimated subtree cost - 0.0068481)

SELECT id, First_Name, Last_Name FROM people WHERE LTRIM(RTRIM(First_Name)) = 'Adam' -- (Estimated subtree cost - 5.22476)

-- For eliminate this cost or reduce cost, we can do one thing.
-- Create a new column for which we want to use in where clause and create non clustered index on it.

/*
ALTER TABLE people 
ADD first_name_trim AS LTRIM(RTRIM(First_Name))

CREATE NON CLUSTERED INDEX non_clu_first_name_trim
ON people (first_name_trim, <other columns>)
*/