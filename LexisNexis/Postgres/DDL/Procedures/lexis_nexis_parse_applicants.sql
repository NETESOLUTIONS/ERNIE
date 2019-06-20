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
        SELECT xmltable.country_code,
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
        FROM xmltable('//bibliographic-data/parties/applicants/applicant' PASSING input_xml COLUMNS
        country_code TEXT PATH '../../../publication-reference/document-id/country',
        doc_number TEXT PATH '../../../publication-reference/document-id/doc-number',
        kind_code TEXT PATH '../../../publication-reference/document-id/kind',
        LANGUAGE TEXT PATH 'addressbook/@lang',
        SEQUENCE SMALLINT PATH '@sequence',
        designation TEXT PATH '@designation',
        organization_name TEXT PATH 'addressbook/orgname',
        organization_type TEXT PATH 'addressbook/orgname-standardized/@type',
        organization_country TEXT PATH 'addressbook/address/country',
        organization_state TEXT PATH 'addressbook/address/state',
        organization_city TEXT PATH 'addressbook/address/city',
        organization_address TEXT PATH 'addressbook/address/addresss-1',
        registered_number TEXT PATH 'addressbook/registered-number',
        issuing_office TEXT PATH 'addressbook/issuing-office'
        );
END;
$$ LANGUAGE plpgsql;
