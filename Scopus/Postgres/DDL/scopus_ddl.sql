\set ON_ERROR_STOP on
\set ECHO all

\if :{?schema}
SET search_path = :schema;
\endif

\include_relative scopus_enums.sql
\include_relative scopus_tables.sql
\include_relative stg_table_ddl.sql
\include_relative scopus_triggers.sql
\include_relative scopus_routines.sql

\include_relative graph_ddl.sql