\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path TO public;

CREATE PROCEDURE lexis_nexis_parse_patent_families(input_xml xml) AS
$$
BEGIN
    INSERT INTO lexis_nexis_patent_families(earliest_date, family_id, family_type)
    SELECT
          xmltable.earliest_date,
          xmltable.family_id,
          xmltable.family_type

     FROM
     XMLTABLE('//patent-family/*[substring(name(), string-length(name()) - 6) = "-family"]' PASSING input_xml
              COLUMNS
                --below come from higher level nodes
                earliest_date DATE PATH '@earliest-date',
                family_id INT PATH '@family-id' NOT NULL ,
                family_type family_type PATH 'substring-before(name(.), "-family")' NOT NULL
              )
    ON CONFLICT DO NOTHING ;
  END;
$$ LANGUAGE plpgsql;
