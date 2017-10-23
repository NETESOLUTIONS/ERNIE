-- Session info
-- Aliases: current_database(), current_role
SELECT
  current_catalog, current_schema, current_user, current_query();

-- Active server processes
-- state: Current overall state of this backend. Possible values are:
-- * active: The backend is executing a query.
-- * idle: The backend is waiting for a new client command.
-- * idle in transaction: The backend is in a transaction, but is not currently executing a query.
-- * idle in transaction (aborted): This state is similar to idle in transaction, except one of the statements in the transaction caused an error.
-- * fastpath function call: The backend is executing a fast-path function.
-- * disabled: This state is reported if track_activities is disabled in this backend.
SELECT
  pid, query, /*state,*/ wait_event_type || ': ' || wait_event AS "Waiting on",
  to_char(current_timestamp - query_start, 'HH24:MI:SS') AS "Running Time", query_start, datname AS db, usename AS user,
  application_name, client_addr, client_hostname
FROM pg_stat_activity
WHERE query <> current_query()
  AND state = 'active'
ORDER BY query_start;
