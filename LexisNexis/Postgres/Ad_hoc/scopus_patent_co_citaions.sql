-- 14m:42s
SELECT topft.cited_1, topft.cited_2, topft.scopus_frequency, lnsc1.country_code, lnsc1.doc_number, lnsc1.kind_code
  FROM cc2.t_o_p_final_table topft
  JOIN lexis_nexis_scopus_citations lnsc1
       ON lnsc1.scp = topft.cited_1
  JOIN lexis_nexis_scopus_citations lnsc2
       ON lnsc2.country_code = lnsc1.country_code AND lnsc2.doc_number = lnsc1.doc_number
           AND lnsc2.kind_code = lnsc1.kind_code AND lnsc2.scp = topft.cited_2;