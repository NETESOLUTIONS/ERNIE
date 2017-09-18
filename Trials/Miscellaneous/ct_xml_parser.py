# coding=utf-8

'''
This is a parser to extract the Clinical Trial (CT) data and to generate :
1. CSV files for CT tables.
    An example file name: NCT0000_ct_clinical_study.csv
    where NCT0000 represents XML file name, and
    ct_clinical_study represents table name.
    Please refer to list_table below for a full list of tables.
2. One PG file for loading tables to PG database.

Usage: python ct_xml_update_parser.py -filename file_name -csv_dir csv_file_directory

Author: Shixin Jiang, Lingtian "Lindsay" Wan
Create Date: 02/05/2016
Modified: 05/19/2016, Lindsay Wan, added documentation
'''

import re
import csv
import exceptions
import time
import os
import os.path
import datetime
import string
import psycopg2
import sys
import numpy as np
from lxml import etree


# %% Create lists of table names, main table headers and children table headers.
list_table = ['ct_clinical_studies', 'ct_secondary_ids', \
              'ct_collaborators', 'ct_authorities', \
              'ct_outcomes', 'ct_conditions', 'ct_arm_groups', \
              'ct_interventions', \
              'ct_intervention_arm_group_labels', \
              'ct_intervention_other_names', 'ct_overall_officials', \
              'ct_overall_contacts', 'ct_locations', \
              'ct_location_investigators', 'ct_location_countries', \
              'ct_links', 'ct_condition_browses', \
              'ct_intervention_browses', 'ct_references', \
              'ct_publications', 'ct_keywords']


# %% Check if the file name is provided, otherwise the program will stop.
in_arr = sys.argv
if '-filename' not in in_arr:
   print "No filename"
   raise NameError('error: file name is not provided')
else:
   input_filename = in_arr[in_arr.index('-filename') + 1]


# %% Check if the CSV file directory is provided, otherwise the program will
# stop.
if '-csv_dir' not in in_arr:
   print "No CSV file directory"
   raise NameError('error: CSV file directory is not provided')
else:
   input_csv_dir= in_arr[in_arr.index('-csv_dir') + 1]


# %% Find the csv directory, if not exist then create a new one.
xml_csv_dir = input_csv_dir+input_filename[:-4]+'/'
#xml_csv_dir = input_csv_dir
try:
   os.stat(xml_csv_dir)
except:
   os.mkdir(xml_csv_dir)


# %% Parse the XML file root and check if the unique ID exists. If not,
# do not load this file for now.
root = etree.parse(input_filename).getroot()
id_info = root.find('id_info')
nct_id = id_info.find('nct_id').text.encode('utf-8') if id_info is not None \
         else None
if nct_id is None:
    sys.exit("No nct_id found, file {} skipped".format(input_filename))


# %% Open connection to ERNIE database
try:
   conn=psycopg2.connect("dbname='ernie' user='ernie_admin'")
except:
   print "I am unable to connect to the database ernie."

cur = conn.cursor()

_date_re = re.compile(r'(?P<yr>\d{4})-(?P<mon>\d{2})-(?P<day>\d{2})')
_non_alphanum_re = re.compile(r'[^\w\s]+')


#url='{http://scientific.thomsonreuters.com/schema/wok5.4/public/FullRecord}'


# %% Find the current max sequence number from each table, create CSV files and
# CSV writer, and create data load command in the loop.
table_maxid = np.zeros(len(list_table), dtype=int)
csvfile_open_list = []
csvfile_write_list = []
file_load = open(xml_csv_dir+input_filename[:-4]+\
                 '_load.pg', 'w')
i=0
for table_name in list_table:
    # Find max ID
    # try:
    #     cur.execute("SELECT MAX(ID) FROM {0}".format(table_name))
    #     max_seq = cur.fetchall()
    #     if (max_seq[0])[0] is not None:
    #         table_maxid[i] = (max_seq[0])[0]
    # except:
    #     print "I can't select from {0} table.".format(table_name)
    i += 1
    # Create csv files and writer
    csvfile_open = open(xml_csv_dir+\
                        input_filename[:-4]+'_'+table_name+'.csv', 'w')
    csvfile_write = csv.writer(csvfile_open)
    csvfile_open_list.append(csvfile_open)
    csvfile_write_list.append(csvfile_write)
    # Create data load command
    copy_command = "copy "+table_name+\
                   " from '"+xml_csv_dir+\
                   input_filename[:-4]+'_'+table_name+\
                   ".csv' delimiter ',' CSV;\n"
    file_load.write((copy_command))


# Parse XML data to the CSV files.
# %% Parse the main table: ct_clinical_studies as ct_cs.
r_ct_cs = dict()
r_ct_cs['id'] = 1
r_ct_cs['nct_id'] = nct_id
rank = root.get('rank')
r_ct_cs['rank'] = rank.encode('utf-8') if rank is not None else ''
required_header = root.find('required_header')
if required_header is not None:
    download_date = required_header.find('download_date')
    r_ct_cs['download_date'] = download_date.text.encode('utf-8') if \
                               download_date is not None else ''
    link_text = required_header.find('link_text')
    r_ct_cs['link_text'] = link_text.text.encode('utf-8') if link_text is not \
                           None else ''
    url = required_header.find('url')
    r_ct_cs['url'] = url.text.encode('utf-8') if url is not None else ''
