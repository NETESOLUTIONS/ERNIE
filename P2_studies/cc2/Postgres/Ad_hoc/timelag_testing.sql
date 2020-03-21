-- Incorrect first_possible_year
SELECT t.cited_1, spg1.pub_year AS pub_year_1, t.cited_2, spg2.pub_year AS pub_year_2, t.first_possible_year
  FROM
    cc2.timelag1 t
      JOIN scopus_publication_groups spg1 ON spg1.sgr = t.cited_1
      JOIN scopus_publication_groups spg2 ON spg2.sgr = t.cited_2
 WHERE t.first_possible_year <> greatest(spg1.pub_year, spg2.pub_year);

-- Incorrect first_co_cited_year
SELECT t.cited_1, t.cited_2, sq.min_co_cited_year, t.first_co_cited_year
  FROM
    cc2.timelag1 t
      JOIN LATERAL ( SELECT min(citing_spg.pub_year) AS min_co_cited_year
                       FROM
                         scopus_references citing_sr
                           JOIN scopus_publication_groups citing_spg ON citing_spg.sgr = citing_sr.scp
                      WHERE citing_sr.ref_sgr = t.cited_1 --
                        AND EXISTS(SELECT 1
                                     FROM scopus_references citing_sr
                                    WHERE citing_sr.scp = citing_spg.sgr AND citing_sr.ref_sgr = t.cited_2) ) sq
      ON sq.min_co_cited_year <> t.first_co_cited_year;