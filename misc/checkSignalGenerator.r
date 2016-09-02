#! /usr/bin/env Rscript

require(optparse)

option_list = list(
	make_option(c("--input-file", "-i"), type="character", action="store", dest="infile", default="na",
		help="Give the input filename")
)
options = parse_args(OptionParser(option_list=option_list))

if( options$infile == "na" ) {
	print("Give me a filename!")
	return(1)
}
input_file = options$infile

data = read.table(input_file, sep=",", header=F)

checkSine = function(timeseries) {
#	amplitude = abs(amplitude)
	flag = T
	is_monotonic_increasing = NULL
	if( (timeseries[2]-timeseries[1]) > 0) {
		is_monotonic_increasing = T
	} else {
		is_monotonic_increasing = F
	}
	for( i in 3:length(timeseries) ) {
#		if (!(i %% 1000)) {print(i)}

		if (is_monotonic_increasing) {
			if( timeseries[i] < timeseries[i-1] ) {
				print("Decreased during monotonically increasing section")
				line = c(paste(i, timeseries[i], sep=" "), paste(i-1, timeseries[i-1], sep=" "))
				print(line)
				flag = F
			}
		} else {
			if( timeseries[i] > timeseries[i-1] ) {
				print("Increased during monotonically decreasing section")
				line = ( c(paste(i, timeseries[i], sep=" "), paste(i-1, timeseries[i-1], sep=" ")) )
				print(line)
				flag = F
			}
		}
		
		if (timeseries[i] == max(timeseries)) {
			is_monotonic_increasing = F
		} else if (timeseries[i] == min(timeseries)) {
			is_monotonic_increasing = T
		}
	}
	return(flag)
}

if(checkSine(data[[1]])){
	print("YAYAYAYAYAY")
} else {
	print("FUCK")
}
