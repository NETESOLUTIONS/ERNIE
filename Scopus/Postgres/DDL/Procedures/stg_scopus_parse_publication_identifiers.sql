\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

CREATE OR REPLACE PROCEDURE stg_scopus_parse_publication_identifiers(scopus_doc_xml XML)
  LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO stg_scopus_publication_identifiers(scp, document_id, document_id_type)
  SELECT scp, document_id, document_id_type
    FROM
      xmltable(--
          XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), --
          '//bibrecord/item-info/itemidlist/itemid' PASSING scopus_doc_xml COLUMNS --
      --@formatter:off
                    scp BIGINT PATH '//itemid[@idtype="SCP"]',
                    document_id TEXT PATH '.',
                    document_id_type TEXT PATH '@idtype'
            --@formatter:on
        )
   WHERE document_id_type != 'SCP' AND document_id_type != 'SGR'
   UNION
  SELECT scp, document_id, upper(substr(document_id_type, 4))
    FROM
      xmltable(XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), '//bibrecord/item-info/itemidlist/ce:doi'
               PASSING scopus_doc_xml COLUMNS --
                 scp BIGINT PATH '../itemid[@idtype="SCP"]', --
                 document_id TEXT PATH '.', --
                 document_id_type TEXT PATH 'name(.)')
   UNION
  SELECT scp, document_id, upper(substr(document_id_type, 4))
    FROM
      xmltable(XMLNAMESPACES ('http://www.elsevier.com/xml/ani/common' AS ce), '//bibrecord/item-info/itemidlist/ce:pii'
               PASSING scopus_doc_xml COLUMNS --
                 scp BIGINT PATH '../itemid[@idtype="SCP"]', --
                 document_id TEXT PATH '.', --
                 document_id_type TEXT PATH 'name(.)');
END; $$

