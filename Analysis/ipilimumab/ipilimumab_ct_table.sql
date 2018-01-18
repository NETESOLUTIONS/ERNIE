-- Author George Chacko 11/6/2017
-- updated 1/18/2018 
-- build subtable setting cutoff as 2011 for ct data (best approximation)

drop table if exists ipilimumab_ct;
create table ipilimumab_ct as select nct_id, start_date, completion_date, SUBSTRING(completion_date 
FROM '.{4}$') as year_of_completion from ct_clinical_studies 
where nct_id in (select distinct nct_id from ct_interventions 
where lower(intervention_name) like '%ipilimumab%' or lower(intervention_name) like '%yervoy%') order by year_of_completion;

-- get pmids for ipilimumab_ct_reference_pmid file
\copy (select pmid from ct_references where nct_id in (select nct_id from ipilimumab_ct) order by pmid) TO '/home/chackoge/ERNIE/Analysis/ipilimumab/ipilimumab_ct_reference_pmid';

-- get pmids for ipilimumab_ct_publication_pmid file
\copy (select pmid from ct_publications where nct_id in (select nct_id from ipilimumab_ct) order by pmid) TO '/home/chackoge/ERNIE/Analysis/ipilimumab/ipilimumab_ct_publication_pmid';







