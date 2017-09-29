# csv_reloader.py
# Basically an insurance script in case anything goes wrong in the database but we still have the CSV files and loader scripts.
# Iterate through the loader scripts in each subdirectory and reload CSV data in parallel.
# Run this file in the parent directory holding all the year files as subdirectories (where those year files contain split subdirectories)
#
# Usage:
#        python csv_reloader.py [directory of year file]
# Example Usage:
#        nohup python csv_reloader.py 2013 > csv_reload.out &
#
# Author: VJ Davey
# Created: 8/2/2017

import os
import sys
from subprocess import call

year_directory = os.getcwd()+"/"+str(sys.argv[1])
print year_directory
for subdir, dirs, files, in os.walk(year_directory):
        for sys_file in files:
                if "load.sh" in sys_file[-7:]:
                    call(["sh", os.path.join(subdir,sys_file)])
		    print "loaded: "+sys_file
