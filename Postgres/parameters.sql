-- Reload server configuration
SELECT CASE WHEN pg_reload_conf()
  THEN 'Reloaded.'
       ELSE 'Failed to reload!' END;

-- ## Current configuration ##

-- All parameters
SHOW ALL;

-- A single parameter
SHOW temp_tablespaces;
SHOW search_path;

-- Server configuration
SELECT
  seqno,
  name,
  setting,
  applied,
  error
FROM pg_file_settings
ORDER BY name;

-- ## Set server defaults ##

--region Require server restart
ALTER SYSTEM SET listen_addresses = '*';

ALTER SYSTEM SET log_statement = 'none';

ALTER SYSTEM SET max_locks_per_transaction = 128;

ALTER SYSTEM SET shared_buffers = '10GB';

ALTER SYSTEM SET work_mem = '1GB';
--endregion

--region Requires configuration reload or server restart
ALTER SYSTEM SET temp_tablespaces = 'temp_tbs';
--endregion

-- ## Set user defaults (require session restart) ##
ALTER ROLE current_user SET temp_tablespaces = 'pardi_private_tbs';

ALTER ROLE current_user SET temp_tablespaces = DEFAULT;

-- ## Set session default ##
-- SELECT set_config('temp_tablespaces', 'pardi_private_tbs', false);
SET temp_tablespaces = 'pardi_private_tbs';