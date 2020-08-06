# column_extractor.py
# this program is used to extract specific columns from the Reporter csv data
# Date: 12/08/2017
# Author: VJ Davey

import pandas as pd
import sys

csv_file_path=str(sys.argv[1]); 
print(f'Working with CSV file located at {csv_file_path}')
keep_headers = ['APPLICATION_ID','ACTIVITY','ADMINISTERING_IC','APPLICATION_TYPE','ARRA_FUNDED','AWARD_NOTICE_DATE','BUDGET_START',
'BUDGET_END','CFDA_CODE','CORE_PROJECT_NUM','ED_INST_TYPE','FOA_NUMBER','FULL_PROJECT_NUM','SUBPROJECT_ID','FUNDING_ICs','FY','IC_NAME',
'NIH_SPENDING_CATS','ORG_CITY','ORG_COUNTRY','ORG_DEPT','ORG_DISTRICT','ORG_DUNS','ORG_FIPS','ORG_NAME','ORG_STATE','ORG_ZIPCODE','PHR',
'PI_IDS','PI_NAMEs','PROGRAM_OFFICER_NAME','PROJECT_START','PROJECT_END','PROJECT_TERMS','PROJECT_TITLE','SERIAL_NUMBER','STUDY_SECTION',
'STUDY_SECTION_NAME','SUFFIX','SUPPORT_YEAR','TOTAL_COST','TOTAL_COST_SUB_PROJECT']
df = pd.read_csv(csv_file_path, dtype=object, encoding='latin-1'); df = df[keep_headers];
for header in keep_headers:
    df[header] = df[header].str.replace(',','')
    df[header] = df[header].str.encode('utf8')
df.to_csv(csv_file_path[:-4]+'_EXTRACTED.csv', index=False)
