# coding=utf-8

# This is a parser to extract the DERWENT XML patent data and generate 8 CSV files:
# 1. derwent_patents.csv
# 2. derwent_inventors.csv
# 3. derwent_examiners.csv
# 4. derwent_assignees.csv
# 5. derwent_patent_citations.csv
# 6. derwent_agents.csv
# 7. derwent_assignors.csv
# 8. derwent_lit_citations.csv

# Usage: python derwent_xml_parser.py -filename file_name -csv_dir csv_file_directory

# Author: Shixin Jiang, Lingtian "Lindsay" Wan
# Create Date: 02/14/2016
# Modified: 05/19/2016, Lindsay Wan, added documentation
#           08/18/2016, VJ Davey, added parallelized shell script output

import re
import csv
import exceptions
import time
import os.path
import datetime
import string
import sys
import multiprocessing as mp

from lxml import etree

# Check if the file name is provided, otherwise the program will stop.
#in_arr  = ["-filename", "formatted_new_dwpi.xml", "-csv_dir", "./"]
in_arr = sys.argv
if '-filename' not in in_arr:
   print "No filename"
   raise NameError('error: file name is not provided')
else:
   input_filename = os.path.expanduser(in_arr[in_arr.index('-filename') + 1])

# Check if the CSV file directory is provided, otherwise the program will stop.
if '-csv_dir' not in in_arr:
   print "No CSV file directory"
   raise NameError('error: CSV file directory is not provided')
else:
   input_csv_dir= in_arr[in_arr.index('-csv_dir') + 1]

xml_csv_dir = os.path.expanduser(input_csv_dir+input_filename[:-4]+'/')
try:
   os.stat(xml_csv_dir)
except:
   import subprocess
   subprocess.check_output("mkdir -p %s"%(xml_csv_dir), shell=True)


_date_re = re.compile(r'(?P<yr>\d{4})-(?P<mon>\d{2})-(?P<day>\d{2})')
_non_alphanum_re = re.compile(r'[^\w\s]+')

# Set up XML namespace
url='{http://schemas.thomson.com/ts/20041221/tsip}'
urltsxm ='{http://schemas.thomson.com/ts/20041221/tsxm}'

# Give list of pre and after-2001 patent types.
before_2001 = ['A','A1','P','P1','S','S1','E','E1']
onafter_2001 = ['B1','B2','P2','P3','S','S1','E','E1']

root = etree.parse(input_filename).getroot()

# Create CSV files
csvfile_patent = open(xml_csv_dir+input_filename[:-4]+'_patents.csv', 'w')
csvfile_examiner = open(xml_csv_dir+input_filename[:-4]+'_examiners.csv', 'w')
csvfile_inventor = open(xml_csv_dir+input_filename[:-4]+'_inventors.csv', 'w')
csvfile_assignee = open(xml_csv_dir+input_filename[:-4]+'_assignees.csv', 'w')
csvfile_assignor = open(xml_csv_dir+input_filename[:-4]+'_assignors.csv', 'w')
csvfile_citation = open(xml_csv_dir+input_filename[:-4]+'_pat_citations.csv', 'w')
csvfile_litcitation = open(xml_csv_dir+input_filename[:-4]+'_lit_citations.csv', 'w')
csvfile_agent = open(xml_csv_dir+input_filename[:-4]+'_agents.csv', 'w')


writer_patent = csv.writer(csvfile_patent)
writer_examiner = csv.writer(csvfile_examiner)
writer_inventor = csv.writer(csvfile_inventor)
writer_assignee = csv.writer(csvfile_assignee)
writer_assignor = csv.writer(csvfile_assignor)
writer_citation = csv.writer(csvfile_citation)
writer_litcitation = csv.writer(csvfile_litcitation)
writer_agent = csv.writer(csvfile_agent)

