Date: 11/17/2017
Author: George Chacko

Affymetrix Amplichip CYP is the fourth case study in ERNIE. This is an unusual case study in that involves looking at inventions from two independent manufacturers as well as 
discovery. Thus, our canonical workflow has to be modified as well as the XML spec. A second tweak is greater reliance on WoS data for the backbone.

a) FDA: List relevant 510ks. List Amplichip 510ks for CYP2D6 and 2C19. There are no embedded references in these documents. We are using Jan 2005 
b) Patents: Find relevant patents. 
   i) search URL: https://patents.google.com/?assignee=Affymetrix%2c+Inc.&before=priority:19960131&language=ENGLISH
   ii) search URL: https://patents.google.com/?inventor=Stephen+P.A.+Fodor,Michael+C.+Pirrung&assignee=Affymetrix%2c+Inc.&before=priority:20060131&language=ENGLISH       
A cluster of patents from 1989 with Pirrung and Fodor as inventor was used as the core patent set. Non-patent citations for each of them were copied from Google patents
into individual files. The files were concatenated into a single file, sorted, and passed through uniq. A second manual step was used to remove duplicates and Solr 
was used to search for relevant WoSIDs. The results were manually curated again and then de-duplicated using sort and uniq and stored in the affymetrix_npl_wosid file.
c) Pubs:
   i) PubMed and WoS searches using keywords and using Jan 2005 as a reference date (Jan 2006 for publication lag).
   ii) Fodor's papers, Pirrung's review, Lenoir's history, and Garfield's Microarray historiography could form a root cluster for papers.
   iii) Search for Amplichip CYP450 in PubMed and WoS, e.g. " python mass_solr_search.py -c wos_pub_core -qf citation -q "Amplichip CYP450"  -ip 10.0.0.5:8983 -n 100"
d) Clinical Trials: Not clear that any are relevant
h) Cited references 
i) Citing references: to be discussed later


