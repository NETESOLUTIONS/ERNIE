library(tm)
library(XML)
setwd("~/Python Scripts/XMLP")

df = read.csv('pdflinks649.csv')

colnames(df)[2] <- 'Link'
colnames(df)[3] <- 'UID'

df <- df[2:3]

Link <- df$Link
UID <- df$UID

Link <- as.vector(Link)
UID <- as.vector(UID)

len = length(UID)

for (i in 1:len){
  url = Link[i]
  x = as.character(UID[i])
  dest <- paste0("C:\\Users\\Avi\\Documents\\pdfntxt\\",x,".pdf")
  e <- tryCatch(
    download.file(url, dest, mode="wb"), error = function(e) e)
  if(!inherits(e, "error")){
    exe <- "C:\\Program Files\\xpdfbin-win-3.04\\bin64\\pdftotext.exe"
    system(paste("\"", exe, "\" \"", dest, "\"", sep = ""), wait = F)
  }
  
}