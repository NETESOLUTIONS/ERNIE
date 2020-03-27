# Analysis of Observed Co-citation Data

This folder contains code relevant to analyzing the observed co-citation frequencies in Scopus.

- lognorm_buckets.exe
  - Purpose: compute the Maximium Likleihood Estimator (MLE) parameters for a lognormal distribution.
  - Compiled C++ program using a modified version of amoeba.h from Numerical recipes in {C}: The art of scientific computing (3rd ed.) by Press, W.H. and Teukolsky, S.A. and Vetterling, W.T. and Flannery, B.P.
  - Input arguments:
     - Reads a text file df_freq.csv from the same folder in which the executable resides with no headers, the first column indicating the co-citation frequency and the second column indicating the probability of each frequency, as shown below.
  - Output:
    - mean and standard deviation of a normal distribution underlying the lognormal distribution that is the MLE solution
  - This program was executed from a Python program to determine the moments of the lognormal distribution as mentioned above.
