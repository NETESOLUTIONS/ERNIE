-- AUthor George Chacko 11/6/2017
-- build subtable setting cutoff as 2013 for ct data (best approximation)

drop table if exists ivacaftor_ct;
create table ivacaftor_ct as select nct_id, start_date, completion_date, SUBSTRING(completion_date FROM '.{4}$') 
as year_of_completion from ct_clinical_studies 
where nct_id in (select distinct nct_id from ct_interventions 
where lower(intervention_name) like '%ivacaftor%' or lower(intervention_name) like '%kalydeco%') 
order by year_of_completion;

-- Get pmids for ivacaftor_ct_postapp_reference_pmid file
\copy (select pmid from ct_references where nct_id in (select nct_id from ivacaftor_ct where year_of_completion::int > 2013 or year_of_completion is null) order by pmid) to '/home/chackoge/ERNIE/Analysis/ivacaftor/ivacaftor_ct_postapp_reference_pmid';

-- get pmids for ivacaftor_ct_postapp_publication_pmid file
\copy (select pmid from ct_publications where nct_id in (select nct_id from ivacaftor_ct where year_of_completion::int > 2013 or year_of_completion is null) order by pmid) TO '/tmp/ivacaftor_ct_postapp_publication_pmid';

--get pmids for ivacaftor_ct_preapp_reference_pmid file
\copy (select pmid from ct_references where nct_id in (select nct_id from ivacaftor_ct where year_of_completion::int <= 2013)  order by pmid) TO '~/ERNIE/Analysis/ivacaftor/pilimumab_ct_preapp_reference_pmid';

--get pmids for ivacaftor_ct_preapp_publication_pmid file
\copy (select pmid from ct_publications where nct_id in (select nct_id from ivacaftor_ct where year_of_completion::int <= 2013)  order by pmid) TO '~/ERNIE/Analysis/ivacaftor/ivacaftor_ct_preapp_publication_pmid';

-- generate ivacaftor_ct_postapp_nct file
\copy (select nct_id from ivacaftor_ct where year_of_completion::int > 2013 or year_of_completion is null) TO '~/ERNIE/Analysis/ivacaftor/ivacaftor_postapp_nct';

-- generate ivacaftor_ct_preapp_nct file
\copy (select nct_id from ivacaftor_ct where year_of_completion::int <= 2013) TO '~/ERNIE/Analysis/ivacaftor/ivacaftor_preapp_nct';




