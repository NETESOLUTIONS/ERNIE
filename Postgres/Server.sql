-- Server version
SHOW SERVER_VERSION;

-- Version details
SELECT version();

-- Installed extensions
SELECT *
FROM pg_extension
ORDER BY extname;

SELECT *
FROM pg_available_extensions
ORDER BY name;

-- Install available extension
CREATE EXTENSION postgres_fdw;

-- Foreign servers
SELECT *
FROM information_schema.foreign_servers;

-- Define foreign servers
CREATE SERVER pardi_prod FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '10.253.56.8', dbname 'pardi', PORT '5432');

-- User mapping for each user
-- Trusted system user doesn't require password
CREATE USER MAPPING FOR pardi_admin SERVER pardi_prod OPTIONS (USER 'pardi_admin');

DROP USER MAPPING IF EXISTS FOR dk SERVER pardi_prod;
CREATE USER MAPPING FOR dk SERVER pardi_prod OPTIONS (USER 'dk', PASSWORD :'password');

-- Create schema
DROP SCHEMA IF EXISTS foreign_prod CASCADE;
CREATE SCHEMA foreign_prod AUTHORIZATION pardi_admin;

-- Import foreign schema
IMPORT FOREIGN SCHEMA public FROM SERVER pardi_prod INTO foreign_prod;

SELECT *
FROM foreign_prod.cg_uids;