#!/usr/bin/env bash

declare -ri FATAL_FAILURE_CODE=255
if [[ $1 == "-h" ]]; then
  cat << 'HEREDOC'
NAME

  neo4j_calculations.sh -- To calculate citation distance and time lag measurements in neo4j

SYNOPSIS
  neo4j_calculations.sh -h: display this help  


EXIT STATUS

    Exits with one of the following values:

    0    Success
    1    An error occurred
    255  fatal failure

HEREDOC
  exit $FATAL_FAILURE_CODE
fi

set -e
set -o pipefail
# Initially off: is turned on by `-v -v`
set +x

readonly SCRIPT_DIR=${0%/*}
readonly ABSOLUTE_SCRIPT_DIR=$(cd "${SCRIPT_DIR}" && pwd)
readonly INPUT_FILE=$1

readonly CITATION_DISTANCE_FILE=$(echo ${INPUT_FILE} | cut -d '.' -f 1)"_citation_distance.csv"
readonly TIME_LAG_FILE=$(echo ${INPUT_FILE} | cut -d '.' -f 1)"_time_lag.csv"

echo "Directory is" ${ABSOLUTE_SCRIPT_DIR}




# printf "load csv with headers from 'file://${ABSOLUTE_SCRIPT_DIR}/${INPUT_FILE}' AS csvFile
#   MATCH p=shortestPath((a:Publication{node_id: csvFile.cited_1})-[*..4]-(b:Publication {node_id: csvFile.cited_2}))
# RETURN a.node_id,b.node_id,length(p) order by length(p) limit 1;" | cypher-shell | grep -v node_id >> ${ABSOLUTE_SCRIPT_DIR}/${CITATION_DISTANCE_FILE}

printf "load csv with headers from 'file://${ABSOLUTE_SCRIPT_DIR}/${INPUT_FILE}' AS csvFile
  MATCH (a:Publication{node_id: csvFile.cited_1})<-[r:CITES]-(p:Publication)-[x:CITES]->(b:Publication {node_id: csvFile.cited_2})
RETURN a.node_id AS cited_1,a.pub_year AS cited_1_year,b.node_id AS cited_2,b.pub_year AS cited_2_year,
p.node_id AS first_cited,p.pub_year AS first_cited_year LIMIT 1" | cypher-shell | grep -v cited >> ${ABSOLUTE_SCRIPT_DIR}/${TIME_LAG_FILE}

#File clean up
sed '/^[[:space:]]*$/d' ${TIME_LAG_FILE}
sed -i 's/"//g' ${TIME_LAG_FILE}

printf "load csv with headers from 'file://${ABSOLUTE_SCRIPT_DIR}/${TIME_LAG_FILE}' AS csvFile
MATCH p=allShortestPaths((a:Publication{node_id: csvFile.cited_1})-[*..6]-(b:Publication {node_id: csvFile.cited_2}))
where all(x in nodes(p) where toInteger(x.pub_year) < csvFile.first_cited_year)
RETURN a.node_id AS cited_1,b.node_id AS cited_2,length(p) AS citation_distance
order by length(p)
limit 1" | cypher-shell | grep -v cited >> ${ABSOLUTE_SCRIPT_DIR}/${CITATION_DISTANCE_FILE}

#     printf "load csv with headers from 'file://${ABSOLUTE_SCRIPT_DIR}/${INPUT_FILE}' AS csvFile
#     match (n:Publication{node_id:csvFile.cited_1})-[:CITES]-(p:Publication{node_id:csvFile.cited_2})
# return n.pub_year,p.pub_year,abs(toInt(n.pub_year)-toInt(p.pub_year)) as time_lag limit 10;" | cypher-shell | grep -v node_id >> ${ABSOLUTE_SCRIPT_DIR}/${TIME_LAG_FILE}

#File clean up
sed '/^[[:space:]]*$/d' ${CITATION_DISTANCE_FILE}
sed -i 's/"//g' ${CITATION_DISTANCE_FILE}