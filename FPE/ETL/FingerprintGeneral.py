import fileinput
import FingerprintEngineClient as efe
import argparse
import psycopg2
from psycopg2 import sql
import psycopg2.extras

def fingerprint_postgres_query(input_sql,non_title_abstract_cols,dsn,min_concepts=3,save_table=None,save_file=None,workflow='MeSHXmlConceptsOnly'):
    # Establish Postgres connections for I/O data
    input_postgres_conn=psycopg2.connect(" ".join("{}={}".format(k,postgres_dsn[k]) for k in postgres_dsn))
    input_cur=input_postgres_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    input_cur.execute(input_sql)
    output_postgres_conn=psycopg2.connect(" ".join("{}={}".format(k,postgres_dsn[k]) for k in postgres_dsn))
    output_postgres_conn.autocommit=True
    output_cur=output_postgres_conn.cursor()
    output_cur.execute('''CREATE TEMP TABLE temp_applications_fingerprint (
                                            {},
                                            concept_id INT,
                                            concept_name TEXT,
                                            concept_rank DECIMAL,
                                            concept_afreq INT
                        ) '''.format(','.join('{} TEXT'.format(group_id) for group_id in non_title_abstract_cols)))
    print(output_cur.statusmessage)

    for idx,input_row in enumerate(input_cur.fetchall()):
        try:
            group_ids={group_id.lower():input_row[group_id.lower()] for group_id in non_title_abstract_cols}
            title, abstract = input_row['title'],input_row['abstract']
            print("Document {}: {}".format(idx+1, title))
            if abstract:
                fp = client.index(workflow, title, abstract).toFingerprint()
                if len(fp) >= min_concepts:
                    doc_len = len(title.split() + abstract.split())
                    for concept in fp:
                        command= sql.SQL('''INSERT INTO temp_applications_fingerprint({},concept_id,concept_name,concept_rank,concept_afreq)
                                            VALUES ({},{},{},{},{})''').format(
                                            sql.SQL(',').join(sql.Identifier(i) for i in non_title_abstract_cols),
                                            sql.SQL(',').join(sql.Literal(group_ids[i]) for i in non_title_abstract_cols),
                                            sql.Literal(concept.conceptid),sql.Literal(concept.name),
                                            sql.Literal(concept.rank),sql.Literal(concept.afreq))
                        output_cur.execute(command)
                        #print(output_cur.statusmessage)
                else:  print("Document {} - {}: *** Insufficient concepts created on fingerprint ({})".format(idx+1, doc_id, len(fp)))
            else:  print("Doc {} : *** No abstract attached".format(idx+1))
        except ValueError:
            print("Document {}: *** Invalid Input Line".format(idx+1))

    if save_table:
        print("Saving temp table data to table {}".format(save_table))
        command=sql.SQL('''DROP TABLE IF EXISTS {}''').format(sql.Identifier(save_table))
        output_cur.execute(command)
        print(output_cur.statusmessage)
        command=sql.SQL('''CREATE TABLE {} AS SELECT * FROM temp_applications_fingerprint''').format(sql.Identifier(save_table))
        output_cur.execute(command)
        print(output_cur.statusmessage)


# Determine if we are working with a PostgreSQL connection or an input file
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='''
     This script uses the Elsevier FPE to:
        1) Process a file containing a list of (n* application ids,titles,abstracts) as input
            NOTE: Include a header, otherwise it will be assumed that the last two columns refer to title and abstract. Less than 3 columns will cause an error.
        2) Develop an N-concept fingerprint based on the provided text
    ''', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-mc','--min_concepts',help='minimum concepts for fingerprint analysis',default=3,type=int)
    parser.add_argument('-fu','--fingerprint_engine_username',help='Fingerprint Engine Username',required=True,type=str)
    parser.add_argument('-fp','--fingerprint_engine_password',help='Fingerprint Engine Password',required=True,type=str)
    parser.add_argument('-d','--postgres_dbname',help='the database to query in the local PostgreSQL server via peer authentication',default=None)
    parser.add_argument('-sql','--input_sql',help='the sql query to run to generate input data to the FPE',default=None)
    parser.add_argument('-n','--non_title_abstract_cols',help='columns to retain as group identifiers when fingerprinting',required=True,nargs='+')
    parser.add_argument('-st','--save_table',help='the sql table to save results as',default=None)
    parser.add_argument('-w','--workflow',help='the workflow the FingerPrint Engine should use',default='MeSHXmlConceptsOnly')
    args = parser.parse_args()

    MinConcepts = args.min_concepts
    client = efe.FingerprintEngineClient('https://fingerprintengine.scivalcontent.com/Taco7900/TacoService.svc/',
                                        args.fingerprint_engine_username,args.fingerprint_engine_password)
    if args.postgres_dbname:
        postgres_dsn={'dbname':args.postgres_dbname}
        fingerprint_postgres_query(args.input_sql,args.non_title_abstract_cols,postgres_dsn,args.min_concepts,save_table=args.save_table,workflow=args.workflow)
