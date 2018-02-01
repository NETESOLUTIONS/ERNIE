-- AUthor George Chacko 11/6/2017
-- build subtable setting cutoff as 1985 for ct data (best approximation)

drop table if exists naltrexone_ct;
create table naltrexone_ct as select nct_id, start_date, completion_date, SUBSTRING(completion_date FROM '.{4}$') 
as year_of_completion from ct_clinical_studies 
where nct_id in (select distinct nct_id from ct_interventions 
where lower(intervention_name) like '%naltrexone%' or lower(intervention_name) like '%revia%' or lower(intervention_name) 
like '%vivitrol%') order by year_of_completion;

-- Get pmids for naltrexone_ct_reference_pmid file
\copy (select pmid from ct_references where nct_id in (select nct_id from naltrexone_ct) order by pmid) TO '/home/chackoge/ERNIE/Analysis/ivacaftor/ivacaftor_ct_reference_pmid';

-- get pmids for naltrexone_ct_publication_pmid file
\copy (select pmid from ct_publications where nct_id in (select nct_id from naltrexone_ct) order by pmid) TO '/home/chackoge/ERNIE/Analysis/ivacaftor/ivacaftor_ct_publication_pmid';










