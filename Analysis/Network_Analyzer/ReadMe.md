


  #### Author: Samet Keserci  
  #### Date: November 2017   
  #### Usage:  

            sh MASTER_DRIVER.sh < drug_name > < input_directory > < output_directory >  

  #### Parameters:  
   `< drug_name > ::` It should be given as it appears in file name. Currently allowed drug or device names are affymetrix, ipilimumab, ivacaftor, buprenorphine, discoverx, lifeskills, naltrexone. If you want to add a new drug name - say new_drug_name, then you need to add  `dd_set.add("new_drug_name");` after `HashSet<String> dd_set = new HashSet<String>()`  in the main method of MainDriver.java file.


   `< input_directory > ::` The directory where the input files are located. Input_directory  must contain following file names and extensions with tab delimiter. For example, for a given  drug_name="ivacaftor", input file names must be as follows.   

     ivacaftor_citation_network.txt  
     ivacaftor_citation_network_years.txt  
     ivacaftor_citation_network_authors.txt  
     ivacaftor_citation_network_grants.txt  
     ivacaftor_generational_references.txt    


   `< output_directory > ::` The directory that output files will be located.
   Outputs files will be as follows:

     author_scores_pmid.csv   
     author_scores_wos.csv  
     publication_scores_pmid.csv  
     publication_scores_wos.csv  
     drugname_edge_node_list_pmid.csv  
     drugname_edge_node_list_wos.pmid   
     final_stat_collector.txt  
