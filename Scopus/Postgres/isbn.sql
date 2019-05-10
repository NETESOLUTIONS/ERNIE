SELECT DISTINCT isbn_length
FROM scopus_isbns;

SELECT *
FROM scopus_isbns
WHERE isbn_length IS NULL;