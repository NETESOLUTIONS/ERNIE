SHOW search_path;

-- Session info
-- Aliases: current_catalog = current_database(), current_role = current_user
SELECT current_database(), current_schema, current_schemas(TRUE) AS search_path, current_user;

-- Waiting on locks
SELECT
  coalesce(blocking_pl.relation :: REGCLASS :: TEXT, blocking_pl.locktype) AS locked_item,
  now() - blocked_psa.query_start AS waiting_duration,
  blocked_psa.pid AS blocked_pid,
  blocked_psa.query AS blocked_query,
  blocked_pl.mode AS blocked_mode,
  blocking_psa.pid AS blocking_pid,
  blocking_psa.query AS blocking_query,
  blocking_pl.mode AS blocking_mode
FROM pg_locks blocked_pl
JOIN pg_stat_activity blocked_psa ON blocked_pl.pid = blocked_psa.pid
JOIN pg_locks blocking_pl ON (((blocking_pl.transactionid = blocked_pl.transactionid) OR
    (blocking_pl.relation = blocked_pl.relation AND blocking_pl.locktype = blocked_pl.locktype)) AND
      blocked_pl.pid != blocking_pl.pid)
JOIN pg_stat_activity blocking_psa ON blocking_pl.pid = blocking_psa.pid AND blocking_psa.datid = blocked_psa.datid
WHERE NOT blocked_pl.granted AND blocking_psa.datname = current_database();

SELECT *
FROM running;

-- Terminate any query via SIGINT. Find a query pid in pg_stat_activity.
SELECT pg_cancel_backend(:pid);

-- Cancel *all* running queries. Check them before running.
SELECT pid, query, pg_cancel_backend(pid) AS cancelled
FROM running;

-- Terminate any query via SIGTERM. Find a query pid in pg_stat_activity.
SELECT pg_terminate_backend(:pid);

-- All running queries' and vacuum progress data
SELECT *
FROM pg_stat_activity
LEFT JOIN pg_stat_progress_vacuum pspv USING (pid)
WHERE /* not this query */ pid <> pg_backend_pid() AND state = 'active'
ORDER BY query_start;