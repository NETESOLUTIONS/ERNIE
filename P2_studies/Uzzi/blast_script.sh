#!/bin/bash

dir_name=$(dirname $1)

echo "dirname is $dir_name"

folder_name=$(echo $dir_name | cut -d '/' -f 4-10)

echo "folder name is $folder_name"

working_directory="/erniedev_data10/P2_studies/background_file/working_directory/"$folder_name

echo "working directory is $working_directory"

if [ ! -d "$working_directory/$2" ]; then
	mkdir -p $working_directory/$2 
	#mkdir $working_directory/$2
	#mkdir /erniedev_data10/P2_studies/background_file/working_directory/blast_$2/analysis
	#mkdir /erniedev_data10/P2_studies/background_file/working_directory/blast_$2/comparison
fi

echo "Getting name of input file to generate observed frequency file"

file_name=$(basename $1)

echo "input filename is $file_name"

file_name=$(echo $file_name | cut -d '.' -f 1)

echo "filename without extension $file_name"

python observed_frequency.py $1 $working_directory/${file_name}_observed_frequency.csv

total=$(ls $dir_name/$2 *_permuted_* | wc -l)

echo "number of files is $total"

for i in $(ls $dir_name/$2/*_permuted_*.csv)
do
	filename=$(basename $i)
	number=$(echo $filename | tr -dc '0-9')
	python background_frequency.py $filename $number $dir_name/$2/ $working_directory/$2/
	echo "Done file number $number"
	echo " "
done


python journal_count.py $working_directory/$2/ $total $working_directory/${file_name}_observed_frequency.csv


python Table_generator.py $1 $working_directory/$2/all_file.csv $dir_name/${file_name}_permute.csv

DATE=`date +%Y-%m-%d`

if [ -z "$3" ]
then
	rm -rf $working_directory*
else
	mv $working_directory ${working_directory}_$DATE
fi
