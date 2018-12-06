#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 30 14:51:24 2018

@author: sitaram
"""

import random
import time
random.seed(time.time())
import os
import sys


inputfile_path=sys.argv[1]
outputfile_path=sys.argv[2]
#file_yr = str(2004)
#file_yr = input("Enter file name: ")
#print("you entered ", file_yr)
file_yr='data1980'

#runs = 10
#runs = input("Enter # of trials: ")
#print("you entered ", runs)
runs=10

#iterations = 10
#iterations = input("Enter # of iterations, eg 2*log10(counter): ")
#print("you entered ", iterations)
#iterations = int(iterations)
iterations = 10

#define a useful data structure
class Dlist(dict):
    def __init__(self, default=None):
        self.default = default

    def __getitem__(self, key):
#        if not self.has_key(key):
        if key not in self:
            self[key] = {'y':'','T9s':[]}
        return dict.__getitem__(self, key)

class Dset(dict):
    def __init__(self, default=None):
        self.default = default

    def __getitem__(self, key):
#        if not self.has_key(key):
        if key not in self:
            self[key] = set()
        return dict.__getitem__(self, key)

class Dlist_simple (dict):
    def __init__(self, default=None):
        self.default = default

    def __getitem__(self, key):
#        if not self.has_key(key):
        if key not in self:
            self[key] = []
        return dict.__getitem__(self, key)

def is_int(s):
    try: 
        int(s)
        return True
    except ValueError:
        return False

def ensure_dir(f):
    d = os.path.dirname(f)
    if not os.path.exists(d):
        os.makedirs(d)


#define functions
def permutate (d, r, f):
    counter=0
    rand_keys = list(f.keys())
    random.shuffle(rand_keys)
    print('rand_keys ' + str(len(rand_keys)))
    for T9 in rand_keys:
        #R9s=set()
        #R9s|=set(f[T9][:])
        R9s=f[T9][:] #this is faster than using sets, though less elegant, speed is more important
        #print 'point A'
        for R9 in R9s:
            #find year of R9 article
            year = r[R9]['y']
            #pull a random R9 from same year, not already cited by current T9
            R9_2 = random.sample(d[year],1)[0]
            #year_R9s=set()
            #year_R9s|= set(d[year])
            #print 'point B'
            ex = 1
            if len(d[year]) > 1: #and year_R9s.issubset(R9s) == False:        
                while R9_2 in R9s and ex < 20:
                    R9_2 = random.sample(d[year],1)[0]
                    ex+=1
                    #print 'R9_2 loop'
            #pull a random T9 citing R9_2 to rewire to original R9
            T9_2 = random.sample(r[R9_2]['T9s'],1)[0]
            ex = 1
            if len(r[R9_2]['T9s']) > 1:    
                while T9_2 == T9 and ex < 20: #so don't get stuck    :
                    T9_2 = random.sample(r[R9_2]['T9s'],1)[0]
                    #print 'T9_2 loop; T9: ' + str(T9) + ', R9: ' + str(R9)
                    ex+=1
            #print 'T9: '+T9+', R9: '+R9+', T9_2: '+T9_2+', R9_2: '+R9_2
            #print f

            #only make switch when the new T9 isn't also the R9, or would create
            #  an invalid self loop, and skip where no change need be made
            if T9_2 != R9 and T9 != T9_2 and R9 != R9_2:
                #switch the R9's
                f[T9].remove(R9)
                f[T9].append(R9_2)
                #update lookup table
                r[R9]['T9s'].remove(T9)
                r[R9]['T9s'].append(T9_2)
                r[R9_2]['T9s'].remove(T9_2)
                r[R9_2]['T9s'].append(T9)
                f[T9_2].remove(R9_2)
                f[T9_2].append(R9)
        counter+=1
        if (counter % 100 == 0):
            print('%d T9s processed' % counter)


#MAIN
#load dataset
#v[0] T9, v[1] R9, v[2] cited_ref_year
#runs = 10
for run in range(1,int(runs)+1):
#    fh = open('/dir/' + file_yr + '.txt','r')### This reads the bibliography data
    fh = open(inputfile_path + file_yr + '.csv','r')
    counter=0
    d = Dset ( dict ) #year-r9s lookup
    r = Dlist ( dict ) #r9-year-t9s lookup lookup
    f = Dlist_simple ( dict ) #t9-r9s lookup

    for line in fh:
        v = line.strip().split(',')
        if counter >= 0:
            #create year lookup dictionary
            d[v[5]].add(v[4])
            r[v[4]]['y']=v[5]
            r[v[4]]['T9s'].append(v[0])
            
            
            #d[v[2]].add(v[1])
            #r[v[1]]['y'] = v[2]
            #r[v[1]]['T9s'].append(v[0])
    
            #create data record dictionary, for switching cites
            f[v[0]].append(v[4])
            
            #f[v[0]].append(v[1])

        counter = counter+1
        if (counter % 1000000 == 0):
            print('%d edges loaded' % counter)

    print('finished loading year lookup dictionary and data record dictionary')
    fh.close()

    #iterations=2 #2*log(e)
    for i in range(1,iterations):
        permutate ( d,r,f )
        print(str(run) + ':' + str(i))
        #print f
    
    #save results
    print('saving results....')
    ensure_dir(outputfile_path + str(file_yr) + '/' + str(run) + '.csv')
    fh2 = open(outputfile_path + str(file_yr) + '/' + str(run) + '.csv','w')
    for T9 in f.keys():
        for R9 in f[T9]:
            print('%s,%s,%s' % (T9,R9,r[R9]['y']),file=fh2)
    fh2.close()
    print('Results written to file. : ' + str(file_yr) + ', run: ' + str(run))
    d.clear()
    r.clear()
    f.clear()

print('Done with file: ' + file_yr)
