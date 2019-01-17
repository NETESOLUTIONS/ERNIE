



'''
Author      : Samet Keserci
Create date : 12/25/2017
Aim         : This script takes 5 columns data in the following format
               Columns:
                   id: this is neccessary for pandas module. It must be numeric or integer, and must be the first columns.
                   source: Contains the nodes
                   stype: Type of the source nodes, such as wosid1, wosid1, fda, ct, root etc.
                   target: Contains target nodes
                   ttype: Type of the targets as above.
            As an output, it porduuces two csv file located in the output directory. Namely,
                author_scores.csv: Has three columns; author, citaiton, PIR
                publication_score: Has three columns; publication, citation, weighted_citation

Usage       : python NetworkAnalyzer.py -file_name <file name> -input_dir <input directory> -output_dir <output directory>
            where <file name> is just file name with its extension
                  <input directory> is the directory where your input file is located.
                  <output directory> is the directory where your output files will be located.
'''





import pandas as pd #use pandas to read the TSV file
import sys #used to pass the TSV file
import numpy as np
#import imat_to_matrix as g_to_m
#from scipy.sparse import csc_matrix
from collections import defaultdict
import csv




'''
Graph type input based Network Analysis
'''


def CorePubByPageRank(filename,top = 30):

    coreNodeList = CoreNodeList(filename)
    page_rank = pageRank(filename,s=.85,maxiter=1)

    page_rank_sorted = sorted(pageRank(G,s=.8,maxerr=.001).items(), key=lambda x: x[1])


def CorePubByWeightCitation(filename,top = 30):

    coreNodeList = CoreNodeList(filename)
    page_rank = pageRank(filename,s=.85,maxiter=10)



def Weigted_Citation_G(filename):


    G = EdgeListToMatrix(filename)

    n = G.shape[0]

    node_list = NodeList(filename);
    print node_list
    weigted_citation = dict();
    gamma = np.zeros(n);

    for i in range(n):
        gamma[i] = 1 + sum(G[:,i])

    for j in range (n):
        weigted_citation[node_list[j]] =  gamma.dot(G[:,j])

    #print weigted_citation
    return weigted_citation



def pageRank(filename, s = .85, maxerr = .0001, maxiter = 1000):
    """
    Computes the pagerank for each of the n states
    Parameters
    ----------
    G: matrix representing state transitions
       Gij is a binary value representing a transition from state i to j.
    s: probability of following a transition. 1-s probability of teleporting
       to another state.
    maxerr: if the sum of pageranks between iterations is bellow this we will
            have converged.
    """

    G = EdgeListToMatrix(filename)
    node_list = NodeList(filename);
    pageRankScore = dict();
    n = G.shape[0]

    # transform G into markov matrix A
    A = csc_matrix(G,dtype=np.float)
    rsums = np.array(A.sum(1))[:,0]
    ri, ci = A.nonzero()
    A.data /= rsums[ri]

    # bool array of sink states
    sink = rsums==0

    # Compute pagerank r until we converge
    ro, r = np.zeros(n), np.ones(n)
    iter_count = 0
    while np.sum(np.abs(r-ro))/n > maxerr:
        ro = r.copy()
        # calculate each pagerank at a time
        iter_count = iter_count +1
        if iter_count == maxiter:
            break;
        for i in xrange(0,n):
            # inlinks of state i
            Ai = np.array(A[:,i].todense())[:,0]
            # account for sink states
            Di = sink / float(n)
            # account for teleportation to state i
            Ei = np.ones(n) / float(n)

            r[i] = ro.dot( Ai*s + Di*s + Ei*(1-s) )

        print iter_count,np.sum(np.abs(r-ro)),np.sum(np.abs(r-ro))/n
        #print np.sum(np.abs(r-ro))
    #print len(r)
    # return normalized pagerank

    print r/float(sum(r))

    for i in range(n):
        pageRankScore[node_list[i]] = r[i]/float(sum(r))


    return pageRankScore






'''
Map based Network Analysis

'''



# id_type wos or pmid
def CoreNodeList(file_name, input_dir, output_dir, id_type):
    #raw_df = pd.DataFrame.read_csv("edgeList.tsv", sep='\t', header=0)
    raw_df_all = pd.DataFrame.read_csv("five_pack_orig.csv", sep=',', header=0)
    unique_nodes_all = pd.concat([raw_df_all[id_type]]).unique().tolist()

    # get drug nodes
    raw_df = pd.DataFrame.read_csv(filename, sep='\t', header=0)
    #unique_nodes = pd.concat([raw_df["citing_"+id_type],raw_df["cited_"+id_type]]).unique().tolist()
    unique_nodes = pd.concat([raw_df["citing_"+id_type]]).unique().tolist()


    #print unique_nodes
    n_all = len(unique_nodes_all)
    n = len(unique_nodes)
    print "Unique Nodes,All,resp:"

    intersection = list(set(unique_nodes_all) & set(unique_nodes))

    n_all = len(unique_nodes_all)
    n = len(unique_nodes)
    n_intersect = len(intersection)
    print "Nodes, All, Intersection resp:"
    print n,n_all,n_intersect # 2008 5258 190

    pmid_sid_mapping = raw_df.set_index('citing_pmid')['citing_sid'].to_dict()
    sid_pmid_mapping = raw_df.set_index('citing_sid')['citing_pmid'].to_dict()

    core_sid_pmid = dict()

    for node in intersection:
        sid = pmid_sid_mapping[node]
        core_sid_pmid[sid] = node;
    #print pmid_sid_mapping;

    n_all = len(unique_nodes_all)
    n = len(unique_nodes)
    n_intersect = len(intersection)
    n_cor_sid_pmid = len(core_sid_pmid)
    print "Nodes, All, Intersection, n_cor_sid_pmid resp:"
    print n,n_all,n_intersect,n_cor_sid_pmid  # 2008 5258 190

    return core_sid_pmid


