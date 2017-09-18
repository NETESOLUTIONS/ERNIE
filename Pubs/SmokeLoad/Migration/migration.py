# migration.py
# This script is used to migrate files from one server to another
#
# Usage:
#       python migration.py
#           -tp : sql string search pattern to pull tables from database
#           -ttbs: target tablespace to change tablespaces to for backup
#           -titbs: target index tablespace to change index tablespaces to for backup
#           -to: target owner to change owner to for backup
#           -tm: target machine to push backup to if not backing up locally
#           -tu: target user name for ssh connection to pgsql on other machine. Use local name if not specified
#
# Example usage:
#   nohup python migration.py -tp "dfix_%" -to postgres -ttbs wosdata_tbs & > migration.out
#
# Note:
#   make sure pg_hba.conf file is set up to allow communication between servers before running this script if running to dump from one server to another
#   specified target tablespace should exist on target machine prior to running this script if running to dump from one server to another
#
# Author: VJ Davey
# Date : 08/09/2017
# Modified:
#   08/30/2017 - adjustments made to break migration into pre-data, data, and post-data sections through pg_dump so the sed pipe only covers pre and post data phases. This makes script more safe and we can be sure that people, databases, etc. with common substrings for the data being moved wont overwrite valuable data through the sed pipe.


import sys
import subprocess
import re

tables = []
target_tbs = None ; target_index_tbs = None
tables={}; replacements={}
sed_pipe = 0; indexes_opt = 0 ; target_machine=None
target_user = subprocess.check_output("whoami",shell=True).strip()

# Function to make quick calls to psql and pull information pertaining to tablename, owner, and space based on a pattern string.
def pull_tables(pattern, replacements):
    # Pull tables with matching prefix
    query_string = "\"select * from pg_catalog.pg_tables a left join pg_indexes b on a.tablename = b.tablename where a.schemaname!=\'pg_catalog\' and a.schemaname!=\'information_schema\' and a.tablename like \'%s\';\"" % (pattern)
    s = subprocess.check_output("psql -d pardi -c " + query_string, shell=True).split("\n")
    # Collect information from the matching tables and save to dictionary
    for string in s[2:-3]:
        temp = re.split(r"\|", string)
        table = temp[1].strip() ; owner = temp[2].strip() ; tablespace = temp[3].strip()
        tables[table] = {}
        tables[table]['owner'] = owner
        tables[table]['tablespace'] = tablespace
        if temp[4].strip() != 'f':
            index_tablespace = temp[11].strip()
            tables[table]['index_tablespace'] = index_tablespace

# Collect user input regarding tables to backup, and targets for tablespace, owner, and machine in the event we want or need to change specifics about the backup
for i in range(0,len(sys.argv)):
    if sys.argv[i][0] == '-':
        option = sys.argv[i]
        if option[1:] in ['table_pattern', 'tp']:
            arg = sys.argv[i+1]; pull_tables(arg,replacements)
        elif option[1:] in ['target_tablespace', 'ttbs']:
            arg = sys.argv[i+1] ; replacements['tablespace'] = arg ; sed_pipe = 1
        elif option[1:] in ['target_index_tablespace', 'titbs']:
            arg = sys.argv[i+1] ; replacements['index_tablespace'] = arg ; sed_pipe = 1
        elif option[1:] in ['target_owner', 'to']:
            arg = sys.argv[i+1] ; replacements['owner'] = arg ; sed_pipe = 1
        elif option[1:] in ['target_machine', 'tm']:
            arg = sys.argv[i+1] ; target_machine = arg
        elif option[1:] in ['target_user', 'tu']:
            arg = sys.argv[i+1] ; target_user = arg
        else:
            raise NameError('Unknown option : \'%s\''%(option))

# Build shell commands for the pg_dump and execute in parallel. Work from a base command and build it up based on conditionals.
with open('migration.sh', 'w') as migration_script:
    for i in range(0,len(tables.keys())):
        table = tables.keys()[i]
        #clear script if we are making one
        clear_script = "echo \'\' > %s_pgdump.sql\n"%(table) if target_machine == None else ''
        #write the pre-data section
        base = "pg_dump -t \"%s\" -d pardi --section=pre-data" % (table)
        base = clear_script+base
        # Conditionally pipe pg_dump through sed for user specified changes
        if sed_pipe == 1:
            sed_augment = ' | sed \'' + ';'.join('s/%s/%s/g' % (tables[table][key], replacements[key]) for key in replacements) + '\''
            base += sed_augment
        base += " >> %s_pgdump.sql\n"%(table) if target_machine == None else " | ssh %s@%s psql -d pardi\n"%(target_user,target_machine)

        #write the data section to the specified table -- no sed piping should happen here
        base += "pg_dump -t \"%s\" -d pardi --section=data" % (table)
        base += " >> %s_pgdump.sql\n"%(table) if target_machine == None else " | ssh %s@%s psql -d pardi\n"%(target_user,target_machine)

        #write the post data section
        base += "pg_dump -t \"%s\" -d pardi --section=post-data" % (table)
        # Conditionally pipe pg_dump through sed for user specified changes
        if sed_pipe == 1:
            sed_augment = ' | sed \'' + ';'.join('s/%s/%s/g' % (tables[table][key], replacements[key]) for key in replacements) + '\''
            base += sed_augment
        base += " >> %s_pgdump.sql\n"%(table) if target_machine == None else " | ssh %s@%s psql -d pardi\n"%(target_user,target_machine)
        base += "ssh %s@%s \"psql -d pardi -c \\\"vacuum full %s \\\" \"" % (target_user,target_machine, table)
        # Use four parallel connections since theres only four cores on the machine
        #migration_script.write('{\n'+base+'\n}&\n'); migration_script.write("wait\n" if ((i+1)%4==0  or  i+1==len(tables.keys())) else '')
        # Write  and execute commands sequentially one after another
        migration_script.write('\n'+base+'\n')

# Call the created shell script
#subprocess.call(["sh", "migration.sh"])

# Optional: Automatically remove the created shell script
#subprocess.call(["rm", "migration.sh"])
