-- Use DVD Rental Database

-- Select from one of the table from database

SELECT * FROM film;

-- EXPLAIN 
-- SHOWS THE EXECUTIPON PLAN OF STATEMENT
/*
OPTIONS		DEFAULT 	VALUE

ANALYZE	- 	FALSE		BOOLEAN	
VERBOSE	-	TRUE		BOOLEAN
COSTS	-	TRUE		BOOLEAN
BUFFERS	-	FALSE		BOOLEAN
TIMING	-	TRUE		BOOLEAN
FORMAT	-	TEXT		TEXT | JSON | XML | YAML
*/

EXPLAIN SELECT * FROM film;

-- OUTPUT -> "Seq Scan on film  (cost=0.00..64.00 rows=1000 width=384)"

-- COST- ESTIMATE STARTUP COST
-- COST- (disk pages read * seq_page_cost) + (rows scanned * cpu_tuples_cost)
-- ROWS- NUMBER OF ROWS RETURNED
-- WIDTH- ESTIMATED AVERAGE WIDTH OF THE ROW OUTPUT (BYTES)

SELECT relpages AS "Disk Page Read", reltuples AS "Rows Scanned"
FROM pg_class
WHERE relname = 'film';

-- seq_page_cost - ESTIMATE OF THE COST OF DISK PAGE FETCH, DEFAULT 1
-- cpu_tuples_cost - ESTIMATE OF THE COST OF PROCESSING EACH ROW, DEFAULT 0.01

-- SEQ SCAN (COST IS MUCH HIGHER)
EXPLAIN SELECT * FROM film
WHERE film_id > 40;

-- INDEX SCAN USING PKEY (COST IS MUCH LOWER)
EXPLAIN SELECT * FROM film
WHERE film_id < 40;

EXPLAIN SELECT * FROM film
WHERE film_id < 40 AND rating = 'R';


-- EXPLAIN ANALYZE
-- ACTUALLY RUNS QUERY AND DISPLAY ACTUAL COST AND TIME (PLANNING TIME & EXECUTION TIME)

EXPLAIN ANALYZE 
SELECT * FROM film;

EXPLAIN ANALYZE
SELECT * FROM film
WHERE film_id < 40;

EXPLAIN ANALYZE
SELECT * FROM film
WHERE film_id < 40 AND rating = 'R';

/*
EXPLAIN VERBOSE
	DISPLAYS VARIOUS OPERATIONS HAPPENING AT NODE LEVEL IN QUERY 

EXPLAIN COSTS
	DISPLAY VARIOUS COSTS ASSOCIATED FOR BUILDING QUERY PLAN

EXPLAIN BUFFER
	DISPLAYS STATUS OF MEMOMRY BUFFER IN POSTGRES

EXPLAIN TIMING
	DISPLAYS EXECUTIONS TIME FOR QUERY AND NODE

EXPLAIN FORMAT
	DISPLAYS RESULT IN TEXT OR ANY DIFFERENT FORMAT 
*/

EXPLAIN ANALYZE
SELECT * FROM film
WHERE length = 100;

CREATE INDEX idx_film_length ON film(length);

DROP INDEX idx_film_length;

-- Multicolumn Indexes (Maximum 32 columns)

/*
Cover Index 
	Index containing all columns needed for a query
*/

EXPLAIN ANALYZE
SELECT film_id, title, length, rating, rental_rate
FROM filM
WHERE length BETWEEN 60 AND 100 AND rating = 'G';

CREATE INDEX idx_film_length_rating ON film(length, rating); 
CREATE INDEX idx_film_rating_length ON film(rating, length); 

DROP INDEX idx_film_length_rating

CREATE INDEX idx_film_cover ON film(rating, length, title, rental_rate)

EXPLAIN ANALYZE 
SELECT title, length, rating, rental_rate
FROM film 
WHERE length BETWEEN 60 AND 70 AND rating = 'G';


-- REINDEX
REINDEX INDEX idx_film_cover;
REINDEX TABLE film;

-- UNIQUE INDEX
-- ENFORCE UNIQUENESS OF A COLUMN'S VALUE

-- POSTGRESQL AUTOMATICALLY CREATES A UNIQUE INDEX WHEN A UNIQUE CONSTRAINT OR PRIMARY KEY IS DEFINED ON THE TABLE.

-- DISPLAYS ALL THE INDEX OF FILM TABLE
SELECT idx.indrelid :: regclass AS table_name,
	i.relname AS index_name,
	idx.indisunique AS is_unique,
	idx.indisprimary AS is_primary
FROM pg_index AS idx JOIN pg_class AS i
ON i.oid = idx.indexrelid
WHERE idx.indrelid = 'film' :: regclass;


-- FUNCTION IS WHERE CLUASE IS COSTLY 
EXPLAIN ANALYZE
SELECT * FROM film
WHERE lower(title) = lower('arizona bang');

CREATE INDEX film_title_lower ON film(lower(title));


-- PARTIAL INDEX
CREATE INDEX film_less_hour ON film(length)
WHERE length < 60;

EXPLAIN ANALYZE
SELECT * FROM film
WHERE length = 40;

EXPLAIN ANALYZE
SELECT * FROM film
WHERE length = 80;


/*
Tips For Populate Large Database

- Disabling autocommit will improve performance for large amount of INSERTS.
- Copy statement is the fastest way to insert or retrive data in various format.
- Always drop indexes before large data import and recreate indexes afterword.
- Analyze tables to improve overall performance with updating statistics.
*/