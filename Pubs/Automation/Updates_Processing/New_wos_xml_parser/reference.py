# coding=utf-8

"""
Function:   this is a class file for references to save its value in the form of an object


USAGE:  	python reference.py -filename file_name -csv_dir csv_file_directory
Author: 	Akshat Maltare
Date:		03/24/2018
Changes:
"""


class reference:
    def __init__(self):
        self.source_id = ''
        self.cited_source_id = None
        self.cited_title = ''
        self.cited_work = ''
        self.cited_author = ''
        self.cited_year = ''
        self.cited_page = ''
        self.created_date = ''
        self.last_modified_date = ''
        self.cited_source_uid = None
        self.id = None

    def __str__(self):
        return "<{}> {}".format(self.__class__, self.__dict__)
