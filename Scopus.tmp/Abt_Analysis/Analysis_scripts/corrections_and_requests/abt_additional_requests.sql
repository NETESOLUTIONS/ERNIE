/* Document counts per group*/
SELECT author_group, count(scopus_id)
FROM
(
  SELECT DISTINCT
                  b.scopus_id,
                  CASE
                  WHEN a.award_number!='COMP' THEN 'CCI'
                  ELSE 'COMP'
                  END AS author_group
  FROM cci_s_author_search_results a
  INNER JOIN cci_s_author_document_mappings b
  ON a.author_id=b.author_id
  INNER JOIN sl_sr_all_personel_and_comp d
  ON a.author_id=d.author_id
) foo
GROUP BY author_group;
/*document count overlap between groups*/
SELECT COUNT(1)
FROM
(
  SELECT scopus_id,count(author_group)
  FROM
  (
    SELECT DISTINCT
                    b.scopus_id,
                    CASE
                    WHEN a.award_number!='COMP' THEN 'CCI'
                    ELSE 'COMP'
                    END AS author_group
    FROM cci_s_author_search_results a
    INNER JOIN cci_s_author_document_mappings b
    ON a.author_id=b.author_id
    INNER JOIN sl_sr_all_personel_and_comp d
    ON a.author_id=d.author_id
  ) foo
  GROUP BY scopus_id
  HAVING count(author_group) > 1
) bar;



/*1a) Person level data (NOT author_id level - potentially a problem with name overlaps + duplicate profiles but meh)
      -publication count
      -citation count(sum)
      -% of pubs coauthored w/ another CCI participant*/
-- CCI group all time
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
            SELECT DISTINCT b.given_name,b.surname,a.scopus_id,a.n_citations
            FROM award_author_documents a
            INNER JOIN
            cci_s_author_search_results b
            ON a.author_id=b.author_id
          )
      SELECT c.given_name,
             c.surname,
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
      GROUP BY given_name,surname
) TO '/tmp/1A_person_level_data_pubs_citations_fraction_CCI_all_time.csv' CSV HEADER;

--COMP GROUP ALL TIME
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
                      WHERE a.award_number='COMP'
                  ),
       author_pubs AS
          (
            SELECT DISTINCT b.given_name,b.surname,a.scopus_id,a.n_citations
            FROM award_author_documents a
            INNER JOIN
            cci_s_author_search_results b
            ON a.author_id=b.author_id
          )
      SELECT c.given_name,
             c.surname,
             count(c.scopus_id) as publication_count,
             sum(c.n_citations) as citation_sum
      FROM
      author_pubs c
      GROUP BY given_name,surname
) TO '/tmp/1A_person_level_data_pubs_citations_COMP_all_time.csv' CSV HEADER;


-- DROP OFF OF 5 AUTHORS TO 321 - 5 DID NOT PUBLISH DURING FUNDING PERIOD - (Nina Singhal Hinrichs, Petra van-Koppen, Darby Feldwinn, George Farrington, Sally Ng) - some have documents, but their publication year is out of the determined range, assuming the author ids are correct
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
            SELECT DISTINCT b.given_name,b.surname,a.scopus_id,a.n_citations
            FROM award_author_documents a
            INNER JOIN
            cci_s_author_search_results b
            ON a.author_id=b.author_id
          ),
      valid_pubs AS
            (
              SELECT DISTINCT c.scopus_id
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
              WHERE d.publication_year BETWEEN foo.first_year AND foo.first_year+foo.duration
            )
      SELECT c.given_name,
             c.surname,
             count(distinct c.scopus_id) as publication_count,
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
      ON foo.scopus_id=d.scopus_id
      GROUP BY given_name,surname
) TO '/tmp/1A_person_level_data_pubs_citations_fraction_CCI_funding_period.csv' CSV HEADER;

