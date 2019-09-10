\set ON_ERROR_STOP on
\set ECHO all

-- DataGrip: start execution from here
SET TIMEZONE = 'US/Eastern';

-- Create table holding scps then drop at the end
CREATE TEMP TABLE del_scps_stg(
  scp BIGINT NOT NULL
);

--edit the delete file with sed, then perform a client side copy into the table
\! sed "s/DELETE-2-s2.0-//g" delete.txt > edited_delete.txt
\copy del_scps_stg FROM 'edited_delete.txt'
\! rm edited_delete.txt
\echo 'Following are records that need to be deleted...'
select * from del_scps_stg limit 100;
\echo ***DELETING FROM TABLE: scopus_publications
DELETE FROM scopus_publications
WHERE scp IN (SELECT scp
          FROM public.del_scps_stg);
