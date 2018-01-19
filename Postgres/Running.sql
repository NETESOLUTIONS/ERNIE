-- Active server processes
-- state: Current overall state of this backend. Possible values are:
-- * active: The backend is executing a query.
-- * idle: The backend is waiting for a new client command.
-- * idle in transaction: The backend is in a transaction, but is not currently executing a query.
-- * idle in transaction (aborted): This state is similar to idle in transaction, except one of the statements in
-- the transaction caused an error.
-- * fastpath function call: The backend is executing a fast-path function.
-- * disabled: This state is reported if track_activities is disabled in this backend.
SELECT pid, query, /*state,*/ wait_event_type || ': ' || wait_event AS "Waiting on",
  to_char(current_timestamp - query_start, 'HH24:MI:SSs') AS "Time", to_char(query_start, 'HH24:MI TZ') AS "Started",
  --datname AS db,
  usename AS user, application_name AS "App",
  -- host(inet): extract IP address as text
  coalesce(host(client_addr), 'server') AS "From"
  -- client_hostname
FROM pg_stat_activity
WHERE pid <> pg_backend_pid() -- not this query
  AND state = 'active'
ORDER BY query_start;