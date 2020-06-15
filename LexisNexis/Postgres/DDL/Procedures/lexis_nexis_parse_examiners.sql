\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

--Parse examiners
CREATE OR REPLACE PROCEDURE lexis_nexis_parse_examiners(input_xml XML) AS
$$
  BEGIN
    INSERT INTO lexis_nexis_examiners(country_code,doc_number,kind_code,primary_last_name, primary_first_name,primary_department,
                                      assistant_last_name, assistant_first_name, assistant_department)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.primary_last_name,
          xmltable.primary_first_name,
          xmltable.primary_department,
          xmltable.assistant_last_name,
          xmltable.assistant_first_name,
          xmltable.assistant_department
     FROM
     XMLTABLE('//bibliographic-data/examiners' PASSING input_xml
              COLUMNS
                country_code TEXT PATH '../publication-reference/document-id/country' NOT NULL,
                doc_number TEXT PATH '../publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH '../publication-reference/document-id/kind' NOT NULL,
                primary_last_name TEXT PATH 'primary-examiner/last-name',
                primary_first_name TEXT PATH 'primary-examiner/first-name',
                primary_department TEXT PATH 'primary-examiner/department',
                assistant_last_name TEXT PATH 'assistant-examiner/last-name',
                assistant_first_name TEXT PATH 'assistant-examiner/first-name',
                assistant_department TEXT PATH 'assistant-examiner/department'
                )
    ON CONFLICT (country_code, doc_number, kind_code)
    DO UPDATE SET primary_last_name=excluded.primary_last_name,primary_first_name=excluded.primary_first_name,
    primary_department=excluded.primary_department,assistant_last_name=excluded.assistant_last_name,
    assistant_first_name=excluded.assistant_first_name,assistant_department=excluded.assistant_department,
    last_updated_time=now();

  END;
$$
LANGUAGE plpgsql;
