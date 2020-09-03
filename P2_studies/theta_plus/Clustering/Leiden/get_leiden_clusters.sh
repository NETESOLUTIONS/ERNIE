#!/usr/bin/env bash
if [[ $1 == "-h" ]]; then
  cat <<'HEREDOC'
NAME

    get_leiden_clusters.sh - Takes input data name and Leiden parameters to output 
                            a CSV file of Leiden clusters along with SCPs

SYNOPSIS

    get_leiden_clusters.sh [ -s schema ] [ -t year_table ] [ -w working_dir ] [ -q quality_func ] 
                         [ -r1 start_res ] [ -r2 stop_res ] [ -r step_res ] [ -l seed ]
                         
    get_leiden_clusters.sh -h : display this help

DESCRIPTION

    For the data name (year_table e.g., imm1985) supplied, get unique undirected edges and copy
    the table along with its corresponding nodes table to working directory. Convert the nodes
    to 0-indexed integers and save edge output (Leiden input) as a tab-separated file. Run the
    Leiden algorithm with required parameters using this output and save leiden output. Convert
    the Leiden output into SCP form and save corresponding cluster-SCP CSV. The standard output 
    also displays cluster size distribution information.
    
    The Leiden resolution parameter is set to 1.0 by default and can be changed to any float value
    by using the -r1 option. This script also allows the user to input a desired range of values
    for the resolution parameter, if needed, by using -r1 (lower bound, inclusive) -r2 (upper bound, 
    inclusive), and -r3 (step value). The quality function is set to CPM by default.
    
    The following options are available:
    
    -s   schema           schema where the edge and node tables are stored
    -t   year_table       name of the data type (e.g. 'imm') and year
    -w   working_dir      directory where all output is stored
    -q   quality_func     quality function to be used by the Leiden algorithm.
                          Default is CPM.
    -r1  start_res        Resolution parameter to be used for the Leiden algorithm.
                          Enter a float - e.g. 1.0
                          If testing a range of parameters, lower-bound of resolution.
    -r2  stop_res         Upper-bound of range of resolution parameters
                          Enter a float - e.g. 1.0
    -r3  step_res         Step value for range of resolution parameters
    -l   seed             Seed value for the Leiden algorithm
                          Set to 2020 by default
    

HEREDOC
  exit 1
fi

set -e
set -o pipefail

declare start_res="1.0"
declare stop_res=$start_res
declare step_res="1.0"
declare quality_func="CPM"
script_dir="/erniedev_data3/theta_plus/Leiden"
declare -i seed=2020

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

cd ${working_dir}

# Call script that creates table with unique undirected edges

citing_cited_table=${year_table}'_citing_cited'

echo "Getting unique undirected edges of ${citing_cited_table} ..."

psql -f ${script_dir}/get_unique_pairs_citing_cited.sql -v schema=${schema} -v citing_cited_table=${citing_cited_table}

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

python ${script_dir}/convert_to_leiden_input.py ${year_table} ${citing_cited_unique_pairs_table} ${year_nodes_table}

leiden_input=${year_table}'_leiden_input.txt'
nodes_coded=${year_nodes_table}'_coded.csv'

echo "Leiden input file ready."

# Get Leiden clusters

for i in $(seq $start_res $step_res $stop_res)
do 
    echo "Resolution Parameter is $i"
    
    first_val="$(cut -d'.' -f1 <<<"$i")"
    second_val="$(cut -d'.' -f2 <<<"$i")"
    res_suffix="R$first_val$second_val"
    
    leiden_output=${year_table}'_cluster_scp_list_leiden_'${quality_func}'_'${res_suffix}'.txt'

    java -jar /usr/local/bin/RunNetworkClustering.jar -q ${quality_func} -a "Leiden" -r ${i} --seed ${seed} -o ${leiden_output} ${leiden_input}
    
    python ${script_dir}/convert_to_cluster_output.py ${leiden_output} ${nodes_coded}
    
    echo "Done with Resolution $i"
    echo ""

done

echo "All Leiden clusters generated."
echo "All complete."