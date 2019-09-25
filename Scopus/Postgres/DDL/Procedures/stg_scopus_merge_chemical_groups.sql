\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_merge_chemical_groups()
  LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO scopus_chemical_groups(scp, chemicals_source, chemical_name, cas_registry_number)
  SELECT DISTINCT scp, chemicals_source, chemical_name, cas_registry_number
    FROM stg_scopus_chemical_groups
      ON CONFLICT (scp, chemical_name, cas_registry_number) DO UPDATE SET chemicals_source=excluded.chemicals_source;
END $$;