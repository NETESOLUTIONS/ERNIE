\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';


--Parse ep agents
CREATE OR REPLACE PROCEDURE lexis_nexis_parse_ep_agents(input_xml XML) AS
$$
  BEGIN
    INSERT INTO lexis_nexis_ep_agents(country_code,doc_number,kind_code,sequence,agent_type,language,agent_name,agent_registration_num,
                                      issuing_office, agent_address, agent_city, agent_country)
    SELECT
          xmltable.country_code,
          xmltable.doc_number,
          xmltable.kind_code,
          xmltable.sequence,
          xmltable.agent_type,
          xmltable.language,
          xmltable.agent_name,
          xmltable.agent_registration_num,
          xmltable.issuing_office,
          xmltable.agent_address,
          xmltable.agent_city,
          xmltable.agent_country
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
                agent_registration_num TEXT PATH 'addressbook[1]/registered-number',
                issuing_office TEXT PATH 'addressbook[1]/issuing-office',
                agent_address TEXT PATH 'addressbook[1]/address/address-1',
                agent_city TEXT PATH 'addressbook[1]/address/city',
                agent_country TEXT PATH 'addressbook[1]/address/country'
                )
    ON CONFLICT (country_code, doc_number, kind_code, sequence)
    DO UPDATE SET agent_type=excluded.agent_type,language=excluded.language,
    agent_name=excluded.agent_name,agent_registration_num=excluded.agent_registration_num,
    issuing_office=excluded.issuing_office,agent_address=excluded.agent_address,
    agent_city=excluded.agent_city,agent_country=excluded.agent_country,last_updated_time=now();

  END;
$$
LANGUAGE plpgsql;
