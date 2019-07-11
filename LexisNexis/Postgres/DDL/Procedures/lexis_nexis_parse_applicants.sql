\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path TO public;


CREATE OR REPLACE PROCEDURE lexis_nexis_applicants_data(input_xml xml) AS
$$
BEGIN

    INSERT INTO lexis_nexis_applicants(country_code, doc_number, kind_code, sequence, language, designation,
                                       organization_name, organization_type, organization_country, organization_state,
                                       organization_city, organization_address, registered_number,
                                       issuing_office)
        SELECT DISTINCT
        xmltable.country_code,
        xmltable.doc_number,
        xmltable.kind_code,
        xmltable.sequence,
        xmltable.language,
        xmltable.designation,
        xmltable.organization_name,
        xmltable.organization_type,
        xmltable.organization_country,
        xmltable.organization_state,
        xmltable.organization_city,
        xmltable.organization_address,
        xmltable.registered_number,
        xmltable.issuing_office
        FROM xmltable('//bibliographic-data/parties/applicants/applicant[not(@data-format)]' PASSING input_xml
        COLUMNS
        country_code TEXT PATH '../../../publication-reference/document-id/country',
        doc_number TEXT PATH '../../../publication-reference/document-id/doc-number',
        kind_code TEXT PATH '../../../publication-reference/document-id/kind',
        language TEXT PATH 'addressbook[1]/@lang',
        sequence SMALLINT PATH '@sequence',
        designation TEXT PATH '@designation',
        organization_name TEXT PATH 'addressbook[1]/orgname',
        organization_type TEXT PATH 'addressbook[1]/orgname-standardized/@type',
        organization_key INT PATH 'addressbook[1]/orgname-normalized/@key',
        organization_country TEXT PATH 'addressbook[1]/address/country',
        organization_state TEXT PATH 'addressbook[1]/address/state',
        organization_city TEXT PATH 'addressbook[1]/address/city',
        organization_address TEXT PATH 'addressbook[1]/address/addresss-1',
        registered_number TEXT PATH 'addressbook[1]/registered-number',
        issuing_office TEXT PATH 'addressbook[1]/issuing-office'
        )
    ON CONFLICT (country_code, doc_number, kind_code, sequence)
    DO UPDATE SET language=excluded.language,designation=excluded.designation,organization_name=excluded.organization_name,
    organization_type=excluded.organization_type,organization_country=excluded.organization_country,
    organization_state=excluded.organization_state,organization_city=excluded.organization_city,
    organization_address=excluded.organization_address,registered_number=excluded.registered_number,
    issuing_office=excluded.issuing_office,last_updated_time=now();
END;
$$ LANGUAGE plpgsql;
