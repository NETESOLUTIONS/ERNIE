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
      EXECUTE format($$DROP SCHEMA IF EXISTS %s CASCADE$$, current_setting('script.deleted_user'));

      EXECUTE format($$REASSIGN OWNED BY %s TO postgres$$, current_setting('script.deleted_user'));

      /*
      Any privileges granted to the given roles on objects in the current database and on shared objects
      (databases, tablespaces) will be revoked.
      */
      EXECUTE format($$DROP OWNED BY %s$$, current_setting('script.deleted_user'));

      EXECUTE format($$DROP USER %s$$, current_setting('script.deleted_user'));
    ELSE
      RAISE WARNING 'User % doesn''t exist', current_setting('script.deleted_user');
    END IF;
  END $block$;