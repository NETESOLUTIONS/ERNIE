DO $$
  DECLARE statements CURSOR FOR SELECT tablename
                                  FROM pg_tables
                                 WHERE tablename LIKE 'stg_scopus%' AND schemaname = current_schema();
  BEGIN
    FOR statement IN statements LOOP
      EXECUTE 'TRUNCATE TABLE ' || quote_ident(statement.tablename) || ' CASCADE';
    END LOOP;
  END ; $$;
