"""
Title: Email Parser-Downloader-Tester
Author: Djamil Lakhdar-Hamina
Date: 06/24/2019


The point of this parser is to take an email and scan it for url.
Once the url is found it opens it up and saves it to a specified directory.
This is code for an automated process which will leverage Jenkins to set off a process when
triggered by the reception of an email with a url-link.

Example link:

https://sccontent-scudd-delivery-prod.s3.amazonaws.com/sccontent-scudd-delivery-prod/nete_1557815293641/2019-6-4/nete_1557815293641_2019-6-4_ANI-ITEM-delete.zip?AWSAccessKeyId=AKIA33DQTS4C4RTMKWFE&Expires=1567427254&Signature=Lecw433oI7gWk4jqVwO8B3KsH%2BY%3D


"""
import re
import urllib
import zipfile
from sys import argv

##Build a function that 1) opens email 2) scans it for urls 3) stores urls and then opens file in them 4) then rename this downloaded file and store in specified directory.

def email_parser(pmt_content=argv[1]):
    """
    Assumptions:

    Given an email, read the email, then scan it for url.
    If url is found, download, rename, and then save to specified directory.

    Arguments: email_message and default directory= /Scopus

    Input: email_message with forwarded emails called pmt_content because that is the property name given by Jenkins when you call as variable to be executed in process
    Output: A group of zip files, renamed, and stored in specified directory called /Scopus

    :return:
    """

msg= re.findall('https://\S*', pmt_content)
for url_link in msg:
    if url_link != re.search('nete.*CITEDBY.zip', url_link):
## Go through list of links, rename
        request = urllib.urlrequest(url_link)
        scopus_update_zip_file = zipfile.ZipFile(request)
        scopus_update_zip_file.filename = temp[0].split('/')[2] = re.search('nete.*ANI.*zip',links)
        print(scopus_update_zip_file)
