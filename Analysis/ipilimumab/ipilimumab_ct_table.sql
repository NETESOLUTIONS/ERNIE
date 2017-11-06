-- AUthor George Chacko 11/6/2017
-- build subtable setting cutoff as 2012 for ct data (best approximation)

drop table if exists ipilimumab_ct;
create table ipilimumab_ct as select nct_id, start_date, completion_date, SUBSTRING(completion_date FROM '.{4}$') 
as year_of_completion from ct_clinical_studies 
where nct_id in (select distinct nct_id from ct_interventions 
where lower(intervention_name) like '%ipilimumab%' or lower(intervention_name) like '%yervoy%') 
order by year_of_completion;

-- get pmids for ipilimumab_ct_postapp_reference_pmid file
\copy (select pmid from ct_references where nct_id in (select nct_id from ipilimumab_ct where year_of_completion::int > 2012 or year_of_completion is null) order by pmid) to '/home/chackoge/ERNIE/Analysis/ipilimumab/ipilimumab_ct_postapp_reference_pmid';

-- get pmids for ipilimumab_ct_postapp_publication_pmid file
\copy (select pmid from ct_publications where nct_id in (select nct_id from ipilimumab_ct where year_of_completion::int > 2012 or year_of_completion is null) order by pmid) TO '/tmp/ipilimumab_ct_postapp_publication_pmid';

--get pmids for ipilimumab_ct_preapp_reference_pmid file
\copy (select pmid from ct_references where nct_id in (select nct_id from ipilimumab_ct where year_of_completion::int <= 2012)  order by pmid) TO '~/ERNIE/Analysis/ipilimumab/pilimumab_ct_preapp_reference_pmid';

--get pmids for ipilimumab_ct_preapp_publication_pmid file
\copy (select pmid from ct_publications where nct_id in (select nct_id from ipilimumab_ct where year_of_completion::int <= 2012)  order by pmid) TO '~/ERNIE/Analysis/ipilimumab/ipilimumab_ct_preapp_publication_pmid';

-- generate ipilimumab_ct_postapp_nct file
\copy (select nct_id from ipilimumab_ct where year_of_completion::int > 2012 or year_of_completion is null) TO '~/ERNIE/Analysis/ipilimumab/ipilimumab_post_app_nct';

-- generate ipilimumab_ct_preapp_nct file
\copy (select nct_id from ipilimumab_ct where year_of_completion::int <= 2012) TO '~/ERNIE/Analysis/ipilimumab/ipilimumab_post_app_nct';



