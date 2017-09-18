# smokeload_wrapper.py
# This program is a wrapper for the yearly smokeload process.
#
# Usage
#       python smokeload_wrapper.py [directory of WOS .zip files] [desired output directory for CSV files]
# Example
#       nohup python smokeload_wrapper.py [source data location] [output directory for csv files] & > wrapper_log.out
#
###############################################
import subprocess
from subprocess import call
import os
import shutil
import sys
import re
from datetime import datetime, timedelta
from time import sleep
disk_requirement = 30 #minimum required GB space for us to run the smokeload


def disk_check(target_dir, requirement):
    # First, build the disk free space dictionary
    free_spc={}
    df_output = subprocess.check_output("df -h", shell=True).split("\n")
    for string in df_output[1:-1]:
        temp = re.split(r" +", string)
        mounted_drive = temp[5] ; available_space = temp[3]
        free_spc[mounted_drive] = available_space
    # Second, check the disk given by the target CSV directory to see if there is enough required space left for the smokeload operation
    target_disk = None
    for disk in free_spc:
        if (disk != '/') and (target_dir.startswith(disk)):
            target_disk = disk
    if target_disk == None:
            print "Target disk does not exist.";return 'fail'
    if free_spc[target_disk][-1] != "G":
            print "Target disk not large enough.";return 'fail'
    print "Target CSV output disk free space : %s" %(free_spc[target_disk])
    if float(free_spc[target_disk][:-1]) < requirement:
        print "Not enough space on target disk.";return 'fail'
    return 'pass'


# Collect start time
start_time = datetime.now()
# Collect directory string
directory = str(sys.argv[1])
csv_output_directory = str(sys.argv[2])
# Loop through the zip files in the specified directory from the command line argument, remove any already completed jobs from our todo list
zip_files = []
for file in os.listdir(directory):
        if file.endswith(".zip"):
                zip_files.append(file)
zip_files.sort(reverse=True)
completed_jobs = directory+"completed_jobs.txt"
print "Checking for completed jobs in: %s" %(completed_jobs)
with open(completed_jobs) as checkfile:
    jobs = checkfile.read()
    for item in zip_files:
        if item in jobs:
            zip_files.remove(item)
            print "Job for item %s already completed. Removing from pending job list" %(item)


# Run the smokeload workflow for each zip file
counter = 0
for zip_file in zip_files:
        # Perform an initial check on disk space for the target CSV directory.
        #  If the available space does not meet our requirements, terminate the script and inform the user
        if disk_check(csv_output_directory, disk_requirement) != 'pass':
            raise NameError('ERROR: Disk Error')
        print "*** Target disk has enough space to continue process..."
        print "*** Working on file: %s"%(zip_file)

        # Lets get to work
        out_file = "~/log_"+zip_file[:4]+".out"
        with open(os.path.expanduser(out_file), "w") as outfile:
            # Run master loader script
            print "*** Running master loader script"
            call(["nohup", "sh", "master_loader_wos.sh", zip_file, directory, csv_output_directory, os.getcwd()], stdout=outfile)

        # Move the created outfile to the appropriate CSV directory
        print "*** Moving out file to CSV directory"
        call(["mv", os.path.expanduser(out_file), csv_output_directory+zip_file[:4] ])

        # Remove the large directory generated from the unzipping procedure of the master script
        year_CORE_directory = directory+zip_file[:-4]
        print "*** Removing XML directory: %s " %(year_CORE_directory)
        call(["rm", "-rf", year_CORE_directory])

        # Note completion of this job in the completed jobs file
        print "*** Marking job as completed"
        with open(completed_jobs, "a") as checkfile:
            checkfile.write("\n"+zip_file)

        # Keep a backup of the completed jobs in the home directory so we know for sure where we left off if things go wrong
        backup_file = "~/completed_jobs.txt"
        with open(os.path.expanduser(backup_file), "w") as backup:
            call(["cat", completed_jobs], stdout=backup)

        # Notify completion of process
        print "*** Completed upload process for file: %s"%(zip_file)



# Collect end time
end_time = datetime.now()
print "Total time taken: "
print (end_time-start_time)
