/*



*/


\timing


CREATE OR REPLACE FUNCTION test_that_there_is_no_100_percent_NULL_column_in_scopus_tables()
RETURNS SETOF TEXT
AS $$
DECLARE tab record;
BEGIN
  FOR tab IN
  (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name in ('scopus_abstracts','scopus_authors','scopus_grants', 'scopus_grant_acknowledgments','scopus_keywords','scopus_publications','scopus_publication_groups','scopus_references','scopus_sources','scopus_subjects','scopus_titles')
 )
  LOOP
    EXECUTE format('ANALYZE verbose %I;',tab.table_name);
  END LOOP;
  RETURN NEXT is_empty( 'select distinct tablename, attname from pg_stats
   where schemaname = ''public'' and tablename in ('scopus_abstracts','scopus_authors','scopus_grants', 'scopus_grant_acknowledgments',
     'scopus_keywords','scopus_publications','scopus_publication_groups','scopus_references','scopus_sources','scopus_subjects','scopus_titles') and null_frac = 1', 'No 100% null column');
END;
$$ LANGUAGE plpgsql;

select schemaname, relname, n_live_tup
from pg_stat_all_tables
where schemaname='public'
and relname in ('scopus_abstracts','scopus_authors','scopus_grants',
                                          'scopus_grant_acknowledgments','scopus_keywords','scopus_publications',
                                          'scopus_publication_groups','scopus_references','scopus_sources','scopus_subjects','scopus_titles')
ORDER BY n_live_tup DESC;


BEGIN;
SELECT plan(11);
select test_that_there_is_no_100_percent_NULL_column_in_scopus_tables();
select pass('my test passed! Let us compare the speed.')
select * from finish();
ROLLBACK;
