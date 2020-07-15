-- Users = roles
SELECT *
  FROM pg_authid
 ORDER BY rolname;

-- Does user exist?
SELECT 1
  FROM pg_authid
 WHERE rolname = :user_name;

-- End user list
SELECT rolname AS login
  FROM pg_authid
    -- Excluding Postgres system users and super-users
 WHERE rolcanlogin AND NOT rolsuper
 ORDER BY rolname;

-- Groups = roles without the login privilege
SELECT *
  FROM pg_group;

-- region Grant read-only privileges to all users on future objects, manually created by superusers
ALTER DEFAULT PRIVILEGES --
-- Owners below would grant automatically on objects created in the future
  FOR USER chackoge, dk, shreya, wenxi --
  IN SCHEMA public --
  GRANT SELECT ON TABLES TO PUBLIC;

ALTER DEFAULT PRIVILEGES --
-- Owners below would grant automatically on objects created in the future
  FOR USER chackoge, dk, shreya, wenxi --
  IN SCHEMA public --
  GRANT SELECT ON SEQUENCES TO PUBLIC;
-- endregion

GRANT SELECT ON ALL TABLES IN SCHEMA public TO PUBLIC;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO PUBLIC;

-- Rename
ALTER USER :old_account RENAME TO :account;

-- region End user creation
CREATE USER :account WITH PASSWORD :password_in_single_quotes;
CREATE SCHEMA :account AUTHORIZATION :account;
-- endregion

-- Set password
ALTER USER :account WITH PASSWORD :'password';

-- region Delete user account and objects

DROP SCHEMA IF EXISTS :deletedUser CASCADE;
REASSIGN OWNED BY :deletedUser TO ernie_admin;
ALTER DEFAULT PRIVILEGES FOR USER :deletedUser IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR USER :deletedUser IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC;
DROP USER :deletedUser;

-- endregion

-- region Graceful user removal

SET script.deleted_user = :'deletedUser';

DO $block$
  BEGIN
    IF EXISTS(SELECT 1 FROM pg_authid WHERE rolname = current_setting('script.deleted_user') LIMIT 1) THEN
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

-- endregion

-- region Move objects to a private schema
DO $block$
  DECLARE c RECORD;
  BEGIN
    FOR c IN (
      SELECT table_pc.relname AS table_name
        FROM pg_class table_pc
        JOIN pg_namespace pn
             ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
        JOIN pg_authid pa
             ON pa.oid = table_pc.relowner AND pa.rolname = :user
       WHERE table_pc.relkind = 'r'
       ORDER BY 1
    ) LOOP
      RAISE NOTICE USING MESSAGE = c.table_name;
      EXECUTE format($$ ALTER TABLE public.%I SET SCHEMA %I $$, c.table_name, :user);
    END LOOP;
  END $block$;
-- endregion
