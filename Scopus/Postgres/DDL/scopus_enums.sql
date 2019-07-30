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

CREATE TYPE SCOPUS_SUBJECT_ABBRE_TYPE AS ENUM ('AGRI', 'ARTS', 'BIOC', 'BUSI', 'CENG', 'CHEM', 'COMP', 'DECI', 'DENT',--
  'EART', 'ECON', 'ENER', 'ENGI', 'ENVI', 'HEAL', 'IMMU', 'MATE', 'MATH', 'MEDI', 'NEUR', 'NURS', 'PHAR', 'PHYS',--
  'PSYC','SOCI', 'VETE','MULT');

COMMENT ON TYPE SCOPUS_SUBJECT_ABBRE_TYPE IS --
  '"AGRI" = Agricultural and Biological Sciences
  "ARTS" = Arts and Humanities
  "BIOC" = Biochemistry, Genetics and Molecular Biology
  "BUSI" = Business, Management and Accounting
  "CENG" = Chemical Engineering
  "CHEM" = Chemistry
  "COMP" = Computer Science
  "DECI" = Decision Sciences
  "DENT" = Dentistry
  "EART" = Earth and Planetary Sciences
  "ECON" = Economics, Econometrics and Finance
  "ENER" = Energy
  "ENGI" = Engineering
  "ENVI" = Environmental Science
  "HEAL" = Health Professions
  "IMMU" = Immunology and Microbiology
  "MATE" = Materials Science
  "MATH" = Mathematics
  "MEDI" = Medicine
  "NEUR" = Neuroscience
  "NURS" = Nursing
  "PHAR" = Pharmacology, Toxicology and Pharmaceutics
  "PHYS" = Physics and Astronomy
  "PSYC" = Psychology
  "SOCI" = Social Sciences
  "VETE" = Veterinary
  "MULT" = Multidisciplinary';