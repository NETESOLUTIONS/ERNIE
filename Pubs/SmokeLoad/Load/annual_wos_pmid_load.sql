

-- Author : Samet Keserci
-- Date   : 10/10/1984
-- Aim    : Annual Loading of WoS pmid mapping table.
-- Usage  : psql -d -pardi -f annual_wos_pmid_load.sql -v file_dir=write_file_diretory_to_here_as_csv_format  (NOT in qoute)

-- load incoming raw table
drop table if exists pre_wos_pmid_mapping;
create table pre_wos_pmid_mapping
  (
  wos_uid varchar(30),
  pmid varchar(30)
  );

--
copy pre_wos_pmid_mapping from :'file_dir' with delimiter '|' csv header;

-- drop oldest table
drop table if exists old_wos_pmid_mapping;

-- save current one as old
alter table wos_pmid_mapping rename to old_wos_pmid_mapping;

-- curate the new data and load it.
create table wos_pmid_mapping as
  select a.*, substring(pmid,9)::int as pmid_int
  from pre_wos_pmid_mapping a
  where pmid is not null and wos_uid is not null;

-- create sequence
alter table wos_pmid_mapping add column wos_pmid_seq serial;