#start to parse XML file by REC (a full record schema in DERWENT XML file)
for tsip in root.findall('.//'+url+'tsip'):
    patent = tsip.find('.//'+url+'patent')
    # Parse the patent data and write it to the csv file
    r_patent = dict()
    r_patent_seq = 1
    r_patent['id'] = r_patent_seq
    r_patent['file_name'] = input_filename
    r_patent['status'] = ''
    r_patent['country'] = ''
    r_patent['published_date'] = ''
    r_patent['classificationipc'] = ''
    r_patent['patent_num_wila'] = ''
    r_patent['patent_num_orig'] = ''
    r_patent['patent_num_tsip'] = ''
    publications = patent.find('.//'+url+'publications')
    if publications is not None:
        document_id = publications.find('.//'+url+'documentId')
        if document_id is not None:
            kindcode = document_id.find('.//'+url+'kindCode')
            if kindcode is not None and kindcode.text is not None:
                r_patent['patent_type'] = kindcode.text.encode('utf-8')
            date = document_id.find('.//'+url+'date')
            if date is not None and date.text is not None:
                r_patent['published_date'] = date.text.encode('utf-8')
                year = int(r_patent['published_date'][0:4])
                if year >= 2001 and r_patent['patent_type'] not in \
                    onafter_2001:
                    continue
                elif year < 2001 and r_patent['patent_type'] not in \
                    before_2001:
                    continue
            country = document_id.find('.//'+url+'countryCode')
            if country is not None and country.text is not None:
                r_patent['country'] = country.text.encode('utf-8')

            for  patent_num in document_id.findall('.//'+url+'number'):
                if patent_num is not None and patent_num.text is not None:
                    form = patent_num.get(url+'form')
                    if form == 'wila':
                        r_patent['patent_num_wila'] = patent_num.text.\
                            encode('utf-8')
                    elif form == 'original' :
                        r_patent['patent_num_orig'] = patent_num.text.\
                            encode('utf-8')
                    else:
                        r_patent['patent_num_tsip'] = patent_num.text.\
                            encode('utf-8')

        r_patent['status'] = publications.get(url+'action')
        classificationIpc = publications.find('.//'+url+'classificationIpc')
        if classificationIpc is not None:
            ipc = classificationIpc.find('.//'+url+'ipc')
            if ipc is not None and ipc.text is not None:
                r_patent['classificationipc'] = ipc.text.encode('utf-8')

    r_patent['appl_num_wila'] = ''
    r_patent['appl_num_orig'] = ''
    r_patent['appl_num_tsip'] = ''
    r_patent['appl_type'] = ''
    r_patent['appl_year'] = ''
    r_patent['appl_date'] = ''
    r_patent['appl_country'] = ''
    r_patent['appl_series_code'] = ''
    applications = patent.find('.//'+url+'applications')
    if applications is not None:
        appl_type = applications.find('.//'+url+'application')
        if appl_type is not None:
            r_patent['appl_type'] = appl_type.get(url+'ki')
        application_id = applications.find('.//'+url+'applicationId')
        if application_id is not None:
            for  application_num in application_id.findall('.//'+url+'number'):
                if application_num is not None and application_num.text is \
                    not None:
                    form = application_num.get(url+'form')
                    if form == 'wila':
                        r_patent['appl_num_wila'] = application_num.text.\
                            encode('utf-8')
                    elif form == 'original':
                        r_patent['appl_num_orig'] = application_num.text.\
                            encode('utf-8')
                    else:
                        r_patent['appl_num_tsip'] = application_num.text.\
                            encode('utf-8')
            appl_year = application_id.find('.//'+url+'applicationYear')
            if appl_year is not None and appl_year.text is not None:
                r_patent['appl_year'] = appl_year.text.encode('utf-8')
            appl_date = application_id.find('.//'+url+'date')
            if appl_date is not None and appl_date.text is not None:
                r_patent['appl_date'] = appl_date.text.encode('utf-8')
            appl_country = application_id.find('.//'+url+'countryCode')
            if appl_country is not None and appl_country.text is not None:
                r_patent['appl_country'] = appl_country.text.encode('utf-8')
            appl_series_code = application_id.find('.//'+url+'seriesCode')
            if appl_series_code is not None and appl_series_code.text is not \
                None:
                r_patent['appl_series_code'] = appl_series_code.text.\
                    encode('utf-8')

    r_patent['parent_patent_num'] = ''
    relateds = patent.find('.//'+url+'relateds')
    if relateds is not None:
      related_patent = relateds.find('.//'+url+'relatedParentChild')
      if related_patent is not None:
        parent_patent = related_patent.find('.//'+url+'parent')
        if parent_patent is not None:
          document_id = parent_patent.find('.//'+url+'documentId')
          if document_id is not None:
            for number in document_id.findall('.//'+url+'number'):
              form = number.get(url+'form')
              if form == 'original':
                r_patent['parent_patent_num'] = number.text

    classificationUs = patent.find('.//'+url+'classificationUs')
    r_patent['main_classification'] = ''
    r_patent['sub_classification'] = ''
    if classificationUs is not None:
        for uspc in classificationUs.findall('.//'+url+'uspc'):
            if uspc.get(url+'type') == 'main':
                main = uspc.find('.//'+url+'mainclass')
                if main is not None and main.text is not None:
                    r_patent['main_classification'] = main.text.encode('utf-8')
                sub = uspc.find('.//'+url+'subclass')
                if sub is not None and sub.text is not None:
                    r_patent['sub_classification'] = sub.text.encode('utf-8')

    r_patent['invention_title'] = ''
    titles = patent.find('.//'+url+'titles')
    if titles is not None:
        invention_title = titles.find('.//'+url+'titleTsxm')
        if invention_title is not None and invention_title.text is not None:
            r_patent['invention_title'] = invention_title.text.encode('utf-8')

    r_patent['claim_text'] = ''
    abstracts = patent.find('.//'+url+'abstracts')
    if abstracts is not None:
        abstractText = abstracts.find('.//'+url+'abstractTsxm')
        if  abstractText is not None:
            claim_text = abstractText.find('.//'+urltsxm+'p')
            if claim_text is not None and claim_text.text is not None:
                r_patent['claim_text'] = claim_text.text.encode('utf-8')

    r_patent['government_support'] = ''
    r_patent['summary_of_invention'] = ''
    descorig = patent.find('.//'+url+'descriptionOriginalTsxm')
    if descorig is not None:
        governmentInterest = descorig.find('.//'+url+'governmentInterestTsxm')
        if governmentInterest is not None:
            government_support = governmentInterest.find('.//'+urltsxm+'p')
            if government_support is not None and government_support.text is \
                not None:
                r_patent['government_support'] = government_support.text.\
                    encode('utf-8')
        else:
            descorig_list = descorig.getchildren()
            govsupport_begin_tag = 'false'
            for p in descorig_list:
                if govsupport_begin_tag == 'true' and p.tag == urltsxm+'p':
                    if p.text is not None:
                        r_patent['government_support'] = p.text.encode('utf-8')
                        govsupport_begin_tag = 'false'
                elif p.tag == urltsxm+'heading' and p.text is not None:
                    if ('GOVERNMENT' in p.text or 'FEDERAL' in p.text or \
                        'STATEMENT OF SUPPORT' in p.text):
                        govsupport_begin_tag = 'true'

        briefSummaryTsxm = descorig.find('.//'+url+'briefSummaryTsxm')
        if briefSummaryTsxm is not None:
            get_children = briefSummaryTsxm.getchildren()
            summary_begin_tag = 'false'
            govsupport_begin_tag = 'false'
            for p in get_children:
                if summary_begin_tag == 'true' and p.tag == urltsxm+'p':
                    if p.text is not None:
                        summary_of_invention = p.text.encode('utf-8')
                        r_patent['summary_of_invention'] += ' '+\
                            summary_of_invention
                elif p.tag == urltsxm+'heading' and p.text is not None:
                    if 'SUMMARY' in p.text:
                        summary_begin_tag = 'true'
                else:
                    summary_begin_tag = 'false'
                if govsupport_begin_tag == 'true' and p.tag == urltsxm+'p':
                    if p.text is not None:
                        r_patent['government_support'] = p.text.encode('utf-8')
                        govsupport_begin_tag = 'false'
                elif p.tag == urltsxm+'heading' and p.text is not None:
                    if ('GOVERNMENT' in p.text or 'FEDERAL' in p.text or \
                        'STATEMENT OF SUPPORT' in p.text):
                        govsupport_begin_tag = 'true'

    # write each record to a CSV file for derwent_patents table
    writer_patent.writerow((r_patent['id'], r_patent['patent_num_orig'], \
        r_patent['patent_num_wila'], r_patent['patent_num_tsip'], \
        r_patent['patent_type'], r_patent['status'], r_patent['file_name'], \
        r_patent['country'], r_patent['published_date'], \
        r_patent['appl_num_orig'], r_patent['appl_num_wila'], \
        r_patent['appl_num_tsip'], r_patent['appl_date'], \
        r_patent['appl_year'], r_patent['appl_type'], \
        r_patent['appl_country'], r_patent['appl_series_code'], \
        r_patent['classificationipc'], r_patent['main_classification'], \
        r_patent['sub_classification'], r_patent['invention_title'], \
        r_patent['claim_text'], r_patent['government_support'], \
        r_patent['summary_of_invention'], r_patent['parent_patent_num']))

    # Parse the agent data and write it to the csv file
    r_agent = dict()

    agents = patent.find('.//'+url+'agents')
    if agents is not None:
        r_agent['patent_num'] = r_patent['patent_num_orig']
        for agent in agents.findall('.//'+url+'agent'):
            r_agent_seq = 1
            r_agent['id'] = r_agent_seq
            r_agent['rep_type'] = agent.get(url+'agentType')
            r_agent['last_name'] = ''
            r_agent['first_name'] = ''
            r_agent['orgname'] = ''
            r_agent['country'] = ''

            last_name = agent.find('.//'+url+'surname')
            if last_name is not None and last_name.text is not None:
                r_agent['last_name'] = last_name.text.encode('utf-8')

            first_name = agent.find('.//'+url+'forename')
            if first_name is not None and first_name.text is not None:
                r_agent['first_name'] = first_name.text.encode('utf-8')

            orgname = agent.find('.//'+url+'agentTotal')
            if orgname is not None and orgname.text is not None:
                r_agent['orgname'] = orgname.text.encode('utf-8')

            country = agent.find('.//'+'country')
            if country is not None and country.text is not None:
                r_agent['country'] = country.text.encode('utf-8')

            writer_agent.writerow((r_agent['id'],r_agent['patent_num'],\
                r_agent['rep_type'],r_agent['last_name'],\
                r_agent['first_name'],r_agent['orgname'],r_agent['country']))


    # Parse the examiner data and write it to the csv file
    r_examiner = dict()

    examiners = patent.find('.//'+url+'examiners')
    if examiners is not None:
        for examiner in examiners.findall('.//'+url+'examiner'):
            r_examiner_seq =1
            r_examiner['id'] = r_examiner_seq
            r_examiner['patent_num'] = r_patent['patent_num_orig']
            r_examiner['full_name'] = ''
            r_examiner['examiner_type'] = ''
            full_name = examiner.find('.//'+url+'examinerTotal')
            if full_name is not None and full_name.text is not None:
                r_examiner['full_name'] = full_name.text.encode('utf-8')
            r_examiner['examiner_type'] = examiner.get(url+'type')
            writer_examiner.writerow((r_examiner['id'],\
                r_examiner['patent_num'],r_examiner['full_name'],\
                r_examiner['examiner_type']))

    # Parse assignee data and write it to the csv file
    r_assignee = dict()
    r_assignee['patent_num'] = r_patent['patent_num_orig']
    assignees = patent.find('.//'+url+'assignees')
    if assignees is not None:
        for assignee in assignees.findall('.//'+url+'assignee'):
            r_assignee_seq = 1
            r_assignee['id'] = r_assignee_seq
            r_assignee['assignee_name']= ''
            r_assignee['city'] = ''
            r_assignee['state'] = ''
            r_assignee['country'] = ''
            assignee_name = assignee.find('.//'+url+'nameTotal')
            if assignee_name is not None and assignee_name.text is not None:
                r_assignee['assignee_name'] = assignee_name.text.\
                                              encode('utf-8')
            r_assignee['role'] = assignee.get(url+'appType')

            address = assignee.find('.//'+url+'address')
            if address is not None:
                city = address.find('.//'+url+'city')
                if city is not None and city.text is not None:
                    r_assignee['city']=city.text.encode('utf-8')

                state=address.find('.//'+url+'state')
                if state is not None and state.text is not None:
                    r_assignee['state']=state.text.encode('utf-8')

                country=address.find('.//'+url+'countryCode')
                if country is not None and country.text is not None:
                    r_assignee['country']=country.text

            writer_assignee.writerow((r_assignee['id'],\
                r_assignee['patent_num'],r_assignee['assignee_name'],\
                r_assignee['role'],r_assignee['city'],r_assignee['state'],\
                r_assignee['country']))

    # Process assignors data and generate CSV file
    r_assignor = dict()
    assignors = patent.find('.//'+url+'assignors')
    r_assignor['patent_num'] = r_patent['patent_num_orig']
    if assignors is not None:
        for assignor in assignors.findall('.//'+url+'assignor'):
            r_assignor_seq = 1
            r_assignor['id'] = r_assignor_seq
            r_assignor['assignor_name'] = ''
            assignor_name = assignor.find('.//'+url+'assignorTotal')
            if assignor_name is not None and assignor_name.text is not None:
                r_assignor['assignor_name'] = assignor_name.text.\
                                              encode('utf-8')
            writer_assignor.writerow((r_assignor['id'],\
                r_assignor['patent_num'],r_assignor['assignor_name']))

    # Parse inventor data and write it to the csv file
    r_inventor = dict()
    r_inventor_seq = 1
    inventors = patent.find('.//'+url+'inventors')
    if inventors is not None:
        for inventor in inventors.findall('.//'+url+'inventor'):
            r_inventor['id'] = r_inventor_seq
            r_inventor['patent_num'] = r_patent['patent_num_orig']
            r_inventor['inventortotal']=''
            r_inventor['full_name'] = ''
            r_inventor['last_name'] = ''
            r_inventor['first_name'] = ''
            r_inventor['city'] = ''
            r_inventor['state'] = ''
            r_inventor['country'] = ''
            inventorTotal = inventor.find('.//'+url+'inventorTotal')
            if inventorTotal is not None and inventorTotal.text is not None:
                r_inventor['inventortotal'] = inventorTotal.text.\
                                              encode('utf-8')

            name = inventor.find('.//'+url+'name')
            if name is not None:
                full_name = name.find('.//'+url+'nameTotal')
                if full_name is not None and full_name.text is not None:
                    r_inventor['full_name'] = full_name.text.encode('utf-8')
                last_name = name.find('.//'+url+'surname')
                if last_name is not None and last_name.text is not None:
                    r_inventor['last_name'] = last_name.text.encode('utf-8')
                first_name = name.find('.//'+url+'forenames')
                if first_name is not None and first_name.text is not None:
                    r_inventor['first_name'] = first_name.text.encode('utf-8')

            address = inventor.find('.//'+url+'address')
            if address is not None:
                city = address.find('.//'+url+'city')
                if city is not None and city.text is not None:
                    r_inventor['city'] = city.text.encode('utf-8')
                state = address.find('.//'+url+'state')
                if state is not None and state.text is not None:
                    r_inventor['state'] = state.text.encode('utf-8')
                country = address.find('.//'+url+'countryCode')
                if country is not None and country.text is not None:
                    r_inventor['country'] = country.text.encode('utf-8')

            writer_inventor.writerow((r_inventor['id'],\
                r_inventor['patent_num'],r_inventor['inventortotal'],\
                r_inventor['full_name'],r_inventor['last_name'],\
                r_inventor['first_name'],r_inventor['city'],\
                r_inventor['state'],r_inventor['country']))

    # Parse literature citation data and write it to the csv file
    r_litcitation = dict()
    r_litcitation['patent_num'] = r_patent['patent_num_orig']

    literatureCitations = patent.find('.//'+url+'literatureCitations')
    if literatureCitations is not None:
        for litcitation in literatureCitations.\
            findall('.//'+url+'litCitation'):
            r_litcitation['lit_cite'] = ''
            litcit = litcitation.find('.//'+url+'litCitationTotal')
            if litcit is not None and litcit.text is not None:
                r_litcitation['lit_cite'] = litcit.text.encode('utf-8')
                r_litcitation_seq =1
                r_litcitation['id'] = r_litcitation_seq
                writer_litcitation.writerow((r_litcitation['id'],\
                    r_litcitation['patent_num'],r_litcitation['lit_cite']))

    # Parse patent citation data and write it to the csv file
    patentCitations = patent.find('.//'+url+'patentCitations')
    r_citation = dict()
    r_citation['patent_num'] = r_patent['patent_num_orig']
    if patentCitations is not None:
        for citation in  patentCitations.findall('.//'+url+'patCitation'):
            if citation is not None:
                r_citation_seq =1
                r_citation['id'] = r_citation_seq
                r_citation['cited_patnum_wila'] = ''
                r_citation['cited_patnum_orig'] = ''
                r_citation['cited_patnum_tsip'] = ''
                r_citation['country'] = ''
                r_citation['kind'] = ''
                r_citation['cited_date'] = ''
                documentId = citation.find('.//'+url+'documentId')
                if documentId is not None:
                    for number in documentId.findall('.//'+url+'number'):
                        if number is not None and number.text is not None:
                            if number.get(url+'form') == 'wila':
                                r_citation['cited_patnum_wila'] = number.text.\
                                                                encode('utf-8')
                            elif number.get(url+'form') == 'original':
                                r_citation['cited_patnum_orig'] = number.text.\
                                                                encode('utf-8')
                            elif number.get(url+'form') == 'tsip':
                                r_citation['cited_patnum_tsip'] = number.text.\
                                                                encode('utf-8')

                    country = documentId.find('.//'+url+'countryCode')
                    if country is not None and country.text is not None:
                        r_citation['country'] = country.text.encode('utf-8')
                    kind = documentId.find('.//'+url+'kindCode')
                    if kind is not None and kind.text is not None:
                        r_citation['kind'] = kind.text.encode('utf-8')
                    cited_date = documentId.find('.//'+'date')
                    if cited_date is not None and cited_date.text is not None:
                        r_citation['cited_date'] = cited_date.text.\
                                                   encode('utf-8')

                citedInventors = citation.find('.//'+url+'citedInventors')
                r_citation['cited_inventor'] = ''
                if citedInventors is not None:
                    nameTotal = citedInventors.find('.//'+url+'nameTotal')
                    if nameTotal is not None and nameTotal.text is not None:
                        r_citation['cited_inventor'] = nameTotal.text.\
                                                       encode('utf-8')

                citedUs = citation.find('.//'+url+'citedUs')
                r_citation['main_class'] = ''
                r_citation['sub_class'] = ''
                if citedUs is not None:
                    mainclass = citedUs.find('.//'+url+'mainclass')
                    if mainclass is not None and mainclass.text is not None:
                        r_citation['main_class'] = mainclass.text.\
                                                   encode('utf-8')
                    subclass = citedUs.find('.//'+url+'subclass')
                    if subclass is not None and subclass.text is not None:
                        r_citation['sub_class'] = subclass.text.encode('utf-8')

                writer_citation.writerow((r_citation['id'],\
                    r_citation['patent_num'],r_citation['cited_patnum_orig'],\
                    r_citation['cited_patnum_wila'],\
                    r_citation['cited_patnum_tsip'],r_citation['country'],\
                    r_citation['kind'],r_citation['cited_inventor'],\
                    r_citation['cited_date'],r_citation['main_class'],\
                    r_citation['sub_class']))

# Write parallelized shell/sql code for uploading CSV to PostgreSQL
shell_load = open(xml_csv_dir+input_filename[:-4]+'_load.sh', 'w') ; cpu_count = mp.cpu_count()
tasks = ['patents','inventors','examiners', 'assignees','pat_citations','agents','assignors','lit_citations']
for i in range(0, len(tasks)):
    csv_file_name = input_filename[:-4]+"_"+tasks[i]+".csv"
    copy_command = "psql -c \"copy new_derwent_"+tasks[i]+" from \'"+xml_csv_dir+csv_file_name+"\' delimiter \',\' CSV;\" &\n"
    y=i+1; copy_command = copy_command+"wait\n" if (y%cpu_count==0)  else copy_command+"wait\n" if (y==len(tasks)) else copy_command
    shell_load.write((copy_command))
shell_load.close()

# Close all opened files
csvfile_patent.close()
csvfile_examiner.close()
csvfile_inventor.close()
csvfile_assignee.close()
csvfile_assignor.close()
csvfile_citation.close()
csvfile_litcitation.close()
csvfile_agent.close()