-- DROP OFF OF 5 AUTHORS TO 321 - 5 DID NOT PUBLISH DURING FUNDING PERIOD - (Nina Singhal Hinrichs, Petra van-Koppen, Darby Feldwinn, George Farrington, Sally Ng) - some have documents, but their publication year is out of the determined range, assuming the author ids are correct
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
                      WHERE a.award_number='COMP'
                  ),
       author_pubs AS
          (
            SELECT DISTINCT b.given_name,b.surname,a.scopus_id,a.n_citations
            FROM award_author_documents a
            INNER JOIN
            cci_s_author_search_results b
            ON a.author_id=b.author_id
          ),
      valid_pubs AS
            (
              SELECT DISTINCT c.scopus_id
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
              WHERE d.publication_year BETWEEN foo.first_year AND foo.first_year+foo.duration
            )
      SELECT c.given_name,
             c.surname,
             count(c.scopus_id) as publication_count,
             sum(c.n_citations) as citation_sum
      FROM author_pubs c
      INNER JOIN valid_pubs d
      ON c.scopus_id=d.scopus_id
      GROUP BY given_name,surname
) TO '/tmp/1A_person_level_data_pubs_citations_COMP_five_year_period.csv' CSV HEADER;



/*1b) Publication level data
      -citation centiles deaggregated*/
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
                  INNER JOIN cci_s_author_document_mappings b -- May need to be chopped down to give a more fine tuned look at viable author ids
                  ON a.author_id=b.author_id
                  INNER JOIN sl_sr_all_personel_and_comp d
                  ON a.author_id=d.author_id
                  WHERE a.award_number='COMP'
                  OR a.award_number IN (SELECT award_number FROM cci_phase_awards WHERE phase IN ('II'))
              )
              SELECT scopus_id,award_number,publication_year,n_citations, cume_dist() over (PARTITION BY publication_year ORDER BY n_citations)*100 as centile
                FROM (
                        SELECT DISTINCT award_number, first_year,scopus_id,publication_year, n_citations
                        FROM award_author_documents
                        WHERE publication_year BETWEEN first_year AND first_year+5
                        AND publication_year < 2019
                    ) foo
  ) TO '/tmp/1B_COMP_and_phase_II_publication_centiles_individual.csv' CSV HEADER;

/* 3b) Subject Area regeneration for CCI documents only - All time*/
-- actually found Siyu's code and updated to include a subset operation prior to table construction


/*
4a) Centile calculations grouped by Center Name
*/
COPY   (
        WITH award_author_documents AS
                  (
                    SELECT a.award_number,
                           a.author_id,
                           a.first_year,
                           b.scopus_id,
                           (SELECT c.publication_year FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as publication_year,
                           (SELECT c.scopus_cited_by_count FROM cci_s_documents_jeroen_updated c WHERE b.scopus_id=c.scopus_id) as n_citations
                      FROM cci_s_author_search_results a
                      INNER JOIN cci_s_author_document_mappings b -- May need to be chopped down to give a more fine tuned look at viable author ids
                      ON a.author_id=b.author_id
                      INNER JOIN sl_sr_all_personel_and_comp d
                      ON a.author_id=d.author_id
                      WHERE a.award_number='COMP'
                      OR a.award_number IN (SELECT award_number FROM cci_phase_awards WHERE phase IN ('II'))
                  )
          SELECT
            official_center_name,
            min(centile) as min,
            percentile_cont(0.25) WITHIN GROUP (ORDER BY centile) as pct_25,
            percentile_cont(0.50) WITHIN GROUP (ORDER BY centile) as pct_50,
            percentile_cont(0.75) WITHIN GROUP (ORDER BY centile) as pct_75,
            max(centile) as max,avg(centile) as mean
          FROM(
            SELECT scopus_id,official_center_name,publication_year,n_citations, cume_dist() over (PARTITION BY publication_year ORDER BY n_citations)*100 as centile
            FROM (
                    SELECT DISTINCT
                      CASE WHEN a.award_number='COMP' THEN 'COMP'
                      ELSE b.official_center_name END AS official_center_name,
                    a.first_year,a.scopus_id,a.publication_year, a.n_citations
                    FROM award_author_documents a
                    LEFT JOIN cci_award_names b
                    ON a.award_number=b.award_number
                    WHERE publication_year BETWEEN first_year AND first_year+5
                    AND publication_year < 2019
                ) foo
            ) bar
            GROUP BY official_center_name
            ORDER BY avg(centile)
  )  TO '/tmp/4A_phase_II_centiles_by_center_name.csv' CSV HEADER;

/* 4b) Co Author table - Made by Siyu, adjusted to use official_center_name as group by criteria*/
COPY   (
  SELECT b.official_center_name, count(DISTINCT author_id)
  FROM abt_valid_pubs a
  INNER JOIN cci_award_names b ON a.award_number = b.award_number
  GROUP BY b.official_center_name
  ORDER BY count DESC
)  TO '/tmp/4B_phase_II_coauthor_counts_by_center_name.csv' CSV HEADER;


--TODO: Make sub tables as needed for funding period AND total publication history
/*
5a) coauthor count (total unique author_ids) per author for all of their publications CCI only
  Note - high counts for some authors are likely a result of their expansive publication histories e.g. Auth ID ' 35187456500' has 16797 distinct co-author IDs
  Anyone working at LHC or similar may have several (dozen) documents with hundreds or thousands of authors
feigning
  A count of distinct author ids isn't necessarily a true count of the number of coauthors a person has had.
  Much like how we realized that we needed to aggregate coauthor counts at the person level for instances where a person might have multiple IDs, we should in theory do the same for co-authors
  However, we dont do this. We dont even have a means for doing this even if we wanted to. We're just counting unique author_id links.

  Angel Di Billo - Award 0802907, Author ID 6507495611 is not returned and author count drops to 326.
  This guy apparently has a Scopus Author ID but no documents were returned at the time of search. 0 documents listed.
*/

-- 5A) CCI All time
COPY (
  SELECT d.surname,d.given_name, count(distinct c.author_id) AS co_author_count
  FROM sl_sr_all_personel_and_comp a
  INNER JOIN cci_s_author_search_results d
  ON a.author_id=d.author_id
  INNER JOIN cci_s_author_document_mappings b
  ON a.author_id=b.author_id
  JOIN cci_s_author_document_mappings c
  ON b.scopus_id=c.scopus_id
  WHERE b.author_id!=c.author_id
  AND d.award_number!='COMP'
  GROUP BY d.surname,d.given_name
  ORDER BY d.surname,d.given_name
) TO '/tmp/5A_CCI_coauthor_count_all_time.csv' CSV HEADER;

