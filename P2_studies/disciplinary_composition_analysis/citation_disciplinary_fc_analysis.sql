
/*
 Author:  Djamil Lakhdar-Hamina

 The point of this experiment is to substantiate or provide evidence for the negative claim that we make about Uzzi's shuffling algorithm and method i.e.
 the shuffling algorithm may preserve n number of citations in a dataset of n publications but it does not preserve the proportions between disciplines
 with the consequence that the sample distribution is different from the distribution sampled. In the following, George and I proceeded with the following
 steps:

 1. Take a data set for a domain say arts and humanities
 3. Shuffle the dataset in 1. with uzzi algorithm
 4. Find common publications between original datset in 2. and shuffled in 3.
 5. Now count the number of subjects wrt to the works cited by each publication
 6. 5. but for shuffled dataset

 */


\set ON_ERROR_STOP on
\set ECHO all
\timing


SET DEFAULT_TABLESPACE=djamil;

-- Arts and Humanities

create table t1 as (with cte as
(
select a.cited_source_uid,
       b.subject
        from dataset1985_ah
            a INNER JOIN wos_publication_subjects b on a.cited_source_uid=b.source_id
        where a.source_id in  ((select source_id from dataset1985_ah)
        intersect (select source_id from dataset1985_ah_shuffle)) and b.subject_classification_type='extended'
)
select subject,count(cited_source_uid) from cte group by subject order by subject);



create table t2 as (with cte as
(
select
       a.cited_source_uid,
       b.subject
        from dataset1985_ah_shuffle
           a INNER JOIN wos_publication_subjects b on a.cited_source_uid=b.source_id
            where a.source_id in  ((select source_id from dataset1985_ah)
            intersect (select source_id from dataset1985_ah_shuffle)) and b.subject_classification_type='extended'
)
select subject,count(cited_source_uid) from cte group by subject order by subject);


create table t3 as select a.subject as orig ,b.subject as shuffle ,a.count as orig_count,b.count as shuffle_count from t1 a FULL OUTER JOIN t2 b on a.subject=b.subject;
alter table t3 add column merged_subjects varchar;
update t3 set merged_subjects=orig;
update t3 set merged_subjects=shuffle where merged_subjects is null;

create table t4 as select merged_subjects, orig_count, shuffle_count from t3;
update t4 set orig_count=0 where orig_count is null;
\copy (select * from t4) to '~/dataset1985_ah_shuffle_subject_analysis.csv' CSV HEADER DELIMITER ',';

-- Update t4 so that there is the fc-calculation

UPDATE t4 SET  orig_count= 1 WHERE orig_count = 0;
UPDATE t4 SET  shuffle_count= 1 WHERE shuffle_count IS NULL ;

ALTER TABLE t4 ADD COLUMN fc NUMERIC;
UPDATE t4 SET fc=0 WHERE fc IS NULL ;
UPDATE t4 SET fc=shuffle_count/orig_count WHERE shuffle_count > orig_count ;
UPDATE t4 SET fc=-orig_count/shuffle_count WHERE orig_count> shuffle_count;


--Life science and biology

create table t5 as (with cte as
(
select a.cited_source_uid,
       b.subject
        from dataset1985_lsb
            a INNER JOIN wos_publication_subjects b on a.cited_source_uid=b.source_id
        where a.source_id in  ((select source_id from dataset1985_lsb)
        intersect (select source_id from dataset1985_lsb_shuffle)) and b.subject_classification_type='extended'
)
select subject,count(cited_source_uid) from cte group by subject order by subject);



create table t6 as (with cte as
(
select
       a.cited_source_uid,
       b.subject
        from dataset1985_lsb_shuffle
           a INNER JOIN wos_publication_subjects b on a.cited_source_uid=b.source_id
            where a.source_id in  ((select source_id from dataset1985_lsb) intersect (select source_id from dataset1985_lsb_shuffle)) and b.subject_classification_type='extended'
)
select subject,count(cited_source_uid) from cte group by subject order by subject);


