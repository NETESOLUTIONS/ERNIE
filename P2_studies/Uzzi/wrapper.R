args <- commandArgs(TRUE)
input_file <- args[1]
output_name_string <- args[2]
source('perm.R')
perm(input_file,output_name_string)
