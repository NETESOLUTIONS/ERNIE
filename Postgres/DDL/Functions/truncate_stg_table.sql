create or replace procedure truncate_stg_table(schema_name text)
	language plpgsql
as $$
DECLARE
    statements cursor for
    select tablename from pg_tables
    where tablename like 'stg_scopus%' and schemaname=$1;
BEGIN
for statement in statements LOOP
    EXECUTE 'TRUNCATE TABLE ' || quote_ident(statement.tablename) || ' CASCADE';
    end loop;
END;
$$;