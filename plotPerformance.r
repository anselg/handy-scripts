#! /usr/bin/Rscript

require("ggplot2")
require("reshape2")

filebit = "xenomai-sparrow-becca-50kHz"
rt_patch = "Xenomai 2.6.3"
processor = ""
os = "Debian 8"
rate = 50 #kHz

data = read.table(paste(filebit, ".txt", sep=""), sep=',', header=F)
if (ncol(data) != 3) {
	print("Check the number of variables.\n\t(Hint: the three you need are Computation Time, Real-time Period, and Jitter)\n ...Exiting\n")
	return
} else {
	colnames(data)  = c("CompTime", "Period", "Jitter")
}

# Scale the data
data$Time = seq(1, length(data[,1]))/(rate*1000) # to s
data$CompTime  = data$CompTime / 1000 # to us
data$Period = data$Period / 1000 # to us
data$Jitter = data$Jitter / 1000 # to us

data.m = melt(data, id.vars='Time')

perfplot = ggplot(data.m, aes(x=Time, y=value, colour=variable)) + 
	geom_point(shape=16,alpha=.10) + 
	facet_wrap( ~ variable, scales="free", ncol=1) + 
	labs(x="Time (s)", y=expression(paste("Time (", mu, "s)"))) + 
	guides(colour=FALSE) +
	ggtitle(paste(os, rt_patch, processor, "\n", "Recording at", rate, "kHz", sep=" "))

ggsave(paste(filebit, ".png", sep=""))
