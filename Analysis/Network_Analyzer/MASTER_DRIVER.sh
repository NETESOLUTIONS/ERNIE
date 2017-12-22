



if [ $# != 3 ]
then
  echo -e "\n\n**************************************************************************"
  echo -e     "***** ERROR : Missing drug name, input directory or output directory *****"
  echo -e "Usage :\nsh MasterDriver.sh <drugname> <input_dir> <output_dir>"
  echo -e "Please provide drugname, input_dir, and output_dir"
  echo -e "Allowed drug or device names are: \naffymetrix, ipilimumab, ivacaftor, buprenorphine, discoverx, lifeskills, naltrexone"
  echo -e "Sample Usage:\nshMasterDriver.sh affymetrix <directory to your input files> <directory to output files> "
  exit
fi


drug_device_name=$1 # must be given
input_dir=$2 # must be given
output_dir=$3 # must be given


javac *.java

java MainDriver $drug_device_name $input_dir $output_dir

rm $output_dir/stat_collector.txt
