# July 25, 2018. NET ESolutions. Email:netelabs@nete.com Author: Avon Davey avon@nete.com
# The five Python 2.x scripts in this folder are
# used to connect to various Scopus APIs as part of a collaborative effort with Abt Associates on a project
# for the US National Science Foundation. For these scripts to be useful, an API key is needed and the script
# should be executed from a machine with a whitelisted IP address. The basic strategy is to
# search for AuthorIDs using "first_name last_name" queries and then use retrieved AuthorIDs to
# retrieve Documents and Affiliations. To prevent overwrites, we push the output from these scripts to a
# PostgreSQL database as it's generated and can share the details of that process if there's interest.
# Reading Elsevier's documentation is very helpful and highly recommended.
# https://dev.elsevier.com

a) ScopusInterface.py: This script is the basis for all other scripts provided here. It is used to interfaces with various Scopus APIs including the author,
abstract, and affiliation retrieval APIs, as well as the SCOPUS search API. For the various functions contained within, a specified subset of the XML
fields are parsed and then returned in a python dictionary. This dictionary can then be used in a multitude of ways, ranging from direct analysis, to CSV population or direct database population.
Due to limited bandwidth at the API end, it is important to ensure the sleep_time variable is set to a value which does not cause the API to choke on response.

b) author_name_search.py: This script takes a CSV containing author information and collects potentially matching author IDs from the Author Search API using ScopusInterface.py and a provided API key.
The input CSV file must come in the format "name,award_number,first_year" where 'name' is in the form "first_name last_name".

c) collect_affiliation_profiles.py: This script utilizes the ScopusInterface script, item a) above, to populate *affiliation* profile related CSV files based on API HTML responses.

d) collect_author_profiles.py:  This script utilizes the ScopusInterface script, item a) above, to populate *author* profile related CSV files based on API HTML responses.

e) collect_document_profiles.py: This script utilizes the ScopusInterface script, item a) above, to populate *document* profile related CSV files based on API HTML responses.
