\set ON_ERROR_STOP on

\pset tuples_only on
\pset format unaligned

/* Existing tables: only those tables and views are shown that the current user has access to
(by way of being the owner or having some privilege). */
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name SIMILAR TO :'tablePattern';