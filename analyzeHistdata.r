#! /usr/bin/env Rscript

options(warn=-1)

# Check if needed packages are installed. Otherwise, exit. 
if( !(require(ggplot2)&&require(scales)) ) {
	print("Look. You really need to install 'ggplot2' and 'scales' to do this.")
}

# Edit this to match your system, not mine!
rt_patch = "Xenomai 2.6.3"
processor = "i5-4570"
graphics_card = "AMD HD 8490"
graphics_driver = "Radeon"
os = "Debian 8"
rate = 10 #kHz

data.raw = read.table("histdata.txt", header=F, col.names=c("Latency", "Count"))
data.stats = data.raw
data.stats$Count = data.raw$Count - 1

#data.long = c()
#for ( stats_idx in 1:length(data.stats$Count) ) {
#	data.long = c(data.long, rep(data.stats$Latency[stats_idx], data.stats$Count[stats_idx]))
#}
#data.long = data.frame(Latency=data.long)

# Put stats into bin_size ns bins. 
bin_size = 200 # bins are to make the histogram look better
data.hist = data.frame( Latency = seq( 0, max(data.stats$Latency) * 
                                       1000 + bin_size, bin_size ) ) / 1000
data.hist$Count = rep( 0, length(data.hist$Latency) )
hist_idx = 1
for ( stats_idx in 1:length(data.stats$Latency) ) {
	if ( data.stats$Latency[stats_idx] < data.hist$Latency[hist_idx] ) {
		data.hist$Count[hist_idx] = data.hist$Count[hist_idx] + data.stats$Count[stats_idx]
	} else {
		hist_idx = hist_idx + 1
		data.hist$Count[hist_idx] = data.hist$Count[hist_idx] + data.stats$Count[stats_idx]
	}
}
data.hist$Count = data.hist$Count + 1

plot.hist = ggplot(data = data.hist, aes(x=Latency, y=Count)) + 
	geom_bar(stat="identity") + 
	scale_y_log10(
		breaks = trans_breaks("log10", function(x) 10^x ),
		labels = trans_format("log10", math_format(10^.x)) ) + 
	scale_x_continuous(
		breaks = round(seq(min(data.hist$Latency), max(data.hist$Latency), by = 1), 1) ) +
	ggtitle(paste(os, rt_patch, "\n", processor, graphics_card, graphics_driver, "\n", 
	              "Running at", rate, "kHz", sep=" ")) + 
	xlab(expression(paste("Latency (", mu, "s)"))) 

#plot.box = ggplot(data = data.long[data.long$Latency < 1.5], aes(x="",y=Latency)) + 
	geom_boxplot()

#plot.all = multiplot(plotlist = c(plot.hist, plot.box), cols=2)

ggsave(filename="histplot.png", plot=plot.hist)
#ggsave(filename="histplot.png", plot=plot.box)