org_study_id = id_info.find('org_study_id')
r_ct_cs['org_study_id'] = org_study_id.text.encode('utf-8') if \
                          org_study_id is not None else ''
nct_alias = id_info.find('nct_alias')
r_ct_cs['nct_alias'] = nct_alias.text.encode('utf-8') if nct_alias is not \
                       None else ''
brief_title = root.find('brief_title')
r_ct_cs['brief_title'] = brief_title.text.encode('utf-8') if brief_title is \
                         not None else ''
acronym = root.find('acronym')
r_ct_cs['acronym'] = acronym.text.encode('utf-8') if acronym is not None \
                     else ''
official_title = root.find('official_title')
r_ct_cs['official_title'] = official_title.text.encode('utf-8') if \
                            official_title is not None else ''
lead_sponsor = root.find('sponsors').find('lead_sponsor') if \
               root.find('sponsors') is not None else None
lead_sponsor_agency = lead_sponsor.find('agency') if lead_sponsor \
                       is not None else None
r_ct_cs['lead_sponsor_agency'] = lead_sponsor_agency.text.encode('utf-8') if \
                                 lead_sponsor_agency is not None else ''
lead_sponsor_agency_class = lead_sponsor.find('agency_class') if \
                            lead_sponsor is not None else None
r_ct_cs['lead_sponsor_agency_class'] = \
    lead_sponsor_agency_class.text.encode('utf-8') if \
    lead_sponsor_agency_class is not None else ''
source = root.find('source')
r_ct_cs['source'] = source.text.encode('utf-8') if source is not None else ''
has_dmc = root.find('oversight_info').find('has_dmc') if \
          root.find('oversight_info') is not None else None
r_ct_cs['has_dmc'] = has_dmc.text.encode('utf-8') if has_dmc is not None \
                     else ''
brief_summary = root.find('brief_summary').find('textblock') if \
                root.find('brief_summary') is not None else None
r_ct_cs['brief_summary'] = brief_summary.text.encode('utf-8') if \
                           brief_summary is not None else ''
detailed_description = root.find('detailed_description').find('textblock') if \
                       root.find('detailed_description') is not None else None
r_ct_cs['detailed_description'] = detailed_description.text.encode('utf-8') \
                                  if detailed_description is not None else ''
overall_status = root.find('overall_status')
r_ct_cs['overall_status'] = overall_status.text.encode('utf-8') if \
                            overall_status is not None else ''
why_stopped = root.find('why_stopped')
r_ct_cs['why_stopped'] = why_stopped.text.encode('utf-8') if why_stopped is \
                         not None else ''
start_date = root.find('start_date')
r_ct_cs['start_date'] = start_date.text.encode('utf-8') if start_date is not \
                        None else ''
completion_date = root.find('completion_date')
r_ct_cs['completion_date'] = completion_date.text.encode('utf-8') if \
                             completion_date is not None else ''
completion_date_type = completion_date.get('type') if completion_date is not \
                       None else None
r_ct_cs['completion_date_type'] = completion_date_type.encode('utf-8') if \
                                  completion_date_type is not None else ''
primary_completion_date = root.find('primary_completion_date')
r_ct_cs['primary_completion_date'] = \
    primary_completion_date.text.encode('utf-8') if \
    primary_completion_date is not None else ''
primary_completion_date_type = primary_completion_date.get('type') if \
                               primary_completion_date is not None else None
r_ct_cs['primary_completion_date_type'] = \
    primary_completion_date_type.encode('utf-8') if \
    primary_completion_date_type is not None else ''
phase = root.find('phase')
r_ct_cs['phase'] = phase.text.encode('utf-8') if phase is not None else ''
study_type = root.find('study_type')
r_ct_cs['study_type'] = study_type.text.encode('utf-8') if study_type is not \
                        None else ''
study_design = root.find('study_design')
r_ct_cs['study_design'] = study_design.text.encode('utf-8') if study_design \
                          is not None else ''
target_duration = root.find('target_duration')
r_ct_cs['target_duration'] = target_duration.text.encode('utf-8') if \
                             target_duration is not None else ''
number_of_arms = root.find('number_of_arms')
r_ct_cs['number_of_arms'] = number_of_arms.text if number_of_arms is not None \
                            else ''
number_of_groups = root.find('number_of_groups')
r_ct_cs['number_of_groups'] = number_of_groups.text if number_of_groups is \
                              not None else ''
enrollment = root.find('enrollment')
r_ct_cs['enrollment'] = enrollment.text.encode('utf-8') if enrollment is not \
                        None else ''
enrollment_type = enrollment.get('type') if enrollment is not None else None
r_ct_cs['enrollment_type'] = enrollment_type.encode('utf-8') if \
                             enrollment_type is not None else ''
