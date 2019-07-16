"""
Title: Scopus_Update Delete Function
Author: Djamil Lakhdar-Hamina
Date: 06/27/2019

The point of this delete function is scan a directory. It scans the date when the file was uploaded and whether it was processed.
If the file satisfies both conditions then it is deleted.

This is part of the code for an automated process which will leverage Jenkins to set off a process when
triggered by the reception of an email with a url-link.

"""

import time
import os
from argparse import ArgumentParser

current_time=time.time()

def delete_function(data_directory="/erniedev_data2/Scopus_updates"):

    """
    Assumptions:

    Given a directory, scan the files in directory. If it is processed and more than 5 weeks old then delete.

    Arguments: directory= /Scopus_update

    Input: directory
    Output: remove a file

    """

    present_time = time.time()
    for file in os.listdir(data_directory):
        file_mtimeresult = os.stat(os.path.join(data_directory, file))
        file_mtimeresult = [file, (present_time - file_mtimeresult.st_mtime)]
            if file_mtimeresult[1] > (840 * 3600):
                print("The present file" + " " + str(file_mtimeresult[0]) + " " + "will be removed....")
                os.remove(os.path.join(data_directory, file))
                 print("The present file " + " "  + str(file_mtimeresult[0]) + " " + "is removed!")

## Run the function with relevant input
print('Scanning for at least 5-week old files within the Scopus_updates directory... ')
target_data_directory="/erniedev_data2/Scopus_updates"
results= delete_function(target_data_directory)
print('The relevant files are removed:',results )
## End of script
