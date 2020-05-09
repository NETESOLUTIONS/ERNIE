# regenerate Fig 4.
library(data.table)
library(ggplot2)
setwd("~/Dropbox/CC2")
x <- fread("~/Dropbox/CC2/cc2_top_null_corrected_max_one.csv")

setwd('~/cocitation_2/R1')
# Fig 4(a)
p <- qplot(top_max_one, scopus_frequency, data = x, alpha = I(0.2), xlab = expression(theta), 
ylab = "Frequency") + theme_bw() + theme(text = element_text(size = 20))

pdf('replacement4a.pdf')
print(p)
dev.off()

# Fig 4(b)
a <- c("0-0.2", x[top_max_one <= 0.2][, .N])
b <- c("0.2-0.4", x[top_max_one > 0.2 & top_max_one <= 0.4][, .N])
c <- c("0.4-0.6", x[top_max_one > 0.4 & top_max_one <= 0.6][, .N])
d <- c("0.6-0.8", x[top_max_one > 0.6 & top_max_one <= 0.8][, .N])
e <- c("0.8-1.0", x[top_max_one > 0.8 & top_max_one <= 1][, .N])
xx <- data.frame(rbind(a, b, c, d, e), stringsAsFactors = FALSE)
xx$X2 <- as.integer(xx$X2)
colnames(xx) <- c("theta_interval", "count")

q <- qplot(theta_interval, count, data = xx, group = 1, geom = c("point", "line"), 
xlab = expression(theta * " interval"),ylab="Count") + scale_y_continuous(trans = "log2") + 
theme_bw() + theme(text = element_text(size = 20))

pdf('replacement4b.pdf')
print(q)
dev.off()