biospec_retention = root.find('biospec_retention')
r_ct_cs['biospec_retention'] = biospec_retention.text.encode('utf-8') if \
                               biospec_retention is not None else ''
biospec_descr = root.find('biospec_descr').find('textblock') if \
                root.find('biospec_descr') is not None else None
r_ct_cs['biospec_descr'] = biospec_descr.text.encode('utf-8') if \
                           biospec_descr is not None else ''
eligibility = root.find('eligibility')
if eligibility is not None:
    study_pop = eligibility.find('study_pop').find('textblock') if \
                eligibility.find('study_pop') is not None else None
    r_ct_cs['study_pop'] = study_pop.text.encode('utf-8') if study_pop is not \
                           None else ''
    sampling_method = eligibility.find('sampling_method')
    r_ct_cs['sampling_method'] = sampling_method.text.encode('utf-8') if \
                                 sampling_method is not None else ''
    criteria = eligibility.find('criteria').find('textblock') if \
               eligibility.find('criteria') is not None else None
    r_ct_cs['criteria'] = criteria.text.encode('utf-8') if criteria is not \
                          None else ''
    gender = eligibility.find('gender')
    r_ct_cs['gender'] = gender.text.encode('utf-8') if gender is not None \
                        else ''
    minimum_age = eligibility.find('minimum_age')
    r_ct_cs['minimum_age'] = minimum_age.text.encode('utf-8') if minimum_age \
                             is not None else ''
    maximum_age = eligibility.find('maximum_age')
    r_ct_cs['maximum_age'] = maximum_age.text.encode('utf-8') if maximum_age \
                             is not None else ''
    healthy_volunteers = eligibility.find('healthy_volunteers')
    r_ct_cs['healthy_volunteers'] = healthy_volunteers.text.encode('utf-8') \
                                    if healthy_volunteers is not None else ''
else: r_ct_cs['study_pop'] = r_ct_cs['sampling_method'] = r_ct_cs['criteria'] \
      = r_ct_cs['gender'] = r_ct_cs['minimum_age'] = r_ct_cs['maximum_age'] = \
      r_ct_cs['healthy_volunteers'] = ''
verification_date = root.find('verification_date')
r_ct_cs['verification_date'] = verification_date.text.encode('utf-8') if \
                               verification_date is not None else ''
lastchanged_date = root.find('lastchanged_date')
r_ct_cs['lastchanged_date'] = lastchanged_date.text.encode('utf-8') if \
                              lastchanged_date is not None else ''
firstreceived_date = root.find('firstreceived_date')
r_ct_cs['firstreceived_date'] = firstreceived_date.text.encode('utf-8') if \
                                firstreceived_date is not None else ''
firstreceived_results_date = root.find('firstreceived_results_date')
r_ct_cs['firstreceived_results_date'] = \
    firstreceived_results_date.text.encode('utf-8') if \
    firstreceived_results_date is not None else ''
responsible_party = root.find('responsible_party')
if responsible_party is not None:
    responsible_party_type = responsible_party.find('responsible_party_type')
    r_ct_cs['responsible_party_type'] = \
        responsible_party_type.text.encode('utf-8') if \
        responsible_party_type is not None else ''
    responsible_investigator_affiliation = \
        responsible_party.find('investigator_affiliation')
    r_ct_cs['responsible_investigator_affiliation'] = \
        responsible_investigator_affiliation.text.encode('utf-8') if \
        responsible_investigator_affiliation is not None else ''
    responsible_investigator_full_name = \
    responsible_party.find('investigator_full_name')
    r_ct_cs['responsible_investigator_full_name'] = \
        responsible_investigator_full_name.text.encode('utf-8') if \
        responsible_investigator_full_name is not None else ''
    responsible_investigator_title = \
    responsible_party.find('investigator_title')
    r_ct_cs['responsible_investigator_title'] = \
        responsible_investigator_title.text.encode('utf-8') if \
        responsible_investigator_title is not None else ''
else: r_ct_cs['responsible_party_type'] = \
          r_ct_cs['responsible_investigator_affiliation'] = \
          r_ct_cs['responsible_investigator_full_name'] = \
          r_ct_cs['responsible_investigator_title'] = ''
is_fda_regulated = root.find('is_fda_regulated')
r_ct_cs['is_fda_regulated'] = is_fda_regulated.text.encode('utf-8') if \
                              is_fda_regulated is not None else ''
is_section_801 = root.find('is_section_801')
r_ct_cs['is_section_801'] = is_section_801.text.encode('utf-8') if \
                            is_section_801 is not None else ''
has_expanded_access = root.find('has_expanded_access')
r_ct_cs['has_expanded_access'] = has_expanded_access.text.encode('utf-8') if \
                                 has_expanded_access is not None else ''


