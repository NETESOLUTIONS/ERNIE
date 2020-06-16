\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';



CREATE OR REPLACE PROCEDURE lexis_nexis_patent_application_reference_data(input_xml XML) AS
$$
BEGIN
    INSERT INTO lexis_nexis_patent_application_references(country_code,doc_number,kind_code,appl_ref_type, appl_ref_doc_number,
                                                         appl_ref_country, appl_ref_date)
    SELECT xmltable.country_code,
           xmltable.doc_number,
           xmltable.kind_code,
           xmltable.appl_ref_type,
           xmltable.appl_ref_doc_number,
           xmltable.appl_ref_country,
           xmltable.appl_ref_date
    FROM xmltable('//bibliographic-data/application-reference/document-id/doc-number' PASSING input_xml COLUMNS
        country_code TEXT PATH '../../../publication-reference/document-id/country' NOT NULL,
        doc_number TEXT PATH '../../../publication-reference/document-id/doc-number' NOT NULL,
        kind_code TEXT PATH '../../../publication-reference/document-id/kind' NOT NULL,
        appl_ref_type TEXT PATH '../../@appl-type',
        appl_ref_doc_number TEXT PATH '.',
        appl_ref_country TEXT PATH '../country',
        appl_ref_date date PATH '../date'
        )
    ON CONFLICT (country_code, doc_number, kind_code,appl_ref_country,appl_ref_doc_number)
    DO UPDATE SET appl_ref_type=excluded.appl_ref_type,appl_ref_country=excluded.appl_ref_country,
    appl_ref_date=excluded.appl_ref_date,last_updated_time=now();

END;
$$ LANGUAGE plpgsql;
