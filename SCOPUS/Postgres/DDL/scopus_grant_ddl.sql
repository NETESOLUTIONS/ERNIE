\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- Drop existing tables manually before executing

-- region scopus_grants
CREATE TABLE scopus_grants (
  scp BIGINT CONSTRAINT sg_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  grant_id TEXT,
  grantor_acronym TEXT,
  grantor TEXT,
  grantor_country_code CHAR(3),
  grantor_funder_registry_id TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_grants_pk PRIMARY KEY (scp, grant_id) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_grants
IS 'Grants information table of publications';

COMMENT ON COLUMN scopus_grants.scp
IS 'Scopus id. Example: 84936047855';

COMMENT ON COLUMN scopus_grants.grant_id
IS 'Identification number of the grant assigned by grant agency';

COMMENT ON COLUMN scopus_grants.grantor_acronym
IS 'Acronym of an organization that has awarded the grant';

COMMENT ON COLUMN scopus_grants.grantor
IS 'Agency name that has awarded the grant';

COMMENT ON COLUMN scopus_grants.grantor_country_code
IS 'Agency country 3-letter iso code';

COMMENT ON COLUMN scopus_grants.grantor_funder_registry_id
IS 'Funder Registry ID';
--endregion

-- region scopus_grant_acknowledgement
CREATE TABLE scopus_grant_acknowledgements (
  scp BIGINT CONSTRAINT sga_scp_fk REFERENCES scopus_publications ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  grant_text TEXT,
  last_updated_time TIMESTAMP DEFAULT now(),
  CONSTRAINT scopus_grant_acknowledgement_pk PRIMARY KEY (scp) USING INDEX TABLESPACE index_tbs
) TABLESPACE scopus_tbs;

COMMENT ON TABLE scopus_grant_acknowledgements
IS 'Grants acknowledgement table of publications';

COMMENT ON COLUMN scopus_grant_acknowledgements.scp
IS 'Scopus id. Example: 84936047855';

COMMENT ON COLUMN scopus_grant_acknowledgements.grant_text
IS 'The complete text of the Acknowledgement section plus all other text elements from the original source containing funding/grnat information';
--endregion