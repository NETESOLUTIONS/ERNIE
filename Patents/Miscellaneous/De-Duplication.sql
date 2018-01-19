-- region derwent_patents
ALTER TABLE derwent_patents
  ALTER COLUMN patent_num_orig SET NOT NULL,
  ALTER COLUMN patent_type SET NOT NULL;
-- 2m:16s

ALTER TABLE derwent_patents
  ADD CONSTRAINT derwent_patents_pk PRIMARY KEY (patent_num_orig, patent_type)
USING INDEX TABLESPACE ernie_index_tbs;
-- 1m:20s

DROP INDEX IF EXISTS patent_num_orig_index;
-- endregion

-- region derwent_agents
ALTER TABLE derwent_agents
  ALTER COLUMN patent_num SET NOT NULL,
  ALTER COLUMN organization_name SET NOT NULL;
-- 9.3s

DELETE
FROM derwent_agents t1
WHERE EXISTS(SELECT 1
             FROM derwent_agents t2
             WHERE t2.patent_num = t1.patent_num
               AND t2.organization_name = t1.organization_name
               AND t2.ctid > t1.ctid);
-- 1m:54s

ALTER TABLE derwent_agents
  ADD CONSTRAINT derwent_agents_pk PRIMARY KEY (patent_num, organization_name)
USING INDEX TABLESPACE ernie_index_tbs;
-- 1m:02s
-- endregion

-- region derwent_assignees
DELETE
FROM derwent_assignees
WHERE assignee_name IS NULL;
-- 7.6s

ALTER TABLE derwent_assignees
  ALTER COLUMN assignee_name SET NOT NULL;
-- 0.9s

DELETE
FROM derwent_assignees t1
WHERE EXISTS(SELECT 1
             FROM derwent_assignees t2
             WHERE t2.patent_num = t1.patent_num
               AND t2.assignee_name = t1.assignee_name
               AND coalesce(t2.role, '') = coalesce(t1.role, '')
               AND coalesce(t2.city, '') = coalesce(t1.city, '')
               AND coalesce(t2.state, '') = coalesce(t1.state, '')
               AND coalesce(t2.country, '') = coalesce(t1.country, '')
               AND t2.ctid > t1.ctid);
-- 3m:07s

CREATE UNIQUE INDEX derwent_assignees_uk
  ON derwent_assignees (patent_num, assignee_name, role, city)
TABLESPACE ernie_index_tbs;
-- 1m:48s
-- endregion

-- region derwent_assignors
ALTER TABLE derwent_assignors
  ALTER COLUMN patent_num SET NOT NULL,
  ALTER COLUMN assignor SET NOT NULL;
-- 11.9s

DELETE
FROM derwent_assignors da1
WHERE EXISTS(SELECT 1
             FROM derwent_assignors da2
             WHERE da2.patent_num = da1.patent_num
               AND da2.assignor = da1.assignor
               AND da2.ctid > da1.ctid);
-- 2m:28s

ALTER TABLE derwent_assignors
  ADD CONSTRAINT derwent_assignors_pk PRIMARY KEY (patent_num, assignor)
USING INDEX TABLESPACE ernie_index_tbs;
-- 1m:27s
-- endregion

-- region derwent_examiners
ALTER TABLE derwent_examiners
  ALTER COLUMN patent_num SET NOT NULL,
  ALTER COLUMN examiner_type SET NOT NULL,
  ALTER COLUMN full_name SET NOT NULL;
-- 0.7s

DELETE
FROM derwent_examiners t1
WHERE EXISTS(SELECT 1
             FROM derwent_examiners t2
             WHERE t2.patent_num = t1.patent_num
               AND t2.examiner_type = t1.examiner_type
               AND t2.ctid > t1.ctid);
-- 10.9s

ALTER TABLE derwent_examiners
  ADD CONSTRAINT derwent_examiners_pk PRIMARY KEY (patent_num, examiner_type)
USING INDEX TABLESPACE ernie_index_tbs;
-- 1m:08s
-- endregion

-- region derwent_inventors
ALTER TABLE derwent_inventors
  ALTER COLUMN patent_num SET NOT NULL,
  -- TODO inventors should be renamed to inventor
  ALTER COLUMN inventors SET NOT NULL;
-- 1.4s

DELETE
FROM derwent_inventors t1
WHERE EXISTS(SELECT 1
             FROM derwent_inventors t2
             WHERE t2.patent_num = t1.patent_num
               AND t2.inventors = t1.inventors
               AND t2.ctid > t1.ctid);
-- 4m:12s

ALTER TABLE derwent_inventors
  ADD CONSTRAINT derwent_inventors_pk PRIMARY KEY (patent_num, inventors)
USING INDEX TABLESPACE ernie_index_tbs;
-- 2m:21s
-- endregion

-- region derwent_lit_citations
ALTER TABLE derwent_lit_citations
  ALTER COLUMN patent_num_orig SET NOT NULL,
  ALTER COLUMN cited_literature SET NOT NULL;
-- 20.1s

DELETE
FROM derwent_lit_citations
WHERE trim(both ' ' || chr(10) from cited_literature) = '';
-- 23.2s

DELETE
FROM derwent_lit_citations dlc1
WHERE EXISTS(SELECT 1
             FROM derwent_lit_citations dlc2
             WHERE dlc2.patent_num_orig = dlc1.patent_num_orig
               AND dlc2.cited_literature = dlc1.cited_literature
               AND dlc2.ctid > dlc1.ctid);
-- 16m:09s

CREATE UNIQUE INDEX derwent_lit_citations_uk
  ON derwent_lit_citations (patent_num_orig, md5(cited_literature))
TABLESPACE ernie_index_tbs;
-- 5m:26s
-- endregion

-- region derwent_pat_citations
ALTER TABLE derwent_pat_citations
  ALTER COLUMN patent_num_orig SET NOT NULL,
  ALTER COLUMN country SET NOT NULL,
  ALTER COLUMN cited_patent_orig SET NOT NULL;
-- 3m:12s

DELETE
FROM derwent_pat_citations dpc1
WHERE EXISTS(SELECT 1
             FROM derwent_pat_citations dpc2
             WHERE dpc2.patent_num_orig = dpc1.patent_num_orig
               AND dpc2.country = dpc1.country
               AND dpc2.cited_patent_orig = dpc1.cited_patent_orig
               AND dpc2.ctid > dpc1.ctid);
-- 1h:12m

ALTER TABLE derwent_pat_citations
  ADD CONSTRAINT derwent_pat_citations_pk PRIMARY KEY (patent_num_orig, country, cited_patent_orig)
USING INDEX TABLESPACE ernie_index_tbs;
-- 27m:27s
-- endregion