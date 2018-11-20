# coding=utf-8

'''
Function:   this is a class file for subjects to save its value in the form of an object


USAGE:  	python subjects.py -filename file_name -csv_dir csv_file_directory
Author: 	Sitaram Devarakonda
Date:		10/03/2018
Changes:
'''

class subjects:
    def __init__(self):
        self.subject_classification_type=''
        self.subject=''
        self.wos_subject_id=None
        self.source_id=''
