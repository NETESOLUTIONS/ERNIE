## Welcome to the Theta+ Repository!

For details on the Markov Clustering Algorithm, please refer to [this wiki](https://github.com/NETESOLUTIONS/ERNIE/wiki/Markov-Clustering).

For details on the analysis of MCL clustersm please refer to [this wiki](https://github.com/NETESOLUTIONS/ERNIE/wiki/Markov-Clustering-Analysis).

####Here is a brief description of the files in this folder:

[ad_hoc.py](ad_hoc.py) - Not part of the pipeline, but may come in handy

[add_author_count.sql](add_author_count.sql) - Compute authorship and co-authorship counts

[all_years_intersect_union.sql](all_years_intersect_union.sql) - Get superset of all MCL year slices

[bib_coupling.sql](bib_coupling.sql) - Identify instances of bibliographic coupling between two members of a co-cited pair

[compute_article_score.py](compute_article_score.py) - Compute article score within cluster

[compute_conductance.py](compute_conductance.py) - Compute conductance within cluster

[gc_misc_sql](gc_misc_sql) - Generate SCPs with concat title and abstract

[generic_mcl_pipeline.sh](generic_mcl_pipeline.sh) - End-to-end MCL cluster-generation pipeline

[get_graclus_cluster_scp_list.py](get_graclus_cluster_scp_list.py) - Get cluster-SCP list for Graclus clusters

[graclus_add_author_counts.sql](graclus_add_author_counts.sql) - Compute authorship and co-authorship counts for Graclus clusters

[immXX.sql](imm85.sql) - DDL for MCL year slice (1985-1995)

[immXX_enriched.sql](imm90_enriched.sql) - DDL for MCL year slice (including citing references) (1990)

[jsd_coherence.py](jsd_coherence.py) - Compute coherence from Cluster JSD and Random JSD

[jsd_compute.py](jsd_compute.py) - Compute Cluster Jensen-Shannon Divergence (JSD)

[jsd_modules.py](jsd_modules.py) - Defines all functions used in most of the Python pipeline

[jsd_random.py](jsd_random.py) - Compute Random JSD

[lstodf.R](lstodf.R) - Early version of pre_process.R

[match_mcl_to_graclus.py](match_mcl_to_graclus.py) - Match MCL year slices to Graclus clusters

[match_superset_years.py](match_superset_years.py) - Match MCL superset clusters to year slices

[mcl_script.sh](mcl_script.sh) - Generate MCL output

[merge_all_output.py](merge_all_output.py) - Merge final output of conductance, article scores, and coherence

[nih_stopwords.txt](nih_stopwords.txt) - Stop-word list provided by the NIH

[post_process.R](post_process.R) - Convert MCL output to CSV

[pre_process.R](pre_process.R) - Convert input edge-list into MCL-readable file in R

[scratch_2.sql](scratch_2.sql) - Scratch file

[shuffled_sample_conductance.py](shuffled_sample_conductance.py) - Compute conductance for clusters with randomly generated edges

[stop_words.txt](stop_words.txt) - Complete list of stop-words used for text-preprocessing

[text_preprocess.py](text_preprocess.py) - Pre-process all text data

[theta_plus.sql](theta_plus.sql) - DDL of test MCL data