-- 5A) CCI during funding period
COPY (
  WITH valid_pubs AS
    (
      SELECT DISTINCT c.scopus_id
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
      WHERE d.publication_year BETWEEN foo.first_year AND foo.first_year+foo.duration
    )

  SELECT d.surname,d.given_name, count(distinct c.author_id) AS co_author_count
  FROM sl_sr_all_personel_and_comp a
  INNER JOIN cci_s_author_search_results d
  ON a.author_id=d.author_id
  INNER JOIN cci_s_author_document_mappings b
  ON a.author_id=b.author_id
  INNER JOIN valid_pubs e
  ON b.scopus_id=e.scopus_id
  JOIN cci_s_author_document_mappings c
  ON b.scopus_id=c.scopus_id
  WHERE b.author_id!=c.author_id
  AND d.award_number!='COMP'
  GROUP BY d.surname,d.given_name
  ORDER BY d.surname,d.given_name
) TO '/tmp/5A_CCI_coauthor_count_during_funding_periods.csv' CSV HEADER;


-- 5A) CCI coauthorship during funding period, CCI participant mapped
COPY (
  SELECT surname,given_name, count(1) AS  senior_personnel_co_author_count
  FROM
  (
    SELECT DISTINCT d.surname,d.given_name, f.surname as cci_co_author_surname, f.given_name as cci_co_author_given_name
    FROM sl_sr_all_personel_and_comp a
    INNER JOIN cci_s_author_search_results d
    ON a.author_id=d.author_id
    INNER JOIN cci_s_author_document_mappings b
    ON a.author_id=b.author_id
    JOIN cci_s_author_document_mappings c
    ON b.scopus_id=c.scopus_id
    INNER JOIN cci_s_author_search_results f
    ON f.author_id=c.author_id
    WHERE b.author_id!=c.author_id
    AND d.award_number!='COMP'
    AND f.award_number!='COMP'
  ) foo
  GROUP BY surname,given_name
  ORDER BY surname,given_name
) TO '/tmp/5A_CCI_coauthor_count_all_time_CCI_mapped.csv' CSV HEADER;

