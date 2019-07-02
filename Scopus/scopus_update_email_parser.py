"""
Title: Email Parser-Downloader
Author: Djamil Lakhdar-Hamina
Date: 06/13/2019

The point of this parser is to take an email and scan it for url.
Once the url is found it opens it up and saves it to a specified directory.

This is part of the code for an automated process which will leverage Jenkins to set off a process when
triggered by the reception of an email with a url-link.
"""

import time
import re
import requests
import urllib
import zipfile
from io import BytesIO, StringIO
from sys import argv

start_time=time.time()

pmt_content=argv[1]

##Build a function that 1) opens email 2) scans it for urls 3) stores urls and then opens file in them 4) then rename this downloaded file and store in specified directory.

def email_parser(pmt_content, data_directory="/erniedev_data2/Scopus_updates"):
    """
    Assumptions:

    Given an email, read the email, then scan it for url.
    If url is found, download, rename, and then save to specified directory.

    Input: email_message and default value for directory= /erniedev_data2/Scopus_updates
    Output: A group of zip files, renamed, and stored in specified directory called /erniedev_data2/Scopus_updates

    :return:
    """

    ## Scan emails for url and store the url(s) in a list
    print("Scanning email now for url...")
    links= re.findall('https://\S*.3D', pmt_content)
    links=links[0:3]
    return links
    links.remove(links[1])
    print("Relevant urls are in the following links:", links )
    for link in links:
    ## Go through list of links, request https, download url with zip
        print("Getting url-requests...")
        req=requests.get(link)
        print("The request went through?",req.ok)
        print("Now saving zip files to specified directory...")
        scopus_zip_file=zipfile.ZipFile(BytesIO(req.content))
        scopus_zip_file.extractall(data_directory)
        print("The zip files should be present in specified directory!")
        #through list of links, come up with name, rename/store in testing_directory
        print("Renaming files...")
        zip_file_name= re.findall('nete.*ANI.*zip', link)
        scopus_zip_file.filename = zip_file_name[0].split('/')[2]
        #print("The revelevant zip files (names) are:", zip_file_name)
        print("The zip files should downloaded in the directory with the correct name!")

## Run the function with the relevant input, which is already default argument for email_parser
testing_directory="/erniedev_data2/Scopus_updates"
email_parser(pmt_content, testing_directory)
print('The revelevant files are parsed!')
print('Total duration:',time.time()-start_time)
## End of the script
