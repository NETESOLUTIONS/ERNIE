truncate table new_wos_abstracts;
truncate table new_wos_addresses;
truncate table new_wos_authors;
truncate table new_wos_document_identifiers;
truncate table new_wos_grants;
truncate table new_wos_keywords;
truncate table new_wos_publications;
truncate table new_wos_references;
truncate table new_wos_titles;
delete from wos_abstracts where source_filename like '%RAW%';
delete from wos_addresses where source_filename like '%RAW%';
delete from wos_authors where source_filename like '%RAW%';
delete from wos_document_identifiers where source_filename like '%RAW%';
delete from wos_grants where source_filename like '%RAW%';
delete from wos_keywords where source_filename like '%RAW%';
delete from wos_publications where source_filename like '%RAW%';
delete from wos_references where source_filename like '%RAW%';
delete from wos_titles where source_filename like '%RAW%';
  

