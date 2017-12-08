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