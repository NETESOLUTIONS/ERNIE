"""
Title: Scopus_Update Delete Function Tester
Author: Djamil Lakhdar-Hamina
Date: 06/27/2019


The point of this delete function is scan a directory. It scans the date when the file was uploaded and whether it was processed.
If the file satisfies both conditions then it is deleted.


"""

import time
import os
from argparse import ArgumentParser

current_time=time.time()

def delete_function():

    """
    Assumptions:

    Given a directory, scan the files in directory. If it is processed and more than 5 weeks old then delete.

    Arguments: directory= /Scopus_update

    Input: directory
    Output: remove a file

    """

    parser = ArgumentParser

    parser.add_argument('-d','--data_directory', required=True, help="""specified directory for zip-file""")

    args = parser.parse_args()

    present_time = time.time()
    print("Scanning directory...")
    for file in os.listdir("/Users/djamillakhdar-hamina/Desktop/"):
        if os.path.isfile(file) == True:
            file_mtimeresult = os.stat(os.path.join("/Users/djamillakhdar-hamina/Desktop/", file))
            file_mtimeresult = [file, (present_time - time_result.st_mtime)]
            if file_mtimeresult[1] < (840 * 3600):
                print("This file would be removed:")
                (return link)
    #print("File(s) is/(are) removed!")

## Run the function with relevant input

results= delete_function(d)
print('The relevant files are removed! ')
## End of script
