import sys

i = 0
for arg in sys.argv[0:]:
    print "Argument #%d = %s" % (i, arg)
    i += 1
