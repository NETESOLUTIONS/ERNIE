# script to remind me what to do with ggplot figures 
# taken from  How I build up a ggplot2 figure
# Posted on February 18, 2016 by strictlystat
# and reposted on R-Bloggers
library(ggplot2)
g <- ggplot(data = quakes,aes(x = lat,y = long,colour = stations)) +  geom_point()
gbig = g + theme(axis.text = element_text(size = 18),axis.title = element_text(size = 20),
                 legend.text = element_text(size = 15), legend.title = element_text(size = 15))
gbig1 = gbig + xlab("Latitude") + ylab("Longitude")
gbig2 <- gbig1 + ggtitle("Spatial Distribution of Stations")
gbigleg_orig = gbig2 + guides(colour = guide_colorbar(title = "Number of Stations Reporting"))
gbigleg = gbigleg + guides(colour = guide_colorbar(title = "Number\nof\nStations\nReporting", title.hjust = 0.5))
gbigleg + theme(legend.position=c(0.3,0.3))
transparent_legend =  theme(
  legend.background = element_rect(fill = "transparent"),
  legend.key = element_rect(fill = "transparent",
                            color = "transparent")
)
gtrans_leg = gbigleg + theme(legend.position = c(0.3, 0.35)) + transparent_legend
print(gtrans_leg)



