-- See Config/Postgres/server_config.sql for server configuration

\include_relative running_view.sql
\include_relative Functions/upsert_file.sql

\include_relative ../../Scopus/Postgres/DDL/scopus_ddl.sql

\include_relative ../../Trials/Postgres/DDL/ct_ddl.sql