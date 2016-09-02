#! /usr/bin/env Rscript

require(maps)
require(ggplot2)
require(reshape2)

filename = "user-institutions.csv"

d = read.table(filename, sep=";", header=T)
d.m = melt(d)

world = map_data("world")
#base_p = ggplot(legend=F) + coord_fixed() + geom_polygon(data=world, aes(x=long, y=lat, group=group))

base_world = ggplot() + 
   coord_fixed() + 
   geom_polygon(data=world[world$region != "Antarctica", ], aes(x=long,y=lat,group=group))

p = base_world + 
   geom_point(data=rawdata, aes(x=rawdata$Longitude, y=rawdata$Latitude), alpha=.5, colour="cyan", size=5) + 
   theme(axis.title = element_blank(), axis.ticks = element_blank(), axis.text = element_blank())

ggsave('output.svg')
