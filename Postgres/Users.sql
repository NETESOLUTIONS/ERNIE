SELECT *
FROM pg_authid
ORDER BY rolname;

ALTER USER current_user WITH PASSWORD :'password';