/* SQL scripts for generating person and author ID level datasets to compare with and recreate portions of the SummaryStatistics XLSX file*/

/* Create a table year_range if it does not exist. populate with year values that are usable for creation of a blank slate table in following queries*/
CREATE TABLE year_range(year INT);
INSERT INTO year_range VALUES (1995),(1996),(1997),(1998),(1999),(2000),(2001),(2002),(2003),(2004),(2005),(2006),(2007),(2008),(2009),(2010),(2011),(2012),(2013),(2014),(2015),(2016),(2017),(2018);

/* CCI GROUP AUTHOR ID LEVEL w/o Base Table */
COPY (
  WITH award_author_documents AS
                    (
                      SELECT a.award_number,
                             a.author_id,
                             a.first_year,
                             b.scopus_id,
                             (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                             (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                        FROM cci_s_author_search_results a
                        INNER JOIN cci_s_author_document_mappings b
                        ON a.author_id=b.author_id
                        INNER JOIN sl_sr_all_personel_and_comp d
                        ON a.author_id=d.author_id
                        WHERE a.award_number!='COMP'
                    ),
         author_pubs AS
            (
              SELECT DISTINCT b.given_name,b.surname,a.author_id,a.scopus_id,a.publication_year,a.n_citations
              FROM award_author_documents a
              INNER JOIN
              cci_s_author_search_results b
              ON a.author_id=b.author_id
            ),
        valid_pubs AS
              (
                SELECT DISTINCT c.scopus_id,c.author_id,foo.award_number,foo.first_year
                FROM cci_s_author_document_mappings c
                INNER JOIN
                (
                  SELECT author_id,a.award_number,a.first_year,CASE WHEN b.phase='I' THEN 3 ELSE 5 END AS duration
                  FROM cci_s_author_search_results a
                  LEFT JOIN cci_phase_awards b
                  ON a.award_number=b.award_number
                ) foo
                ON c.author_id=foo.author_id
                INNER JOIN  cci_s_documents_jeroen_updated d
                ON d.scopus_id=c.scopus_id
                WHERE d.publication_year BETWEEN foo.first_year-5 AND foo.first_year + 12 -- REPLACING WITH 12 TO CAPTURE 10 YEAR SPAN POST AWARD FOR Summary statistics table foo.duration
              ),
        base_table AS
                 (
                   SELECT DISTINCT a.surname,a.given_name,a.author_id,a.award_number,a.first_year,b.year,b.year-a.first_year AS award_year, 0 as publication_count, 0 as citation_sum
                   FROM cci_s_author_search_results a
                   INNER JOIN year_range b
                   ON b.year >= a.first_year-5 AND b.year <= a.first_year+12
                   WHERE a.author_id IN (SELECT author_id FROM sl_sr_all_personel_and_comp)
                   AND a.award_number!='COMP'
                 ),
        calculations AS
                (
                   SELECT c.author_id,
                          d.award_number,
                          d.first_year,
                          c.publication_year - first_year as award_year,
                          c.publication_year,
                          count(distinct c.scopus_id) as publication_count,
                          sum(c.n_citations) as citation_sum,
                          sum(CASE WHEN foo.n_participants > 1 THEN 1 ELSE 0 END)::decimal/ count(distinct c.scopus_id) as perc_pubs_w_more_than_1_CCI
                   FROM
                   (
                     SELECT scopus_id,count(scopus_id) AS n_participants
                     FROM author_pubs
                     GROUP BY scopus_id
                   )foo
                   INNER JOIN author_pubs c
                   ON foo.scopus_id=c.scopus_id
                   INNER JOIN valid_pubs d
                   ON c.scopus_id=d.scopus_id
                   AND c.author_id=d.author_id
                   GROUP BY c.author_id,publication_year,d.award_number,d.first_year
                )
        SELECT * FROM calculations
) TO '/tmp/1A_CCI_author_id_year_level_data_before_during_after.csv' CSV HEADER;
/* CCI GROUP AUTHOR ID LEVEL w/ Base Table */
COPY(
  WITH award_author_documents AS
                    (
                      SELECT a.award_number,
                             a.author_id,
                             a.first_year,
                             b.scopus_id,
                             (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                             (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                        FROM cci_s_author_search_results a
                        INNER JOIN cci_s_author_document_mappings b
                        ON a.author_id=b.author_id
                        INNER JOIN sl_sr_all_personel_and_comp d
                        ON a.author_id=d.author_id
                        WHERE a.award_number!='COMP'
                    ),
         author_pubs AS
            (
              SELECT DISTINCT b.given_name,b.surname,a.author_id,a.scopus_id,a.publication_year,a.n_citations
              FROM award_author_documents a
              INNER JOIN
              cci_s_author_search_results b
              ON a.author_id=b.author_id
            ),
        valid_pubs AS
              (
                SELECT DISTINCT c.scopus_id,c.author_id,foo.award_number,foo.first_year
                FROM cci_s_author_document_mappings c
                INNER JOIN
                (
                  SELECT author_id,a.award_number,a.first_year,CASE WHEN b.phase='I' THEN 3 ELSE 5 END AS duration
                  FROM cci_s_author_search_results a
                  LEFT JOIN cci_phase_awards b
                  ON a.award_number=b.award_number
                ) foo
                ON c.author_id=foo.author_id
                INNER JOIN  cci_s_documents_jeroen_updated d
                ON d.scopus_id=c.scopus_id
                WHERE d.publication_year BETWEEN foo.first_year-5 AND foo.first_year+ 12 -- REPLACING WITH 12 TO CAPTURE 10 YEAR SPAN POST AWARD FOR Summary statistics table foo.duration
              ),
        base_table AS
                 (
                   SELECT DISTINCT a.surname,a.given_name,a.author_id,a.award_number,a.first_year,b.year,b.year-a.first_year AS award_year, 0 as publication_count, 0 as citation_sum
                   FROM cci_s_author_search_results a
                   INNER JOIN year_range b
                   ON b.year >= a.first_year-5 AND b.year <= a.first_year+12
                   WHERE a.author_id IN (SELECT author_id FROM sl_sr_all_personel_and_comp)
                   AND a.award_number!='COMP'
                 ),
        calculations AS
                (
                   SELECT c.author_id,
                          d.award_number,
                          d.first_year,
                          c.publication_year - first_year as award_year,
                          c.publication_year,
                          count(c.scopus_id) as publication_count,
                          sum(c.n_citations) as citation_sum,
                          sum(CASE WHEN foo.n_participants > 1 THEN 1 ELSE 0 END)::decimal/ count(c.scopus_id) as perc_pubs_w_more_than_1_CCI
                   FROM
                   (
                     SELECT scopus_id,count(scopus_id) AS n_participants
                     FROM author_pubs
                     GROUP BY scopus_id
                   )foo
                   INNER JOIN author_pubs c
                   ON foo.scopus_id=c.scopus_id
                   INNER JOIN valid_pubs d
                   ON c.scopus_id=d.scopus_id
                   AND c.author_id=d.author_id
                   GROUP BY c.author_id,publication_year,d.award_number,d.first_year
                )
        SELECT
          a.author_id,
          a.award_number,
          a.first_year,
          a.award_year,
          a.first_year+a.award_year as publication_year,
          CASE WHEN b.publication_count IS NULL THEN a.publication_count ELSE b.publication_count END AS publication_count,
          CASE WHEN b.citation_sum IS NULL THEN a.citation_sum ELSE b.citation_sum END AS citation_sum,
          b.perc_pubs_w_more_than_1_CCI
        FROM base_table a
        LEFT JOIN calculations b
        ON a.author_id=b.author_id AND a.award_number=b.award_number AND a.first_year=b.first_year AND a.award_year=b.award_year
) TO '/tmp/1A_CCI_author_id_year_level_data_before_during_after_w_background.csv' CSV HEADER;
/* CCI GROUP PERSON (surname+given_name) YEAR LEVEL w/ Base Table */
COPY(
  WITH award_author_documents AS
                    (
                      SELECT a.award_number,
                             a.author_id,
                             a.first_year,
                             b.scopus_id,
                             (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                             (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                        FROM cci_s_author_search_results a
                        INNER JOIN cci_s_author_document_mappings b
                        ON a.author_id=b.author_id
                        INNER JOIN sl_sr_all_personel_and_comp d
                        ON a.author_id=d.author_id
                        WHERE a.award_number!='COMP'
                    ),
         author_pubs AS
            (
              SELECT DISTINCT b.given_name,b.surname,a.author_id,a.scopus_id,a.publication_year,a.n_citations
              FROM award_author_documents a
              INNER JOIN
              cci_s_author_search_results b
              ON a.author_id=b.author_id
            ),
        valid_pubs AS
              (
                SELECT DISTINCT c.scopus_id,c.author_id,foo.award_number,foo.first_year
                FROM cci_s_author_document_mappings c
                INNER JOIN
                (
                  SELECT author_id,a.award_number,a.first_year,CASE WHEN b.phase='I' THEN 3 ELSE 5 END AS duration
                  FROM cci_s_author_search_results a
                  LEFT JOIN cci_phase_awards b
                  ON a.award_number=b.award_number
                ) foo
                ON c.author_id=foo.author_id
                INNER JOIN  cci_s_documents_jeroen_updated d
                ON d.scopus_id=c.scopus_id
                WHERE d.publication_year BETWEEN foo.first_year-5 AND foo.first_year+12 -- REPLACING WITH 12 TO CAPTURE 10 YEAR SPAN POST AWARD FOR Summary statistics table foo.duration
              ),
        base_table AS
                 (
                   SELECT DISTINCT a.surname,a.given_name,a.award_number,a.first_year,b.year,b.year-a.first_year AS award_year, 0 as publication_count, 0 as citation_sum
                   FROM cci_s_author_search_results a
                   INNER JOIN year_range b
                   ON b.year >= a.first_year-5 AND b.year <= a.first_year+12
                   WHERE a.author_id IN (SELECT author_id FROM sl_sr_all_personel_and_comp)
                   AND a.award_number!='COMP'
                 ),
        calculations AS
                (
                   SELECT bar.given_name,
                          bar.surname,
                          bar.award_number,
                          bar.first_year,
                          bar.publication_year - first_year as award_year,
                          bar.publication_year,
                          count(distinct bar.scopus_id) as publication_count,
                          sum(bar.n_citations) as citation_sum,
                          sum(CASE WHEN foo.n_participants > 1 THEN 1 ELSE 0 END)::decimal/ count(distinct bar.scopus_id) as perc_pubs_w_more_than_1_CCI
                   FROM
                   (
                     SELECT scopus_id,count(scopus_id) AS n_participants
                     FROM (SELECT DISTINCT surname, given_name, scopus_id
                            FROM author_pubs) foo
                     GROUP BY scopus_id
                   )foo
                   INNER JOIN
                   (
                     SELECT DISTINCT c.given_name,c.surname,c.scopus_id,c.publication_year,c.n_citations,d.first_year,d.award_number
                     FROM author_pubs c
                     INNER JOIN valid_pubs d
                     ON c.scopus_id=d.scopus_id
                     AND c.author_id=d.author_id
                   ) bar
                   ON foo.scopus_id=bar.scopus_id
                   GROUP BY given_name,surname,publication_year,award_number,first_year
                   ORDER BY surname,given_name,award_number,first_year,publication_year
                )
        SELECT
          a.surname,
          a.given_name,
          a.award_number,
          a.first_year,
          a.award_year,
          a.first_year+a.award_year as publication_year,
          CASE WHEN b.publication_count IS NULL THEN a.publication_count ELSE b.publication_count END AS publication_count,
          CASE WHEN b.citation_sum IS NULL THEN a.citation_sum ELSE b.citation_sum END AS citation_sum,
          b.perc_pubs_w_more_than_1_CCI
        FROM base_table a
        LEFT JOIN calculations b
        ON a.surname=b.surname AND a.given_name=b.given_name AND a.award_number=b.award_number AND a.first_year=b.first_year AND a.award_year=b.award_year
) TO '/tmp/1A_CCI_person_year_level_data_before_during_after_w_background.csv' CSV HEADER;
/* CCI GROUP PERSON (surname+given_name) YEAR LEVEL w/o Base Table */
COPY(
  WITH award_author_documents AS
                    (
                      SELECT a.award_number,
                             a.author_id,
                             a.first_year,
                             b.scopus_id,
                             (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                             (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                        FROM cci_s_author_search_results a
                        INNER JOIN cci_s_author_document_mappings b
                        ON a.author_id=b.author_id
                        INNER JOIN sl_sr_all_personel_and_comp d
                        ON a.author_id=d.author_id
                        WHERE a.award_number!='COMP'
                    ),
         author_pubs AS
            (
              SELECT DISTINCT b.given_name,b.surname,a.author_id,a.scopus_id,a.publication_year,a.n_citations
              FROM award_author_documents a
              INNER JOIN
              cci_s_author_search_results b
              ON a.author_id=b.author_id
            ),
        valid_pubs AS
              (
                SELECT DISTINCT c.scopus_id,c.author_id,foo.award_number,foo.first_year
                FROM cci_s_author_document_mappings c
                INNER JOIN
                (
                  SELECT author_id,a.award_number,a.first_year,CASE WHEN b.phase='I' THEN 3 ELSE 5 END AS duration
                  FROM cci_s_author_search_results a
                  LEFT JOIN cci_phase_awards b
                  ON a.award_number=b.award_number
                ) foo
                ON c.author_id=foo.author_id
                INNER JOIN  cci_s_documents_jeroen_updated d
                ON d.scopus_id=c.scopus_id
                WHERE d.publication_year BETWEEN foo.first_year-5 AND foo.first_year+12 -- REPLACING WITH 12 TO CAPTURE 10 YEAR SPAN POST AWARD FOR Summary statistics table foo.duration
              ),
        base_table AS
                 (
                   SELECT DISTINCT a.surname,a.given_name,a.award_number,a.first_year,b.year,b.year-a.first_year AS award_year, 0 as publication_count, 0 as citation_sum
                   FROM cci_s_author_search_results a
                   INNER JOIN year_range b
                   ON b.year >= a.first_year-5 AND b.year <= a.first_year+12
                   WHERE a.author_id IN (SELECT author_id FROM sl_sr_all_personel_and_comp)
                   AND a.award_number!='COMP'
                 ),
        calculations AS
                (
                   SELECT bar.given_name,
                          bar.surname,
                          bar.award_number,
                          bar.first_year,
                          bar.publication_year - first_year as award_year,
                          bar.publication_year,
                          count(distinct bar.scopus_id) as publication_count,
                          sum(bar.n_citations) as citation_sum,
                          sum(CASE WHEN foo.n_participants > 1 THEN 1 ELSE 0 END)::decimal/ count(distinct bar.scopus_id) as perc_pubs_w_more_than_1_CCI
                   FROM
                   (
                     SELECT scopus_id,count(scopus_id) AS n_participants
                     FROM (SELECT DISTINCT surname, given_name, scopus_id
                            FROM author_pubs) foo
                     GROUP BY scopus_id
                   )foo
                   INNER JOIN
                   (
                     SELECT DISTINCT c.given_name,c.surname,c.scopus_id,c.publication_year,c.n_citations,d.first_year,d.award_number
                     FROM author_pubs c
                     INNER JOIN valid_pubs d
                     ON c.scopus_id=d.scopus_id
                     AND c.author_id=d.author_id
                   ) bar
                   ON foo.scopus_id=bar.scopus_id
                   GROUP BY given_name,surname,publication_year,award_number,first_year
                   ORDER BY surname,given_name,award_number,first_year,publication_year
                )
        SELECT * FROM calculations
) TO '/tmp/1A_CCI_person_year_level_data_before_during_after.csv' CSV HEADER;


/* COMP GROUP AUTHOR ID LEVEL w/o Base Table */
COPY(
  WITH award_author_documents AS
                    (
                      SELECT a.award_number,
                             a.author_id,
                             a.first_year,
                             b.scopus_id,
                             (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                             (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                        FROM cci_s_author_search_results a
                        INNER JOIN cci_s_author_document_mappings b
                        ON a.author_id=b.author_id
                        INNER JOIN sl_sr_all_personel_and_comp d
                        ON a.author_id=d.author_id
                        WHERE a.award_number='COMP'
                    ),
         author_pubs AS
            (
              SELECT DISTINCT b.given_name,b.surname,a.author_id,a.scopus_id,a.publication_year,a.n_citations
              FROM award_author_documents a
              INNER JOIN
              cci_s_author_search_results b
              ON a.author_id=b.author_id
            ),
        valid_pubs AS
              (
                SELECT DISTINCT c.scopus_id,c.author_id,foo.award_number,foo.first_year
                FROM cci_s_author_document_mappings c
                INNER JOIN
                (
                  SELECT author_id,a.award_number,a.first_year,CASE WHEN b.phase='I' THEN 3 ELSE 5 END AS duration
                  FROM cci_s_author_search_results a
                  LEFT JOIN cci_phase_awards b
                  ON a.award_number=b.award_number
                ) foo
                ON c.author_id=foo.author_id
                INNER JOIN  cci_s_documents_jeroen_updated d
                ON d.scopus_id=c.scopus_id
                WHERE d.publication_year BETWEEN foo.first_year-5 AND foo.first_year + 12 -- REPLACING WITH 12 TO CAPTURE 10 YEAR SPAN POST AWARD FOR Summary statistics table foo.duration
              ),
        base_table AS
                 (
                   SELECT DISTINCT a.surname,a.given_name,a.author_id,a.award_number,a.first_year,b.year,b.year-a.first_year AS award_year, 0 as publication_count, 0 as citation_sum
                   FROM cci_s_author_search_results a
                   INNER JOIN year_range b
                   ON b.year >= a.first_year-5 AND b.year <= a.first_year+12
                   WHERE a.author_id IN (SELECT author_id FROM sl_sr_all_personel_and_comp)
                   AND a.award_number='COMP'
                 ),
        calculations AS
                (
                   SELECT c.author_id,
                          d.award_number,
                          d.first_year,
                          c.publication_year - first_year as award_year,
                          c.publication_year,
                          count(distinct c.scopus_id) as publication_count,
                          sum(c.n_citations) as citation_sum
                   FROM
                   author_pubs c
                   INNER JOIN valid_pubs d
                   ON c.scopus_id=d.scopus_id
                   AND c.author_id=d.author_id
                   GROUP BY c.author_id,publication_year,d.award_number,d.first_year
                )
        SELECT * FROM calculations
) TO '/tmp/1A_COMP_author_id_year_level_data_before_during_after.csv' CSV HEADER;
/* COMP GROUP AUTHOR ID LEVEL w/ Base Table */
COPY(
  WITH award_author_documents AS
                    (
                      SELECT a.award_number,
                             a.author_id,
                             a.first_year,
                             b.scopus_id,
                             (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                             (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                        FROM cci_s_author_search_results a
                        INNER JOIN cci_s_author_document_mappings b
                        ON a.author_id=b.author_id
                        INNER JOIN sl_sr_all_personel_and_comp d
                        ON a.author_id=d.author_id
                        WHERE a.award_number='COMP'
                    ),
         author_pubs AS
            (
              SELECT DISTINCT b.given_name,b.surname,a.author_id,a.scopus_id,a.publication_year,a.n_citations
              FROM award_author_documents a
              INNER JOIN
              cci_s_author_search_results b
              ON a.author_id=b.author_id
            ),
        valid_pubs AS
              (
                SELECT DISTINCT c.scopus_id,c.author_id,foo.award_number,foo.first_year
                FROM cci_s_author_document_mappings c
                INNER JOIN
                (
                  SELECT author_id,a.award_number,a.first_year,CASE WHEN b.phase='I' THEN 3 ELSE 5 END AS duration
                  FROM cci_s_author_search_results a
                  LEFT JOIN cci_phase_awards b
                  ON a.award_number=b.award_number
                ) foo
                ON c.author_id=foo.author_id
                INNER JOIN  cci_s_documents_jeroen_updated d
                ON d.scopus_id=c.scopus_id
                WHERE d.publication_year BETWEEN foo.first_year-5 AND foo.first_year+ 12 -- REPLACING WITH 12 TO CAPTURE 10 YEAR SPAN POST AWARD FOR Summary statistics table foo.duration
              ),
        base_table AS
                 (
                   SELECT DISTINCT a.surname,a.given_name,a.author_id,a.award_number,a.first_year,b.year,b.year-a.first_year AS award_year, 0 as publication_count, 0 as citation_sum
                   FROM cci_s_author_search_results a
                   INNER JOIN year_range b
                   ON b.year >= a.first_year-5 AND b.year <= a.first_year+12
                   WHERE a.author_id IN (SELECT author_id FROM sl_sr_all_personel_and_comp)
                   AND a.award_number='COMP'
                 ),
        calculations AS
                (
                   SELECT c.author_id,
                          d.award_number,
                          d.first_year,
                          c.publication_year - first_year as award_year,
                          c.publication_year,

                          count(c.scopus_id) as publication_count,
                          sum(c.n_citations) as citation_sum
                   FROM
                   author_pubs c
                   INNER JOIN valid_pubs d
                   ON c.scopus_id=d.scopus_id
                   AND c.author_id=d.author_id
                   GROUP BY c.author_id,publication_year,d.award_number,d.first_year
                )
        SELECT
          a.author_id,
          a.award_number,
          a.first_year,
          a.award_year,
          a.first_year+a.award_year as publication_year,
          CASE WHEN b.publication_count IS NULL THEN a.publication_count ELSE b.publication_count END AS publication_count,
          CASE WHEN b.citation_sum IS NULL THEN a.citation_sum ELSE b.citation_sum END AS citation_sum
        FROM base_table a
        LEFT JOIN calculations b
        ON a.author_id=b.author_id AND a.award_number=b.award_number AND a.first_year=b.first_year AND a.award_year=b.award_year
) TO '/tmp/1A_COMP_author_id_year_level_data_before_during_after_w_background.csv' CSV HEADER;
/* COMP GROUP PERSON (surname+given_name) YEAR LEVEL w/ Base Table */
COPY(
  WITH award_author_documents AS
                    (
                      SELECT a.award_number,
                             a.author_id,
                             a.first_year,
                             b.scopus_id,
                             (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                             (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                        FROM cci_s_author_search_results a
                        INNER JOIN cci_s_author_document_mappings b
                        ON a.author_id=b.author_id
                        INNER JOIN sl_sr_all_personel_and_comp d
                        ON a.author_id=d.author_id
                        WHERE a.award_number='COMP'
                    ),
         author_pubs AS
            (
              SELECT DISTINCT b.given_name,b.surname,a.author_id,a.scopus_id,a.publication_year,a.n_citations
              FROM award_author_documents a
              INNER JOIN
              cci_s_author_search_results b
              ON a.author_id=b.author_id
            ),
        valid_pubs AS
              (
                SELECT DISTINCT c.scopus_id,c.author_id,foo.award_number,foo.first_year
                FROM cci_s_author_document_mappings c
                INNER JOIN
                (
                  SELECT author_id,a.award_number,a.first_year,CASE WHEN b.phase='I' THEN 3 ELSE 5 END AS duration
                  FROM cci_s_author_search_results a
                  LEFT JOIN cci_phase_awards b
                  ON a.award_number=b.award_number
                ) foo
                ON c.author_id=foo.author_id
                INNER JOIN  cci_s_documents_jeroen_updated d
                ON d.scopus_id=c.scopus_id
                WHERE d.publication_year BETWEEN foo.first_year-5 AND foo.first_year+12 -- REPLACING WITH 12 TO CAPTURE 10 YEAR SPAN POST AWARD FOR Summary statistics table foo.duration
              ),
        base_table AS
                 (
                   SELECT DISTINCT a.surname,a.given_name,a.award_number,a.first_year,b.year,b.year-a.first_year AS award_year, 0 as publication_count, 0 as citation_sum
                   FROM cci_s_author_search_results a
                   INNER JOIN year_range b
                   ON b.year >= a.first_year-5 AND b.year <= a.first_year+12
                   WHERE a.author_id IN (SELECT author_id FROM sl_sr_all_personel_and_comp)
                   AND a.award_number='COMP'
                 ),
        calculations AS
                (
                   SELECT bar.given_name,
                          bar.surname,
                          bar.award_number,
                          bar.first_year,
                          bar.publication_year - first_year as award_year,
                          bar.publication_year,
                          count(distinct bar.scopus_id) as publication_count,
                          sum(bar.n_citations) as citation_sum
                   FROM
                   (
                     SELECT DISTINCT c.given_name,c.surname,c.scopus_id,c.publication_year,c.n_citations,d.first_year,d.award_number
                     FROM author_pubs c
                     INNER JOIN valid_pubs d
                     ON c.scopus_id=d.scopus_id
                     AND c.author_id=d.author_id
                   ) bar
                   GROUP BY given_name,surname,publication_year,award_number,first_year
                   ORDER BY surname,given_name,award_number,first_year,publication_year
                )
        SELECT
          a.surname,
          a.given_name,
          a.award_number,
          a.first_year,
          a.award_year,
          a.first_year+a.award_year as publication_year,
          CASE WHEN b.publication_count IS NULL THEN a.publication_count ELSE b.publication_count END AS publication_count,
          CASE WHEN b.citation_sum IS NULL THEN a.citation_sum ELSE b.citation_sum END AS citation_sum
        FROM base_table a
        LEFT JOIN calculations b
        ON a.surname=b.surname AND a.given_name=b.given_name AND a.award_number=b.award_number AND a.first_year=b.first_year AND a.award_year=b.award_year
) TO '/tmp/1A_COMP_person_year_level_data_before_during_after_w_background.csv' CSV HEADER;
/* COMP GROUP PERSON (surname+given_name) YEAR LEVEL w/o Base Table */
COPY(
  WITH award_author_documents AS
                    (
                      SELECT a.award_number,
                             a.author_id,
                             a.first_year,
                             b.scopus_id,
                             (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                             (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                        FROM cci_s_author_search_results a
                        INNER JOIN cci_s_author_document_mappings b
                        ON a.author_id=b.author_id
                        INNER JOIN sl_sr_all_personel_and_comp d
                        ON a.author_id=d.author_id
                        WHERE a.award_number='COMP'
                    ),
         author_pubs AS
            (
              SELECT DISTINCT b.given_name,b.surname,a.author_id,a.scopus_id,a.publication_year,a.n_citations
              FROM award_author_documents a
              INNER JOIN
              cci_s_author_search_results b
              ON a.author_id=b.author_id
            ),
        valid_pubs AS
              (
                SELECT DISTINCT c.scopus_id,c.author_id,foo.award_number,foo.first_year
                FROM cci_s_author_document_mappings c
                INNER JOIN
                (
                  SELECT author_id,a.award_number,a.first_year,CASE WHEN b.phase='I' THEN 3 ELSE 5 END AS duration
                  FROM cci_s_author_search_results a
                  LEFT JOIN cci_phase_awards b
                  ON a.award_number=b.award_number
                ) foo
                ON c.author_id=foo.author_id
                INNER JOIN  cci_s_documents_jeroen_updated d
                ON d.scopus_id=c.scopus_id
                WHERE d.publication_year BETWEEN foo.first_year-5 AND foo.first_year+12 -- REPLACING WITH 12 TO CAPTURE 10 YEAR SPAN POST AWARD FOR Summary statistics table foo.duration
              ),
        base_table AS
                 (
                   SELECT DISTINCT a.surname,a.given_name,a.award_number,a.first_year,b.year,b.year-a.first_year AS award_year, 0 as publication_count, 0 as citation_sum
                   FROM cci_s_author_search_results a
                   INNER JOIN year_range b
                   ON b.year >= a.first_year-5 AND b.year <= a.first_year+12
                   WHERE a.author_id IN (SELECT author_id FROM sl_sr_all_personel_and_comp)
                   AND a.award_number='COMP'
                 ),
        calculations AS
                (
                   SELECT bar.given_name,
                          bar.surname,
                          bar.award_number,
                          bar.first_year,
                          bar.publication_year - first_year as award_year,
                          bar.publication_year,
                          count(distinct bar.scopus_id) as publication_count,
                          sum(bar.n_citations) as citation_sum
                   FROM
                   (
                     SELECT DISTINCT c.given_name,c.surname,c.scopus_id,c.publication_year,c.n_citations,d.first_year,d.award_number
                     FROM author_pubs c
                     INNER JOIN valid_pubs d
                     ON c.scopus_id=d.scopus_id
                     AND c.author_id=d.author_id
                   ) bar
                   GROUP BY given_name,surname,publication_year,award_number,first_year
                   ORDER BY surname,given_name,award_number,first_year,publication_year
                )
        SELECT * FROM calculations
) TO '/tmp/1A_COMP_person_year_level_data_before_during_after.csv' CSV HEADER;
