# Import modules
import os

# Create list of files from directory and initiate variables
d = os.listdir('/Users/avi/Documents/Dec14/pdf')
temp = []
UID = []
# Remove extentions and move files that aren't broken
for i in d:
    if '.txt' in i:
        j = i[:-4]
        path1_1 = '/Users/avi/Documents/Dec14/pdf/' + j + '.pdf'
        path1_2 = '/Users/avi/Documents/Dec14/pdf/pdftotext/' + j + '.pdf'
        path2_1 = '/Users/avi/Documents/Dec14/pdf/' + i 
        path2_2 = '/Users/avi/Documents/Dec14/pdf/pdftotext/' + i     
        os.rename(path1_1, path1_2)
        os.rename(path2_1, path2_2)
        UID.append(j)
