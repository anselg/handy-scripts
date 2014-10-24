#! /usr/bin/R

require("ggplot2")
require("reshape2")

data = read.table("fuckyou.txt", sep=',', header=F)
if (ncol(data) != 3) {
	print("Check the num. of variables. Exiting")
	return
} else {
	colnames(data)  = c("CompTime", "Period", "Jitter")
}

# Scale the data
data$Time = seq(1, length(data[,1]))/10000 # to s
data$CompTime  = data$CompTime / 1000 # to us
data$Period = data$Period / 1000 # to us
data$Jitter = data$Jitter / 1000 # to us

data.m = melt(data, id.vars='Time')

perfplot = ggplot(data.m, aes(x=Time, y=value, colour=variable)) + 
	geom_point(shape=16,alpha=.15) + 
	facet_wrap( ~ variable, scales="free", ncol=1) + 
	labs(x="Time (s)", y=expression(paste("Time (", mu, "s)"))) + 
	guides(colour=FALSE)
ggsave("perfstats.png")
