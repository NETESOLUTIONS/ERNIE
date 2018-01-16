import sys
import psycopg2

i = 0
for arg in sys.argv[0:]:
    print "Argument #%d = %s" % (i, arg)
    i += 1

# Open connection with the default Postgres parameters
conn = psycopg2.connect()
print "Connected to Postgres successfully"
conn.close()