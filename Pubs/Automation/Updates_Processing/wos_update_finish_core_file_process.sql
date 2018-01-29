\set ON_ERROR_STOP on
\set ECHO all

TRUNCATE TABLE new_wos_references;

UPDATE update_log_wos
SET last_updated = current_timestamp
WHERE id = (SELECT max(id)
FROM update_log_wos);