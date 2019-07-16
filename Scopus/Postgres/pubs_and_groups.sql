SELECT * FROM scopus_publication_groups WHERE sgr=20384762;

SELECT * FROM scopus_publications WHERE sgr=20384762;

SELECT st.* FROM scopus_titles st
JOIN scopus_publications sp ON sp.scp = st.scp AND sp.sgr=20384762;

SELECT count(1) FROM scopus_publications
WHERE scp <> sgr;
-- 0
-- 2m:18s