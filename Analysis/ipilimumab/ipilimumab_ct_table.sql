create table ipilimumab_ct as select nct_id, start_date, completion_date, SUBSTRING(completion_date FROM '.{4}$') 
as year_of_completion from ct_clinical_studies 
where nct_id in (select distinct nct_id from ct_interventions 
where lower(intervention_name) like '%ipilimumab%' or lower(intervention_name) like '%yervoy%') order by year_of_completion;