def combiner_writer(A, B):

    list1 = list()
    list2 = list()

    with open('pir_pageRank_score.csv','wb') as f:
        writer = csv.writer(f)
        for k,v in A.items():

            list1.append(v)
            list2.append(B[k])
            writer.writerow((k,v,B[k]))

    com_list = list()
    com_list.append(list1)
    com_list.append(list1)

    print "Pearson correlation coef:"
    print pearsonCorr(list1,list2)
    return com_list




'''
This method returns Pearson corrolation coefficent of two list.
'''
def pearsonCorr(list1, list2):
    corcoef = np.corrcoef(list1,list2)[0,1]
    print corcoef
    return corcoef







'''
This method returns a data frame which has stype or type as wosid*
'''
def NodeList(file_name, input_dir, output_dir):
    #raw_df = pd.DataFrame.read_csv("edgeList.tsv", sep='\t', header=0)
    #"source"	"stype"	"target"	"ttype"
    raw_df = pd.DataFrame.read_csv(input_dir+file_name, sep='\t', header=0)
    unique_nodes = pd.concat([raw_df['source'],raw_df['target']]).unique().tolist()
    unique_source_nodes = raw_df['source'].unique().tolist()
    unique_target_nodes = raw_df['target'].unique().tolist()
    only_pub_df = raw_df[lambda y: ((y.stype == 'wosid1')|(y.stype == 'wosid2'))&((y.ttype=='wosid1')|(y.ttype=='wosid2'))]
    unique_pub_nodes = pd.concat([only_pub_df['source'],only_pub_df['target']]).unique().tolist()
    unique_citingpub_nodes = only_pub_df['source'].unique().tolist()
    unique_citedpub_nodes = only_pub_df['target'].unique().tolist()

    #print unique_nodes
    nodes_total = len(unique_nodes)
    nodes_source = len(unique_source_nodes)
    nodes_target = len(unique_target_nodes)
    nodes_total_pub = len(unique_pub_nodes)
    nodes_source_pub = len(unique_citingpub_nodes)
    nodes_target_pub = len(unique_citedpub_nodes)

    #print nodes_total, nodes_source,nodes_target,nodes_total_pub, nodes_source_pub, nodes_target_pub
    #print unique_nodes
    return only_pub_df


'''
This method returns a dictionary of publication and its citation
'''
def Citation(file_name, input_dir, output_dir):
    cit_map = dict()
    pub_citedPub_df = NodeList(file_name, input_dir, output_dir)
    node_list = pd.concat([pub_citedPub_df['source'],pub_citedPub_df['target']]).unique().tolist()
    flag = 0;
    for index,row in pub_citedPub_df.iterrows():
        if flag == 0:
            flag = flag + 1
            continue
        source = row[0]
        stype = row[1]
        target = row[2]
        ttype = row[3]
        if cit_map.has_key(target):
            cit_map[target]=cit_map[target] + 1
        else:
            cit_map[target] = 1

    for node in node_list:
        if cit_map.has_key(node):
            continue
        else:
            cit_map[node] = 0

    #print "publication size:"
    #print len(cit_map)
    return cit_map



'''
This method returns a dictionary of publication and its citing publications set
'''
def Cited_CitingSet(file_name, input_dir, output_dir):

    cited_citingSet = dict()

    pub_citedPub_df = NodeList(file_name, input_dir, output_dir)

    flag = 0
    for index,row in pub_citedPub_df.iterrows():
        if flag == 0:
            flag = flag + 1
            continue
        citing = row[0]
        cited = row[2]
        if cited_citingSet.has_key(cited):
            cited_citingSet[cited].add(citing)
        else:
            citingSet = set()
            citingSet.add(citing)

            cited_citingSet[cited] = citingSet

    #print "cited_citing set size:"
    #print len(cited_citingSet)
    return cited_citingSet


