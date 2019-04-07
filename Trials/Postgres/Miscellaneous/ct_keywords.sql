SELECT *
FROM ct_keywords ck
WHERE keyword = 'Neuropathic pain';

SELECT *
FROM ct_keywords ck
JOIN ct_outcomes co USING (nct_id)
WHERE ck.keyword = 'Neuropathic pain'
AND co.measure LIKE '%Sleep%'
ORDER BY co.outcome_type, co.time_frame;

-- Keywords by trial
SELECT nct_id, keyword
FROM ct_keywords
WHERE nct_id = 'NCT02820558';

-- Aggregated keywords, ordered alphabetically (case-insensitively)
SELECT nct_id, string_agg(keyword, ', ' ORDER BY lower(keyword))
FROM ct_keywords
WHERE nct_id = 'NCT02820558'
GROUP BY nct_id;
