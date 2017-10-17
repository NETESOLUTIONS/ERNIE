-- build subtable
create table ipilimumab_ct as select nct_id, start_date, completion_date, SUBSTRING(completion_date FROM '.{4}$') 
as year_of_completion from ct_clinical_studies 
where nct_id in (select distinct nct_id from ct_interventions 
where lower(intervention_name) like '%ipilimumab%' or lower(intervention_name) like '%yervoy%') order by year_of_completion;

-- get pmids for ipilimumab_ct_postapp_reference_pmid file
select pmid from ct_references where nct_id in (select nct_id from ipilimumab_ct where year_of_completion::int > 2011 or year_of_completion is null) order by pmid;

-- get pmids for ipilimumab_ct_postapp_publication_pmid file
select pmid from ct_publications where nct_id in (select nct_id from ipilimumab_ct where year_of_completion::int > 2011 or year_of_completion is null) order by pmid;

--get pmids for ipilimumab_ct_preapp_reference_pmid file
select pmid from ct_references where nct_id in (select nct_id from ipilimumab_ct where year_of_completion::int <= 2011)  order by pmid;

--get pmids for ipilimumab_ct_preapp_publication_pmid file
select pmid from ct_publications where nct_id in (select nct_id from ipilimumab_ct where year_of_completion::int <= 2011)  order by pmid;

