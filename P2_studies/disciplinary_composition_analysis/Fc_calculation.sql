/*
 Author:  Djamil Lakhdar-Hamina

 The point of this experiment is to substantiate or provide evidence for the negative claim that we make about Uzzi's shuffling algorithm and method i.e.
 the shuffling algorithm may preserve n number of citations in a dataset of n publications but it does not preserve the proportions between disciplines
 with the consequence that the sample distribution is different from the distribution sampled. In the following, George and I proceeded with the following
 steps:

 */


\set ON_ERROR_STOP on
\set ECHO all
\timing


SET DEFAULT_TABLESPACE=P2_studies;

-- Arts and Humanities

create table t1 as (with cte as
(
select a.cited_source_uid,
       b.subject
        from :dataset1985_subject_subject
            a INNER JOIN wos_publication_subjects b on a.cited_source_uid=b.source_id
        where a.source_id in  ((select source_id from :dataset1985_subject)
        intersect (select source_id from :dataset1985_shuffle_subject)) and b.subject_classification_type='extended'
)
select subject,count(cited_source_uid) from cte group by subject order by subject);


create table t2 as (with cte as
(
select
       a.cited_source_uid,
       b.subject
        from :dataset1985_shuffle_subject
           a INNER JOIN wos_publication_subjects b on a.cited_source_uid=b.source_id
            where a.source_id in  ((select source_id from :dataset1985_subject)
            intersect (select source_id from :dataset1985_shuffle_subject)) and b.subject_classification_type='extended'
)
select subject,count(cited_source_uid) from cte group by subject order by subject);


create table t3 as select a.subject as orig ,b.subject as shuffle ,a.count as orig_count,b.count as shuffle_count from t1 a FULL OUTER JOIN t2 b on a.subject=b.subject;
alter table t3 add column subject_of_citation varchar;
update t3 set subject_of_citation=orig;
update t3 set subject_of_citation=shuffle where subject_of_citation is null;

create table :t4 as select subject_of_citation, orig_count, shuffle_count from t3;
update :t4 set orig_count=1 where orig_count is null;
-- \copy (select * from :t4) to '~/dataset1985_ah_shuffle_subject_analysis.csv' CSV HEADER DELIMITER ',';--
ALTER TABLE :t4 ADD COLUMN fc NUMERIC;
UPDATE :t4 SET fc=0 WHERE fc IS NULL ;
UPDATE :t4 SET shuffle_count= 1 WHERE shuffle_count IS NULL ;
UPDATE :t4 SET fc=shuffle_count/orig_count WHERE shuffle_count > orig_count ;
UPDATE :t4 SET fc=-orig_count/shuffle_count WHERE orig_count> shuffle_count;
UPDATE :t4 SET fc=1 WHERE orig_count=shuffle_count;


DROP TABLE IF EXISTS t1,t2,t3;