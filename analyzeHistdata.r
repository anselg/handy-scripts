#! /usr/bin/env Rscript

options(warn=-1)
args = commandArgs(trailingOnly = T)


# Check if needed packages are installed. Otherwise, exit. 
if( !(require(ggplot2)&&require(scales)&&require(plyr)) ) {
	print("Look. You really need to install 'ggplot2', 'plyr', and 'scales' to do this.")
}

# Edit this to match your system, not mine!
#rt_patch = "Xenomai 2.6.3"
#processor = "i5-4570"
#graphics_card = "AMD HD 8490"
#graphics_driver = "Radeon"
#os = "Debian 8"
#rate = 10 #kHz

os = as.character(args[1])
hostname = as.character(args[2])
rt_patch = as.character(args[3])
processor = as.character(args[4])
graphics_card = as.character(args[5])
graphics_driver = as.character(args[6])
rate = as.integer(args[7]) # kHz

data.raw = read.table("histdata.txt", header=F, col.names=c("Latency", "Count"))
data.stats = data.raw
data.stats$Count = data.raw$Count - 1

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

# Create function to show probability of losing RT as a function of RT period over 1 hr...
# Plot p(stay in RT) from 1 kHz to 50 kHz
#nperiods = 3600 * rate
data.prob_rt = data.frame("Frequency"=seq(1,50,.01))
data.prob_rt$ProbRT = ddply(data.prob_rt, c("Frequency"), function(x) {
	sum ( data.stats$Latency[data.stats$Latency > 1000/x$Frequency] * 
	      data.stats$Count[data.stats$Latency > 1000/x$Frequency] ) / 
	sum( data.stats$Latency * data.stats$Count ) * x$Frequency * 1000 * 3600
})
# prob( RT | Freq for 1 hr ) = count(latency less than 1/Freq)/count(all latencies) * Freq * 1 hr

plot.hist = ggplot(data = data.hist, aes(x=Latency, y=Count)) + 
	geom_bar(stat="identity") + 
	scale_y_log10(
		breaks = trans_breaks("log10", function(x) 10^x ),
		labels = trans_format("log10", math_format(10^.x)) ) + 
	scale_x_continuous(
		breaks = round(seq(min(data.hist$Latency), max(data.hist$Latency), by = 1), 1) ) +
	ggtitle(paste(hostname, os, "\n", rt_patch, "\n", processor, "\n", graphics_card, "\n", graphics_driver, "\n", "Running at", rate, "kHz", sep=" ")) + 
	xlab(expression(paste("Latency (", mu, "s)"))) 

ggsave(filename="histplot.png", plot=plot.hist)
