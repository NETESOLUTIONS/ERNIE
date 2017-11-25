Date: 11/17/2017
Author: George Chacko

Affymetrix Amplichip CYP is the fourth case study in ERNIE. This is an unusual case study in that involves looking at inventions from two independent manufacturers as well as 
discovery. Thus, our canonical workflow has to be modified as well as the XML spec. A second tweak is greater reliance on WoS data for the backbone.

a) FDA: List relevant 510ks. 
b) Patents: List Affymax and Affymetrix patents
c) Fodor's papers, Pirrung's review, and Garfield's Microarray historiography could form a root cluster for papers.
d) Clinical Trials: Not clear that any are relevant
e) Cytochrome P450 drug metabolism literature 
f) NIDA support for 2D6 and 2C19 research
g) Expression profiling for CYP450
h) Citing and cited references using Jan 2005 as a reference date (Jan 2006 for publication lag). Why?

1. FDA: List Amplichip 510ks for CYP2D6 and 2C19. There are no embedded references in these documents. We are using Jan 2005 
as the date of approval for both 510ks so the cut off period for publications would be one year later (01/31/2006)
2. Patents: Search Google patents for Affymetrix as assignee using priority date of before 2006.
a) search URL: https://patents.google.com/?assignee=Affymetrix%2c+Inc.&before=priority:19960131&language=ENGLISH
b) search URL: https://patents.google.com/?inventor=Stephen+P.A.+Fodor,Michael+C.+Pirrung&assignee=Affymetrix%2c+Inc.&before=priority:20060131&language=ENGLISH       
A cluster of patents from 1989 with Pirrung and Fodor as inventor was used as the core patent set. Non-patent citations for each of them were copied from Google patents
into individual files. The files were concatenated into a single file, sorted, and passed through uniq. A second manual step was used to remove duplicates and Solr 
was used to search for relevant WoSIDs. The results were manually curated again and then de-duplicated using sort and uniq and stored in the affymetrix_npl_wosid file.


		     


