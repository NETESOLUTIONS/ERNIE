import fileinput
import Vector as vec
from   decimal import *
import numpy as np
import psycopg2
from psycopg2 import sql
import psycopg2.extras
import argparse


# Build the IDF index to search against
def build_IDF(index_table,index_ident_col,dsn):
    IDF={}
    input_postgres_conn=psycopg2.connect(" ".join("{}={}".format(k,postgres_dsn[k]) for k in postgres_dsn))
    input_cur=input_postgres_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    # Collect concept/term frequencies
    input_cur.execute(sql.SQL('''SELECT * FROM {}''').format(sql.Identifier(index_table)))
    for record in input_cur.fetchall():
        IDF[str(record['concept_id'])]=IDF.get(record['concept_id'],Decimal(0.0)) + Decimal(1.0)
    # Collect count of documents that make up the index
    input_cur.execute(sql.SQL('''SELECT COUNT(DISTINCT {}) FROM {}''').format(sql.Identifier(index_ident_col),
                                                                             sql.Identifier(index_table)))
    num_documents = Decimal(input_cur.fetchone()[0])
    # Complete building IDF dict
    for concept_id in IDF:
        IDF[concept_id] = ((num_documents - IDF[concept_id] + Decimal(0.5)) / (IDF[concept_id] + Decimal(0.5))).log10()
    return IDF

# Return the dot product of two vectors after normalizing
def calculate_cosine_score(vector_1,vector_2):
    return Decimal(vector_1.normalize().inner(vector_2.normalize()))

# Return BM25 score of two vectors after normalizing. Based on https://en.wikipedia.org/wiki/Okapi_BM25
def calculate_bm25_score(term_vector,idf_vector,doc_len, avg_doc_len, k=Decimal(2.0),b=Decimal(0.75)):
    return sum([(idf_vector[i] * term_vector[i] * (k +1)) / (idf_vector[i] + (k * (1 - b + (b * doc_len / avg_doc_len))))
                    for i in range(len(term_vector))])

