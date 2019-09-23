\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create or replace procedure stg_scopus_merge_grants()
    language plpgsql
as
$$
BEGIN
insert into scopus_grants(scp, grant_id, grantor_acronym, grantor,
                          grantor_country_code, grantor_funder_registry_id)
select  scp,
       grant_id,
        max(grantor_acronym) as grantor_acronym,
       grantor,
       max(grantor_country_code) as grantor_country_code,
       max(grantor_funder_registry_id) as grantor_funder_registry_id
from stg_scopus_grants
GROUP BY scp, grant_id, grantor
ON CONFLICT (scp, grant_id, grantor) DO UPDATE SET grantor_acronym=excluded.grantor_acronym,
                                                   grantor_country_code=excluded.grantor_country_code,
                                                   grantor_funder_registry_id=excluded.grantor_funder_registry_id;

INSERT INTO scopus_grant_acknowledgements(scp, grant_text)
select distinct scopus_publications.scp,
       grant_text
from stg_scopus_grant_acknowledgements, scopus_publications
ON CONFLICT (scp) DO UPDATE SET grant_text=excluded.grant_text;
END
$$;
