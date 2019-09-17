set search_path = ':';
\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

create procedure scopus_create_indexes()
    language plpgsql
as
$$
BEGIN
    set search_path='jenkins' ;
   CREATE INDEX sa_author_indexed_name_i ON jenkins.scopus_authors USING btree (author_indexed_name);
   CREATE INDEX sce_conf_code_conf_name_i ON jenkins.scopus_conf_editors USING btree (conf_code, conf_name);
   CREATE INDEX scp_conf_code_conf_name_i ON jenkins.scopus_conf_proceedings USING btree (conf_code, conf_name);
   CREATE INDEX spg_pub_year_i ON jenkins.scopus_publication_groups USING btree (pub_year);
   CREATE INDEX sp_ernie_source_id_i ON jenkins.scopus_publications USING btree (ernie_source_id);
   CREATE INDEX sp_sgr_i ON jenkins.scopus_publications USING btree (sgr);
   CREATE INDEX scopus_references_partition_1_ref_sgr_idx ON jenkins.scopus_references_partition_1 USING btree (ref_sgr);
   CREATE INDEX scopus_references_partition_2_ref_sgr_idx ON jenkins.scopus_references_partition_2 USING btree (ref_sgr);
   CREATE INDEX scopus_references_partition_3_ref_sgr_idx ON jenkins.scopus_references_partition_3 USING btree (ref_sgr);
   CREATE INDEX scopus_references_partition_4_ref_sgr_idx ON jenkins.scopus_references_partition_4 USING btree (ref_sgr);
   CREATE INDEX scopus_references_partition_5_ref_sgr_idx ON jenkins.scopus_references_partition_5 USING btree (ref_sgr);
   CREATE INDEX scopus_references_partition_6_ref_sgr_idx ON jenkins.scopus_references_partition_6 USING btree (ref_sgr);
   CREATE INDEX scopus_references_partition_7_ref_sgr_idx ON jenkins.scopus_references_partition_7 USING btree (ref_sgr);
   CREATE INDEX scopus_references_partition_8_ref_sgr_idx ON jenkins.scopus_references_partition_8 USING btree (ref_sgr);
   CREATE UNIQUE INDEX scopus_sources_source_id_issn_isbn_uk ON jenkins.scopus_sources USING btree (source_id, issn_main, isbn_main);
   CREATE INDEX st_title_fti ON jenkins.scopus_titles USING gin (to_tsvector('english'::regconfig, title));
END;
$$;
