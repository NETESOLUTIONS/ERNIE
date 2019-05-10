\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- additional source information
CREATE OR REPLACE PROCEDURE scopus_parse_grants(scopus_doc_xml XML)
AS $$
  BEGIN
    -- scopus_grants
    INSERT INTO scopus_grants(scp, grant_id, grant_acronym, grant_agency,
                                 grant_agency_address, grant_agency_id)
    SELECT
     scp,
     coalesce(grant_id,'') as grant_id,
     grant_acronym,
     grant_agency,
     grant_agency_address,
     grant_agency_id
    FROM xmltable(--
      '//bibrecord/head/grantlist/grant' PASSING scopus_doc_xml COLUMNS --
      --@formatter:off
      scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      grant_id TEXT PATH 'grant-id',
      grant_acronym TEXT PATH 'grant-acronym',
      grant_agency TEXT PATH 'grant-agency',
      grant_agency_address TEXT PATH 'grant-agency/@iso-code',
      grant_agency_id TEXT PATH 'grant-agency-id'
      )
    ON CONFLICT DO NOTHING;

    -- scopus_grant_acknowledgements
    INSERT INTO scopus_grant_acknowledgements(scp,grant_text)

    SELECT
      scp,
      grant_text
    FROM
      xmltable(--
      '//bibrecord/head/grantlist/grant-text' PASSING scopus_doc_xml COLUMNS --
      scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      grant_text TEXT PATH '.'
      )
    ON CONFLICT DO NOTHING;
  END;
  $$
  LANGUAGE plpgsql;