-- This script creates indices for all smokeload derwent tables.

-- Author: VJ Davey
-- Created: 08/22/2017

SET default_tablespace = indexes;

DROP INDEX IF EXISTS derwent_appl_idx;
DROP INDEX IF EXISTS patent_num_orig_index;
DROP INDEX IF EXISTS patent_num_wila_index;
DROP INDEX IF EXISTS cited_patent_orig_index;
DROP INDEX IF EXISTS derwent_pat_cit_index2;

CREATE INDEX derwent_appl_idx ON derwent_patents USING btree (appl_num_orig);
CREATE INDEX patent_num_orig_index ON derwent_patents USING btree (patent_num_orig);
CREATE INDEX patent_num_wila_index ON derwent_patents USING btree (patent_num_wila);
CREATE INDEX cited_patent_orig_index ON derwent_pat_citations USING btree (patent_num_orig, cited_patent_orig);
CREATE INDEX derwent_pat_cit_index2 ON derwent_pat_citations USING btree (cited_patent_orig, patent_num_orig);