-- 5A) CCI coauthorship during funding period, CCI participant mapped
COPY (
  WITH valid_pubs AS
    (
      SELECT DISTINCT c.scopus_id
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
      WHERE d.publication_year BETWEEN foo.first_year AND foo.first_year+foo.duration
    )
  SELECT surname,given_name, count(1) AS senior_personnel_co_author_count
  FROM
  (
    SELECT DISTINCT d.surname,d.given_name, f.surname as cci_co_author_surname, f.given_name as cci_co_author_given_name
    FROM sl_sr_all_personel_and_comp a
    INNER JOIN cci_s_author_search_results d
    ON a.author_id=d.author_id
    INNER JOIN cci_s_author_document_mappings b
    ON a.author_id=b.author_id
    INNER JOIN valid_pubs e
    ON b.scopus_id=e.scopus_id
    JOIN cci_s_author_document_mappings c
    ON b.scopus_id=c.scopus_id
    INNER JOIN cci_s_author_search_results f
    ON f.author_id=c.author_id
    WHERE b.author_id!=c.author_id
    AND d.award_number!='COMP'
    AND f.award_number!='COMP'
  ) foo
  GROUP BY surname,given_name
  ORDER BY surname,given_name
) TO '/tmp/5A_CCI_coauthor_count_during_funding_periods_CCI_mapped.csv' CSV HEADER;

/* 5b) coauthor count (total unique author_ids) per publications*/
-- CCI PUBLICATIONS ALL TIME (Note there is some document overlap with COMP group)
COPY (
  SELECT bar.*,c.doi,c.publication_year,c.title
  FROM
  (
    SELECT foo.scopus_id, count(bar.author_id) as co_author_count
    FROM
    (
      SELECT DISTINCT b.scopus_id
      FROM cci_s_author_search_results a
      INNER JOIN cci_s_author_document_mappings b
      ON a.author_id=b.author_id
      INNER JOIN sl_sr_all_personel_and_comp d
      ON a.author_id=d.author_id
      WHERE a.award_number!='COMP'
    ) foo
    INNER JOIN cci_s_author_document_mappings bar
    on foo.scopus_id = bar.scopus_id
    GROUP BY foo.scopus_id
  ) bar LEFT JOIN cci_s_documents_jeroen_updated c
  ON bar.scopus_id = c.scopus_id
  ORDER BY bar.co_author_count DESC
) TO '/tmp/5B_CCI_publication_coauthor_count_all_time.csv' CSV HEADER;
-- COMP PUBLICATIONS ALL TIME (Note there is some document overlap with CCI group)
COPY (
  SELECT bar.*,c.doi,c.publication_year,c.title
  FROM
  (
    SELECT foo.scopus_id, count(bar.author_id) as co_author_count
    FROM
    (
      SELECT DISTINCT b.scopus_id
      FROM cci_s_author_search_results a
      INNER JOIN cci_s_author_document_mappings b
      ON a.author_id=b.author_id
      INNER JOIN sl_sr_all_personel_and_comp d
      ON a.author_id=d.author_id
      WHERE a.award_number='COMP'
    ) foo
    INNER JOIN cci_s_author_document_mappings bar
    on foo.scopus_id = bar.scopus_id
    GROUP BY foo.scopus_id
  ) bar LEFT JOIN cci_s_documents_jeroen_updated c
  ON bar.scopus_id = c.scopus_id
  ORDER BY bar.co_author_count DESC
) TO '/tmp/5B_COMP_publication_coauthor_count_all_time.csv' CSV HEADER;

-- CCI PUBLICATIONS CONSIDERED DURING FUNDING PERIOD
COPY (
  WITH valid_pubs AS
    (
      SELECT DISTINCT c.scopus_id
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
      WHERE d.publication_year BETWEEN foo.first_year AND foo.first_year+foo.duration
    )
  SELECT bar.*,c.doi,c.publication_year,c.title
  FROM
  (
    SELECT foo.scopus_id, count(bar.author_id) as co_author_count
    FROM
    (
      SELECT DISTINCT b.scopus_id
      FROM cci_s_author_search_results a
      INNER JOIN cci_s_author_document_mappings b
      ON a.author_id=b.author_id
      INNER JOIN sl_sr_all_personel_and_comp d
      ON a.author_id=d.author_id
      WHERE a.award_number!='COMP'
    ) foo
    INNER JOIN cci_s_author_document_mappings bar
    on foo.scopus_id = bar.scopus_id
    GROUP BY foo.scopus_id
  ) bar
  INNER JOIN valid_pubs d
  ON d.scopus_id=bar.scopus_id
  LEFT JOIN cci_s_documents_jeroen_updated c
  ON bar.scopus_id = c.scopus_id
  ORDER BY bar.co_author_count DESC
) TO '/tmp/5B_coauthor_count_CCI_during_funding_period_subset.csv' CSV HEADER;

