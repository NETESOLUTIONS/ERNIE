#!/usr/bin/python3

import pandas as pd
import os

"""
The following script is to be used after extracting example scp IDs 
and their corresponding pubmed IDs using SQL and saving the results
as a CSVf file.
"""

doi_examples = pd.read_csv('/home/shreya/tmp_doi/doi_examples.csv') # ---> A file containing scp, pubmed ID, and publish year

pubmed_id_list = doi_examples.pub_id.tolist()
scp_list = doi_examples.pub_scp.tolist()
year_list = doi_examples.pub_year.tolist()

scp_list_padded = [str(i).zfill(10) for i in scp_list] # ---> Scopus scps are zero padded to be 10 characters long


# Directly find the corresponding files from the baseline dataset,
# unzip them, and store them into home directory

for i in range(len(doi_examples)):
    text = "find-in-zips.sh -u /home/shreya/doi_examples_tmp /erniedev_data5/Scopus/" + str(year_list[i]) + "/*.zip '2-s2.0-" + scp_list_padded[i] + ".xml'"
    os.system(text)



"""
After running this script,in the /doi_examples_tmp, use

fgrep -c "DOI" * |grep :1

to get all the files that do actually contain DOIs in the Scopus XML files. 
"""

