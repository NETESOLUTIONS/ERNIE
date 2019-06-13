\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- WARNING: Double-check the selected schema path. You're about to lose all Scopus data!

TRUNCATE lexis_nexis_patents CASCADE;
