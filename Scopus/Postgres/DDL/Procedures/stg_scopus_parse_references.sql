\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create procedure stg_scopus_parse_references(input_xml xml)
    language plpgsql
as
$$
BEGIN
    INSERT INTO stg_scopus_references(scp,ref_sgr,citation_text)
    SELECT
          xmltable.scp AS scp,
          xmltable.ref_sgr AS ref_sgr,
          --row_number() over (PARTITION BY scp  ORDER BY xmltable.pub_ref_id DESC NULLS LAST, COALESCE(xmltable.ref_fulltext,xmltable.ref_text) ASC ) as pub_ref_id, -- introduced ERNIE team produced pub_ref_id, but be on alert from Elsevier to determine if this is actually fair to do
          max(COALESCE(xmltable.ref_fulltext,xmltable.ref_text)) AS citation_text
     FROM
     XMLTABLE('//bibrecord/tail/bibliography/reference' PASSING input_xml
              COLUMNS
                scp BIGINT PATH '//itemidlist/itemid[@idtype="SCP"]/text()',
                ref_sgr BIGINT PATH 'ref-info/refd-itemidlist/itemid[@idtype="SGR"]/text()',
                --pub_ref_id INT PATH'@id',
                ref_fulltext TEXT PATH 'ref-fulltext/text()[1]', -- should work around situations where additional tags are included in the text field (e.g. a <br/> tag). Otherwise, would encounter a "more than one value returned by column XPath expression" error.
                ref_text TEXT PATH 'ref-info/ref-text/text()[1]'
                )
    GROUP BY scp, ref_sgr;
    END;
$$;