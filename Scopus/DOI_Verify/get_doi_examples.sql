
-- Script to get example articles from Scopus and save the result as a CSV file

\COPY (

SELECT doi.* 

FROM 
	(SELECT spi1.scp as pub_scp, spi1.document_id as pub_id, spi2.scp as doi_scp, spi2.document_id as doi_id, spg.pub_year 
	
	FROM 
		(SELECT * FROM scopus_publication_identifiers where document_id_type='MEDL') spi1 

		JOIN scopus_publication_groups spg on spg.sgr = spi1.scp 

		LEFT JOIN 
			(SELECT * from scopus_publication_identifiers where document_id_type='DOI') spi2 on spi1.scp = spi2.scp 

		WHERE spg.pub_year>2000
		
		LIMIT 3000) doi 

WHERE doi.doi_id IS NULL

) TO '/home/shreya/tmp_doi/doi_examples_new.csv' csv header;



