#! /usr/bin/Rscript

options(warn=-1)
args = commandArgs(trailingOnly=T)

if( !(require(ggplot2)&&require(reshape2)) ) {
   message("I need some R packages installed. (ggplot2, plyr, gridExtra, and scales)")
   message(prompt="Want me to install them? (y/N)")
   val <- scan("stdin", character(), n=1)
   if ((val == "y")||(val == "Y")) {
      install.packages("ggplot2", repos="http://watson.nci.nih.gov/cran_mirror/")
      install.packages("reshape2", repos="http://watson.nci.nih.gov/cran_mirror/")

      require(ggplot2)
      require(reshape2)
   } else {
      stop("Look, you need to install 'ggplot2', 'plyr', 'gridExtra', and 'scales' to do this.")
   }
}

# Headings for the plot. Edit them here. 
os = as.character(args[1])
hostname = as.character(args[2])
rt_kernel = as.character(args[3])
processor = as.character(args[4])
graphics_card = as.character(args[5])
graphics_driver = as.character(args[6])
rt_period = as.integer(args[7]) # in ns
downsample = as.integer(args[8])
channel1 = as.character(args[9])
channel2 = as.character(args[10])
channel3 = as.character(args[11])
infile = as.character(args[12])
outfile = as.character(args[13])

data.raw = read.table(infile)
data.stats = data.frame(Time=seq(1, length(data.raw$V1))/(1e6/rt_period*downsample))

# messy, but needed
if (channel1 == "Comp Time") {
	data.stats$CompTime = data.raw$V2
} else if (channel2 == "Comp Time") {
	data.stats$CompTime = data.raw$V3
} else if (channel3 == "Comp Time") {
	data.stats$CompTime = data.raw$V4
}
# messy, but needed
if (channel1 == "Real-time Period") {
	data.stats$Period = data.raw$V2
} else if (channel2 == "Real-time Period") {
	data.stats$Period = data.raw$V3
} else if (channel3 == "Real-time Period") {
	data.stats$Period = data.raw$V4
}
# messy, but needed
if (channel1 == "RT Jitter") {
	data.stats$Jitter = data.raw$V2
} else if (channel2 == "RT Jitter") {
	data.stats$Jitter = data.raw$V3
} else if (channel3 == "RT Jitter") {
	data.stats$Jitter = data.raw$V4
}

head(data.stats)
#stop("Hehe, still a work in progress...")

# Scale the data.
#data.stats$Time = seq(1, length(data[,1])) #/(rate*1000) # to s
data.stats$CompTime  = data.stats$CompTime / 1000 # to us
data.stats$Period = data.stats$Period / 1000 # to us
data.stats$Jitter = data.stats$Jitter / 1000 # to us

data.m = melt(data.stats, id.vars='Time')

# Create the plot. 
perfplot = ggplot(data.m, aes(x=Time, y=value, colour=variable)) + 
	geom_point(shape=16,alpha=.1) + 
	facet_wrap( ~ variable, scales="free", ncol=1) + 
	labs(x="Time (s)", y=expression(paste("Time (", mu, "s)"))) + 
	guides(colour=FALSE) #+
#	ggtitle(paste(os, rt_patch, "\n", processor, graphics_card, graphics_driver, "\n", "Recording at", rate, "kHz", sep=" "))

ggsave(filename=outfile, plot=perfplot)
