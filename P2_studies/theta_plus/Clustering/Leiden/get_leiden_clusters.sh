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
    -q)
      shift
      readonly quality_func=$1
      ;;  
    -r1)
      shift
      readonly start_res="$1"
      ;;
    -r2)
      shift
      readonly stop_res="$1"
      ;;
    -r3)
      shift
      readonly step_res="$1"
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

echo "Getting unique undirected edges of ${citing_cited_table} ..."

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

echo "Converting nodes to 0-indexed values..."

python convert_to_leiden_input.py ${year_table} ${citing_cited_unique_pairs_table} ${year_nodes_table}

leiden_input=${year_table}'_leiden_input.txt'

echo "Leiden input file ready."

# Get Leiden clusters

for i in $(seq $start_res $step_res $stop_res)
do 
    echo "Resolution Parameter is $i"
    
    first_val="$(cut -d'.' -f1 <<<"$i")"
    second_val="$(cut -d'.' -f2 <<<"$i")"
    res_suffix="R$first_val$second_val"
    
    leiden_output=${year_table}'_cluster_scp_list_leiden_'${quality_func}'_'${res_suffix}'.txt'

    java -jar /usr/local/bin/RunNetworkClustering.jar -q ${quality_func} -r ${i} --seed ${seed} -o ${leiden_output} ${leiden_input}
    
    python convert_to_cluster_output.py ${leiden_output}
    
    echo "Done with Resolution $i"

done

echo "All Leiden clusters generated."
echo "All complete."