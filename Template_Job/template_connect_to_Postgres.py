import sys
import psycopg2

i = 0
for arg in sys.argv[0:]:
    print "Argument #%d = %s" % (i, arg)
    i += 1

# Open connection to PARDI database
conn = psycopg2.connect(host="localhost", dbname="pardi", user="pardi_admin")
print "Connected to the PARDI DB successfully"
conn.close()
