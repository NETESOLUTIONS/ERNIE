import fileinput
import Vector as vec
from   decimal import *
import psycopg2
from psycopg2 import sql
import psycopg2.extras
import argparse


# Build the IDF index to search against
def build_IDF(index_table,index_ident_col,dsn):
    IDF={}
    input_postgres_conn=psycopg2.connect(" ".join("{}={}".format(k,postgres_dsn[k]) for k in postgres_dsn))
    input_cur=input_postgres_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    # Collect the total number of documents in the corpus
    input_cur.execute(sql.SQL('''SELECT * FROM {}''').format(sql.Identifier(index_table)))
    # Collect term frequencies -- can likely just use SQL/Pandas group by on concept ids here
    for record in input_cur.fetchall():
        IDF[record['concept_id']]=IDF.get(record['concept_id'],Decimal(0.0)) + Decimal(1.0)
    # Collect IDF scores for each concept
    input_cur.execute(sql.SQL('''SELECT COUNT(DISTINCT {}) FROM {}''').format(sql.Identifier(index_ident_col),
                                                                             sql.Identifier(index_table)))
    num_documents = input_cur.fetchone()[0]
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
    parser = argparse.ArgumentParser(description='''
     This script is used to find matches/similarity scores between FPE fingerprint vector collections stored in the PostgreSQL database
    ''', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-d','--postgres_dbname',help='the database to query in the local PostgreSQL server via peer authentication',default=None)
    parser.add_argument('-s','--search_sql',help='the sql query that corresponds to search vectors',required=True)
    parser.add_argument('-i','--index_table',help='the sql table that corresponds to the index vectors',required=True)
    parser.add_argument('-I','--index_ident_col',help='the column that corresponds to the identifier of the index table',required=True)
    args = parser.parse_args()

    # Build IDF dictionary
    postgres_dsn={'dbname':args.postgres_dbname}
    IDF = build_IDF(args.index_table,args.index_ident_col,postgres_dsn)
    print(IDF)

    # For each document,
        # Perform fast searches by using an inverted index (terms -> documents).
        # e.g. SELECT DISTINCT application_id FROM fpe_nda_grants WHERE concept_id IN (SELECT distinct concept_id FROM fpe_nda_documents WHERE scp='XXX');

        # Among the subset of positive match index vectors, generate cosine scores, BM25 scores, and final scores based on complete vector

        # return search results to a TXT file or SQL table
