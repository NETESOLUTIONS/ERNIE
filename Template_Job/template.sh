#!/usr/bin/env bash
cd `dirname $0`

echo "Executing Postgres script..."
# -a = --echo-all: pPrint all nonempty input lines to standard output as they are read.
# -h localhost switches from Unix sockets to TCP/IP
psql -a -v ON_ERROR_STOP=on -f template_query.sql -h localhost ernie ernie_admin

echo "Executing Python script..."
# Unquoted $SWITCHES get expanded into *multiple* command-line arguments
# Quoted $SWITCHES get expanded into a *single* command-line argument
python template.py -t test 'argument with spaces' $switches

echo "Done."