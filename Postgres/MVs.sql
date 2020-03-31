-- List all MVs
SELECT schemaname AS schema_name, matviewname AS view_name, matviewowner AS owner, ispopulated AS is_populated,
  definition AS DDL
  FROM pg_matviews
 ORDER BY schema_name, view_name;