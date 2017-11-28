drop table if exists solr_5k_out_temp;
create table solr_5k_out_temp as
select a.source_id, concat(a.publication_year,' ', a.document_title,' ', a.source_title) as pub_data
from wos_publications a
where random() < 0.3 limit 5000;


drop table if exists solr_5k_out;
create table solr_5k_out as
  select a.source_id, 0 as label,  concat(string_agg(a.full_name,' '), ' ', b.pub_data) as citation
  from wos_authors a
  inner join solr_5k_out_temp b
  on a.source_id = b.source_id group by a.source_id, b.pub_data;


drop table if exists solr_65m_temp;
create table solr_65m_temp   tablespace ernie_wos_tbs as
  select source_id, concat(publication_year,' ', document_title,' ', source_title) as pub_data
  from wos_publications
  where source_id not in (select source_id from solr_5k_out);

create index solr_test_wos_ind on solr_65m_temp using hash(source_id) tablespace ernie_index_tbs;

drop table if exists solr_65m;
create table solr_65m  tablespace ernie_wos_tbs as
  select a.source_id, concat(string_agg(a.full_name,' '), ' ', b.pub_data) as citation
  from wos_authors a
  inner join solr_65m_temp b
  on a.source_id = b.source_id group by a.source_id, b.pub_data;

drop table if exists solr_5k_in;
create table solr_5k_in as
  select source_id, 1 as label, citation
  from solr_65m where random() < 0.01 limit 5000;

drop table if exists solr_10k_inout;
create table solr_10k_inout as
  Select * from solr_5k_in union
  Select * from solr_5k_out;
