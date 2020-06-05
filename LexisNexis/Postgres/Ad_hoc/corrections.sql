DELETE
  FROM lexis_nexis_patents
 WHERE (country_code, doc_number, kind_code) IN (('EP', '12109', 'A2'), ('EP', '459', 'A1'));

SELECT *
  FROM lexis_nexis_patents
 WHERE (country_code, doc_number, kind_code) IN (('EP', '12109', 'A2'), ('EP', '459', 'A1'));