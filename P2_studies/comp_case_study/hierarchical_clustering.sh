#!/usr/bin/bash

#Original input file
input_file=$1

#Initial clustering results file
clustering_results=$2

#Splitting name
temp_name=$(echo $clustering_results | cut -d '.' -f 1)

#edge file name
edge_file=$3

#Number of iterations
iterations=$4

for number in $(seq 1 $iterations);
do
    echo "Iteration number" $number

    python hierarchical_clustering_merge.py -f $input_file -c $clustering_results -o $edge_file

    python hierarchical_clustering_agglomeration.py -f $edge_file -c $clustering_results -o $clustering_results

done