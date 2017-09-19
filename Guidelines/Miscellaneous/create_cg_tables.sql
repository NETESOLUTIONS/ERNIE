
-- Author: Samet Keserci
-- Date: 03/23/2016



create table update_log_cg
(
id serial,
last_updated timestamp,
num_current_uid integer,
num_expired_uid integer,
num_pmid integer
) tablespace ernie_cg_tbs ;


drop table if exists new_cg_uids;
create table new_cg_uids
(
uid varchar(30),
title varchar(5000),
load_date date,
expire_date date,
status varchar(30)
)
tablespace ernie_cg_tbs;

create table cg_uids
(
uid varchar(30),
title varchar(5000),
load_date date,
expire_date date,
status varchar(30)
)
tablespace ernie_cg_tbs;


drop table if exists new_cg_uid_pmid_mapping;
create table new_cg_uid_pmid_mapping
(
uid varchar(30),
pmid varchar(50)
)
tablespace ernie_cg_tbs;


drop table if exists new_cg_uid_pmid_mapping;
create table new_cg_uid_pmid_mapping
(
uid varchar(30),
pmid varchar(50)
)
tablespace ernie_cg_tbs;


create table cg_uid_pmid_mapping
(
uid varchar(30),
pmid varchar(50)
)
tablespace ernie_cg_tbs;
