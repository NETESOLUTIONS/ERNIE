##Script to back up the existing WoS tables @ Dev3
#Author: VJ Davey

#TODO: add code for creation of b_wos tables, add code to log time

echo 'BACKING UP WOS TABLES'
{
psql -d pardi -c "copy wos_grants to stdout;" | psql -d pardi -c "copy b_wos_grants from stdin;"
echo 'COMPLETED BACKUP OF wos_publications'
psql -d pardi -c "copy wos_publications to stdout;" | psql -d pardi -c "copy b_wos_publications from stdin;"
echo 'COMPLETED BACKUP OF wos_publications'
psql -d pardi -c "copy wos_titles to stdout;" | psql -d pardi -c "copy b_wos_titles from stdin;"
echo 'COMPLETED BACKUP OF wos_titles'
psql -d pardi -c "copy wos_abstracts to stdout;" | psql -d pardi -c "copy b_wos_abstracts from stdin;"
echo 'COMPLETED BACKUP OF wos_abstracts'
psql -d pardi -c "copy wos_keywords to stdout;" | psql -d pardi -c "copy b_wos_keywords from stdin;"
echo 'COMPLETED BACKUP OF wos_keywords'
psql -d pardi -c "copy wos_addresses to stdout;" | psql -d pardi -c "copy b_wos_addresses from stdin;"
echo 'COMPLETED BACKUP OF wos_addresses'
psql -d pardi -c "copy wos_authors to stdout;" | psql -d pardi -c "copy b_wos_authors from stdin;"
echo 'COMPLETED BACKUP OF wos_authors'
psql -d pardi -c "copy wos_document_identifiers to stdout;" | psql -d pardi -c "copy b_wos_document_identifiers from stdin;"
echo 'COMPLETED BACKUP OF wos_document_identifiers'
} &
{
psql -d pardi -c "copy wos_references to stdout;" | psql -d pardi -c "copy b_wos_references from stdin;"
echo 'COMPLETED BACKUP OF wos_references'
} &
wait
