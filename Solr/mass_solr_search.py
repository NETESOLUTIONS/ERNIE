# This is a generalized script to search a SOLR server for matches based on a list of search criteria
# Usage:
#        python mass_solr_search.py -c 'core_name' -qf 'query_field' -q|-f 'query or file' -ip 'solr ip address and port' -n 'number of solr results' -o 'output file name'
# Example 1:
#        python mass_solr_search.py -c wos_pub_core -qf citation -q "DNA microarray" -ip 10.0.0.5:8983 -n 10 -o dna_microarray.csv
# Example 2:
#        python mass_solr_search.py -c wos_pub_core -qf citation -f pirrung.txt -ip 10.0.0.5:8983 -n 5 -o pirrung.csv




# Author: VJ Davey
import sys; import string; import re ; import subprocess
# search the SOLR database # pmid_file=sys.argv[6]
query=None; core=None; query_field=None; search_file=None; num_results=10; ip_and_port='localhost:8983' ; psql_ip='localhost' ; psql_port='5432'; output_file='temp.csv'
for i in range(0,len(sys.argv)):
    if sys.argv[i][0] == '-':
        option = sys.argv[i]
        if option[1:] in ['ip_and_port', 'ip']:
            ip_and_port= sys.argv[i+1]
        elif option[1:] in ['core', 'c']:
            core = sys.argv[i+1]
        elif option[1:] in ['query_field', 'qf']:
            query_field = sys.argv[i+1]
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
if (core==None) or (query_field==None): raise NameError('Missing critical information - core and query field')
curl_search_string="curl \'http://%s/solr/%s/select?fl=id,citation,score&q=%s:"%(ip_and_port, core, query_field)
curl_search_string_ending='&rows=%s&wt=csv&csv.separator=~\''%(num_results)
stem_words=['et al']
i=1; match=0; top_10_match=0
queries=[]
if search_file!=None:
    with open(search_file) as f:
        queries = f.read().splitlines()
else:
    queries.append(query)

with open(output_file, 'wb') as csv_file:
    csv_file.write('query, wos_id, wos_title, PMID, search_result_rank, solr_score\n')
    for line in queries:
        print i; i+=1; line=(line.decode('utf-8')).encode('ascii','ignore')
        input_string=re.sub('|'.join(stem_words),'',line); input_string=re.sub(r'[,.{}<>\"\'\n\r]','',input_string) ; input_string=re.sub(r'[:@*#() -]','\\+',input_string) ; input_string=re.sub(r'\u+2260','',input_string)
        query_string=curl_search_string+input_string+curl_search_string_ending
        s = subprocess.check_output(query_string, shell=True).split("\n")
        print line ; print query_string

        for result in s[1:-1]:
            result_list=result.split('~'); wos_id=result_list[0]; citation='\"'+re.sub(r'[\"]','',result_list[1])+'\"'; score=result_list[2]
            psql_query='\"select pmid_int from wos_pmid_mapping where wos_id=\''+ wos_id+'\';\"'
            psql_result=subprocess.check_output("psql -h "+psql_ip+" -p "+psql_port+" -U ernie_admin -d ernie -c " + psql_query, shell=True).split("\n")
            #found = ' pmid IS in file' if psql_result[2].lstrip() in open(pmid_file).read() else ' pmid NOT in file'
            #match += 1 if (found == ' pmid IS in file' and  result==s[1]) else 0
            #top_10_match +=1 if (found == ' pmid IS in file') else 0
            print wos_id+":"+citation+" -- PMID: "+psql_result[2]+"\n" if len(psql_result) > 5 else wos_id+":"+citation+"\n"
            if len(psql_result) > 5:
                csv_file.write('\"'+re.sub(r'[,\n\r]','',line)+'\",'+wos_id+','+citation+','+psql_result[2].lstrip()+','+str(s.index(result))+','+score+"\n")
            else:
                csv_file.write('\"'+re.sub(r'[,\n\r]','',line)+'\",'+wos_id+','+citation+','+'NA'+','+str(s.index(result))+','+score+"\n")
#print '\n\nGot a correct PMID match with first SOLR result returned:  %.2f percent of the time...' %((float(match)/i)*100)
#print '\n\nGot a correct PMID in the top 10:  %.2f percent of the time...'%((float(top_10_match)/i)*100)
