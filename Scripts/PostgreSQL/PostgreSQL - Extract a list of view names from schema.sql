-- PostgreSQL
-- Get a simple list of view names from schema
select 
table_schema as schema_name,
table_name as view_name 
from information_schema.views 
where table_schema = 'SCHEMA NAME'
order by table_name

-- get a list of views from schema with sql statement to get row count (combine them in excel)
select
	'select count(*) c, \'' || x || ' \' v from ' || x as xx
from
	(
	select
		TABLE_CATALOG || '.' || TABLE_SCHEMA || '."' || TABLE_NAME || '"' x
	from
		DATABASE_NAME.INFORMATION_SCHEMA.VIEWS
	where
		table_schema = 'SCHEMA NAME'
    )

-- sql statement to get row count for every view from the above sql statment (need to combine them in excel) 