# %% Write the main table to CSV file.
csvfile_write_list[0].writerow((r_ct_cs['id'], r_ct_cs['nct_id'], \
    r_ct_cs['rank'], r_ct_cs['download_date'], r_ct_cs['link_text'], \
    r_ct_cs['url'], r_ct_cs['org_study_id'], r_ct_cs['nct_alias'], \
    r_ct_cs['brief_title'], r_ct_cs['acronym'], r_ct_cs['official_title'], \
    r_ct_cs['lead_sponsor_agency'], r_ct_cs['lead_sponsor_agency_class'], \
    r_ct_cs['source'], r_ct_cs['has_dmc'], \
    r_ct_cs['brief_summary'], r_ct_cs['detailed_description'], \
    r_ct_cs['overall_status'], r_ct_cs['why_stopped'], r_ct_cs['start_date'], \
    r_ct_cs['completion_date'], r_ct_cs['completion_date_type'], \
    r_ct_cs['primary_completion_date'], \
    r_ct_cs['primary_completion_date_type'], r_ct_cs['phase'], \
    r_ct_cs['study_type'], r_ct_cs['study_design'], \
    r_ct_cs['target_duration'], r_ct_cs['number_of_arms'], \
    r_ct_cs['number_of_groups'], r_ct_cs['enrollment'], \
    r_ct_cs['enrollment_type'], r_ct_cs['biospec_retention'], \
    r_ct_cs['biospec_descr'], r_ct_cs['study_pop'], \
    r_ct_cs['sampling_method'], r_ct_cs['criteria'], r_ct_cs['gender'], \
    r_ct_cs['minimum_age'], r_ct_cs['maximum_age'], \
    r_ct_cs['healthy_volunteers'], r_ct_cs['verification_date'], \
    r_ct_cs['lastchanged_date'], r_ct_cs['firstreceived_date'], \
    r_ct_cs['firstreceived_results_date'], r_ct_cs['responsible_party_type'], \
    r_ct_cs['responsible_investigator_affiliation'], \
    r_ct_cs['responsible_investigator_full_name'], \
    r_ct_cs['responsible_investigator_title'], r_ct_cs['is_fda_regulated'], \
    r_ct_cs['is_section_801'], r_ct_cs['has_expanded_access']))


# %% Parse and write children table:  ct_secondary_ids as ct_si.
r_ct_si = dict()
id_seq = 1
r_ct_si['nct_id'] = nct_id
for secondary_id_count in id_info.findall('secondary_id'):
    # id_seq += 1
    r_ct_si['id'] = id_seq
    r_ct_si['secondary_id'] = secondary_id_count.text.encode('utf-8') \
                              if secondary_id_count is not None else ''
    csvfile_write_list[1].writerow((r_ct_si['id'], r_ct_si['nct_id'], \
        r_ct_si['secondary_id']))


# %% Parse and write children table: ct_collaborators as ct_co.
if root.find('sponsors') is not None:
    r_ct_co = dict()
    id_seq = 1
    r_ct_co['nct_id'] = nct_id
    for collaborator_count in root.find('sponsors').findall('collaborator'):
        # id_seq += 1
        r_ct_co['id'] = id_seq
        agency = collaborator_count.find('agency')
        r_ct_co['agency'] = agency.text.encode('utf-8') if agency is not None \
                            else ''
        agency_class = collaborator_count.find('agency_class')
        r_ct_co['agency_class'] = agency_class.text.encode('utf-8') if \
                                  agency_class is not None else ''
        csvfile_write_list[2].writerow((r_ct_co['id'], r_ct_co['nct_id'], \
            r_ct_co['agency'], r_ct_co['agency_class']))


# %% Parse and write children table: ct_authorities as ct_au.
if root.find('oversight_info') is not None:
    r_ct_au = dict()
    id_seq = 1
    r_ct_au['nct_id'] = nct_id
    for authority_count in root.find('oversight_info').findall('authority'):
        # id_seq += 1
        r_ct_au['id'] = id_seq
        r_ct_au['authority'] = authority_count.text.encode('utf-8') if \
                               authority_count is not None else ''
        csvfile_write_list[3].writerow((r_ct_au['id'], r_ct_au['nct_id'], \
            r_ct_au['authority']))


# %% Parse and write children table: ct_outcomes as ct_oc.
r_ct_oc = dict()
id_seq = 1
r_ct_oc['nct_id'] = nct_id
outcome_header = ['primary_outcome', 'secondary_outcome', 'other_outcome']
for header_name in outcome_header:
    for outcome_count in root.findall(header_name):
        # id_seq += 1
        r_ct_oc['id'] = id_seq
        r_ct_oc['outcome_type'] = header_name
        measure = outcome_count.find('measure')
        r_ct_oc['measure'] = measure.text.encode('utf-8') if measure is not \
                             None else ''
        time_frame = outcome_count.find('time_frame')
        r_ct_oc['time_frame'] = time_frame.text.encode('utf-8') if time_frame \
                                is not None else ''
        safety_issue = outcome_count.find('safety_issue')
        r_ct_oc['safety_issue'] = safety_issue.text.encode('utf-8') if \
                                  safety_issue is not None else ''
        description = outcome_count.find('description')
        r_ct_oc['description'] = description.text.encode('utf-8') if \
                                 description is not None else ''
        csvfile_write_list[4].writerow((r_ct_oc['id'], r_ct_oc['nct_id'], \
            r_ct_oc['outcome_type'], r_ct_oc['measure'], \
            r_ct_oc['time_frame'], r_ct_oc['safety_issue'], \
            r_ct_oc['description']))


