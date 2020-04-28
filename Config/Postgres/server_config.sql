\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

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