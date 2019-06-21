"""
Title: Email Parser-Downloader
Author: Djamil Lakhdar-Hamina
Date: 06/13/2019

The point of this parser is to take an email and scan it for url.
Once the url is found it opens it up and saves it to a specified directory.
This is code for an automated process which will leverage Jenkins to set off a process when
triggered by the reception of an email with a url-link.

Example link:

https://sccontent-scudd-delivery-prod.s3.amazonaws.com/sccontent-scudd-delivery-prod/nete_1557815293641/2019-6-4/nete_1557815293641_2019-6-4_ANI-ITEM-delete.zip?AWSAccessKeyId=AKIA33DQTS4C4RTMKWFE&Expires=1567427254&Signature=Lecw433oI7gWk4jqVwO8B3KsH%2BY%3D


"""
import re
import urllib
import email
import zipfile
from email.policy import default
import os
from argparse import ArgumentParser


##Build a function that 1) opens email 2) scans it for urls 3) stores urls and then opens file in them 4) then rename this downloaded file and store in specified directory.

def email_parser():
    """
    Assumptions:

    Given an email, read the email, then scan it for url.
    If url is found, download, rename, and then save to specified directory.

    Arguments: email_message and default directory= /Scopus

    Input: email_message with forwarded emails called pmt_content because that is the property name given by Jenkins when you call as variable to be executed in process
    Output: A group of zip files, renamed, and stored in specified directory called /Scopus

    :return:
    """

    parser = ArgumentParser
    parser.add_argument('-p', '--pmt_content', required=True,
                        help="""email message that will get parsed for url-link and zip-file""")
    parser.add_argument('-d','--directory', required=True, help="""specified directory for zip-file""")#
    args = parser.parse_args()

    ## Open email, fortunately the parse function will treat attachments, essentially, as part of (an instance) of the MIME or email data-structure.

    with open(args.pmt_content, 'r') as email_msg:
        msg = email.parse(email_msg, policy=default)

    ## Scan emails for url and store the url(s) in a list
    msg= re.findall('https://\S*', msg)
    for url_link in msg.walk():
        if url_link != re.search('nete.*CITEDBY.zip', url_link):
    ## Go through list of links, rename
            request = urllib.urlrequest(url)
            scopus_update_zip_file = zipfile.ZipFile(request)
            scopus_update_zip_file.filename = temp[0].split('/')[2] = re.search('nete.*ANI.*zip',links)
    ## Now store them in specified directory
            os.path.join(args.directory, scopus_update_zip_file)





            