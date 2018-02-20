-- Session info
-- Aliases: current_database(), current_role
SELECT
  current_catalog, current_schema, current_user, current_query();

-- Locks
SELECT
  coalesce(blocking_pl.relation::REGCLASS::TEXT, blocking_pl.locktype) AS locked_item,
  now() - blocked_psa.query_start AS waiting_duration, blocked_psa.pid AS blocked_pid,
  blocked_psa.query AS blocked_query, blocked_pl.mode AS blocked_mode, blocking_psa.pid AS blocking_pid,
  blocking_psa.query AS blocking_query, blocking_pl.mode AS blocking_mode
FROM pg_catalog.pg_locks blocked_pl
  JOIN pg_stat_activity blocked_psa ON blocked_pl.pid = blocked_psa.pid
  JOIN pg_catalog.pg_locks blocking_pl ON (((blocking_pl.transactionid = blocked_pl.transactionid) OR
    (blocking_pl.relation = blocked_pl.relation AND blocking_pl.locktype = blocked_pl.locktype)) AND
    blocked_pl.pid != blocking_pl.pid)
  JOIN pg_stat_activity blocking_psa ON blocking_pl.pid = blocking_psa.pid
    AND blocking_psa.datid = blocked_psa.datid
WHERE NOT blocked_pl.granted
  AND blocking_psa.datname = current_database();

-- Terminate any query. Find a query pid in pg_stat_activity.
SELECT pg_cancel_backend(:pid);