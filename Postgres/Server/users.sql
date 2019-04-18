-- Users = roles
SELECT *
FROM pg_authid
ORDER BY rolname;

-- Groups = roles without the login privilege
SELECT *
FROM pg_group;

CREATE USER avon SUPERUSER;
CREATE USER chackoge SUPERUSER;
CREATE USER sitaram SUPERUSER;
CREATE USER siyu SUPERUSER;

CREATE USER jenkins SUPERUSER;
ALTER USER jenkins SUPERUSER;

-- region Create non-superuser and grant all privileges
CREATE USER jenkins;

GRANT ALL ON SCHEMA public TO jenkins;
GRANT ALL ON ALL TABLES IN SCHEMA public TO jenkins;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO jenkins;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO jenkins;

CREATE SCHEMA AUTHORIZATION jenkins;
-- endregion

ALTER DEFAULT PRIVILEGES --
-- All active users who can create public objects would grant theses privileges in the future
FOR USER pardi_admin, avon, chackoge, dk --
IN SCHEMA public --
GRANT ALL ON TABLES TO jenkins;

ALTER DEFAULT PRIVILEGES --
-- All active users who can create public objects would grant theses privileges in the future
FOR USER pardi_admin, avon, chackoge, dk --
IN SCHEMA public --
GRANT ALL ON SEQUENCES TO jenkins;

ALTER DEFAULT PRIVILEGES --
-- All active users who can create public objects would grant theses privileges in the future
FOR USER pardi_admin, avon, chackoge, dk --
IN SCHEMA public --
GRANT ALL ON FUNCTIONS TO jenkins;

ALTER DEFAULT PRIVILEGES --
-- All active users who can create public objects would grant theses privileges in the future
FOR USER pardi_admin, avon, chackoge, dk --
IN SCHEMA public --
GRANT ALL ON TYPES TO jenkins;
-- endregion

-- Set password
ALTER USER current_user WITH PASSWORD :password;