-- CCI PUBLICATIONS CONSIDERED 5 YEARS PRIOR TO FUNDING PERIOD
COPY (
  WITH valid_pubs AS
    (
      SELECT DISTINCT c.scopus_id
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
      WHERE d.publication_year BETWEEN foo.first_year-5 AND foo.first_year
    )
  SELECT bar.*,c.doi,c.publication_year,c.title
  FROM
  (
    SELECT foo.scopus_id, count(bar.author_id) as co_author_count
    FROM
    (
      SELECT DISTINCT b.scopus_id
      FROM cci_s_author_search_results a
      INNER JOIN cci_s_author_document_mappings b
      ON a.author_id=b.author_id
      INNER JOIN sl_sr_all_personel_and_comp d
      ON a.author_id=d.author_id
      WHERE a.award_number!='COMP'
    ) foo
    INNER JOIN cci_s_author_document_mappings bar
    on foo.scopus_id = bar.scopus_id
    GROUP BY foo.scopus_id
  ) bar
  INNER JOIN valid_pubs d
  ON d.scopus_id=bar.scopus_id
  LEFT JOIN cci_s_documents_jeroen_updated c
  ON bar.scopus_id = c.scopus_id
  ORDER BY bar.co_author_count DESC
) TO '/tmp/5B_coauthor_count_CCI_5_years_prior_to_funding_period_subset.csv' CSV HEADER;

-- CCI PUBLICATIONS CONSIDERED 5 YEARS POST FUNDING PERIOD
COPY (
  WITH valid_pubs AS
    (
      SELECT DISTINCT c.scopus_id
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
      WHERE d.publication_year BETWEEN foo.first_year+5 AND foo.first_year+10
    )
  SELECT bar.*,c.doi,c.publication_year,c.title
  FROM
  (
    SELECT foo.scopus_id, count(bar.author_id) as co_author_count
    FROM
    (
      SELECT DISTINCT b.scopus_id
      FROM cci_s_author_search_results a
      INNER JOIN cci_s_author_document_mappings b
      ON a.author_id=b.author_id
      INNER JOIN sl_sr_all_personel_and_comp d
      ON a.author_id=d.author_id
      WHERE a.award_number!='COMP'
    ) foo
    INNER JOIN cci_s_author_document_mappings bar
    on foo.scopus_id = bar.scopus_id
    GROUP BY foo.scopus_id
  ) bar
  INNER JOIN valid_pubs d
  ON d.scopus_id=bar.scopus_id
  LEFT JOIN cci_s_documents_jeroen_updated c
  ON bar.scopus_id = c.scopus_id
  ORDER BY bar.co_author_count DESC
) TO '/tmp/5B_coauthor_count_CCI_5_years_post_funding_period_subset.csv' CSV HEADER;

-- COMP PUBLICATIONS CONSIDERED DURING 5 YEAR PERIOD BEFORE AND AFTER FIRST YEAR
COPY (
  WITH valid_pubs AS
    (
      SELECT DISTINCT c.scopus_id
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
      WHERE d.publication_year BETWEEN foo.first_year-duration AND foo.first_year+foo.duration
    )
  SELECT bar.*,c.doi,c.publication_year,c.title
  FROM
  (
    SELECT foo.scopus_id, count(bar.author_id) as co_author_count
    FROM
    (
      SELECT DISTINCT b.scopus_id
      FROM cci_s_author_search_results a
      INNER JOIN cci_s_author_document_mappings b
      ON a.author_id=b.author_id
      INNER JOIN sl_sr_all_personel_and_comp d
      ON a.author_id=d.author_id
      WHERE a.award_number='COMP'
    ) foo
    INNER JOIN cci_s_author_document_mappings bar
    on foo.scopus_id = bar.scopus_id
    GROUP BY foo.scopus_id
  ) bar
  INNER JOIN valid_pubs d
  ON d.scopus_id=bar.scopus_id
  LEFT JOIN cci_s_documents_jeroen_updated c
  ON bar.scopus_id = c.scopus_id
  ORDER BY bar.co_author_count DESC
) TO '/tmp/5B_coauthor_count_COMP_plus_minus_5_year_subset.csv' CSV HEADER;
