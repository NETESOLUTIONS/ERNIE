\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

\include_relative main_ddl.sql
\include_relative wos_ddl_triggers.sql
\include_relative wos_mvs.sql