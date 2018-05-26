# Start extracting data from esummary

# In this case chunks 12,13,14 seem to be structurally different from all the other chunks so split them out
e1 <- esummary[-c(12, 13, 14)]
e2 <- esummary[c(12, 13, 14)]

# e1_namevec <- names(e1)
# e2_namevec <- names(e2)

# Process e1 first

e1_authors <- list()
for (i in 1:length(e1)) {
	t1 <- map(e1[[i]], "authors")
	e1_authors[[i]] <- t1
}
e1_authors <- flatten(e1_authors)

d1 <- data.frame()
for (i in 1:length(e1_authors)) {
	a <- rep(names(e1_authors[i]), 
		length(e1_authors[[i]][[1]]))
	b <- e1_authors[[i]][[1]]
	c <- data.frame(cbind(a, b), stringsAsFactors = FALSE)
	d1 <- rbind(d1, c)
	d1 <- unique(d1)
}
d1 <- d1 %>% group_by(a) %>% summarise(authors = paste(b, 
	collapse = ", "))
colnames(d1) <- c("uid", "authors")

f1 <- list()
for (i in 1:length(e1)) {
	f1[[i]] <- map_df(e1[[i]], `[`, 
		c("uid", "title", "pubdate", 
			"fulljournalname", "volume"))
}
g1 <- do.call(rbind, f1)

h1 <- merge(d1, g1)
h1$pubdate <- substr(h1$pubdate, 1, 4)

# Process e2 next

e2_authors <- list()
for (i in 1:length(e2)) {
	t1 <- map(e2[[i]], "authors")
	e2_authors[[i]] <- t1
}
e2_authors <- flatten(e2_authors)

d2 <- data.frame()
for (i in 1:length(e2_authors)) {
a <- rep(names(e2_authors[i]), length(e2_authors[[i]][[1]]))
b <- e2_authors[[i]][[1]]
c <- data.frame(cbind(a, b), stringsAsFactors = FALSE)
d2 <- rbind(d2,c)
d2 <- unique(d2)}
d2 <- d2 %>% group_by(a) %>% summarise(authors = paste(b, collapse = ", "))
colnames(d2) <- c("uid","authors")

e2_flat <- flatten(e2)
e2_clean <- e2_flat[!lengths(e2_flat)< 43]

e2_uid <- unname(sapply(e2_clean, function(x) x$uid))
e2_title <- unname(sapply(e2_clean, function(x) x$title))
e2_pubdate <- unname(sapply(e2_clean, function(x) x$pubdate))
e2_fulljournalname <- unname(sapply(e2_clean, function(x) x$fulljournalname))
e2_volume <- unname(sapply(e2_clean, function(x) x$volume))
e2_df <- data.frame(cbind(e2_uid,e2_title,e2_pubdate,e2_fulljournalname,e2_volume),stringsAsFactors=FALSE)
colnames(e2_df) <- c("uid","title","pubdate","fulljournalname","volume")

h2 <- merge(d2, e2_df)
h2$pubdate <- substr(h2$pubdate, 1, 4)
solr_neg <- rbind(h1,h2)