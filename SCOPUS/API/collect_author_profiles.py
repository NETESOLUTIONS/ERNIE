'''
collect_author_profiles.py

    This script utilizes the ScopusInterface script to populate author profile related CSV files based on API HTML responses.

 Author: VJ Davey
'''
import ScopusInterface as si
import sys
from time import sleep
api_key=# INSERT API KEY HERE

# CSV file set up
profiles=['authors','author_document_mappings']#'author_affiliation_mappings','author_document_mappings']
files={header:open('{}.csv'.format(header),'wa') for header in profiles}
cols={
'authors':['author_id','indexed_name','surname','given_name','initials','scopus_co_author_count','process_co_author_count','scopus_document_count','process_document_count','scopus_citation_count','scopus_cited_by_count','alias_author_id'],
'author_affiliation_mappings':['author_id','affiliation_id'],
'author_document_mappings':['author_id','scopus_id']
}
for k in cols.keys():
    files[k].write((",".join(col for col in cols[k]) + "\n").encode('utf8'))

# Collect base author profile information and mapping information from the API
for line in sys.stdin:
    sleep(0.05)
    author_id=line.strip('\n')
    # Collect Author info, specify generational depth on search for documents/co-authors
    auth_profile=si.author_retrieval(author_id,api_key)
    if auth_profile is None:
        continue
    line=",".join(auth_profile[col] for col in cols['authors'])
    files['authors'].write((line+"\n").encode('utf8'))
    # Write author affiliation mapping information
    for affiliation in auth_profile['affiliations']:
        files['author_affiliation_mappings'].write("{},{}\n".format(auth_profile['author_id'],affiliation).encode('utf8'))
     Collect and write document affiliation mapping information
    document_listing=si.document_search("au-id({})".format(author_id),api_key)
    if document_listing is None:
        continue
    print(document_listing)
    for document in document_listing['documents'].itertuples():
        files['author_document_mappings'].write("{},{}\n".format(auth_profile['author_id'],document.identifier).encode('utf8'))
