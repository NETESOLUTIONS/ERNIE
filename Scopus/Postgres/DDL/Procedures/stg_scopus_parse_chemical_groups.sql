\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_parse_chemical_groups(scopus_doc_xml XML)
  LANGUAGE plpgsql AS $$
DECLARE elsevier_biblio_db_division_chemical_src CONSTANT VARCHAR = 'esbd'; --
        cur RECORD;
BEGIN
  --scopus_chemical_groups
  FOR cur IN (
    SELECT
      scp, coalesce(chemicals_source, elsevier_biblio_db_division_chemical_src) AS chemicals_source, chemical_name,
      cas_registry_number
      FROM
        xmltable(XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce),
                 '//bibrecord/head/enhancement/chemicalgroup/chemicals/chemical/cas-registry-number' PASSING
                 scopus_doc_xml
                 COLUMNS scp BIGINT PATH '//item-info/itemidlist/itemid[@idtype="SCP"]', chemicals_source TEXT PATH '../chemicals[@source]', chemical_name TEXT PATH '../chemical-name', cas_registry_number TEXT PATH '.')
  ) LOOP
    INSERT INTO stg_scopus_chemical_groups(scp, chemicals_source, chemical_name, cas_registry_number)
    VALUES
      (cur.scp, cur.chemicals_source, cur.chemical_name, cur.cas_registry_number);
  END LOOP;
END; $$