# %% Parse and write children table: ct_conditions as ct_cd.
r_ct_cd = dict()
id_seq = 1
r_ct_cd['nct_id'] = nct_id
for condition_count in root.findall('condition'):
    # id_seq += 1
    r_ct_cd['id'] = id_seq
    r_ct_cd['condition'] = condition_count.text.encode('utf-8') if \
                           condition_count is not None else ''
    csvfile_write_list[5].writerow((r_ct_cd['id'], r_ct_cd['nct_id'], \
        r_ct_cd['condition']))


# %% Parse and write children table: ct_arm_groups as ct_ag.
r_ct_ag = dict()
id_seq = 1
r_ct_ag['nct_id'] = nct_id
for arm_group_count in root.findall('arm_group'):
    # id_seq += 1
    r_ct_ag['id'] = id_seq
    arm_group_label = arm_group_count.find('arm_group_label')
    r_ct_ag['arm_group_label'] = arm_group_label.text.encode('utf-8') if \
                                 arm_group_label is not None else ''
    arm_group_type = arm_group_count.find('arm_group_type')
    r_ct_ag['arm_group_type'] = arm_group_type.text.encode('utf-8') if \
                                 arm_group_type is not None else ''
    description = arm_group_count.find('description')
    r_ct_ag['description'] = description.text.encode('utf-8') if description \
                             is not None else ''
    csvfile_write_list[6].writerow((r_ct_ag['id'], r_ct_ag['nct_id'], \
        r_ct_ag['arm_group_label'], r_ct_ag['arm_group_type'], \
        r_ct_ag['description']))


# %% Parse and write children table: ct_interventions as ct_iv.
r_ct_iv = dict()
id_seq = 1
r_ct_iv['nct_id'] = nct_id
for intervention_count in root.findall('intervention'):
    # id_seq += 1
    r_ct_iv['id'] = id_seq
    intervention_type = intervention_count.find('intervention_type')
    r_ct_iv['intervention_type'] = intervention_type.text.encode('utf-8') if \
                                   intervention_type is not None else ''
    intervention_name = intervention_count.find('intervention_name')
    r_ct_iv['intervention_name'] = intervention_name.text.encode('utf-8') if \
                                   intervention_name is not None else ''
    description = intervention_count.find('description')
    r_ct_iv['description'] = description.text.encode('utf-8') if description \
                             is not None else ''
    csvfile_write_list[7].writerow((r_ct_iv['id'], r_ct_iv['nct_id'], \
        r_ct_iv['intervention_type'], r_ct_iv['intervention_name'], \
        r_ct_iv['description']))


# %% Parse and write children table for ct_interventions:
# ct_intervention_arm_group_labels as ct_iv_ag.
r_ct_iv_ag = dict()
id_seq = 1
r_ct_iv_ag['nct_id'] = nct_id
for intervention_count in root.findall('intervention'):
    for arm_group_label_count in intervention_count.findall('arm_group_label'):
        # id_seq += 1
        r_ct_iv_ag['id'] = id_seq
        r_ct_iv_ag['intervention_name'] = \
            intervention_count.find('intervention_name').text.encode('utf-8')
        r_ct_iv_ag['arm_group_label'] = \
            arm_group_label_count.text.encode('utf-8') if \
            arm_group_label_count is not None else ''
        csvfile_write_list[8].writerow((r_ct_iv_ag['id'], \
            r_ct_iv_ag['nct_id'], r_ct_iv_ag['intervention_name'], \
            r_ct_iv_ag['arm_group_label']))


# %% Parse and write children table for ct_interventions:
# ct_intervention_other_names as ct_iv_on.
r_ct_iv_on = dict()
id_seq = 1
r_ct_iv_on['nct_id'] = nct_id
for intervention_count in root.findall('intervention'):
    for other_name_count in intervention_count.findall('other_name'):
        # id_seq += 1
        r_ct_iv_on['id'] = id_seq
        r_ct_iv_on['intervention_name'] = \
            intervention_count.find('intervention_name').text.encode('utf-8')
        r_ct_iv_on['other_name'] = \
            other_name_count.text.encode('utf-8') if other_name_count is not \
            None else ''
        csvfile_write_list[9].writerow((r_ct_iv_on['id'], \
            r_ct_iv_on['nct_id'], r_ct_iv_on['intervention_name'], \
            r_ct_iv_on['other_name']))


