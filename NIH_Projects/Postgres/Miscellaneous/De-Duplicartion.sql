-- region exporter_projects
DELETE FROM exporter_projects ep
WHERE EXISTS (
  SELECT 1
  FROM exporter_projects ep2
  WHERE ep2.application_id = ep.application_id
  AND ep2.ctid > ep.ctid
);

ALTER TABLE exporter_projects
  ALTER COLUMN application_id TYPE INTEGER USING application_id::INTEGER;

ALTER TABLE exporter_projects
  ADD CONSTRAINT exporter_projects_pk PRIMARY KEY (application_id);
-- endregion

-- region exporter_publink
-- 13s
DELETE FROM exporter_publink t1
WHERE EXISTS(SELECT 1
             FROM exporter_publink t2
             WHERE t2.pmid = t1.pmid AND t2.project_number = t1.project_number AND t2.ctid > t1.ctid);

ALTER TABLE exporter_publink
  ADD CONSTRAINT exporter_publink_pk PRIMARY KEY (pmid, project_number);

-- 57s
UPDATE exporter_publink
SET admin_ic = substring(project_number, 4, 2);

-- 1.5s
ALTER TABLE exporter_publink
  ALTER COLUMN admin_ic SET NOT NULL;

-- 5.4s
CREATE INDEX IF NOT EXISTS ep_pmid_admin_ic_i
  ON exporter_publink (pmid, admin_ic);

SELECT
  a.*,
  EXISTS(SELECT 1
         FROM exporter_publink b
         WHERE a.pmid_int = b.pmid AND b.admin_ic = 'DA') AS nida_support,
  EXISTS(SELECT 1
         FROM exporter_publink b
         WHERE a.pmid_int = b.pmid AND b.admin_ic <> 'DA') AS other_hhs_support
FROM chackoge.grant_tmp a;
-- endregion