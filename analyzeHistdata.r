#! /usr/bin/env Rscript

options(warn=-1)

# Edit this to match your system, not mine!
rt_patch = "Xenomai 2.6.3"
processor = "i5-4570"
graphics_card = "AMD HD 8490"
graphics_driver = "Radeon"
os = "Debian 8"
rate = 10 #kHz

data = read.table("histdata.txt", header=F, col.names=c("Latency", "Count"))

if(require(ggplot2)&&require(scales)) {
	print("yay. you have ggplot")
	
	plot = ggplot(data = data, aes(x=Latency, y=Count)) + 
		geom_bar(stat="identity") + 
		scale_y_continuous(trans=log10_trans(), 
			breaks = trans_breaks("log10", function(x) 10^x ),
			labels = trans_format("log10", math_format(10^.x)) ) +
		ggtitle(paste(os, rt_patch, "\n", processor, graphics_card, graphics_driver, "\n", "Running at", rate, "kHz", sep=" ")) + 
		xlab(expression(paste("Latency (", mu, "s)")))

	ggsave(filename="histplot.png", plot=plot)
} else {
	print("Okay. I'll plot the histogram for you, but just know that it'll look better with ggplot")

	png("histplot.png")
	barplot(data$Count, names.arg=data$Latency, xlab="Latency (us)", ylab="Count", log="y")
	dev.off()
}