# %% Parse and write children table: ct_overall_officials as ct_of.
r_ct_of = dict()
id_seq = 1
r_ct_of['nct_id'] = nct_id
for official_count in root.findall('overall_official'):
    # id_seq += 1
    r_ct_of['id'] = id_seq
    first_name = official_count.find('first_name')
    r_ct_of['first_name'] = first_name.text.encode('utf-8') if first_name is \
                            not None else ''
    middle_name = official_count.find('middle_name')
    r_ct_of['middle_name'] = middle_name.text.encode('utf-8') if middle_name \
                             is not None else ''
    last_name = official_count.find('last_name')
    r_ct_of['last_name'] = last_name.text.encode('utf-8') if last_name is not \
                           None else ''
    degrees = official_count.find('degrees')
    r_ct_of['degrees'] = degrees.text.encode('utf-8') if degrees is not None \
                         else ''
    role = official_count.find('role')
    r_ct_of['role'] = role.text.encode('utf-8') if role is not None else ''
    affiliation = official_count.find('affiliation')
    r_ct_of['affiliation'] = affiliation.text.encode('utf-8') if affiliation \
                             is not None else ''
    csvfile_write_list[10].writerow((r_ct_of['id'], r_ct_of['nct_id'], \
        r_ct_of['first_name'], r_ct_of['middle_name'], r_ct_of['last_name'], \
        r_ct_of['degrees'], r_ct_of['role'], r_ct_of['affiliation']))


# %% Parse and write children table: ct_overall_contacts as ct_ct.
r_ct_ct = dict()
id_seq = 1
r_ct_ct['nct_id'] = nct_id
contact_header = ['overall_contact', 'overall_contact_backup']
for header_name in contact_header:
    for contact_count in root.findall(header_name):
        # id_seq += 1
        r_ct_ct['id'] = id_seq
        r_ct_ct['contact_type'] = header_name
        first_name = contact_count.find('first_name')
        r_ct_ct['first_name'] = first_name.text.encode('utf-8') if first_name \
                                is not None else ''
        middle_name = contact_count.find('middle_name')
        r_ct_ct['middle_name'] = middle_name.text.encode('utf-8') if \
                                 middle_name is not None else ''
        last_name = contact_count.find('last_name')
        r_ct_ct['last_name'] = last_name.text.encode('utf-8') if last_name is \
                               not None else ''
        degrees = contact_count.find('degrees')
        r_ct_ct['degrees'] = degrees.text.encode('utf-8') if degrees is not \
                             None else ''
        phone = contact_count.find('phone')
        r_ct_ct['phone'] = phone.text.encode('utf-8') if phone is not None \
                           else ''
        phone_ext = contact_count.find('phone_ext')
        r_ct_ct['phone_ext'] = phone_ext.text.encode('utf-8') if phone_ext is \
                               not None else ''
        email = contact_count.find('email')
        r_ct_ct['email'] = email.text.encode('utf-8') if email is not None \
                           else ''
        csvfile_write_list[11].writerow((r_ct_ct['id'], r_ct_ct['nct_id'], \
            r_ct_ct['contact_type'], r_ct_ct['first_name'], \
            r_ct_ct['middle_name'], r_ct_ct['last_name'], r_ct_ct['degrees'], \
            r_ct_ct['phone'], r_ct_ct['phone_ext'], r_ct_ct['email']))


