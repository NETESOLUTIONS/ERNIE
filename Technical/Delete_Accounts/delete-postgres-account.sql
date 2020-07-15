\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

SET script.deleted_user = :'deletedUser';

DO $block$
  BEGIN
    IF EXISTS(SELECT 1
              FROM pg_authid
              WHERE
                rolname = current_setting('script.deleted_user')
              LIMIT 1) THEN
      EXECUTE format($$DROP SCHEMA IF EXISTS %s$$, current_setting('script.deleted_user'));

      EXECUTE format($$REASSIGN OWNED BY %s TO ernie_admin$$, current_setting('script.deleted_user'));

      EXECUTE format($$REVOKE ALL ON ALL TABLES IN SCHEMA public FROM %s$$, current_setting('script.deleted_user'));
      EXECUTE format($$REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM %s$$, current_setting('script.deleted_user'));

      EXECUTE format($$ALTER DEFAULT PRIVILEGES
                FOR USER %s IN SCHEMA public
                REVOKE ALL ON TABLES FROM PUBLIC$$, current_setting('script.deleted_user'));
      EXECUTE format($$ALTER DEFAULT PRIVILEGES
                FOR USER %s IN SCHEMA public
                REVOKE ALL ON SEQUENCES FROM PUBLIC$$, current_setting('script.deleted_user'));

      EXECUTE format($$DROP USER %s$$, current_setting('script.deleted_user'));
    ELSE
      RAISE WARNING 'User % doesn''t exist', current_setting('script.deleted_user');
    END IF;
  END $block$;