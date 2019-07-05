CREATE TYPE SCOPUS_CITATION_TYPE AS --
  ENUM ('ab','ar','bk','br','ch','cp', 'cr','di','ed','er','ip','le','no','pa','pr','re','rp','sh','wp');

COMMENT ON TYPE SCOPUS_CITATION_TYPE IS -- 
'"ab" = Abstract Report
"ar" = Article
"bk" = Book
"br" = Book Review
"bz" = Business Article
"ch" = Chapter
"cp" = Conference Paper
"cr" = Conference Review
"di" = Dissertation
"ed" = Editorial
"er" = Erratum
"ip" = Article In Press
"le" = Letter
"no" = Note
"pa" = Patent
"pr" = Press Release
"re" = Review
"rp" = Report
"sh" = Short Survey
"wp" = Working Paper';
