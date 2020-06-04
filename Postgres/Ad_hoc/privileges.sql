GRANT SELECT ON ALL TABLES IN SCHEMA public TO PUBLIC;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO PUBLIC;

GRANT SELECT ON public.:table_name TO PUBLIC;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- List grants on a table of a view
SELECT *
  FROM information_schema.role_table_grants
 WHERE table_schema = 'public' AND table_name = :table_name
 ORDER BY grantee;

-- List grants ny grantee and privilege
SELECT grantee, privilege_type, string_agg(table_name, ', ') AS tables
  FROM information_schema.role_table_grants
 WHERE table_schema = 'public'
 GROUP BY grantee, privilege_type
 ORDER BY grantee, privilege_type;

-- List objects in a public schema without PUBLIC SELECT
SELECT table_name, table_type, pa.rolname AS owner
  FROM
    information_schema.tables t
      JOIN pg_class table_pc ON table_pc.relname = t.table_name
      JOIN pg_namespace pn ON pn.oid = table_pc.relnamespace AND pn.nspname = 'public'
      JOIN pg_authid pa ON pa.oid = table_pc.relowner
 WHERE t.table_schema = 'public' AND NOT has_table_privilege('public', table_pc.oid, 'SELECT')
 ORDER BY table_name;

-- Roles of a user
SELECT rolname
  FROM
    pg_user
      JOIN pg_auth_members ON (pg_user.usesysid = pg_auth_members.member)
      JOIN pg_roles ON (pg_roles.oid = pg_auth_members.roleid)
 WHERE pg_user.usename = :user;