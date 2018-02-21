-- Author George Chacko 11/6/2017
-- updated 1/18/2018 
-- build subtable setting cutoff as 2011 for ct data (best approximation)

drop table if exists buprenorphine_ct;
create table buprenorphine_ct as select nct_id, start_date, completion_date, SUBSTRING(completion_date 
FROM '.{4}$') as year_of_completion from ct_clinical_studies 
where nct_id in (select distinct nct_id from ct_interventions 
where lower(intervention_name) like '%buprenorphine%') order by year_of_completion;

-- get pmids for buprenorphine_ct_reference_pmid file
\copy (select pmid from ct_references where nct_id in (select nct_id from ivacaftor_ct) order by pmid) TO '/home/chackoge/ERNIE/Analysis/buprenorphine/buprenorphine_ct_reference_pmid';

-- get pmids for ivacaftor_ct_publication_pmid file
\copy (select pmid from ct_publications where nct_id in (select nct_id from ivacaftor_ct) order by pmid) TO '/home/chackoge/ERNIE/Analysis/buprenorphine/buprenorphine_ct_publication_pmid';







