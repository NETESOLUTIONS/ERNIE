'''
collect_document_profiles.py

    This script utilizes the ScopusInterface script to populate document profile related CSV files based on API HTML responses.

 Author: VJ Davey
'''

import ScopusInterface as si
import argparse
import sys
from time import sleep
parser = argparse.ArgumentParser(description='''
 Collect profile information where available for a list of scopus ids
''', formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-k','--api_key',help='Elsevier provided API key', required=True)
args = parser.parse_args()

# CSV file set up
profiles=['author_document_mappings','documents','documents_citations','document_affiliation_mappings']
files={header:open('{}.csv'.format(header),'wa') for header in profiles}
cols={
'author_document_mappings':['author_id','scopus_id'],
'documents':['scopus_id','title','document_type','scopus_cited_by_count','process_cited_by_count','publication_name','publisher','issn','volume','page_range','cover_date','publication_year','publication_month','publication_day','pubmed_id','doi','description','scopus_first_author_id','subject_areas','keywords'],
#'documents_citations':['citing_scopus_id',' cited_scopus_id'],
'document_affiliation_mappings':['scopus_id','affiliation_id']
}
for k in cols.keys():
    files[k].write((",".join(col for col in cols[k]) + "\n").encode('utf8'))

# Loop through Scopus IDs being passed through STDIN and query the API for abstract information
for line in sys.stdin:
    sleep(0.05)
    document_id=line.strip('\n')
    doc_profile=si.abstract_retrieval(document_id,args.api_key,id_type='scopus_id')
    if doc_profile is None:
        continue
    line=",".join(doc_profile[col] for col in cols['documents'])
    files['documents'].write((line+"\n").encode('utf8'))
    # Write author document mapping information
    for author_id in doc_profile['authors']:
        files['author_document_mappings'].write("{},{}\n".format(author_id,doc_profile['scopus_id']).encode('utf8'))
    # Write document affiliation mapping information
    for affiliation_id in doc_profile['affiliations']:
        files['document_affiliation_mappings'].write("{},{}\n".format(doc_profile['scopus_id'],affiliation_id).encode('utf8'))
    # Write cited document information
    for cited_scopus_id in doc_profile['cited_scopus_ids']:
        files['documents_citations'].write("{},{}\n".format(doc_profile['scopus_id'],cited_scopus_id).encode('utf8'))
    # Collect and write citing document information
    #low_bound=int(doc_profile['publication_year'])
    #citing_document_listing=si.citing_scopus_id_search(doc_profile['scopus_id'],args.api_key,low_bound=low_bound,high_bound=2019)
    #if citing_document_listing is None:
    #    continue
    #for citing_scopus_id in citing_document_listing['citing_scopus_ids']:
    #    files['documents_citations'].write("{},{}\n".format(citing_scopus_id,doc_profile['scopus_id']).encode('utf8'))
