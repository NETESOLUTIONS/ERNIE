d95_pub_cit_100 <- d95_pub_cit[citation_count > 100]
d95_pub_cit_100 <- d95_pub_cit_100[order(citation_count)]
d95_pub_cit_100[,`:=`(sno=1:nrow(d95_pub_cit_100))]
d95_pub_cit_100[,`:=`(gp='x')]
d95_pub_cit_100$gp[d95_pub_cit_100$sno <= 2500] <- 'gp1'
d95_pub_cit_100$gp[d95_pub_cit_100$sno <= 5000 & d95_pub_cit_100$sno > 2500 ] <- 'gp2'
d95_pub_cit_100$gp[d95_pub_cit_100$sno <= 7500 & d95_pub_cit_100$sno > 5000 ] <- 'gp3'
d95_pub_cit_100$gp[d95_pub_cit_100$sno > 7500] <- 'gp4'

d95_pub_cit_50_100 <- d95_pub_cit[citation_count <= 100 & citation_count > 50]
d95_pub_cit_50_100 <- d95_pub_cit_50_100[order(citation_count)]
d95_pub_cit_50_100[,`:=`(sno=1:nrow(d95_pub_cit_50_100))]
d95_pub_cit_50_100[,`:=`(gp='x')]
d95_pub_cit_50_100$gp[d95_pub_cit_50_100$sno <= 5700] <- 'gp1'
d95_pub_cit_50_100$gp[d95_pub_cit_50_100$sno <= 11400 & d95_pub_cit_50_100$sno > 5700 ] <- 'gp2'
d95_pub_cit_50_100$gp[d95_pub_cit_50_100$sno <= 17100 & d95_pub_cit_50_100$sno > 11400 ] <- 'gp3'
d95_pub_cit_50_100$gp[d95_pub_cit_50_100$sno > 17100] <- 'gp4'
d95_pub_cit_50_100_nsi <- d95_pub_cit_50_100[,-1]
m_d95_pub_cit_50_100_nsi <- melt(d95_pub_cit_50_100_nsi,id=c('citation_count','sno','gp'))

d95_pub_cit_10_50 <- d95_pub_cit[citation_count <= 50 & citation_count > 10]
d95_pub_cit_10_50 <- d95_pub_cit_10_50[order(citation_count)]
d95_pub_cit_10_50[,`:=`(sno=1:nrow(d95_pub_cit_10_50))]
d95_pub_cit_10_50[,`:=`(gp='x')]
d95_pub_cit_10_50$gp[d95_pub_cit_10_50$sno <= 44000] <- 'gp1'
d95_pub_cit_10_50$gp[d95_pub_cit_10_50$sno <= 88000 & d95_pub_cit_10_50$sno > 44000 ] <- 'gp2'
d95_pub_cit_10_50$gp[d95_pub_cit_10_50$sno <= 132000 & d95_pub_cit_10_50$sno > 88000 ] <- 'gp3'
d95_pub_cit_10_50$gp[d95_pub_cit_10_50$sno > 132000] <- 'gp4'
d95_pub_cit_10_50_nsi <- d95_pub_cit_10_50[,-1]
m_d95_pub_cit_10_50_nsi <- melt(d95_pub_cit_10_50_nsi,id=c('citation_count','sno','gp'))