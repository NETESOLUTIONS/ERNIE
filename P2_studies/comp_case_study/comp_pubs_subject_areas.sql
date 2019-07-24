\set ON_ERROR_STOP on
\set ECHO all

\set column_name 'year_':year

\set comp_table 'comp_':year

SET TIMEZONE = 'US/Eastern';

SET SEARCH_PATH = public;

ALTER TABLE comp_pubs_subject_areas
    ADD COLUMN :column_name integer;

UPDATE comp_pubs_subject_areas cpsa
SET :column_name=temp.area_count
FROM
(WITH pubs_year AS (
    SELECT DISTINCT source_id
    FROM :comp_table
),
     pubs_subjects AS (
         SELECT p.source_id, sc.class_code
         FROM pubs_year p
                  JOIN scopus_classes sc ON p.source_id = sc.scp
         WHERE sc.class_type = 'ASJC'
     )
         SELECT minor_subject_area, count(*) AS area_count
         FROM pubs_subjects ps
                  JOIN scopus_asjc_codes sac ON ps.class_code = sac.code::text
         GROUP BY minor_subject_area
         ORDER BY count(*) DESC) temp  WHERE temp.minor_subject_area=cpsa.minor_subject_area;

