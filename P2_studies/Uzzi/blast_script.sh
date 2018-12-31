#!/bin/bash

if [ -d "/erniedev_data10/P2_studies/background_file/working_directory/blast/blast_$2" ]; then
	mkdir /erniedev_data10/P2_studies/background_file/working_directory/blast/blast_$2
	mkdir /erniedev_data10/P2_studies/background_file/working_directory/blast/blast_$2/analysis
	mkdir /erniedev_data10/P2_studies/background_file/working_directory/blast/blast_$2/comparison
fi

python observed_frequency.py $1 /erniedev_data10/P2_studies/background_file/working_directory/blast_$2/blast_$2_$3_observed_frequency.csv

for i in $(ls /erniedev_data10/P2_studies/data_slices/blast/blast_$2/$3/bl_*.csv)
do
	filename=$(basename $i)
	number=$(echo $filename | tr -dc '0-9')
	python background_frequency.py $filename $number /erniedev_data10/P2_studies/data_slices/blast/blast_$2/$3/ /erniedev_data10/P2_studies/background_file/working_directory/blast_$2/$3/ 
	echo "Done file number $number"
	echo " "
done


python journal_count.py /erniedev_data10/P2_studies/background_file/working_directory/blast_$2/$3/ 1000 /erniedev_data10/P2_studies/background_file/working_directory/blast_$2/blast_$2_$3_observed_frequency.csv


python Table_generator.py $1 /erniedev_data10/P2_studies/background_file/working_directory/blast_$2/comparison/all_file.csv /erniedev_data10/P2_studies/data_slices/blast/blast_$2/blast_gen1_$3_$2_zscores.csv
