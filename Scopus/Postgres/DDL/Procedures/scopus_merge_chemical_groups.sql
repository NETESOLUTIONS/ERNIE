set search_path=':';
\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create or replace procedure stg_scopus_merge_chemical_groups()
    language plpgsql
as
$$
BEGIN
    INSERT INTO scopus_chemical_groups(scp, chemicals_source, chemical_name, cas_registry_number)
    select scp,
           chemicals_source,
           chemical_name,
           cas_registry_number
    from stg_scopus_chemical_groups
    ON CONFLICT (scp, chemical_name, cas_registry_number) DO UPDATE SET chemicals_source=excluded.chemicals_source;
END
$$;