# Return a final score aggregate wth optional bias
def calculate_final_score(cosine_score,idf_score,idf_bias=Decimal(0.5)):
    return (idf_score * idf_bias) + (cosine_score * (1 - idf_bias))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='''
     This script is used to find matches/similarity scores between FPE fingerprint vector collections stored in the PostgreSQL database
    ''', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-d','--postgres_dbname',help='the database to query in the local PostgreSQL server via peer authentication',default=None)
    parser.add_argument('-q','--query_table',help='the sql table that corresponds to the query vectors',required=True)
    parser.add_argument('-Q','--query_ident_col',help='the column that corresponds to the identifier of the query vectors',required=True)
    parser.add_argument('-i','--index_table',help='the sql table that corresponds to the index vectors',required=True)
    parser.add_argument('-I','--index_ident_col',help='the column that corresponds to the identifier of the index table',required=True)
    parser.add_argument('-s','--score_bias',help='geometric bias for score values (raising this value makes higher scoring results stand out more)',type=int,default=1)
    args = parser.parse_args()

    # Build IDF dictionary
    postgres_dsn={'dbname':args.postgres_dbname}
    IDF = build_IDF(args.index_table,args.index_ident_col,postgres_dsn)

    # Collect query vectors
    input_postgres_conn=psycopg2.connect(" ".join("{}={}".format(k,postgres_dsn[k]) for k in postgres_dsn))
    input_cur=input_postgres_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    input_cur.execute(sql.SQL('''SELECT {},string_agg(concept_id::text||','||concept_rank::text||','||concept_afreq::text,';') FROM {} GROUP BY {}''').format(sql.Identifier(args.query_ident_col),sql.Identifier(args.query_table),
                                                                                        sql.Identifier(args.query_ident_col)))
    query_vectors=input_cur.fetchall()

    with open('/tmp/scores.csv','w') as output_file:
        output_file.write("{},Result_Rank,{},Unweighted_Cosine,Weighted_Cosine,BM25,Final_Score\n".format(args.query_ident_col,args.index_ident_col))
        for query_vector in query_vectors:
            query_vector_identifier=query_vector[0]
            # Use dict comprehension to rebuild fingerprint locally
            query_fingerprint={ vector.split(',')[0]:{'Rank':vector.split(',')[1],'AFreq':vector.split(',')[2]} for vector in query_vector[1].split(';') }

            # Perform fast searches by using an inverted index (terms -> documents). This way, rankings only account for docs with at least one concept match.
            input_cur.execute(sql.SQL('''SELECT {},string_agg(concept_id::text||','||concept_rank::text||','||concept_afreq::text,';')
                                         FROM {}
                                         WHERE {} IN
                                            ( SELECT DISTINCT {} FROM {} WHERE concept_id IN ({}) )
                                         GROUP BY {}
                                         ''').format( sql.Identifier(args.index_ident_col),
                                                      sql.Identifier(args.index_table),
                                                      sql.Identifier(args.index_ident_col),
                                                      sql.Identifier(args.index_ident_col),
                                                      sql.Identifier(args.index_table),
                                                      sql.SQL(',').join(sql.Literal(int(concept_id)) for concept_id in query_fingerprint.keys()),
                                                      sql.Identifier(args.index_ident_col)))
            index_vectors=input_cur.fetchall()
            query_vec = vec.Vector(list(Decimal(query_fingerprint[concept_id]['Rank']) for concept_id in query_fingerprint.keys()))
            idf_vec = vec.Vector(list(Decimal(IDF.get(concept_id, 0.0)) for concept_id in query_fingerprint.keys()))

            # Collect indexed document length Information
            # NOTE: Doc lengths here correspond to length of what is indexed (meaning length of fingerprint if using fingerprint vectors)
            input_cur.execute(sql.SQL('''SELECT {}, COUNT(DISTINCT concept_id)
                                         FROM {}
                                         GROUP BY {}''').format(sql.Identifier(args.index_ident_col),
                                                                sql.Identifier(args.index_table),
                                                                sql.Identifier(args.index_ident_col)))
            document_len_results=input_cur.fetchall()
            document_lengths={i[0]:i[1] for i in document_len_results}
            average_document_length=np.mean([i[1] for i in document_len_results])

            # Set up miscellaneous variables
            min_unweighted_cosine = None
            max_unweighted_cosine = Decimal(0.0)
            min_weighted_cosine = None
            max_weighted_cosine = Decimal(0.0)
            min_bm25 = None
            max_bm25 = Decimal(0.0)
            scores = []

            for index_vector in index_vectors:
                index_vector_identifier=index_vector[0]
                # Use dict comprehension to rebuild fingerprint locally
                index_fingerprint={ vector.split(',')[0]:{'Rank':vector.split(',')[1],'AFreq':vector.split(',')[2]} for vector in index_vector[1].split(';') }

                # Calculate weighted and unweighted cosine scores
                index_vec = vec.Vector(list(Decimal(index_fingerprint.get(concept_id, {}).get('Rank', 0.0)) for concept_id in query_fingerprint.keys()))
                unweighted_cosine_score=calculate_cosine_score(query_vec,index_vec)
                weighted_cosine_score=calculate_cosine_score(query_vec.mult(idf_vec),index_vec.mult(idf_vec))
                min_unweighted_cosine=unweighted_cosine_score if min_unweighted_cosine is None else min(min_unweighted_cosine,unweighted_cosine_score)
                max_unweighted_cosine=max(max_unweighted_cosine,unweighted_cosine_score)
                min_weighted_cosine=unweighted_cosine_score if min_weighted_cosine is None else min(min_weighted_cosine,weighted_cosine_score)
                max_weighted_cosine=max(max_weighted_cosine,weighted_cosine_score)

                # Calculate BM25 score
                term_vec =  vec.Vector(list(Decimal(index_fingerprint.get(concept_id, {}).get('AFreq', 0.0)) for concept_id in query_fingerprint.keys()))
                bm25_score= calculate_bm25_score(term_vec.values,idf_vec.values,Decimal(document_lengths[index_vector_identifier]),Decimal(average_document_length))
                min_bm25=bm25_score if min_bm25 is None else min(min_bm25,bm25_score)
                max_bm25=max(max_bm25,bm25_score)

                # Append all scores to a list of lists
                scores.append([ index_vector_identifier, # Search result ID
                                unweighted_cosine_score, # Search result unweighted cosine score
                                weighted_cosine_score,   # Search result weighted cosine score
                                bm25_score               # BM25 score
                              ])
            # Post process scores for normalization and generate final score
            # Adjust maximums to compensate for minimums, for normalization
            max_unweighted_cosine -= min_unweighted_cosine
            max_weighted_cosine -= min_weighted_cosine
            max_bm25 -= min_bm25
            for idx,row in enumerate(scores):
                scores[idx][1] = ( row[1] - min_unweighted_cosine ) / max_unweighted_cosine
                scores[idx][2] = ( row[2] - min_weighted_cosine ) / max_weighted_cosine
                scores[idx][3] = ( row[3] - min_bm25 ) / max_bm25
                scores[idx].append(calculate_final_score(scores[idx][2],scores[idx][3]))

            # Return search results to a TXT file or SQL table, sorted by score results
            scores.sort(key=lambda x: x[3], reverse=True)
            for i in range(10):
                output_file.write("{},{},{},{:.4},{:.4},{:.4},{:.4}\n".format(query_vector_identifier,
                                                          i+1,
                                                          scores[i][0],
                                                          scores[i][1] ** args.score_bias, # Unweighted cosine
                                                          scores[i][2] ** args.score_bias, # Weighted cosine
                                                          scores[i][3] ** args.score_bias,  # BM25
                                                          scores[i][4] ** args.score_bias   # Final score (split between weighted cosine and BM25)
                                                          ))