# %% Parse and write children table: ct_locations as ct_lc.
r_ct_lc = dict()
id_seq = 1
r_ct_lc['nct_id'] = nct_id
for location_count in root.findall('location'):
    # id_seq += 1
    r_ct_lc['id'] = id_seq
    facility = location_count.find('facility')
    if facility is not None:
        facility_name = facility.find('name')
        r_ct_lc['facility_name'] = facility_name.text.encode('utf-8') if \
                                   facility_name is not None else ''
        address = facility.find('address')
        if address is not None:
            facility_city = address.find('city')
            r_ct_lc['facility_city'] = facility_city.text.encode('utf-8') if \
                                       facility_city is not None else ''
            facility_state = address.find('state')
            r_ct_lc['facility_state'] = facility_state.text.encode('utf-8') \
                                        if facility_state is not None else ''
            facility_zip = address.find('zip')
            r_ct_lc['facility_zip'] = facility_zip.text.encode('utf-8') if \
                                      facility_zip is not None else ''
            facility_country = address.find('country')
            r_ct_lc['facility_country'] = \
                facility_country.text.encode('utf-8') if facility_country is \
                not None else ''
        else: r_ct_lc['facility_city'] = r_ct_lc['facility_state'] = \
                  r_ct_lc['facility_zip'] = r_ct_lc['facility_country'] = ''
    else: r_ct_lc['facility_name'] = r_ct_lc['facility_city'] = \
              r_ct_lc['facility_state'] = r_ct_lc['facility_zip'] = \
              r_ct_lc['facility_country'] = ''
    status = location_count.find('status')
    r_ct_lc['status'] = status.text.encode('utf-8') if status is not None \
                        else ''
    contact = location_count.find('contact')
    if contact is not None:
        first_name = contact.find('first_name')
        r_ct_lc['contact_first_name'] = first_name.text.encode('utf-8') if \
                                        first_name is not None else ''
        middle_name = contact.find('middle_name')
        r_ct_lc['contact_middle_name'] = middle_name.text.encode('utf-8') if \
                                         middle_name is not None else ''
        last_name = contact.find('last_name')
        r_ct_lc['contact_last_name'] = last_name.text.encode('utf-8') if \
                                       last_name is not None else ''
        degrees = contact.find('degrees')
        r_ct_lc['contact_degrees'] = degrees.text.encode('utf-8') if degrees \
                                     is not None else ''
        phone = contact.find('phone')
        r_ct_lc['contact_phone'] = phone.text.encode('utf-8') if phone is not \
                                   None else ''
        phone_ext = contact.find('phone_ext')
        r_ct_lc['contact_phone_ext'] = phone_ext.text.encode('utf-8') if \
                                       phone_ext is not None else ''
        email = contact.find('email')
        r_ct_lc['contact_email'] = email.text.encode('utf-8') if email is not \
                                   None else ''
    else: r_ct_lc['contact_first_name'] = r_ct_lc['contact_middle_name'] = \
              r_ct_lc['contact_last_name'] = r_ct_lc['contact_degrees'] = \
              r_ct_lc['contact_phone'] = r_ct_lc['contact_phone_ext'] = \
              r_ct_lc['contact_email'] = ''
    contact_backup = location_count.find('contact_backup')
    if contact_backup is not None:
        first_name = contact_backup.find('first_name')
        r_ct_lc['contact_backup_first_name'] = \
            first_name.text.encode('utf-8') if first_name is not None else ''
        middle_name = contact_backup.find('middle_name')
        r_ct_lc['contact_backup_middle_name'] = \
            middle_name.text.encode('utf-8') if middle_name is not None else ''
        last_name = contact_backup.find('last_name')
        r_ct_lc['contact_backup_last_name'] = last_name.text.encode('utf-8') \
                                              if last_name is not None else ''
        degrees = contact_backup.find('degrees')
        r_ct_lc['contact_backup_degrees'] = degrees.text.encode('utf-8') if \
                                            degrees is not None else ''
        phone = contact_backup.find('phone')
        r_ct_lc['contact_backup_phone'] = phone.text.encode('utf-8') if phone \
                                          is not None else ''
        phone_ext = contact_backup.find('phone_ext')
        r_ct_lc['contact_backup_phone_ext'] = phone_ext.text.encode('utf-8') \
                                              if phone_ext is not None else ''
        email = contact_backup.find('email')
        r_ct_lc['contact_backup_email'] = email.text.encode('utf-8') if email \
                                          is not None else ''
    else: r_ct_lc['contact_backup_first_name'] = \
              r_ct_lc['contact_backup_middle_name'] = \
              r_ct_lc['contact_backup_last_name'] = \
              r_ct_lc['contact_backup_degrees'] = \
              r_ct_lc['contact_backup_phone'] = \
              r_ct_lc['contact_backup_phone_ext'] = \
              r_ct_lc['contact_backup_email'] = ''
    csvfile_write_list[12].writerow((r_ct_lc['id'], r_ct_lc['nct_id'], \
        r_ct_lc['facility_name'], r_ct_lc['facility_city'], \
        r_ct_lc['facility_state'], r_ct_lc['facility_zip'], \
        r_ct_lc['facility_country'], r_ct_lc['status'], \
        r_ct_lc['contact_first_name'], r_ct_lc['contact_middle_name'], \
        r_ct_lc['contact_last_name'], r_ct_lc['contact_degrees'], \
        r_ct_lc['contact_phone'], r_ct_lc['contact_phone_ext'], \
        r_ct_lc['contact_email'], r_ct_lc['contact_backup_first_name'], \
        r_ct_lc['contact_backup_middle_name'], \
        r_ct_lc['contact_backup_last_name'], \
        r_ct_lc['contact_backup_degrees'], r_ct_lc['contact_backup_phone'], \
        r_ct_lc['contact_backup_phone_ext'], r_ct_lc['contact_backup_email']))


# %% Parse and write children table for ct_locations:
# ct_location_investigators as ct_lc_in.
r_ct_lc_in = dict()
id_seq = 1
r_ct_lc_in['nct_id'] = nct_id
for location_count in root.findall('location'):
    for investigator in location_count.findall('investigator'):
        # id_seq += 1
        r_ct_lc_in['id'] = id_seq
        first_name = investigator.find('first_name')
        r_ct_lc_in['investigator_first_name'] = \
            first_name.text.encode('utf-8') if first_name is not None else ''
        middle_name = investigator.find('middle_name')
        r_ct_lc_in['investigator_middle_name'] = \
            middle_name.text.encode('utf-8') if middle_name is not None else ''
        last_name = investigator.find('last_name')
        r_ct_lc_in['investigator_last_name'] = last_name.text.encode('utf-8') \
                                               if last_name is not None else ''
        degrees = investigator.find('degrees')
        r_ct_lc_in['investigator_degrees'] = degrees.text.encode('utf-8') if \
                                             degrees is not None else ''
        role = investigator.find('role')
        r_ct_lc_in['investigator_role'] = role.text.encode('utf-8') if role \
                                          is not None else ''
        affiliation = investigator.find('affiliation')
        r_ct_lc_in['investigator_affiliation'] = \
            affiliation.text.encode('utf-8') if affiliation is not None else ''
        csvfile_write_list[13].writerow((r_ct_lc_in['id'], \
            r_ct_lc_in['nct_id'], r_ct_lc_in['investigator_first_name'], \
            r_ct_lc_in['investigator_middle_name'], \
            r_ct_lc_in['investigator_last_name'], \
            r_ct_lc_in['investigator_degrees'], \
            r_ct_lc_in['investigator_role'], \
            r_ct_lc_in['investigator_affiliation']))


