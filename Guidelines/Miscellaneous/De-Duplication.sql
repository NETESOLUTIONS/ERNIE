-- region cg_uids
-- 1.3s
DELETE
FROM
  cg_uids cu1
WHERE EXISTS(SELECT 1
             FROM cg_uids cu2
             WHERE cu2.uid = cu1.uid
               AND cu2.ctid > cu1.ctid);

-- <0.1s
ALTER TABLE cg_uids
  ALTER COLUMN uid SET NOT NULL,
  ALTER COLUMN title SET NOT NULL,
  ALTER COLUMN status SET NOT NULL,
  ALTER COLUMN load_date SET NOT NULL;

-- 0.7s
ALTER TABLE cg_uids
  ADD CONSTRAINT cg_uids_pk PRIMARY KEY (uid);
-- endregion

-- region cg_uid_pmid_mapping
-- 0.4s
DELETE
FROM
  cg_uid_pmid_mapping cupm1
WHERE EXISTS(SELECT 1
             FROM cg_uid_pmid_mapping cupm2
             WHERE cupm2.uid = cupm1.uid
               AND cupm2.pmid = cupm1.pmid
               AND cupm2.ctid > cupm1.ctid);

-- <0.1s
ALTER TABLE cg_uid_pmid_mapping
  ALTER COLUMN uid SET NOT NULL,
  ALTER COLUMN pmid SET NOT NULL;

-- 0.1s
ALTER TABLE cg_uid_pmid_mapping
  ADD CONSTRAINT cg_uid_pmid_mapping_pk PRIMARY KEY (uid);
-- endregion