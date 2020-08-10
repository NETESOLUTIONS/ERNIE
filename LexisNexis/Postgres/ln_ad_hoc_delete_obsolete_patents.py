"""
Use this script to delete obsolete patents from the list
provided by IPDD. 
"""

import pandas as pd
import psycopg2
from sys import argv

user_name = argv[1] # ---> database username
password = argv[2] # ---> database password

conn = psycopg2.connect(database="ernie",
                      user=user_name, 
                      host="localhost",
                      password=password)

conn.set_client_encoding('UTF8')
conn.autocommit=True
curs=conn.cursor()

delete_list = pd.read_csv("delete_list.csv") # ---> provided by IPDD

for i in range(len(delete_list)):
    
    # columns from the list
    delete_query = """DELETE FROM public.lexis_nexis_patents
    WHERE country_code= '""" + delete_list['fromAuthority'][i] + """'
        AND doc_number= '""" + str(delete_list['fromDocumentNumber'][i]) + """'
        AND kind_code= '""" + delete_list['fromKind'][i] + """';"""
    
    curs.execute(delete_query)
    
conn.close()
print("All Completed.")