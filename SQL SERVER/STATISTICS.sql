-- Historical Query Plans (Estimated plans or if not found than removed from cache memory)
SELECT * FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_query_plan(plan_handle)
CROSS APPLY sys.dm_exec_sql_text(plan_handle)

-- Query store (Another way for prev plans)
SELECT CAST(p.query_plan AS XML), *
FROM sys.query_store_query	AS q
INNER JOIN sys.query_store_plan AS p
ON q.query_id = p.query_id

-- By default SQL Server create and update statistics on index
DBCC SHOW_STATISTICS('people', 'PK_people')