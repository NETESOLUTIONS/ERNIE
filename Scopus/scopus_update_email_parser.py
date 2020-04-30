"""
Title: Email Parser-Downloader
Author: Djamil Lakhdar-Hamina
Date: 06/13/2019
Updated by Shreya Chandrasekharan on 04/24/2020
The point of this parser is to take an email and scan it for url.
Once the url is found it opens it up and saves it to a specified directory.
This is part of the code for an automated process which will leverage Jenkins to set off a process when
triggered by the reception of an email with a url-link.

Arguments: 
	1. PMT Content
	2. Save path
"""

import time
import re
import requests
import urllib.request
import os
from sys import argv

start_time=time.time()

pmt_content=argv[1]
data_directory = argv[2]

## Build a function that 1) opens email 2) scans it for urls 3) stores urls and then opens file in them 4) then rename this downloaded file and store in specified directory.


def scopus_zip_file_name_date_edit(scopus_zip_file_name):
    
    """
    The original scopus_zip_file_name is returned with date in the format YYYY-M-D
    We would like to change the date format to YYYY-MM-DD so that file name order is maintained.
    
    Argument(s):
    scopus_zip_file_name: (str) Name extracted at the end of this email parser
    
    Output(s):
    scopus_zip_file_name: (str) Edited name with corrected date format.
    
    """
    old_format = 'YYYY-M-D'
    match_pattern_index = scopus_zip_file_name.index('_ANI-ITEM')
    date_field = scopus_zip_file_name[(match_pattern_index-len(old_format)):match_pattern_index]

    first_part = scopus_zip_file_name[:(match_pattern_index-len(old_format))] 
    last_part = scopus_zip_file_name[match_pattern_index:]
    
    date_field = date_field.split('-')
    date_field[1] = date_field[1].zfill(2)
    date_field[2] = date_field[2].zfill(2)
    date_field = ('-').join(date_field)
    
    scopus_zip_file_name = first_part + date_field + last_part
    
    return scopus_zip_file_name


def email_parser(pmt_content, data_directory):
    """
    Assumptions:
    Given an email, read the email, then scan it for url.
    If url is found, download, rename, and then save to specified directory.
    Input: email_message and default value for directory= /erniedev_data2/Scopus_updates
    Output: A group of zip files, renamed, and stored in specified directory called /erniedev_data2/Scopus_updates
    :return:
    """

    ## Scan emails for url and store the url(s) in a list
    links= re.findall('https://\S[^<]*', pmt_content)
    links=links[0:3]
    links.remove(links[1])
    ## Go through list of links, request https, download url with zip
    for url in links:
        #through list of links, come up with name, rename/store in testing_directory
        scopus_zip_file_name= re.findall('nete.*ANI.*zip', url)
        scopus_zip_file_name= scopus_zip_file_name[0].split('/')[2]
        print("Old zip file name: ", scopus_zip_file_name)
        scopus_zip_file_name = scopus_zip_file_name_date_edit(scopus_zip_file_name)
        print("New zip file name: ", scopus_zip_file_name)
        urllib.request.urlretrieve(url,os.path.join(data_directory,scopus_zip_file_name))
        print(scopus_zip_file_name)


## Run the function with the relevant input, which is already default argument for email_parser
print("Scanning email now for url...")
print("The email content is:")
print("")
print(pmt_content)
print("")
result=email_parser(pmt_content, data_directory)
#print('The revelevant items are zip files:', result)
print('The total duration for the whole process:',time.time()-start_time)
## End of the script
