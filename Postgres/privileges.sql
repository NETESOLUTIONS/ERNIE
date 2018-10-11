-- Lists grants on a table of a view
SELECT grantee, privilege_type, string_agg(table_name, ', ') AS tables
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
GROUP BY grantee, privilege_type
ORDER BY grantee, privilege_type;

-- Lists grants on a table of a view
SELECT *
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name = :table_name
ORDER BY grantee;

-- Roles of a user
SELECT rolname
FROM pg_user
JOIN pg_auth_members
  ON (pg_user.usesysid = pg_auth_members.member)
JOIN pg_roles
  ON (pg_roles.oid = pg_auth_members.roleid)
WHERE pg_user.usename = :user;

GRANT SELECT ON public.nlm_idconverter TO PUBLIC;