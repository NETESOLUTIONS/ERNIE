#eid_padding.py
# This script will pad all provided EIDs to 10 chars and ensure that they are usable as SCOPUS IDs

import sys

for line in sys.stdin:
    eid=line.strip('\n')
    if len(eid)<10:
        print("{:0>11}".format(eid))
    else:
        print("{}".format(eid))
