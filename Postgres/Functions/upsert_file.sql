CREATE OR REPLACE FUNCTION upsert_file(toTable TEXT, dataFile TEXT, csvHeaders BOOLEAN = TRUE, delimiter CHAR(1) = ',', dataFormat TEXT = 'CSV', columnList TEXT = NULL, alterDeltaTable TEXT = NULL) RETURNS BIGINT AS $block$
--@formatter:off In order to match with stored line numbers avoid wrapping or formatting above.
/**
Inserts/updates records from a file.

Parameters:
  * toTable: destination table in the public schema
  ** The table must have all columns and the structure of the loaded CSV file.
  ** The table must have a single unique key: PK or UK (unique index).
  * dataFile: absolute path. Make sure that the file is readable by postgres user (pardicore group).
  * csvHeaders: does a CSV file have a line of headers?
  * delimiter: field delimiter
  * dataFormat: see COPY documentation for file format details.
  * columnList: columns present in a file. NULL means that all toTable columns must be present. Other columns in
  the toTable are populated with default values.
  * alterDeltaTable: clauses to add to the ALTER TABLE {toTable}_delta statement

Returns: number of records inserted or updated (<= # of CSV records because records are de-duplicated prior to upsert)
 */
DECLARE --
  -- Matches columns only in table keys e.g '(patent_num, md5((othercit)::text))' -> ['patent_num', 'othercit']
  key_column_re CONSTANT TEXT = '([( ])(\w+)([,)])';

  deltaTable TEXT = toTable || '_delta';
  columns TEXT;
  toTableKey TEXT;
  processed BIGINT;
BEGIN --
  --region CSV import to the delta table
  EXECUTE format($$
    CREATE TEMP TABLE %s
    AS
    SELECT *
    FROM %s
    WHERE FALSE$$, deltaTable, toTable);
  RAISE NOTICE 'Created %', deltaTable;

  --FIXME SQL injection is possible here
  IF alterDeltaTable IS NOT NULL THEN
    EXECUTE format($$
      ALTER TABLE %s
        %s$$, deltaTable, alterDeltaTable);
  END IF;

  EXECUTE format($$COPY %s%s FROM %L (FORMAT %s, HEADER %s, DELIMITER %L)$$, --
                 deltaTable, --
                 '(' || columnlist || ')', -- expression with NULL would collapse into NULL
                 dataFile, --
                 dataFormat, --
                 CASE csvheaders WHEN TRUE THEN 'ON' ELSE 'OFF' END, delimiter);
  GET DIAGNOSTICS processed = ROW_COUNT;
  RAISE NOTICE 'Imported % records to %', processed, deltaTable;
  --endregion

  -- Table key '(column or index expression 1, column or index expression 2, ...)'
  SELECT substring(pg_get_indexdef(index_pc.relname :: REGCLASS) FROM '\(.*\)') INTO toTableKey
  FROM pg_class table_pc
  JOIN pg_namespace pn ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
  -- pi.indrelid: The OID of the pg_class entry for the table this index is for
  JOIN pg_index pi ON pi.indrelid = table_pc.oid AND pi.indisunique
  -- pi.indexrelid: The OID of the pg_class entry for this index
  JOIN pg_class index_pc ON index_pc.oid = pi.indexrelid
  WHERE table_pc.relname = toTable;

  -- De-duplicate delta table to prevent the "ON CONFLICT DO UPDATE command cannot affect row a second time" error
  EXECUTE format($$
    DELETE
    FROM %s t1
    WHERE EXISTS(SELECT 1
                 FROM %1$s t2
                 WHERE %s = %s
                   AND t2.ctid > t1.ctid)$$, --
                 deltaTable, --
                 regexp_replace(toTableKey, key_column_re, '\1t1.\2\3', 'g'), --
                 regexp_replace(toTableKey, key_column_re, '\1t2.\2\3', 'g'));

  -- List of table columns
  SELECT string_agg(pa.attname, ', '
  ORDER BY pa.attnum) INTO columns
  FROM pg_class pc
  JOIN pg_namespace pn ON pn.oid = pc.relnamespace AND pn.nspname = 'public'
  -- pa.attrelid: The table this column belongs to
  -- Ordinary columns are numbered from 1 up. System columns, such as oid, have (arbitrary) negative numbers.
  JOIN pg_attribute pa ON pc.oid = pa.attrelid AND pa.attnum > 0
  WHERE pc.relname = toTable;

  EXECUTE format($$
    INSERT INTO %s
      SELECT *
      FROM %s
    ON CONFLICT %s
      DO UPDATE SET
        (%s) =
        (%s)$$, toTable, deltaTable, toTableKey, columns, regexp_replace(columns, '\w+', 'excluded.\&', 'g'));
  GET DIAGNOSTICS processed = ROW_COUNT;
  RAISE NOTICE 'Inserted/updated % records in %', processed, toTable;
  RETURN processed;
--@formatter:on
END; $block$ LANGUAGE plpgsql;