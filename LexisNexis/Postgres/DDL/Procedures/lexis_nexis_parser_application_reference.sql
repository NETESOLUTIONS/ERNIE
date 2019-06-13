\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';
SET search_path TO public;


CREATE OR REPLACE PROCEDURE lexis_nexis_patent_application_reference_data(input_xml XML) AS
$$
BEGIN
    INSERT INTO lexis_nexis_patent_application_reference(doc_number, appl_ref_type, appl_ref_doc_number,
                                                         appl_ref_country, appl_ref_date)
    SELECT xmltable.doc_number,
           xmltable.appl_ref_type,
           xmltable.appl_ref_doc_number,
           xmltable.appl_ref_country,
           xmltable.appl_ref_date
    FROM xmltable('//bibliographic-data/application-reference/document-id/doc-number' PASSING input_xml COLUMNS
        doc_number BIGINT PATH '../../../publication-reference/document-id/doc-number',
        appl_ref_type TEXT PATH '../../@appl-type',
        appl_ref_doc_number BIGINT PATH '.',
        appl_ref_country TEXT PATH '../country',
        appl_ref_date date PATH '../date'
             )
    ON CONFLICT DO NOTHING;

END;
$$ LANGUAGE plpgsql;
