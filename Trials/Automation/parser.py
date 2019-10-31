# coding=utf-8
#TODO: introduce pkey completeness checks on each row insert. populate pkey dictionary at top of file.
'''
This script contains the function parse(), a function uniquely designed for the Clinical Trials ETL for parsing CT XML data.
This script and those which use it should maintain accordance with the Clinical Trials XML schema here: https://clinicaltrials.gov/ct2/html/images/info/public.xsd

Author: VJ Davey
Create Date: 06/14/2018
Modified:
'''
from lxml import etree
import re


# Parse the input file and return a list of lists that contain the data to add to the database
def parse(input_filename):
    # Create empty lists to be populated inside a dictionary and also include pkey mappings
    ct_dict={
    'ct_clinical_studies':[],'ct_study_design_info':[],'ct_expanded_access_info':[],
    'ct_secondary_ids':[],'ct_collaborators':[],
    'ct_outcomes':[],'ct_conditions':[],'ct_arm_groups':[],'ct_interventions':[],
    'ct_intervention_arm_group_labels':[],'ct_intervention_other_names':[],'ct_overall_officials':[],
    'ct_overall_contacts':[],'ct_locations':[],'ct_location_investigators':[],'ct_location_countries':[],
    'ct_links':[],'ct_condition_browses':[],'ct_intervention_browses':[],
    'ct_references':[],'ct_publications':[],'ct_keywords':[]
    }
    ct_pkeys={str(key):[] for key in ct_dict.keys()}
    # Parse the XML file root and check if the unique ID exists. If not, do not load this file for now.
    root = etree.parse(input_filename).getroot()
    nct_id=next(iter(root.xpath("//*[local-name()='id_info']/*[local-name()='nct_id']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    if nct_id is "":
        return None
    # Parse XML data of interest to populate variables via xpaths
    row=dict(); row['nct_id']=nct_id
    row['rank']=root.get('rank')
    row['download_date']=next(iter(root.xpath("//*[local-name()='required_header']/*[local-name()='download_date']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['link_text']=next(iter(root.xpath("//*[local-name()='required_header']/*[local-name()='link_text']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['url']=next(iter(root.xpath("//*[local-name()='required_header']/*[local-name()='url']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['org_study_id']=next(iter(root.xpath("//*[local-name()='id_info']/*[local-name()='org_study_id']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['nct_alias']=next(iter(root.xpath("//*[local-name()='id_info']/*[local-name()='nct_alias']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['brief_title']=next(iter(root.xpath("//*[local-name()='brief_title']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['acronym']=next(iter(root.xpath("//*[local-name()='acronym']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['official_title']=next(iter(root.xpath("//*[local-name()='official_title']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['lead_sponsor_agency']=next(iter(root.xpath("//*[local-name()='sponsors']/*[local-name()='lead_sponsor']/*[local-name()='agency']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['lead_sponsor_agency_class']=next(iter(root.xpath("//*[local-name()='sponsors']/*[local-name()='lead_sponsor']/*[local-name()='agency_class']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['source']=next(iter(root.xpath("//*[local-name()='source']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['has_dmc']=next(iter(root.xpath("//*[local-name()='oversight_info']/*[local-name()='has_dmc']/text()")),'NULL').strip().replace("'","''").replace("\"","*") #TODO: doublecheck oversight_info blocks
    row['is_fda_regulated_drug']=next(iter(root.xpath("//*[local-name()='oversight_info']/*[local-name()='is_fda_regulated_drug']/text()")),'NULL').strip().replace("'","''").replace("\"","*") #TODO: doublecheck oversight_info blocks
    row['is_fda_regulated_device']=next(iter(root.xpath("//*[local-name()='oversight_info']/*[local-name()='is_fda_regulated_device']/text()")),'NULL').strip().replace("'","''").replace("\"","*") #TODO: doublecheck oversight_info blocks
    row['is_unapproved_device']=next(iter(root.xpath("//*[local-name()='oversight_info']/*[local-name()='is_unapproved_device']/text()")),'NULL').strip().replace("'","''").replace("\"","*") #TODO: doublecheck oversight_info blocks
    row['is_ppsd']=next(iter(root.xpath("//*[local-name()='oversight_info']/*[local-name()='is_ppsd']/text()")),'NULL').strip().replace("'","''").replace("\"","*") #TODO: doublecheck oversight_info blocks
    row['is_us_export']=next(iter(root.xpath("//*[local-name()='oversight_info']/*[local-name()='is_us_export']/text()")),'NULL').strip().replace("'","''").replace("\"","*") #TODO: doublecheck oversight_info blocks
    row['brief_summary']=next(iter(root.xpath("//*[local-name()='brief_summary']/*[local-name()='textblock']/text()")),'NULL').strip().replace("'","''").replace("\"","*") #TODO: check to see if there are files with multiple textblocks. If so, grab all blocks and join into a single variable. Also maybe introduce SOLR indexing.
    row['detailed_description']=next(iter(root.xpath("//*[local-name()='detailed_description']/*[local-name()='textblock']/text()")),'NULL').strip().replace("'","''").replace("\"","*") #TODO: check to see if there are files with multiple textblocks. If so, grab all blocks and join into a single variable. Also maybe introduce SOLR indexing.
    row['overall_status']=next(iter(root.xpath("//*[local-name()='overall_status']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['why_stopped']=next(iter(root.xpath("//*[local-name()='why_stopped']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['start_date']=next(iter(root.xpath("//*[local-name()='start_date']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['completion_date']=next(iter(root.xpath("//*[local-name()='completion_date']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['completion_date_type']=next(iter(root.xpath("//*[local-name()='completion_date']/@type")),'NULL').strip().replace("'","''").replace("\"","*")
    row['primary_completion_date']=next(iter(root.xpath("//*[local-name()='primary_completion_date']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['primary_completion_date_type']=next(iter(root.xpath("//*[local-name()='primary_completion_date']/@type")),'NULL').strip().replace("'","''").replace("\"","*")#TODO: introduce xpath query to pull type field text
    row['phase']=next(iter(root.xpath("//*[local-name()='phase']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['study_type']=next(iter(root.xpath("//*[local-name()='study_type']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['target_duration']=next(iter(root.xpath("//*[local-name()='target_duration']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['number_of_arms']=next(iter(root.xpath("//*[local-name()='number_of_arms']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['number_of_groups']=next(iter(root.xpath("//*[local-name()='number_of_groups']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['enrollment']=next(iter(root.xpath("//*[local-name()='enrollment']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['enrollment_type']=next(iter(root.xpath("//*[local-name()='enrollment']/@type")),'NULL').strip().replace("'","''").replace("\"","*")
    row['biospec_retention']=next(iter(root.xpath("//*[local-name()='biospec_retention']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['biospec_descr']=next(iter(root.xpath("//*[local-name()='biospec_descr']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['study_pop']=next(iter(root.xpath("//*[local-name()='eligibility']/*[local-name()='study_pop']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['sampling_method']=next(iter(root.xpath("//*[local-name()='eligibility']/*[local-name()='sampling_method']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['criteria']=next(iter(root.xpath("//*[local-name()='eligibility']/*[local-name()='criteria']/*[local-name()='textblock']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['gender']=next(iter(root.xpath("//*[local-name()='eligibility']/*[local-name()='gender']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['gender_based']=next(iter(root.xpath("//*[local-name()='eligibility']/*[local-name()='gender_based']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['gender_description']=next(iter(root.xpath("//*[local-name()='eligibility']/*[local-name()='gender_description']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['minimum_age']=next(iter(root.xpath("//*[local-name()='eligibility']/*[local-name()='minimum_age']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['maximum_age']=next(iter(root.xpath("//*[local-name()='eligibility']/*[local-name()='maximum_age']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['healthy_volunteers']=next(iter(root.xpath("//*[local-name()='eligibility']/*[local-name()='healthy_volunteers']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['verification_date']=next(iter(root.xpath("//*[local-name()='verification_date']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['responsible_party_type']=next(iter(root.xpath("//*[local-name()='responsible_party']/*[local-name()='responsible_party_type']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['responsible_investigator_affiliation']=next(iter(root.xpath("//*[local-name()='responsible_party']/*[local-name()='investigator_affiliation']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['responsible_investigator_full_name']=next(iter(root.xpath("//*[local-name()='responsible_party']/*[local-name()='investigator_full_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['responsible_investigator_title']=next(iter(root.xpath("//*[local-name()='responsible_party']/*[local-name()='investigator_title']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['has_expanded_access']=next(iter(root.xpath("//*[local-name()='has_expanded_access']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['disposition_first_submitted']=next(iter(root.xpath("//*[local-name()='disposition_first_submitted']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['results_first_submitted']=next(iter(root.xpath("//*[local-name()='results_first_submitted']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['study_first_submitted']=next(iter(root.xpath("//*[local-name()='study_first_submitted']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['last_update_submitted']=next(iter(root.xpath("//*[local-name()='last_update_submitted']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    ct_dict['ct_clinical_studies']+=[row]
    ct_pkeys['ct_clinical_studies']=['nct_id']

    ##### ct_study_design_info
    for study_design_info in root.xpath("//*[local-name()='study_design_info']"):
        row=dict(); row['nct_id']=nct_id
        row['allocation']=next(iter(etree.ElementTree(study_design_info).xpath("//*[local-name()='allocation']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['intervention_model']=next(iter(etree.ElementTree(study_design_info).xpath("//*[local-name()='intervention_model']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['intervention_model_description']=next(iter(etree.ElementTree(study_design_info).xpath("//*[local-name()='intervention_model_description']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['primary_purpose']=next(iter(etree.ElementTree(study_design_info).xpath("//*[local-name()='primary_purpose']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['observational_model']=next(iter(etree.ElementTree(study_design_info).xpath("//*[local-name()='study_design_info']/*[local-name()='observational_model']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['time_perspective']=next(iter(etree.ElementTree(study_design_info).xpath("//*[local-name()='study_design_info']/*[local-name()='time_perspective']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['masking']=next(iter(etree.ElementTree(study_design_info).xpath("//*[local-name()='study_design_info']/*[local-name()='masking']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['masking_description']=next(iter(etree.ElementTree(study_design_info).xpath("//*[local-name()='study_design_info']/*[local-name()='masking_description']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        ct_dict['ct_study_design_info']+=[row]
    ct_pkeys['ct_study_design_info']=['nct_id']
    ##### ct_expanded_access_info
    row=dict(); row['nct_id']=nct_id
    row['expanded_access_type_individual']=next(iter(root.xpath("//*[local-name()='expanded_access_info']/*[local-name()='expanded_access_type_individual']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['expanded_access_type_intermediate']=next(iter(root.xpath("//*[local-name()='expanded_access_info']/*[local-name()='expanded_access_type_intermediate']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    row['expanded_access_type_treatment']=next(iter(root.xpath("//*[local-name()='expanded_access_info']/*[local-name()='expanded_access_type_treatment']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
    ct_dict['ct_expanded_access_info']+=[row]
    ct_pkeys['ct_expanded_access_info']=['nct_id']
    ##### ct_secondary_ids
    secondary_ids=[secondary_id.strip().replace("'","''").replace("\"","*") for secondary_id in root.xpath("//*[local-name()='id_info']/*[local-name()='secondary_id']/text()")]
    for secondary_id in secondary_ids:
        row=dict(); row['nct_id']=nct_id; row['secondary_id']=secondary_id
        ct_dict['ct_secondary_ids']+=[row]
    ct_pkeys['ct_secondary_ids']=['nct_id','secondary_id']
    ##### ct_collaborators
    for collaborator_count in root.xpath("//*[local-name()='sponsors']/*[local-name()='collaborator']"):
        row=dict(); row['nct_id']=nct_id
        row['agency']=next(iter(etree.ElementTree(collaborator_count).xpath("//*[local-name()='agency']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['agency_class']=next(iter(etree.ElementTree(collaborator_count).xpath("//*[local-name()='agency_class']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        ct_dict['ct_collaborators']+=[row]
    ct_pkeys['ct_collaborators']=['nct_id', 'agency']
    ##### ct_outcomes newer kind
    for outcome in root.xpath("//*[local-name()='outcome_list']/*[local-name()='outcome']"):
        row=dict(); row['nct_id']=nct_id
        row['outcome_type']=next(iter(etree.ElementTree(outcome).xpath("//*[local-name()='type']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['measure']=next(iter(etree.ElementTree(outcome).xpath("//*[local-name()='title']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['time_frame']=next(iter(etree.ElementTree(outcome).xpath("//*[local-name()='time_frame']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['description']=next(iter(etree.ElementTree(outcome).xpath("//*[local-name()='description']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['population']=next(iter(etree.ElementTree(outcome).xpath("//*[local-name()='population']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        ct_dict['ct_outcomes']+=[row]
    ##### ct_outcomes older kind
    outcome_header = ['Primary', 'Secondary', 'Other']
    for outcome_type in outcome_header:
        row=dict(); row['nct_id']=nct_id ; row['outcome_type']=outcome_type
        row['measure']=next(iter(root.xpath("//*[local-name()='"+outcome_type.lower()+"_outcome']/*[local-name()='measure']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['time_frame']=next(iter(root.xpath("//*[local-name()='"+outcome_type.lower()+"']/*[local-name()='time_frame']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['description']=next(iter(root.xpath("//*[local-name()='"+outcome_type.lower()+"']/*[local-name()='description']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['population']='NULL'
        ct_dict['ct_outcomes']+=[row]
    ct_pkeys['ct_outcomes']=['nct_id', 'outcome_type', 'measure', 'time_frame']
    ##### ct_conditions
    conditions=[condition.strip().replace("'","''").replace("\"","*") for condition in root.xpath("//*[local-name()='condition']/text()")]
    for condition in conditions:
        row=dict(); row['nct_id']=nct_id; row['condition']=condition
        ct_dict['ct_conditions']+=[row]
    ct_pkeys['ct_conditions']=['nct_id', 'condition']
    ##### ct_arm_groups
    for arm_group in root.xpath("//*[local-name()='arm_group']"):
        row=dict(); row['nct_id']=nct_id
        row['arm_group_label']=next(iter(etree.ElementTree(arm_group).xpath("//*[local-name()='arm_group_label']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['arm_group_type']=next(iter(etree.ElementTree(arm_group).xpath("//*[local-name()='arm_group_type']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['description']=next(iter(etree.ElementTree(arm_group).xpath("//*[local-name()='description']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        ct_dict['ct_arm_groups']+=[row]
    ct_pkeys['ct_arm_groups']=['nct_id', 'arm_group_label', 'arm_group_type', 'description']
    ##### ct_interventions, ct_intervention_arm_group_labels, and ct_intervention_other_names
    for intervention_count in root.xpath("//*[local-name()='intervention']"):
        row=dict(); row['nct_id']=nct_id
        row['intervention_type']=next(iter(etree.ElementTree(intervention_count).xpath("//*[local-name()='intervention_type']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['intervention_name']=next(iter(etree.ElementTree(intervention_count).xpath("//*[local-name()='intervention_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['description']=next(iter(etree.ElementTree(intervention_count).xpath("//*[local-name()='description']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        ct_dict['ct_interventions']+=[row]
        ###
        arm_group_labels=[arm_group_label.strip().replace("'","''").replace("\"","*") for arm_group_label in etree.ElementTree(intervention_count).xpath("//*[local-name()='arm_group_label']/text()")]
        for arm_group_label in arm_group_labels:
            child_row=dict(); child_row['nct_id']=nct_id; child_row['intervention_name']=row['intervention_name']; child_row['arm_group_label']=arm_group_label
            ct_dict['ct_intervention_arm_group_labels']+=[child_row]
        ###
        other_names=[other_name.strip().replace("'","''").replace("\"","*") for other_name in etree.ElementTree(intervention_count).xpath("//*[local-name()='other_name']/text()")]
        for other_name in other_names:
            child_row=dict(); child_row['nct_id']=nct_id; child_row['intervention_name']=row['intervention_name']; child_row['other_name']=other_name
            ct_dict['ct_intervention_other_names']+=[child_row]
    ct_pkeys['ct_interventions']=['nct_id', 'intervention_type', 'intervention_name', 'description']
    ct_pkeys['ct_intervention_arm_group_labels']=['nct_id', 'intervention_name', 'arm_group_label']
    ct_pkeys['ct_intervention_other_names']=['nct_id', 'intervention_name', 'other_name']
    #### ct_overall_officials
    for official_count in root.xpath("//*[local-name()='overall_official']"):
        row=dict(); row['nct_id']=nct_id
        row['first_name']=next(iter(etree.ElementTree(official_count).xpath("//*[local-name()='first_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['middle_name']=next(iter(etree.ElementTree(official_count).xpath("//*[local-name()='middle_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['degrees'] = next(iter(etree.ElementTree(official_count).xpath("//*[local-name()='degrees']/text()")),'NULL').strip().replace("'", "''").replace("\"", "*")
        if(row['first_name']=='NULL'):
            temp_last_name=next(iter(etree.ElementTree(official_count).xpath("//*[local-name()='last_name']/text()")),'NULL')
            name_degree_split = temp_last_name.split(',')
            if (name_degree_split is None ):

                words = temp_last_name.split(' ')
                if len(words) == 1:
                    row['last_name'] = words[0].strip().replace("'","''").replace("\"","*")
                elif len(words) == 2:
                    row['first_name'] = words[0].strip().replace("'","''").replace("\"","*")
                    row['last_name'] = words[1].strip().replace("'","''").replace("\"","*")
                elif len(words) > 2:
                    row['first_name']=words[0].strip().replace("'","''").replace("\"","*")
                    row['middle_name']=words[1].strip().replace("'","''").replace("\"","*")
                    row['last_name']=" ".join(words[2:]).strip().replace("'","''").replace("\"","*")
            else:
                #print("no degree split found")
                row['degrees']=','.join(name_degree_split[1:]).strip().replace("'","''").replace(
                    "\"","*")
                words = name_degree_split[0].split()
                if len(words) == 1:
                    row['last_name'] = words[0].strip().replace("'","''").replace("\"","*")
                elif len(words) == 2:
                    row['first_name'] = words[0].strip().replace("'","''").replace("\"","*")
                    row['last_name'] = words[1].strip().replace("'","''").replace("\"","*")
                elif len(words) > 2:
                    row['first_name'] = words[0].strip().replace("'","''").replace("\"","*")
                    row['middle_name'] = words[1].strip().replace("'","''").replace("\"","*")
                    row['last_name'] = " ".join(words[2:]).strip().replace("'","''").replace("\"","*")
        else:
            row['last_name']=next(iter(etree.ElementTree(official_count).xpath("//*[local-name()='last_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")

        row['role']=next(iter(etree.ElementTree(official_count).xpath("//*[local-name()='role']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['affiliation']=next(iter(etree.ElementTree(official_count).xpath("//*[local-name()='affiliation']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        ct_dict['ct_overall_officials']+=[row]
    ct_pkeys['ct_overall_officials']=['nct_id', 'role', 'last_name']
    #### ct_overall_contacts
    contact_header = ['overall_contact', 'overall_contact_backup']
    for contact_type in contact_header:
        row=dict(); row['nct_id']=nct_id ; row['contact_type']=contact_type
        row['first_name']=next(iter(root.xpath("//*[local-name()='"+contact_type+"']/*[local-name()='first_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['middle_name']=next(iter(root.xpath("//*[local-name()='"+contact_type+"']/*[local-name()='middle_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['last_name']=next(iter(root.xpath("//*[local-name()='"+contact_type+"']/*[local-name()='last_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['degrees'] = next(iter(root.xpath("//*[local-name()='" + contact_type + "']/*[local-name()='degrees']/text()")),'NULL').strip().replace("'", "''").replace("\"", "*")
        if (row['first_name'] == 'NULL'):

            name_degree_split = row['last_name'].split(',')
            if (name_degree_split is None):

                words = row['last_name'].split(' ')
                if len(words) == 1:
                    row['last_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                elif len(words) == 2:
                    row['first_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                    row['last_name'] = words[1].strip().replace("'", "''").replace("\"", "*")
                elif len(words) > 2:
                    row['first_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                    row['middle_name'] = words[1].strip().replace("'", "''").replace("\"", "*")
                    row['last_name'] = " ".join(words[2:]).strip().replace("'", "''").replace("\"", "*")
            else:
                # print("no degree split found")
                row['degrees'] = ','.join(name_degree_split[1:]).strip().replace("'", "''").replace(
                    "\"", "*")
                words = name_degree_split[0].split()
                if len(words) == 1:
                    row['last_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                elif len(words) == 2:
                    row['first_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                    row['last_name'] = words[1].strip().replace("'", "''").replace("\"", "*")
                elif len(words) > 2:
                    row['first_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                    row['middle_name'] = words[1].strip().replace("'", "''").replace("\"", "*")
                    row['last_name'] = " ".join(words[2:]).strip().replace("'", "''").replace("\"", "*")

        row['phone']=next(iter(root.xpath("//*[local-name()='"+contact_type+"']/*[local-name()='phone']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['phone_ext']=next(iter(root.xpath("//*[local-name()='"+contact_type+"']/*[local-name()='phone_ext']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['email']=next(iter(root.xpath("//*[local-name()='"+contact_type+"']/*[local-name()='email']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        ct_dict['ct_overall_contacts']+=[row]
    ct_pkeys['ct_overall_contacts']=['nct_id', 'contact_type', 'last_name']
    #### ct_locations, ct_location_investigators
    for location_count in root.xpath("//*[local-name()='location']"):
        row=dict(); row['nct_id']=nct_id
        row['facility_name']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='facility']/*[local-name()='name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['facility_city']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='facility']/*[local-name()='address']/*[local-name()='city']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['facility_state']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='facility']/*[local-name()='address']/*[local-name()='state']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['facility_zip']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='facility']/*[local-name()='address']/*[local-name()='zip']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['facility_country']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='facility']/*[local-name()='address']/*[local-name()='country']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['status']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='status']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['contact_first_name']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact']/*[local-name()='first_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['contact_middle_name']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact']/*[local-name()='middle_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['contact_last_name']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact']/*[local-name()='last_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['contact_degrees']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact']/*[local-name()='degrees']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        if (row['contact_first_name'] == 'NULL'):

            name_degree_split = row['contact_last_name'].split(',')
            if (name_degree_split is None):

                words = row['contact_last_name'].split(' ')
                if len(words) == 1:
                    row['contact_last_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                elif len(words) == 2:
                    row['contact_first_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                    row['contact_last_name'] = words[1].strip().replace("'", "''").replace("\"", "*")
                elif len(words) > 2:
                    row['contact_first_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                    row['contact_middle_name'] = words[1].strip().replace("'", "''").replace("\"", "*")
                    row['contact_last_name'] = " ".join(words[2:]).strip().replace("'", "''").replace("\"", "*")
            else:
                # print("no degree split found")
                row['contact_degrees'] = ','.join(name_degree_split[1:]).strip().replace("'", "''").replace(
                    "\"", "*")
                words = name_degree_split[0].split()
                if len(words) == 1:
                    row['contact_last_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                elif len(words) == 2:
                    row['contact_first_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                    row['contact_last_name'] = words[1].strip().replace("'", "''").replace("\"", "*")
                elif len(words) > 2:
                    row['contact_first_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                    row['contact_middle_name'] = words[1].strip().replace("'", "''").replace("\"", "*")
                    row['contact_last_name'] = " ".join(words[2:]).strip().replace("'", "''").replace("\"", "*")

        row['contact_phone']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact']/*[local-name()='phone']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['contact_phone_ext']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact']/*[local-name()='phone_ext']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['contact_email']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact']/*[local-name()='email']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['contact_backup_first_name']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact_backup']/*[local-name()='first_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['contact_backup_middle_name']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact_backup']/*[local-name()='middle_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['contact_backup_last_name']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact_backup']/*[local-name()='last_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['contact_backup_degrees']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact_backup']/*[local-name()='degrees']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['contact_backup_phone']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact_backup']/*[local-name()='phone']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['contact_backup_phone_ext']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact_backup']/*[local-name()='phone_ext']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['contact_backup_email']=next(iter(etree.ElementTree(location_count).xpath("//*[local-name()='contact_backup']/*[local-name()='email']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        ct_dict['ct_locations']+=[row]
        ###
        for investigator_count in etree.ElementTree(location_count).xpath("//*[local-name()='investigator']"):
            child_row=dict(); child_row['nct_id']=nct_id
            child_row['investigator_first_name']=next(iter(etree.ElementTree(investigator_count).xpath("//*[local-name()='first_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
            child_row['investigator_middle_name']=next(iter(etree.ElementTree(investigator_count).xpath("//*[local-name()='middle_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
            child_row['investigator_last_name']=next(iter(etree.ElementTree(investigator_count).xpath("//*[local-name()='last_name']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
            child_row['investigator_degrees']=next(iter(etree.ElementTree(investigator_count).xpath("//*[local-name()='degrees']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
            if (child_row['investigator_first_name'] == 'NULL'):

                name_degree_split = child_row['investigator_last_name'].split(',')
                if (name_degree_split is None):

                    words = child_row['investigator_last_name'].split(' ')
                    if len(words) == 1:
                        child_row['investigator_last_name'] = words[0].strip().replace("'", "''").replace(
                            "\"", "*")
                    elif len(words) == 2:
                        child_row['investigator_first_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                        child_row['investigator_last_name'] = words[1].strip().replace("'", "''").replace("\"", "*")
                    elif len(words) > 2:
                        child_row['investigator_first_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                        row['investigator_middle_name'] = words[1].strip().replace("'", "''").replace("\"", "*")
                        row['investigator_last_name'] = " ".join(words[2:]).strip().replace("'", "''").replace("\"", "*")
                else:
                    # print("no degree split found")
                    child_row['investigator_degrees'] = ','.join(name_degree_split[1:]).strip().replace("'", "''").replace(
                        "\"", "*")
                    words = name_degree_split[0].split(' ')
                    if len(words) == 1:
                        child_row['investigator_last_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                    elif len(words) == 2:
                        child_row['investigator_first_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                        child_row['investigator_last_name'] = words[1].strip().replace("'", "''").replace("\"", "*")
                    elif len(words) > 2:
                        child_row['investigator_first_name'] = words[0].strip().replace("'", "''").replace("\"", "*")
                        child_row['investigator_middle_name'] = words[1].strip().replace("'", "''").replace("\"", "*")
                        child_row['investigator_last_name'] = " ".join(words[2:]).strip().replace("'", "''").replace("\"", "*")

            child_row['investigator_role']=next(iter(etree.ElementTree(investigator_count).xpath("//*[local-name()='role']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
            child_row['investigator_affiliation']=next(iter(etree.ElementTree(investigator_count).xpath("//*[local-name()='affiliation']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
            ct_dict['ct_location_investigators']+=[child_row]
    ct_pkeys['ct_locations']=['nct_id', 'facility_country', 'facility_city', 'facility_zip', 'facility_name']
    ct_pkeys['ct_location_investigators']=['nct_id', 'investigator_last_name']

    ## ct_location_countries
    for country in root.xpath("//*[local-name()='location_countries']/*[local-name()='country']/text()"):
        child_row = dict(); child_row['nct_id'] = nct_id
        child_row['country']=country
        ct_dict['ct_location_countries'] += [child_row]
    ct_pkeys['ct_location_countries']=['nct_id', 'country']

    #### ct_links
    for link_count in root.xpath("//*[local-name()='link']"):
        row=dict(); row['nct_id']=nct_id
        row['url']=next(iter(etree.ElementTree(link_count).xpath("//*[local-name()='url']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['description']=next(iter(etree.ElementTree(link_count).xpath("//*[local-name()='description']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        ct_dict['ct_links']+=[row]
    ct_pkeys['ct_links']=['nct_id', 'url', 'description']
    #### ct_condition_browses
    mesh_terms=[mesh_term.strip().replace("'","''").replace("\"","*") for mesh_term in root.xpath("//*[local-name()='condition_browse']/*[local-name()='mesh_term']/text()")]
    for mesh_term in mesh_terms:
        row=dict(); row['nct_id']=nct_id; row['mesh_term']=mesh_term
        ct_dict['ct_condition_browses']+=[row]
    ct_pkeys['ct_condition_browses']=['nct_id', 'mesh_term']
    #### ct_intervention_browses
    mesh_terms=[mesh_term.strip().replace("'","''").replace("\"","*") for mesh_term in root.xpath("//*[local-name()='intervention_browse']/*[local-name()='mesh_term']/text()")]
    for mesh_term in mesh_terms:
        row=dict(); row['nct_id']=nct_id; row['mesh_term']=mesh_term
        ct_dict['ct_intervention_browses']+=[row]
    ct_pkeys['ct_intervention_browses']=['nct_id', 'mesh_term']
    #### ct_references
    for reference in root.xpath("//*[local-name()='reference']"):
        row=dict(); row['nct_id']=nct_id
        row['citation']=next(iter(etree.ElementTree(reference).xpath("//*[local-name()='citation']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['pmid']=next(iter(etree.ElementTree(reference).xpath("//*[local-name()='PMID']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        ct_dict['ct_references']+=[row]
    ct_pkeys['ct_references']=['nct_id', 'citation']
    #### ct_publications
    for reference in root.xpath("//*[local-name()='results_reference']"):
        row=dict(); row['nct_id']=nct_id
        row['citation']=next(iter(etree.ElementTree(reference).xpath("//*[local-name()='citation']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        row['pmid']=next(iter(etree.ElementTree(reference).xpath("//*[local-name()='PMID']/text()")),'NULL').strip().replace("'","''").replace("\"","*")
        ct_dict['ct_publications']+=[row]
    ct_pkeys['ct_publications']=['nct_id', 'citation']
    #### ct_keywords
    keywords=[keyword.strip().replace("'","''").replace("\"","*") for keyword in root.xpath("//*[local-name()='keyword']/text()")]
    for keyword in keywords:
        row=dict(); row['nct_id']=nct_id; row['keyword']=keyword
        ct_dict['ct_keywords']+=[row]
    ct_pkeys['ct_keywords']=['nct_id', 'keyword']
    ##### clean data dictionary locally in ct_dict to avoid upload issues
    #first clean out all tables with no information populated
    ct_dict={ key:value for key, value in ct_dict.items() if value!=[] }
    #second perform local cleaning on those tables with information populated
    for key in ct_dict.keys():
        ### first, remove all rows where the pk not null constraint is not satisfied
        ct_dict[key]=[row for row in ct_dict[key] if all(row[column]!='NULL' for column in ct_pkeys[key])]
        ### second, remove all duplicate rows
        seen=set()
        ct_dict[key]=[row for row in ct_dict[key] if [tuple(row[column] for column in ct_pkeys[key]) not in seen, seen.add(tuple(row[column] for column in ct_pkeys[key]))][0]]
        ### lastly, add index values
        for idx,row in enumerate(ct_dict[key]):
            ct_dict[key][idx]['id']=str(idx+1)
    ### Miscellaneous last minute changes for dictionary values before passing values on to update script
    ct_pkeys['ct_references']=['nct_id', 'md5(citation)']
    ##### Return a tuple of dictionaries. The ct_dict which holds the data, and a ct_pkeys dict which holds the pkey information
    return (ct_dict,ct_pkeys)
