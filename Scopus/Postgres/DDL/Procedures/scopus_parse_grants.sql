\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- additional source information
CREATE OR REPLACE PROCEDURE scopus_parse_grants(scopus_doc_xml XML) AS $$
BEGIN
  -- scopus_grants
  INSERT
  INTO scopus_grants(
    scp, grant_id, grantor_acronym, grantor,
    grantor_country_code, grantor_funder_registry_id)
  SELECT scp, coalesce(grant_id, '') AS grant_id, grantor_acronym, grantor, grantor_country_code,
    grantor_funder_registry_id
  FROM
    xmltable(--
      '//bibrecord/head/grantlist/grant' PASSING scopus_doc_xml COLUMNS --
      scp BIGINT PATH '../../preceding-sibling::item-info/itemidlist/itemid[@idtype="SCP"]',
      grant_id TEXT PATH 'grant-id',
      grantor_acronym TEXT PATH 'grant-acronym',
      grantor TEXT PATH 'grant-agency',
      grantor_country_code TEXT PATH 'grant-agency/@iso-code',
      grantor_funder_registry_id TEXT PATH 'grant-agency-id'
      )
    ON CONFLICT DO UPDATE SET scp=excluded.scp,
     grant_id=excluded.grant_id, grantor_acronym=excluded.grantor_acronym,
      grantor=excluded.grantor, grantor_country_code=excluded.grantor_country_code,
      grantor_funder_registry_id=excluded.grantor_funder_registry_id ;

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
    ON CONFLICT DO UPDATE SET scp=excluded.scp, grant_text=excluded.grant_text;
  END;
  $$
  LANGUAGE plpgsql;
