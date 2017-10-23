-- Lists grants on a table of a view
SELECT *
FROM information_schema.role_table_grants
WHERE table_schema='pg_catalog'
-- For pg_file_settings view
AND table_name='pg_file_settings'
ORDER BY grantee;

-- Roles of a user
SELECT rolname
FROM pg_user
  JOIN pg_auth_members ON (pg_user.usesysid = pg_auth_members.member)
  JOIN pg_roles ON (pg_roles.oid = pg_auth_members.roleid)
WHERE pg_user.usename = 'dk';
