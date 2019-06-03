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


SET DEFAULT_TABLESPACE='p2_studies';

-- calculate fc
SELECT :
'dataset1' AS dataset1,
'dataset2' AS dataset2 ,
'shuffled_dataset' AS shuffled_dataset
FROM (
create table t1 as (with cte as
(
select a.cited_source_uid,
       b.subject
        from :dataset1
            a INNER JOIN wos_publication_subjects b on a.cited_source_uid=b.source_id
        where a.source_id in ((select source_id from :dataset2)
        intersect (select source_id from shuffled_dataset) and b.subject_classification_type='extended'
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
\copy (select * from t4) to '~/dataset1985_ah_shuffle_subject_analysis.csv' CSV HEADER DELIMITER ','; ))
