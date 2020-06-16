\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';


--Parse us agents
CREATE OR REPLACE PROCEDURE lexis_nexis_parse_us_agents(input_xml XML) AS
$$
  BEGIN
    INSERT INTO lexis_nexis_us_agents(country_code,doc_number,kind_code,sequence,agent_type,language,agent_name,last_name,first_name)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.sequence,
          xmltable.agent_type,
          xmltable.language,
          xmltable.agent_name,
          xmltable.last_name,
          xmltable.first_name
     FROM
     xmltable('//bibliographic-data/parties/agents/agent' PASSING input_xml
              COLUMNS
                country_code TEXT PATH '../../../publication-reference/document-id/country' NOT NULL,
                doc_number TEXT PATH '../../../publication-reference/document-id/doc-number' NOT NULL,
                kind_code TEXT PATH '../../../publication-reference/document-id/kind' NOT NULL,
                sequence SMALLINT PATH '@sequence',
                agent_type TEXT PATH '@rep-type',
                language TEXT PATH 'addressbook[1]/@lang',
                agent_name TEXT PATH 'addressbook[1]/name',
                last_name TEXT PATH 'addressbook[1]/last-name',
                first_name TEXT PATH 'addressbook[1]/first-name'
                )
    ON CONFLICT (country_code, doc_number, kind_code, sequence)
    DO UPDATE SET agent_type=excluded.agent_type,language=excluded.language,agent_name=excluded.agent_name,
    last_name=excluded.last_name,first_name=excluded.first_name,last_updated_time=now();
  END;
$$
LANGUAGE plpgsql;
