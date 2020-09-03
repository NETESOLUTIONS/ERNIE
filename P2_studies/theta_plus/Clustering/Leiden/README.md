This directory contains the scripts needed to run the Ledien clustering algorithm.

#### Here is a brief description of the files in this folder:

[convert_to_cluster_output.py](convert_to_cluster_output.py) - Convert 0-indexed Leiden output to CSV with orginal SCPs

[convert_to_leiden_input.py](convert_to_leiden_input.py) - Convert CSV to Leiden input with 0-indexed SCPs

[get_leiden_clusters.sh](get_leiden_clusters.sh) - End-to-end Leiden clustering pipeline

[get_unique_pairs_citing_cited.sql](get_unique_pairs_citing_cited.sql) - Remove duplicate undirected edges from input data

[leiden_clusters.sh](leiden_clusters.sh) - Get clusters using Leiden algorithm
