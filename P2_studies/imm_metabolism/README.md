Feb 22, 2019
# Author: George Chacko

As part of our work on co-citation, we constructed datasets based on broad keyword based searches intended to assemble sets of 
publications within biomedical research. Accordingly, 

imm85: search PubMed for 'immunology' in all fields plus pub dates of 1985-01-01 to 1985-12-31
metab85: search PubMed for 'metabolism' in all fields plus pub dates of 1985-01-01 to 1985-12-31

imm95: search PubMed for 'immunology' in all fields plus pub dates of 1995-01-01 to 1995-12-31
metab95: search PubMed for 'metabolism' in all fields plus pub dates of 1995-01-01 to 1995-12-31

imm2005: search PubMed for 'immunology' in all fields plus pub dates of 1995-01-01 to 1995-12-31
metab2005: search PubMed for 'metabolism' in all fields plus pub dates of 1995-01-01 to 1995-12-31

pmids were downloaded for these searches and mapped to wos_ids to create the tables

immunology_1985_wos_ids (21606 records)
immunology_1995_wos_ids (29320 records)
immunology_2005_wos_ids (37296)

metabolism_1985_wos_ids (78998 records)
metabolism_1995_wos_ids (121247 records)
metabolism_2005_wos_ids (200052 records)

source_ids from these datasets were used to subset whole-year WoS slices to create input 
files for permutation calculations. Then z-scores were calculated as described elsewhere
in this repo. *Note that the number of records decreases when merged with citation data
since we select for publications that have at least one citation and some have none*
 


