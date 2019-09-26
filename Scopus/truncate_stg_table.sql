DO
$$
    DECLARE
        statements cursor for
            select tablename
            from pg_tables
            where tablename like 'stg_scopus%'
              and schemaname = 'jenkins' ;
    BEGIN
        for statement in statements
            LOOP
                EXECUTE 'TRUNCATE TABLE ' || quote_ident(statement.tablename) || ' CASCADE';
            end loop;
    END ;
$$;