create table t7 as select a.subject as orig ,b.subject as shuffle ,a.count as orig_count,b.count as shuffle_count from t5 a FULL OUTER JOIN t6 b on a.subject=b.subject;
alter table t7 add column merged_subjects varchar;
update t7 set merged_subjects=orig;
update t7 set merged_subjects=shuffle where merged_subjects is null;

create table t8 as select merged_subjects, orig_count, shuffle_count from t7;
update t8 set orig_count=0 where orig_count is null;
\copy (select * from t8) to '~/dataset1985_lsb_shuffle_subject_analysis.csv' CSV HEADER DELIMITER ',';

--fc calculation
UPDATE t8 SET  orig_count= 1 WHERE orig_count = 0;
UPDATE t8 SET  shuffle_count= 1 WHERE shuffle_count IS NULL ;

ALTER TABLE t8 ADD COLUMN fc NUMERIC;
UPDATE t8 SET fc=0 WHERE fc IS NULL ;
UPDATE t8 SET fc=shuffle_count/orig_count WHERE shuffle_count > orig_count ;
UPDATE t8 SET fc=-orig_count/shuffle_count WHERE orig_count> shuffle_count;

-- Physical Science

create table t9 as (with cte as
(
select a.cited_source_uid,
       b.subject
        from dataset1985_ps
            a INNER JOIN wos_publication_subjects b on a.cited_source_uid=b.source_id
        where a.source_id in  ((select source_id from dataset1985_ps)
        intersect (select source_id from dataset1985_ps_shuffle)) and b.subject_classification_type='extended'
)
select subject,count(cited_source_uid) from cte group by subject order by subject);



create table t10 as (with cte as
(
select
       a.cited_source_uid,
       b.subject
        from dataset1985_ps_shuffle
           a INNER JOIN wos_publication_subjects b on a.cited_source_uid=b.source_id
            where a.source_id in  ((select source_id from dataset1985_ps)
            intersect (select source_id from dataset1985_ps_shuffle)) and b.subject_classification_type='extended'
)
select subject,count(cited_source_uid) from cte group by subject order by subject);


create table t11 as select a.subject as orig ,b.subject as shuffle ,a.count as orig_count,b.count as shuffle_count from t9 a FULL OUTER JOIN t10 b on a.subject=b.subject;
alter table t11 add column merged_subjects varchar;
update t11 set merged_subjects=orig;
update t11 set merged_subjects=shuffle where merged_subjects is null;

create table t12 as select merged_subjects, orig_count, shuffle_count from t11;
update t12 set orig_count=1 where orig_count is null;
\copy (select * from t12) to '~/dataset1985_ah_shuffle_subject_analysis.csv' CSV HEADER DELIMITER ',';

--fc caluclation
UPDATE t12 SET  orig_count= 1 WHERE orig_count = 0;
UPDATE t12 SET  shuffle_count= 1 WHERE shuffle_count IS NULL ;

ALTER TABLE t12 ADD COLUMN fc NUMERIC;
UPDATE t12 SET fc=0 WHERE fc IS NULL ;
UPDATE t12 SET fc=shuffle_count/orig_count WHERE shuffle_count > orig_count ;
UPDATE t12 SET fc=-orig_count/shuffle_count WHERE orig_count> shuffle_count;


-- Tech

create table t13 as (with cte as
(
select a.cited_source_uid,
       b.subject
        from dataset1985_tech
            a INNER JOIN wos_publication_subjects b on a.cited_source_uid=b.source_id
        where a.source_id in  ((select source_id from dataset1985_tech)
        intersect (select source_id from dataset1985_tech_shuffle)) and b.subject_classification_type='extended'
)
select subject,count(cited_source_uid) from cte group by subject order by subject);



