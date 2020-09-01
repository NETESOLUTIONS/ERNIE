#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME

   

SYNOPSIS

  

DESCRIPTION

   

HEREDOC
  exit 1
fi

set -e
set -o pipefail

while (( $# > 0 )); do
  case "$1" in
    -s)
      shift
      readonly schema="$1"
      ;;
    -t)
      shift
      readonly year_table="$1"
      ;;
    -w)
      shift
      readonly working_dir=$1
      ;;
    -r)
      shift
      readonly resolution_param="$1"
      ;;
    -l)
      shift
      readonly seed="$1"
      ;;    
    *)
      break
  esac
  shift
done


# Call script that creates table with unique undirected edges

citing_cited_table=${year_table}'_citing_cited'

psql -f get_unique_pairs_citing_cited.sql -v schema=${schema} -v citing_cited_table=${citing_cited_table}

# Copy table to working directory as CSV
citing_cited_unique_pairs_table=${citing_cited_table}'_unique_pairs'
# Get nodes data for re-indexing
year_nodes_table=${year_table}'_nodes'

psql << HEREDOC
\copy ${schema}.${citing_cited_unique_pairs_table} TO '${citing_cited_unique_pairs_table}.csv' CSV HEADER
HEREDOC

psql << HEREDOC
\copy ${schema}.${year_nodes_table} TO '${year_nodes_table}.csv' CSV HEADER
HEREDOC


# Convert SCPs to 0-indexed values 

python convert_to_leiden_input.py ${year_table} ${citing_cited_unique_pairs_table} ${year_nodes_table}

leiden_input=${year_table}'_leiden_input.txt'
leiden_output=${year_table}'_leiden_clusters.txt'

# Get Leiden clusters

java -jar /usr/local/bin/RunNetworkClustering.jar -r ${resolution_param} --seed ${seed} -o ${leiden_output} ${leiden_input}