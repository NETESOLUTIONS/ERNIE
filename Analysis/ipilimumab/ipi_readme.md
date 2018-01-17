Date: 10/17/2017
Author: George Chacko

Ipilimumab is the first case study in ERNIE. The process involves

a) Assemble initial documents: 
   i. go to drugs@fda and saerch ipilimumab. Copy bla, date of approval, brand name.
   ii. Download Medical Review document
   iii. Using drugbank.ca, Google, Google Patents and any other web source identify a single US patent that best represents the original invention 
   for the therapaeutic or intervention or diagnostic etc. 
   iv. DOwnload the patent document from Google Patents.

b) Assemble lists of pmids from each data source. 

   i. Patent: Copy the non-patent literature citations on Google Patents for this patent and manually parse them in PubMed to get a list of pmids. 
   For ipilimumab, pmids were found for all 52 citations as in <npl_pmid></npl_pmid>> For patent number use <pl_USPatentno> </pl_USPatentno>

   ii. Clinical Trials. Saerch for ipilimumab or yervoy in the interventions field of ct_clinical_studies in ERNIE. Tag each clinical trial with completion
   date (year). 

select nct_id,pmid  from ct_references where nct_id in (select nct_id, start_date, completion_date, SUBSTRING(completion_date FROM '.{4}$') as 
year_of_completion from ct_clinical_studies where nct_id in (select distinct nct_id from ct_interventions where lower(intervention_name) like '%ipilimumab%' 
or lower(intervention_name) like '%yervoy%') order by year_of_completion);

    By convention in this study, for ipilimumab, Dec 31, 2011 is the cut-off date for pre-approval to post-approval. This comes with its own set of issues 
    but it is what it is. Thus, tag the retrieved  NCTs as <ct_preapp_nct></ct_preapp_nct> and <ct_postapp_nct></ct_postapp_nct> acoording to year of 
    completion.
    
    For each NCT join with the ct_publications and ct_references tables to identify pmids for references and publications respectively. Thus. 
    <ct_preapp_reference_pmid></ct_preapp_reference_pmid> and <ct_preapp_publication_pmid></ct_preapp_publication_pmid>
    <ct_postapp_reference_pmid></ct_postapp_reference_pmid> and <ct_postapp_publication_pmid></ct_postapp_publication_pmid>

    iii. FDA. From the medical review document, scrape any cited references and find pmids for them in PubMed (manually till we have a better way). Use
    <fda_medical_review_pmid> </fda_medical_review_pmid>. For ipilimumab there was only one reference. If you find any other useful references such as 
    in the summary review use <fda_other_pmid> </fda_other_pmid>.

    iii. PubMed. 

    Again using the preapp and postapp convention (actual approval date is 3/25/2011) at 12/31/2011 conduct PubMed searches.

    Preapp: (("ipilimumab"[Supplementary Concept] OR "ipilimumab"[All Fields]) OR ("ipilimumab"[Supplementary Concept] OR "ipilimumab"[All Fields] 
    OR "yervoy"[All Fields])) AND ("1900/01/01"[PDAT] : "2011/12/31"[PDAT]) tag as <pubmed_preapp_pmid> </pubmed_preapp_pmid>

    Postapp: (("ipilimumab"[Supplementary Concept] OR "ipilimumab"[All Fields]) OR ("ipilimumab"[Supplementary Concept] OR "ipilimumab"[All Fields] 
    OR "yervoy"[All Fields])) AND ("2011/12/31"[PDAT] : "3000"[PDAT]) tag as <pubmed_postapp_pmid> </pubmed_postapp_pmid>

    Reviews: To capture reviews published a year post-approval (((("ipilimumab"[Supplementary Concept] OR "ipilimumab"[All Fields]) 
    OR ("ipilimumab"[Supplementary Concept] OR "ipilimumab"[All Fields] OR "yervoy"[All Fields])) 
    AND ("2011/12/31"[PDAT] : "2012/12/31"[PDAT])) AND "review"[Publication Type]) AND "english"[Language]
    tag as <pubmed_reviews_pmid> </pubmed_reviews_pmid> 

    PubMed Clinical Trials: To capture clinical trial publications that are not in the National Clinical Trials database 
    
	Preapp ((("ipilimumab"[Supplementary Concept] OR "ipilimumab"[All Fields]) OR ("ipilimumab"[Supplementary Concept] 
    OR "ipilimumab"[All Fields] OR "yervoy"[All Fields])) AND ("1900/01/01"[PDAT] : "2011/12/13"[PDAT])) 
    AND "clinical trial"[Publication Type]
    tag as <pubmed_ct_preapp_pmid> </<pubmed_ct_preapp_pmid>

    	Postapp ((("ipilimumab"[Supplementary Concept] OR "ipilimumab"[All Fields]) OR ("ipilimumab"[Supplementary Concept] 
    OR "ipilimumab"[All Fields] OR "yervoy"[All Fields])) AND ("2011/12/31"[PDAT] : "3000"[PDAT])) 
    AND "clinical trial"[Publication Type]
    tag as <pubmed_ct_postapp_pmid> </pubmed_ct_postapp_pmid>

An ipilimumab.xml file is constructed using these tags, that is compliant with a DTD (seedset.dtd) which can be found on the Github repo.