create table t14 as (with cte as
(
select
       a.cited_source_uid,
       b.subject
        from dataset1985_tech_shuffle
           a INNER JOIN wos_publication_subjects b on a.cited_source_uid=b.source_id
            where a.source_id in  ((select source_id from dataset1985_tech)
            intersect (select source_id from dataset1985_tech_shuffle)) and b.subject_classification_type='extended'
)
select subject,count(cited_source_uid) from cte group by subject order by subject);


create table t15 as select a.subject as orig ,b.subject as shuffle ,a.count as orig_count,b.count as shuffle_count from t13 a FULL OUTER JOIN t14 b on a.subject=b.subject;
alter table t15 add column merged_subjects varchar;
update t15 set merged_subjects=orig;
update t15 set merged_subjects=shuffle where merged_subjects is null;

create table t16 as select merged_subjects, orig_count, shuffle_count from t15;
update t16 set orig_count=1 where orig_count is null;
\copy (select * from t16) to '~/dataset1985_ah_shuffle_subject_analysis.csv' CSV HEADER DELIMITER ',';

--fc calculation
UPDATE t16 SET  orig_count= 1 WHERE orig_count = 0;
UPDATE t16 SET  shuffle_count= 1 WHERE shuffle_count IS NULL ;

ALTER TABLE t16 ADD COLUMN fc NUMERIC;
UPDATE t16 SET fc=0 WHERE fc IS NULL ;
UPDATE t16 SET fc=shuffle_count/orig_count WHERE shuffle_count > orig_count ;
UPDATE t16 SET fc=-orig_count/shuffle_count WHERE orig_count> shuffle_count;


-- Social Science

create table t17 as (with cte as
(
select a.cited_source_uid,
       b.subject
        from dataset1985_ss
            a INNER JOIN wos_publication_subjects b on a.cited_source_uid=b.source_id
        where a.source_id in  ((select source_id from dataset1985_ss)
        intersect (select source_id from dataset1985_ss_shuffle)) and b.subject_classification_type='extended'
)
select subject,count(cited_source_uid) from cte group by subject order by subject);



create table t18 as (with cte as
(
select
       a.cited_source_uid,
       b.subject
        from dataset1985_ss_shuffle
           a INNER JOIN wos_publication_subjects b on a.cited_source_uid=b.source_id
            where a.source_id in ((select source_id from dataset1985_ss)
            intersect (select source_id from dataset1985_ss_shuffle)) and b.subject_classification_type='extended'
)
select subject,count(cited_source_uid) from cte group by subject order by subject);


create table t19 as select a.subject as orig ,b.subject as shuffle ,a.count as orig_count,b.count as shuffle_count from t17 a FULL OUTER JOIN t18 b on a.subject=b.subject;
alter table t19 add column merged_subjects varchar;
update t19 set merged_subjects=orig;
update t19 set merged_subjects=shuffle where merged_subjects is null;

create table t20 as select merged_subjects, orig_count, shuffle_count from t19;
update t20 set orig_count=1 where orig_count is null;
\copy (select * from t20) to '~/dataset1985_ah_shuffle_subject_analysis.csv' CSV HEADER DELIMITER ',';

--fc calculation
UPDATE t20 SET  orig_count= 1 WHERE orig_count = 0;
UPDATE t20 SET  shuffle_count= 1 WHERE shuffle_count IS NULL ;

ALTER TABLE t20 ADD COLUMN fc NUMERIC;
UPDATE t20 SET fc=0 WHERE fc IS NULL ;
UPDATE t20 SET fc=shuffle_count/orig_count WHERE shuffle_count > orig_count ;
UPDATE t20 SET fc=-orig_count/shuffle_count WHERE orig_count> shuffle_count;


-- Change to intuitive name

alter table t4
rename to dataset1985_ah_disc_comp_fc_calc;
alter table t8
rename to dataset1985_lsb_disc_comp_fc_calc;
alter table t12
rename to dataset1985_ps_disc_comp_fc_calc;
alter table t16
rename to dataset1985_tech_disc_comp_fc_calc;
alter table t20
rename to dataset1985_ss_disc_comp_fc_calc;



