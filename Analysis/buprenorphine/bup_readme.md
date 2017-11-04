Date: 10/28/2017
Author: George Chacko

Buprenorphine is the third case study in ERNIE. The process involves

a) Assemble initial documents: 
   i. go to drugs@fda and search buprenorphine. Copy nda, date of approval, brand name. [in this case, multiple NDAs were observed so the earliest was selected, which resulted in 
   selection of 018401 and 018410 for Buprenex granted on 12/29/1981 according to the FDA.
   ii. Download Medical Review document [The medical review document (pg 8-146 did not have a single reference in it. Neither did the chemistry review pg 146-150. 
   The pharmacology review (pg 151-226) was relatively rich in references (pg171-181), which were manually harvested and classified under buprenorphine_fda_other_review_pmid. Where a 
   match could not be found, a pmid of 00000 was assigned. The statistical review had no references. The clinical pharmacology and biopharmaceutics review had no references either.] 
   iii. Using drugbank.ca, Google, Google Patents and any other web source identify a single US patent that best represents the original invention 
   for the therapaeutic or intervention or diagnostic etc. 
   iv. Download the patent document from Google Patents.
   v. In this case, the patent was located at http://www.naabt.org/documents/buprenorphine_patent.pdf.

b) Assemble lists of pmids from each data source. 

   i. Patent: Copy the non-patent literature citations on Google Patents for this patent and manually parse them in PubMed to get a list of pmids. 
   For buprenorphine, the original patent appears to be US3433791, granted in 1969, no NPL were found. http://www.naabt.org/documents/buprenorphine_patent.pdf

   ii. Clinical Trials. Search for buprenorphine  in the interventions field of ct_clinical_studies in ERNIE. Tag each clinical trial with completion
   date (year). For buprenorphine the cutoff year would be > 1982

   create table case_buprenorphine_ct as select nct_id, start_date, completion_date, SUBSTRING(completion_date FROM '.{4}$') as
   year_of_completion from ct_clinical_studies where nct_id in (select distinct nct_id from ct_interventions where lower(intervention_name) like '%buprenorphine%'
   or lower(intervention_name) like '%buprenex%') order by year_of_completion;


    By revised convention in this study, for buprenorphine, which was approved on 12/29/1981, 1982 is the cut-off date for pre-approval to post-approval. 
    This comes with its own set of issues but it is what it is. Thus, tag the retrieved  NCTs as <ct_preapp_nct></ct_preapp_nct> and 
    <ct_postapp_nct></ct_postapp_nct> according to year of completion.
    
    For each NCT join with the ct_publications and ct_references tables to identify pmids for references and publications respectively. Thus. 
    
    (i) ct_preapp_reference_pmid: select pmid from ct_references where nct_id in (select nct_id from case_buprenorphine_ct where year_of_completion::int <= 1982);
    (ii) ct_preapp_publication_pmid: select pmid from ct_publications where nct_id in (select nct_id from case_buprenorphine_ct where year_of_completion::int <= 1982);  
    (iii) ct_postapp_reference_pmid: select pmid from ct_references where nct_id in (select nct_id from case_buprenorphine_ct where year_of_completion::int > 1982);
    (iv) ct_postapp_publication_pmid: select pmid from ct_publications where nct_id in (select nct_id from case_buprenorphine_ct where year_of_completion::int > 1982);
 
    <ct_preapp_reference_pmid></ct_preapp_reference_pmid> and <ct_preapp_publication_pmid></ct_preapp_publication_pmid>
    <ct_postapp_reference_pmid></ct_postapp_reference_pmid> and <ct_postapp_publication_pmid></ct_postapp_publication_pmid>

    iii. FDA. From the medical review document, scrape any cited references and find pmids for them in PubMed (manually till we have a better way). Use
    <fda_medical_review_pmid> </fda_medical_review_pmid>. For ipilimumab there was only one reference. If you find any other useful references such as 
    in the summary review use <fda_other_pmid> </fda_other_pmid>.

    iii. PubMed. 

    Again using the preapp and postapp convention conduct PubMed searches.

    Preapp: (("buprenorphine"[MeSH Terms] OR "buprenorphine"[All Fields]) AND ("1900/01/01"[PDAT] : "1982/12/29"[PDAT])) AND "english"[Language]

    Postapp: (("buprenorphine"[MeSH Terms] OR "buprenorphine"[All Fields]) AND ("1982/12/29"[PDAT] : "3000"[PDAT])) AND "english"[Language]

    Reviews: To capture reviews published a year post-approval: ((("buprenorphine"[MeSH Terms] OR "buprenorphine"[All Fields]) AND ("1982/12/29"[PDAT] : "1983/12/29"[PDAT])) 
    AND "review"[Publication Type]) AND "english"[Language]

    tag as <pubmed_review_pmid> </pubmed_review_pmid> 

    PubMed Clinical Trials: To capture clinical trial publications that are not in the National Clinical Trials database 
    
	Preapp: ((("buprenorphine"[MeSH Terms] OR "buprenorphine"[All Fields]) AND ("1900/01/01"[PDAT] : "1982/12/29"[PDAT])) AND "english"[Language]) 
	AND "clinical trial"[Publication Type]
 	tag as <pubmed_ct_preapp_pmid> </<pubmed_ct_preapp_pmid>

    	Postapp: ((((buprenorphine) AND ("1982/12/29"[Date - Publication] : "3000"[Date - Publication])) AND "english"[Language])) 
	AND "clinical trial"[Publication Type]

A buprenorphine.xml file is constructed using these tags, that is compliant with a DTD (seedset.dtd) which can be found on the Github repo.



