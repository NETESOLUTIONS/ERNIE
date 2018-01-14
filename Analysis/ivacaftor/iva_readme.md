Date: 10/23/2017
Author: George Chacko

Ivacaftor is the second case study in ERNIE. The process involves

a) Assemble initial documents: 
   i. go to drugs@fda and saerch ivacaftor. Copy nda, date of approval, brand name.
   ii. Download Medical Review document
   iii. Using drugbank.ca, Google, Google Patents and any other web source identify a single US patent that best represents the original invention 
   for the therapaeutic or intervention or diagnostic etc. 
   iv. Download the patent document from Google Patents.

b) Assemble lists of pmids from each data source. 

   i. Patent: Copy the non-patent literature citations on Google Patents for this patent and manually parse them in PubMed to get a list of pmids. 
   For ivacaftor, pmids were found for 8 of 20 citations and are tagged as  <npl_pmid></npl_pmid>> For patent number use <pl_USPatentno> </pl_USPatentno>

   ii. Clinical Trials. Saerch for ivacaftor or kalydeco in the interventions field of ct_clinical_studies in ERNIE. Tag each clinical trial with completion
   date (year). 

   create table case_ivacaftor_ct as select nct_id, start_date, completion_date, SUBSTRING(completion_date FROM '.{4}$') as
   year_of_completion from ct_clinical_studies where nct_id in (select distinct nct_id from ct_interventions where lower(intervention_name) like '%ivacaftor%'
   or lower(intervention_name) like '%kalydeco%') order by year_of_completion;


    By convention in this study, for ivacaftor, which was approved on 1/31/2012, Dec 31, 2012 is the cut-off date for pre-approval to post-approval. 
    This comes with its own set of issues but it is what it is. Thus, tag the retrieved  NCTs as <ct_preapp_nct></ct_preapp_nct> and 
    <ct_postapp_nct></ct_postapp_nct> acoording to year of completion.
    
    For each NCT join with the ct_publications and ct_references tables to identify pmids for references and publications respectively. Thus. 
    
    (i) ct_preapp_reference_pmid: select pmid from ct_references where nct_id in (select nct_id from case_ivacaftor_ct where year_of_completion::int <= 2012);
    (ii) ct_preapp_publication_pmid: select pmid from ct_publications where nct_id in (select nct_id from case_ivacaftor_ct where year_of_completion::int <= 2012);  
    (iii) ct_postapp_reference_pmid: select pmid from ct_references where nct_id in (select nct_id from case_ivacaftor_ct where year_of_completion::int > 2012);
    (iv) ct_postapp_publication_pmid: select pmid from ct_publications where nct_id in (select nct_id from case_ivacaftor_ct where year_of_completion::int > 2012);
 
    <ct_preapp_reference_pmid></ct_preapp_reference_pmid> and <ct_preapp_publication_pmid></ct_preapp_publication_pmid>
    <ct_postapp_reference_pmid></ct_postapp_reference_pmid> and <ct_postapp_publication_pmid></ct_postapp_publication_pmid>

    iii. FDA. From the medical review document, scrape any cited references and find pmids for them in PubMed (manually till we have a better way). Use
    <fda_medical_review_pmid> </fda_medical_review_pmid>. For ipilimumab there was only one reference. If you find any other useful references such as 
    in the summary review use <fda_other_pmid> </fda_other_pmid>.

    iii. PubMed. 

    Again using the preapp and postapp convention conduct PubMed searches.

    Preapp: ((("ivacaftor"[Supplementary Concept] OR "ivacaftor"[All Fields]) OR ("ivacaftor"[Supplementary Concept] 
    OR "ivacaftor"[All Fields] OR "kalydeco"[All Fields])) OR ("ivacaftor"[Supplementary Concept] OR "ivacaftor"[All Fields] 
    OR "vx 770"[All Fields])) AND ("1900/01/01"[PDAT] : "2013/12/31"[PDAT])

    Postapp: ((("ivacaftor"[Supplementary Concept] OR "ivacaftor"[All Fields]) OR ("ivacaftor"[Supplementary Concept] 
    OR "ivacaftor"[All Fields] OR "kalydeco"[All Fields])) OR ("ivacaftor"[Supplementary Concept] OR "ivacaftor"[All Fields] 
    OR "vx 770"[All Fields])) AND ("2013/12/31"[PDAT] : "3000"[PDAT])

    Reviews: To capture reviews published a year post-approval ((((("ivacaftor"[Supplementary Concept] OR "ivacaftor"[All Fields]) 
    OR ("ivacaftor"[Supplementary Concept] OR "ivacaftor"[All Fields] OR "kalydeco"[All Fields])) AND ("ivacaftor"[Supplementary Concept] 
    OR "ivacaftor"[All Fields] OR "vx 770"[All Fields])) AND "review"[Publication Type]) AND ("2013/12/31"[PDAT] : "2014/12/31"[PDAT])) AND "english"[Language]

    tag as <pubmed_review_pmid> </pubmed_review_pmid> 

    PubMed Clinical Trials: To capture clinical trial publications that are not in the National Clinical Trials database 
    
	Preapp: (((("ivacaftor"[Supplementary Concept] OR "ivacaftor"[All Fields]) OR ("ivacaftor"[Supplementary Concept] 
	OR "ivacaftor"[All Fields] OR "kalydeco"[All Fields])) OR ("ivacaftor"[Supplementary Concept] OR "ivacaftor"[All Fields] 
	OR "vx 770"[All Fields])) AND "clinical trial"[Publication Type]) AND ("1900/01/01"[PDAT] : "2012/12/31"[PDAT])
 	tag as <pubmed_ct_preapp_pmid> </<pubmed_ct_preapp_pmid>

    	Postapp: (((("ivacaftor"[Supplementary Concept] OR "ivacaftor"[All Fields]) OR ("ivacaftor"[Supplementary Concept] 
	OR "ivacaftor"[All Fields] OR "kalydeco"[All Fields])) OR ("ivacaftor"[Supplementary Concept] OR "ivacaftor"[All Fields] 
	OR "vx 770"[All Fields])) AND "clinical trial"[Publication Type]) AND ("2012/12/31"[PDAT] : "3000"[PDAT]) 
    	tag as <pubmed_ct_postapp_pmid> </pubmed_ct_postapp_pmid>

An ivacaftor.xml file is constructed using these tags, that is compliant with a DTD (seedset.dtd) which can be found on the Github repo.



