-- Query to bin ten_year_cocit_union_freq11_freqsum into 1000 bins

CREATE TABLE cc2.ten_year_cocit_union_freq11_freqsum_bins TABLESPACE p2_studies_tbs AS
SELECT *, ntile(1000) OVER (ORDER BY fsum DESC ,num_nulls DESC,cited_1,cited_2) AS bin
FROM cc2.ten_year_cocit_union_freq11_freqsum;


--kinetics data ddl
CREATE TABLE cc2.kinetics_data
(
    cited_1             BIGINT,
    cited_2             BIGINT,
    co_cited_year       SMALLINT,
    frequency           INTEGER,
    first_co_cited_year SMALLINT,
    peak_frequency      INTEGER,
    first_peak_year     SMALLINT,
    min_frequency       INTEGER,
    first_possible_year SMALLINT,
    l_t                 decimal,
    sb                  decimal
) TABLESPACE p2_studies_tbs;


--sb data results
CREATE TABLE cc2.sb_results
(
    cited_1 BIGINT,
    cited_2 BIGINT,
    sb      DECIMAL
) TABLESPACE p2_studies_tbs;


ALTER TABLE cc2.ten_year_cocit_union_freq11_freqsum_bins
    ADD COLUMN t_o decimal DEFAULT NULL;

ALTER TABLE cc2.ten_year_cocit_union_freq11_freqsum_bins
    ADD COLUMN jc1 decimal DEFAULT NULL;

ALTER TABLE cc2.ten_year_cocit_union_freq11_freqsum_bins
    ADD COLUMN jc2 decimal DEFAULT NULL;

ALTER TABLE cc2.ten_year_cocit_union_freq11_freqsum_bins
    ADD COLUMN normalized_co_citation_freq DECIMAL NULL;


CREATE TABLE cc2.normalized_co_citation_frequency_50 AS
SELECT cited_1, cited_2, scopus_frequency, scc.citation_count AS cited_1_count, scc2.citation_count AS cited_2_count
FROM cc2.ten_year_cocit_union_freq11_freqsum_bins tycuf11fb
         JOIN cc2.scopus_citation_counts scc
              ON scc.scp = tycuf11fb.cited_1
         JOIN cc2.scopus_citation_counts scc2
              ON scc2.scp = tycuf11fb.cited_2
WHERE tycuf11fb.scopus_frequency >= 50;

UPDATE cc2.normalized_co_citation_frequency_50
SET normalized_co_citation_frequency=scopus_frequency / sqrt(cited_1_count * cited_2_count::decimal);



CREATE TABLE cc2.co_citation_data
(
    cited_1             BIGINT,
    cited_2             BIGINT,
    jc2                 DECIMAL,
    sb                  decimal,
    t_o                 decimal,
    jc1                 decimal,
    cited_1_year        SMALLINT,
    cited_2_year        SMALLINT,
    first_co_cited_year SMALLINT,
    refdiff             SMALLINT,
    mindiff             SMALLINT,
    maxdiff             SMALLINT,
    fsum                BIGINT,
    scopus_frequency    BIGINT

) TABLESPACE p2_studies_tbs;