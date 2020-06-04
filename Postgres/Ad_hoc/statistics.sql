-- Number of rows per object
SELECT parent_pc.relname, sum(coalesce(partition_pc.reltuples, parent_pc.reltuples)) AS total_rows
  FROM
    pg_class parent_pc
      JOIN pg_namespace pn ON pn.oid = parent_pc.relnamespace AND pn.nspname = current_schema
      LEFT JOIN pg_inherits pi ON pi.inhparent = parent_pc.oid
      LEFT JOIN pg_class partition_pc ON partition_pc.oid = pi.inhrelid
 WHERE parent_pc.relname LIKE :pattern AND parent_pc.relkind IN ('r', 'p') AND NOT parent_pc.relispartition
 GROUP BY parent_pc.oid, parent_pc.relname;

-- Statistics for the current schema
SELECT *
  FROM pg_stats
 WHERE schemaname = current_schema AND tablename LIKE :pattern
 ORDER BY tablename;