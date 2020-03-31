-- Reload server configuration
SELECT
  CASE
    WHEN pg_reload_conf() THEN 'Reloaded.'
    ELSE 'Failed to reload!'
  END;

-- ## Current configuration ##

-- All parameters by category. Reload configuration first for pending_restart to be correct.
SELECT pending_restart, name, setting, unit, category, context, source, min_val, max_val, enumvals
FROM pg_settings
ORDER BY category, name;

-- All parameters
SHOW ALL;

-- A single parameter: psql
SHOW temp_tablespaces;
SHOW search_path;
SHOW default_tablespace;

-- A single parameter: SQL
SELECT current_setting('temp_tablespaces');
SELECT current_setting('search_path');

-- Server configuration
SELECT seqno, name, setting, applied, error
FROM pg_file_settings
ORDER BY name;

-- ## Set server defaults ##

--region Require server restart
ALTER SYSTEM SET listen_addresses = '*';

ALTER SYSTEM SET max_locks_per_transaction = 256;

ALTER SYSTEM SET shared_buffers = '10GB';
--endregion

--region Requires configuration reload or server restart
ALTER SYSTEM SET log_statement = 'ddl';

ALTER SYSTEM SET work_mem = '1GB';

ALTER SYSTEM SET maintenance_work_mem = '2GB';

ALTER SYSTEM SET max_wal_size = '2GB';

ALTER SYSTEM SET temp_tablespaces = 'temp_tbs';

--region Client Connection Defaults
ALTER SYSTEM SET default_tablespace = 'user_tbs';

-- SELECT *
-- FROM pg_timezone_names;

ALTER SYSTEM RESET TimeZone;

SELECT now();
--endregion
--endregion

-- ## Set user defaults (require session restart) ##
ALTER ROLE current_user SET temp_tablespaces = 'temp_tbs';

ALTER ROLE current_user SET temp_tablespaces = DEFAULT;

ALTER USER :user RESET default_tablespace;

-- ## Set session default ##
SET temp_tablespaces = 'temp_tbs';

SET client_min_messages = 'WARNING';