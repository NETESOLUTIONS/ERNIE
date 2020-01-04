-- Query to bin ten_year_cocit_union_freq11_freqsum into 1000 bins

CREATE TABLE cc2.ten_year_cocit_union_freq11_freqsum_bins TABLESPACE p2_studies_tbs AS
SELECT *, ntile(1000) OVER (ORDER BY fsum DESC ,num_nulls DESC,cited_1,cited_2) AS bin
FROM cc2.ten_year_cocit_union_freq11_freqsum;