'''
This method returns a dictionary of publication and its weighted citation
'''
def Weigted_Citation(file_name, input_dir, output_dir):
    citation_map = Citation(file_name, input_dir, output_dir)
    cited_citingSet_map= Cited_CitingSet(file_name, input_dir, output_dir)

    weighted_citation = dict()
    for node in citation_map.keys():
        wscore = citation_map[node];
        if cited_citingSet_map.has_key(node):
            for citing_nodes in cited_citingSet_map[node]:
                wscore = wscore + citation_map[citing_nodes]

        weighted_citation[node] = wscore

    #print "weighted cited_citing set size:"
    #print len(weighted_citation)
    #print weighted_citation
    return weighted_citation


'''
This method returns a dictionary of authors and their publication set
'''
def Auth_pubSet(file_name, input_dir, output_dir):

    raw_df = pd.DataFrame.read_csv(input_dir+file_name, sep='\t', header=0)
    only_pub_auth = raw_df[lambda y: (y.ttype=='author')]
    unique_auth_nodes = only_pub_auth['ttype'].unique().tolist()


    auth_pub = dict()

    flag = 0
    for index, row in only_pub_auth.iterrows():
        if (flag == 0):
            flag = flag +1
            continue
        pub = row[0]
        auth = row[2].lower().replace(',',' ');
        lname = auth.split()[0]

        #fname = auth.split()[1]
        #fnameInt = fname[0]

        if len(auth.split()) == 1:
            fname = " "
        else:
            fname = auth.split()[1]

        lastNameFirstInitial = lname+" "+fname[0]

        if auth_pub.has_key(lastNameFirstInitial):
            auth_pub[lastNameFirstInitial].add(pub)
        else:
            pubSet = set()
            pubSet.add(pub)
            auth_pub[lastNameFirstInitial] = pubSet

    print "Auth size_pubset :"
    print len(auth_pub)

    return  auth_pub


''' Calculates the author citation and PIR scores, and write them into csv file
    as well as with publications citaiton score and wighted citation scores.
'''
def Auth_Scores(file_name, input_dir, output_dir):

    auth_pubSet= Auth_pubSet(file_name, input_dir, output_dir)
    pub_citation = Citation(file_name, input_dir, output_dir)
    pub_weighted_citation = Weigted_Citation(file_name, input_dir, output_dir)

    print "publication size:"
    print len(pub_citation)
    #print len(pub_weighted_citation)


    auth_PIR = dict()
    auth_totalCitation = dict()

    for auth in auth_pubSet.keys():
        citation_sum = 0
        w_citation_sum = 0
        for pub in auth_pubSet[auth]:
            citation_sum += pub_citation[pub]
            w_citation_sum += pub_weighted_citation[pub]

        auth_totalCitation[auth] = citation_sum
        auth_PIR[auth] = w_citation_sum

    with open(output_dir+'author_scores.csv','wb') as f:
        writer = csv.writer(f)
        writer.writerow(("author","total_citation","PIR"))
        for auth in auth_totalCitation.keys():
            writer.writerow((auth,auth_totalCitation[auth],auth_PIR[auth]))

    with open(output_dir+'publication_scores.csv','wb') as f:
        writer = csv.writer(f)
        writer.writerow(("publication","citation","weighted_citation"))
        for pub in pub_citation.keys():
            writer.writerow((pub,pub_citation[pub],pub_weighted_citation[pub]))




    #print auth_PIR
    #print len(auth_PIR)
    #print len(auth_totalCitation)
    #print auth_pubSet['taubman m']
    #print pub_citation['WOS:000225948900012']
    #print pub_citation['WOS:000079909300081']
    #print pub_weighted_citation['WOS:000225948900012']
    #print pub_weighted_citation['WOS:000079909300081']








if __name__=='__main__':


    in_arr = sys.argv

    if '-file_name' not in in_arr:
       print
       print "No file name is given."
       print 'USAGE: python NetworkAnalyzer.py -file_name <file name> -input_dir <input directory> -output_dir <output directory>'
       raise NameError('ERROR: NO INPUT FILE NAME!')
    else:
       file_name = in_arr[in_arr.index('-file_name') + 1]

    if '-input_dir' not in in_arr:
       print "No input_dir is specified"
       print 'USAGE: python NetworkAnalyzer.py -file_name <file name> -input_dir <input directory> -output_dir <output directory>'
       raise NameError('ERROR: NO INPUT DIRECTORY!')
    else:
       input_dir = in_arr[in_arr.index('-input_dir') + 1]+"/"

    if '-output_dir' not in in_arr:
       print "No output_dir is specified"
       print 'USAGE: python NetworkAnalyzer.py -file_name <file name> -input_dir <input directory> -output_dir <output directory>'
       raise NameError('ERROR: NO OUTPUT DIRECTORY!')
    else:
       output_dir = in_arr[in_arr.index('-output_dir') + 1]+"/"


    #file_name = "samet_test3.txt"
    #input_dir = "/Users/Samet/NetworkAnalysisPython/"
    #output_dir ="/Users/Samet/NetworkAnalysisPython/"
    Auth_Scores(file_name, input_dir, output_dir)
