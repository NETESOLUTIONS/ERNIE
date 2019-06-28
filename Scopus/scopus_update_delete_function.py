"""
Title: Scopus_Update Delete Function
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

    parser.add_argument('-d','--directory', required=True, help="""specified directory for zip-file""")

    args = parser.parse_args()

    for file in os.walk(args.directory):
        print("Scanning directory...")
        return file
        if (current_time - os.path.getmtime(file)) > (5 * 604800) :
            return file
            os.remove(file)
            print("File is removed")


## Run the function with relevant input
results= delete_function(args.directory)
print('The relevant files are removed! ')
## End of script
