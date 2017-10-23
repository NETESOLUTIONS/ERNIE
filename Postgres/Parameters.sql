-- Current parameter value
-- SELECT current_setting('temp_tablespaces');
show temp_tablespaces;

-- Server configuration
SELECT seqno, name, setting, applied, error
FROM pg_file_settings
ORDER BY name;

-- ### Initial setup ###

-- Requires server restart
ALTER SYSTEM
   SET listen_addresses = '*';

ALTER SYSTEM
   SET log_statement = 'none';

-- Requires server restart
ALTER SYSTEM
   SET shared_buffers = '10GB';

ALTER SYSTEM
   SET work_mem = '1GB';
   
-- Set server default (requires configuration reload or server restart)
ALTER SYSTEM
   SET temp_tablespaces = 'pardi_private_tbs';

-- ## Set user default (requires session restart) ##
ALTER ROLE CURRENT_USER
   SET temp_tablespaces = 'pardi_private_tbs';

ALTER ROLE CURRENT_USER
   SET temp_tablespaces = DEFAULT;

-- Set session parameter
-- SELECT set_config('temp_tablespaces', 'pardi_private_tbs', false);
SET temp_tablespaces = 'pardi_private_tbs';
