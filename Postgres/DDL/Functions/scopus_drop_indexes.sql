create procedure scopus_disable_indexes(schema_name text)
    language plpgsql
as
$$
DECLARE
    statements cursor for
        select indexname
        from pg_indexes
        where schemaname = $1
          and indexname not like '%pk'
          and indexname not like '%pkey';
BEGIN
    for statement in statements
        LOOP
            EXECUTE 'DROP INDEX ' || quote_ident(statement.indexname);
        end loop;
END;
$$;