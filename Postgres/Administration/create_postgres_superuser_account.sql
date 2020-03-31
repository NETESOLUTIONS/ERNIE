\set ON_ERROR_STOP on
\set ECHO all

--@formatter:off
SET script.dropped_user = :'user';

DO $block$ --
  DECLARE
    sql CONSTANT TEXT := $$ALTER DEFAULT PRIVILEGES
            FOR USER %I IN SCHEMA public
            REVOKE SELECT ON %s FROM PUBLIC$$;
  BEGIN
    IF EXISTS(SELECT 1
              FROM pg_roles pr
              WHERE rolname = current_setting('script.dropped_user')) THEN --
      EXECUTE format(sql, current_setting('script.dropped_user'), 'TABLES');
      EXECUTE format(sql, current_setting('script.dropped_user'), 'SEQUENCES');
      EXECUTE format($$REASSIGN OWNED BY %I TO ernie_admin$$, current_setting('script.dropped_user'));
    END IF;
  END $block$;
--@formatter:on
DROP SCHEMA IF EXISTS :"user";
DROP USER IF EXISTS :"user";

CREATE USER :"user" WITH SUPERUSER PASSWORD :'password';
CREATE SCHEMA :"user" AUTHORIZATION :"user";

-- region Grant read-only privileges to all users on future objects, manually created by superusers
ALTER DEFAULT PRIVILEGES --
FOR USER :"user"
IN SCHEMA public --
GRANT SELECT ON TABLES TO PUBLIC;

ALTER DEFAULT PRIVILEGES --
FOR USER :"user"
IN SCHEMA public --
GRANT SELECT ON SEQUENCES TO PUBLIC;
-- endregion

