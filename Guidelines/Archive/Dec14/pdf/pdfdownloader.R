library(tm)
library(XML)
setwd("~/Documents/Dec14")

#df = read.csv('pdflinks649.csv')

#colnames(df)[2] <- 'Link'
#colnames(df)[3] <- 'UID'

#df <- df[2:3]

Link <- df$url
UID <- df$uid

Link <- as.vector(Link)
UID <- as.vector(UID)

len = length(UID)

for (i in 1:len){
  url = Link[i]
  x = as.character(UID[i])
  dest <- paste0("/Users/Avi/Documents/Dec14/pdf/",x,".pdf")
  e <- tryCatch(
    download.file(url, dest, mode="wb"), error = function(e) e)
  if(!inherits(e, "error")){
    exe <- "/Users/avi/xpdf/bin64/pdftotext"
    system(paste(exe, dest), wait = F)

  }
  
}