# %% Parse and write children table: ct_location_countries as ct_cu.
location_countries = root.find('location_countries')
if location_countries is not None:
    r_ct_cu = dict()
    id_seq = 1
    r_ct_cu['nct_id'] = nct_id
    for country_count in location_countries.findall('country'):
        # id_seq += 1
        r_ct_cu['id'] = id_seq
        r_ct_cu['country'] = country_count.text.encode('utf-8') if \
                             country_count is not None else ''
        csvfile_write_list[14].writerow((r_ct_cu['id'], r_ct_cu['nct_id'], \
            r_ct_cu['country']))


# %% Parse and write children table: ct_links as ct_li.
r_ct_li = dict()
id_seq = 1
r_ct_li['nct_id'] = nct_id
for link_count in root.findall('link'):
    # id_seq += 1
    r_ct_li['id'] = id_seq
    url = link_count.find('url')
    r_ct_li['url'] = url.text.encode('utf-8') if url is not None else ''
    description = link_count.find('description')
    r_ct_li['description'] = description.text.encode('utf-8') if description \
                             is not None else ''
    csvfile_write_list[15].writerow((r_ct_li['id'], r_ct_li['nct_id'], \
        r_ct_li['url'], r_ct_li['description']))


# %% Parse and write children table: ct_condition_browses as ct_cb.
if root.find('condition_browse') is not None:
    r_ct_cb = dict()
    id_seq = 1
    r_ct_cb['nct_id'] = nct_id
    for mesh_term in root.find('condition_browse').findall('mesh_term'):
        # id_seq += 1
        r_ct_cb['id'] = id_seq
        r_ct_cb['mesh_term'] = mesh_term.text.encode('utf-8') if mesh_term is \
                               not None else ''
        csvfile_write_list[16].writerow((r_ct_cb['id'], r_ct_cb['nct_id'], \
            r_ct_cb['mesh_term']))


# %% Parse and write children table: ct_intervention_browses as ct_ib.
if root.find('intervention_browse') is not None:
    r_ct_ib = dict()
    id_seq = 1
    r_ct_ib['nct_id'] = nct_id
    for mesh_term in root.find('intervention_browse').findall('mesh_term'):
        # id_seq += 1
        r_ct_ib['id'] = id_seq
        r_ct_ib['mesh_term'] = mesh_term.text.encode('utf-8') if mesh_term is \
                               not None else ''
        csvfile_write_list[17].writerow((r_ct_ib['id'], r_ct_ib['nct_id'], \
            r_ct_ib['mesh_term']))


# %% Parse and write children table: ct_references as ct_rf.
r_ct_rf = dict()
id_seq = 1
r_ct_rf['nct_id'] = nct_id
for reference in root.findall('reference'):
    # id_seq += 1
    r_ct_rf['id'] = id_seq
    citation = reference.find('citation')
    r_ct_rf['citation'] = citation.text.encode('utf-8') if citation is not \
                          None else ''
    pmid = reference.find('PMID')
    r_ct_rf['PMID'] = pmid.text.encode('utf-8') if pmid is not None else ''
    csvfile_write_list[18].writerow((r_ct_rf['id'], r_ct_rf['nct_id'], \
        r_ct_rf['citation'], r_ct_rf['PMID']))


# %% Parse and write children table: ct_publications as ct_pb.
r_ct_pb = dict()
id_seq = 1
r_ct_pb['nct_id'] = nct_id
for reference in root.findall('results_reference'):
    # id_seq += 1
    r_ct_pb['id'] = id_seq
    citation = reference.find('citation')
    r_ct_pb['citation'] = citation.text.encode('utf-8') if citation is not \
                          None else ''
    pmid = reference.find('PMID')
    r_ct_pb['PMID'] = pmid.text.encode('utf-8') if pmid is not None else ''
    csvfile_write_list[19].writerow((r_ct_pb['id'], r_ct_pb['nct_id'], \
        r_ct_pb['citation'], r_ct_pb['PMID']))


# %% Parse and write children table: ct_keywords as ct_kw.
r_ct_kw = dict()
id_seq = 1
r_ct_kw['nct_id'] = nct_id
for keyword in root.findall('keyword'):
    # id_seq += 1
    r_ct_kw['id'] = id_seq
    r_ct_kw['keyword'] = keyword.text.encode('utf-8') if keyword is not None \
                         else ''
    csvfile_write_list[20].writerow((r_ct_kw['id'], r_ct_kw['nct_id'], \
        r_ct_kw['keyword']))


# %% Close all open files.
for i in csvfile_open_list:
    i.close()
file_load.close()
