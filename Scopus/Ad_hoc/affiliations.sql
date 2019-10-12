-- Staged duplicates
SELECT *
  FROM stg_scopus_affiliations t1
 WHERE EXISTS(SELECT 1
                FROM stg_scopus_affiliations t2
               WHERE (t2.scp, t2.affiliation_no) IS NOT DISTINCT FROM (t1.scp, t1.affiliation_no)
                 AND t2.ctid <> t1.ctid)
-- ORDER BY scp, affiliation_no
LIMIT 100;
-- 85062592144 + 1
