-- AUthor George Chacko 11/6/2017
-- build subtable setting cutoff as 1985 for ct data (best approximation)

drop table if exists naltrexone_ct;
create table naltrexone_ct as select nct_id, start_date, completion_date, SUBSTRING(completion_date FROM '.{4}$') 
as year_of_completion from ct_clinical_studies 
where nct_id in (select distinct nct_id from ct_interventions 
where lower(intervention_name) like '%naltrexone%' or lower(intervention_name) like '%revia%' or lower(intervention_name) 
like '%vivitrol%') order by year_of_completion;

-- Get pmids for naltrexone_ct_postapp_reference_pmid file
\copy (select pmid from ct_references where nct_id in (select nct_id from naltrexone_ct where year_of_completion::int > 1985 or year_of_completion is null) order by pmid) to '/home/chackoge/ERNIE/Analysis/naltrexone/naltrexone_ct_postapp_reference_pmid';

-- get pmids for naltrexone_ct_postapp_publication_pmid file
\copy (select pmid from ct_publications where nct_id in (select nct_id from naltrexone_ct where year_of_completion::int > 1985 or year_of_completion is null) order by pmid) TO '/tmp/naltrexone_ct_postapp_publication_pmid';

--get pmids for naltrexone_ct_preapp_reference_pmid file
\copy (select pmid from ct_references where nct_id in (select nct_id from naltrexone_ct where year_of_completion::int <= 1985)  order by pmid) TO '~/ERNIE/Analysis/naltrexone/pilimumab_ct_preapp_reference_pmid';

--get pmids for naltrexone_ct_preapp_publication_pmid file
\copy (select pmid from ct_publications where nct_id in (select nct_id from naltrexone_ct where year_of_completion::int <= 1985)  order by pmid) TO '~/ERNIE/Analysis/naltrexone/naltrexone_ct_preapp_publication_pmid';

-- generate naltrexone_ct_postapp_nct file
\copy (select nct_id from naltrexone_ct where year_of_completion::int > 1985 or year_of_completion is null) TO '~/ERNIE/Analysis/naltrexone/naltrexone_postapp_nct';

-- generate naltrexone_ct_preapp_nct file
\copy (select nct_id from naltrexone_ct where year_of_completion::int <= 1985) TO '~/ERNIE/Analysis/naltrexone/naltrexone_preapp_nct';




