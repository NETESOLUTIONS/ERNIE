--\set ON_ERROR_STOP on
--\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path TO shreya;

-- Abstract parsing
CREATE OR REPLACE PROCEDURE lexis_nexis_parse_patent_families(input_xml XML) AS
$$
  BEGIN
    INSERT INTO lexis_nexis_patent_families(earliest_date, family_id, family_type)
    SELECT
          xmltable.earliest_date,
          xmltable.family_id,
          xmltable.family_type

     FROM
     XMLTABLE('//patent-family' PASSING input_xml
              COLUMNS
                --below come from higher level nodes
                earliest_date TEXT PATH '//@earliest-date' NOT NULL,
                family_id TEXT PATH '//@family-id' NOT NULL,
                family_type TEXT PATH '*[contains("domestic") or contains("main") or contains("complete") or contains("extended")]' NOT NULL

              )
    ON CONFLICT
    DO UPDATE SET earliest_date = excluded.earliest_date, family_id = excluded.family_id, family_type = excluded.family_type;

  END;
$$
LANGUAGE plpgsql;
