import fileinput
import Vector as vec
from   decimal import *
import psycopg2
from psycopg2 import sql
import psycopg2.extras

# Constants
zero = Decimal(0)
one = Decimal(1)
two = Decimal(2)
nine = Decimal(9)

# Process first N Authors (Set to 0 or None for all)
max_authors = None  # NOTE: Set to None if using test_authors, below
# OR List of explicit Author IDs to output - Set to None for unlimited
test_authors = None
# test_authors = ['7201759125','35618310300']
# Maximum publications to process per author for matches
max_pubs = 15
# Maximum number of Apps to recommend per author
max_apps = 20
# Minimum Pubs per Author for consideration    (0 for no minimum)
min_publications = 0
# How much to Bias (or depress) idf vs. cosine results (range from 0.0-1.0)
# A zero means remove idf complete, a 1 means use only IDF (BM25) score
idf_bias = Decimal(0.5)
# Bias cosine score based on overall number of concepts matched (adjust to increase effect)
cosine_bias = Decimal(1.0)
# Bias overall match by how many pubs matched total
use_docs_bias = True
# Minimum number of Concepts required to try matching
min_concepts = 3
# Outlier Bias - geometric bias (exponent) for high-scoring publications
# The higher this number, the more individual high-scoring pubs will influence overall app match score, over overall average
score_bias = two  # At least 1.0 (for no bias)
# Top N concepts to match (Set to 0 or None for unlimited)
max_pub_concepts = None
max_app_concepts = None

# Build the IDF index to search against
def build_IDF(fingerprint_table,group_id_cols,dsn):
    IDF={} ;
    input_postgres_conn=psycopg2.connect(" ".join("{}={}".format(k,postgres_dsn[k]) for k in postgres_dsn))
    input_cur=input_postgres_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    # Collect the total number of documents in the corpus
    input_cur.execute(sql.SQL('''SELECT count(1)
                                 FROM (SELECT DISTINCT {}
                                        FROM {} ) foo''').format(
                                        sql.SQL(',').join(sql.Identifier(i) for i in group_id_cols),
                                        sql.Identifier(fingerprint_table)))
    num_documents=input_cur.fetchone()[0]
    # Collect term frequencies -- can likely just use SQL/Pandas group by on concept ids here
    input_cur.execute(sql.SQL('''SELECT concept_id,COUNT(concept_id) as frequency
                                 FROM {} GROUP BY concept_id''').format(sql.Identifier(fingerprint_table)))
    for input_row in input_cur.fetchall():
        IDF[input_row['concept_id']]=Decimal(input_row['frequency'])
    # Be ready to use concept_rank and concept_afreq, but there's likely no need to actually load on Python end instead of just calling w/ query - thus App dict not needed?
    # Collect IDF scores for each concept based on frequency:overall corpus size
    for concept_id in IDF:
        IDF[concept_id] = ((num_documents - IDF[concept_id] + Decimal(0.5)) / (IDF[concept_id] + Decimal(0.5))).log10()
    return IDF

# Return the dot product of two vectors after normalizing
def generate_cosine_score(vector_1,vector_2):
    return Decimal(vector_1.normalize().inner(vector_2.normalize()))

# Return BM25 score of two vectors after normalizing. Based on https://en.wikipedia.org/wiki/Okapi_BM25
def generate_bm25_score(term_vector,idf_vector,doc_len, avg_doc_len, k=2.0,b=0.75):
    return sum([(idf_vector[i] * term_vector[i] * (k +1)) / (idf_vector[i] + (k * (1 - b + (b * doc_len / avg_doc_len))))
                    for i in range(len(term_vector))])

# Return a final score aggregate wth optional bias
def generate_final_score(cosine_score,idf_score,idf_bias=Decimal(0.5)):
    return (idf_score * idf_bias) + (cosine_score * (1 - idf_bias))


if __name__ == '__main__':
    







# Search the Index using the provided query and receive a BM25 score for each element of the index for the query
# query fingerprint should be a dictionary of dictionaries {'concept_id': {'Rank':x,'AFreq':x} for i in concepts}
def match_fingerprints(query_fingerprint,idf_dict,k=Decimal(2.0),b=Decimal(0.75),prec=Decimal('1.0000'),max_concepts=None,
                        min_cosine=None,max_cosine=Decimal(0.0),min_idf=None,max_idf=Decimal(0.0)):
    results=[]
    query_fingerprint_concepts=list(query_fingerprint.keys())
    query_fingerprint_concepts.sort(key=lambda x: query_fingerprint[x]['Rank'], reverse=True)
    if max_concepts: query_fingerprint_concepts = query_fingerprint_concepts[:max_concepts]
    idf_vector=vec.Vector(list(IDF.get(x,Decimal(0.0) for x in query_fingerprint_concepts))
    query_vector=vec.Vector(list(query_fingerprint[x]['Rank'] for x in query_fingerprint_concepts))
    intermediate_vector=query_vector.mult(idf_vector).normalize()
    # for concept in query, collect index IDF score, frequency occurence in query
    for concept_id in query_fingerprint:
        concept_idf_score=idf_dict[concept_id]


    pass

# Optionally aggregate match scores into higher level fingerprints if necessary -- Do this prior to any sorting or cutoffs of results
#def aggregate_matches(group_id,fingerprint_matches):
#    pass
