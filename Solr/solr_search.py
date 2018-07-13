# This is an updated generalized script to search a core on a SOLR server for matches based on several search criteria
# Usage:
#        python mass_solr_search.py -c 'core_name' -qf 'query_field' -q|-f 'query or file' -ip 'solr ip address and port' -n 'number of solr results' -o 'output file name'
# Example 1:
#        python mass_solr_search.py -c wos_pub_core -qf citation -q "DNA microarray" -ip 10.0.0.5:8983 -n 10 -o dna_microarray.csv
# Example 2:
#        python mass_solr_search.py -c wos_pub_core -qf citation -f pirrung.txt -ip 10.0.0.5:8983 -n 5 -o pirrung.csv
# Author: VJ Davey




import sys; import string; import re ; import subprocess; import pandas as pd

# Collect user input
query=None; core=None; query_fields=[]; target_fields=[]; search_file=None; num_results=10; ip_and_port='localhost:8983' ; psql_ip='localhost' ; psql_port='5432'; output_file='temp.csv';
for i in range(0,len(sys.argv)):
    if sys.argv[i][0] == '-':
        option = sys.argv[i]
        if option[1:] in ['ip_and_port', 'ip']:
            ip_and_port= sys.argv[i+1]
        elif option[1:] in ['core', 'c']:
            core = sys.argv[i+1]
        elif option[1:] in ['query_field', 'qf']:
            query_fields.append(sys.argv[i+1])
        elif option[1:] in ['target_field', 'tf']:
            target_fields.append(sys.argv[i+1])
        elif option[1:] in ['query', 'q']:
            query = sys.argv[i+1] ;
            if search_file!=None:
                raise NameError('Choose either to use a query or a file. Not both and not neither.')
        elif option[1:] in ['file', 'f']:
            search_file = sys.argv[i+1] ;
            if query!=None:
                raise NameError('Choose either to use a query or a file. Not both and not neither.')
        elif option[1:] in ['num_results', 'n']:
            num_results = sys.argv[i+1]
        elif option[1:] in ['output_file', 'o']:
            output_file = sys.argv[i+1]
        elif option[1:] in ['psql_ip', 'pi']:
            psql_ip = sys.argv[i+1]
        elif option[1:] in ['psql_port', 'pp']:
            psql_port = sys.argv[i+1]
        else:
            raise NameError('Unknown option : \'%s\''%(option))
if (core==None): raise NameError('Missing critical information - core')


# Set up for the queries. If the user has not specified any fields for the query, check the core for all fields, return a comma seperated list, and use those returned fields for the dismax query
field_collector_string="curl \'http://%s/solr/%s/select?&q=\"*:*\"&wt=csv&rows=0\'"%(ip_and_port, core)
fields=subprocess.check_output(field_collector_string, shell=True).rstrip().split(","); fields.remove('id') ; fields=fields if len(query_fields) < 1 else query_fields
fields=[i for i in fields if i not in target_fields]
#TODO: In future, make sure this is adjustable for weight
field_list_string1='%20'.join(fields)
field_list_string2=','.join(['id','score']+target_fields+fields)
curl_search_string="curl \'http://%s/solr/%s/select?defType=dismax&qf=%s&fl=%s&q=:"%(ip_and_port, core, field_list_string1,field_list_string2)
curl_search_string_ending='&rows=%s&wt=csv&csv.separator=~\''%(num_results)


# Some manual settings. Removal of useless stem words and such. Edit as needed
stem_words=['\' et al. \'', '\' the \'', '\' a \'']
query_no=1; match=0; top_10_match=0
queries=[]; expected_ids=[]; true_status=[]
if search_file!=None:
    query_sheet=pd.read_csv(search_file)
    for i in range(0,len(query_sheet)):
        queries+=[query_sheet.citation[i]]
        expected_ids+=[query_sheet.wos_id[i]]
        true_status+=[query_sheet.status[i]]

else:
    queries.append(query)

# The actual run. Return results on the query. Hardcode any mapping to other DB information as needed if dealing with something like a WOS to PMID mapping
with open(output_file, 'wb') as csv_file:
    csv_file.write(','.join(['query','expected_id','result_id','status','solr_score','rank']+target_fields+fields)+'\n')
    for index in range(0,len(queries)):
        line=queries[index]; print '### Query No. %d ###'%(query_no); query_no+=1; line=(line.decode('utf-8','ignore')).encode('ascii','ignore')
        input_string=re.sub('|'.join(stem_words),'',line); input_string=re.sub(r'[,.{}<>\"\'\n\r]','',input_string) ; input_string=re.sub(r'[^0-9a-zA-Z]+','\\+',input_string) ; input_string=re.sub(r'\u+2260','',input_string)
        query_string=curl_search_string+input_string+curl_search_string_ending
        s = subprocess.check_output(query_string, shell=True) ; s=s.replace('\\n','') ;s=s.split("\n")
        print 'Search : '+line ; print 'Generated Query : '+query_string

        for result in s[1:-1]:
            result_list=result.split('~'); doc_id=result_list[0]; score=result_list[1]; others=['\"'+re.sub(r'[\"]','',i[:32700])+'\"' for i in result_list[2:]]
            csv_file.write('\"'+re.sub(r'[,\n\r]','',line)+'\",\"'+expected_ids[index]+'\",\"'+doc_id+'\",\"'+true_status[index]+'\",'+score+','+str(s.index(result))+','+','.join(others)+"\n")
