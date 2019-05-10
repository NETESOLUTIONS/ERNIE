\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- WARNING: Double-check the selected schema path. You're about to lose all Scopus data!

TRUNCATE scopus_classification_lookup CASCADE;
TRUNCATE scopus_sources CASCADE;
TRUNCATE scopus_conference_events CASCADE;
TRUNCATE scopus_publication_groups CASCADE;
