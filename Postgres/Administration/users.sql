-- Users = roles
SELECT *
FROM pg_authid
ORDER BY rolname;

-- Does user exist?
SELECT 1
FROM pg_authid
WHERE rolname = :user_name;

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

-- region User decommissioning
--@formatter:off
SET script.dropped_user = :'dropped_user';

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
    END IF;
  END $block$;
--@formatter:on

REASSIGN OWNED BY :user TO ernie_admin;
DROP SCHEMA :enduser;
DROP USER :enduser;
-- endregion

-- region Graceful user removal
SET SESSION.deleteduser = :deletedUser;

DO $block$ --
  DECLARE --
    deleteduser VARCHAR := current_setting('session.deletedUser');
  BEGIN
    --
    IF EXISTS(SELECT 1
              FROM pg_authid
              WHERE rolname = deleteduser) THEN --
      EXECUTE format($$ DROP OWNED BY %I CASCADE $$, deleteduser);
      DROP USER deleteduser;
    ELSE --
      RAISE WARNING 'User `%` does not exist', deleteduser; --
    END IF;
  END $block$;
-- endregion

-- region Move objects to a private schema
DO $block$
  DECLARE
    c RECORD;
  BEGIN
    FOR c in (
      SELECT
        table_pc.relname AS table_name
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
