SELECT scp, grant_id
FROM scopus_grants
WHERE grant_id ~ '.*R01.MH'
LIMIT 100