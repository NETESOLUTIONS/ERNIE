\set ON_ERROR_STOP on
\set ECHO all

-- REASSIGN OWNED BY :user TO :admin;
DROP SCHEMA IF EXISTS :"user";
DROP USER IF EXISTS :"user";

CREATE USER :"user" WITH PASSWORD :'password';
CREATE SCHEMA :"user" AUTHORIZATION :"user";