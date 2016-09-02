#! /usr/bin/env julia

################################################################################
# This script plots all timeseries data from an HDF file. 
#
# Parse command line arguments. 
################################################################################
using ArgParse

s = ArgParseSettings()
@add_arg_table s begin
	"--hdf-file", "-i"
		help = "HDF file from RTXI"
		required = true
	"--trial-num", "-t"
		help = "Trial number"
		arg_type = Int
		default = 0
	"--num-points", "-n"
		help = "Max. number of points per plot"
		arg_type = Int
		default = 100000
end

parsed_args = parse_args(ARGS,s)

################################################################################
# Load remaining modules and define global variables.
################################################################################
using Gadfly
using DataFrames
using HDF5
using Cairo
using Fontconfig

filename = parsed_args["hdf-file"]
plotname = replace(filename, ".h5", ".pdf")
#plotname = replace(filename, ".h5", ".png")

trial_num = parsed_args["trial-num"]
num_points = parsed_args["num-points"]

################################################################################
# Open the HDF file and read the data into a DataFrame. 
################################################################################

hdf = h5open(filename, "r");

trial_basestring = string("/Trial", trial_num, "/Synchronous Data/");
trial = hdf[trial_basestring];

period = convert(Float64, read(hdf["/Trial1/Period (ns)"])); # ns
downsampling_rate = convert(Int64, read(hdf["/Trial1/Downsampling Rate"]));
date = read(hdf["/Trial1/Date"]);

trial_data = [ read(hdf[string(trial_basestring, elem)]) 
               for elem in names(trial) ];
trial_names = [ split(trial_data[idx], ": ")[2] 
                for idx in 1:length(trial_data)-1 ];

# Change units from ns to μs. 
comp_time_idx = find(trial_names .== "Comp Time (ns)")[1]
rt_period_idx = find(trial_names .== "Real-time Period (ns)")[1]
rt_jitter_idx = find(trial_names .== "RT Jitter (ns)")[1]
trial_names[comp_time_idx] = "Comp Time (μs)"
trial_names[rt_period_idx] = "Real-time Period (μs)"
trial_names[rt_jitter_idx] = "RT Jitter (μs)"

# Convert data from ns to μs.
trial_data = [ trial_data[end][i][j] ./ 1000 
               for i in 1:length(trial_data[end]), 
                   j in [comp_time_idx, rt_period_idx, rt_jitter_idx] ];

trial_frame = DataFrame(trial_data);
names!(trial_frame, convert(Array{Symbol, 1}, trial_names));

close(hdf);

################################################################################
# Tweak the data as needed.
################################################################################

# Add time in s or min. 
if(length(trial_frame[1])*period/downsampling_rate/1000000000 < 3) # ns->s
	trial_frame[symbol("Time (s)")] = collect(1:length(trial_frame[1])) * 
	                                  period / downsampling_rate / 1000000000; 
	time_symbol=symbol("Time (s)");
else
	trial_frame[symbol("Time (min)")] = collect(1:length(trial_frame[1])) / 60 *
	                                    period / downsampling_rate / 1000000000;
	time_symbol=symbol("Time (min)");
end
												 
# Downsample the data before it's plotted to reduce the file size and speed up 
# execution. 
factor = ceil(Int, length(trial_frame[1])/num_points);
trial_frame = trial_frame[collect(1:factor:length(trial_frame[1])), :];

# melt() the DataFrame
trial_melt = deepcopy(trial_frame);
trial_melt = melt(trial_melt, time_symbol);

################################################################################
# Generate plots. 
################################################################################

#s = Cairo.CairoPDFSurface(plotname, 720.0, 300.0);
#c = Cairo.CairoContext(s);
#b = Compose.CAIROSURFACE(s);

# Plot each variable against time in individual plots. Using levels from 
# trial_melt instead of names(trial_frame) prevents plotting time against time. 
#for level in levels(trial_melt[:variable])
#	p = plot(trial_frame, x=time_symbol, y=level, Geom.point,
#	         Theme(lowlight_opacity=.1),
#	         Coord.Cartesian(xmax=maximum(trial_frame[time_symbol]), 
#	                         xmin=minimum(trial_frame[time_symbol]),
#	                         ymin=minimum(trial_frame[level]),
#	                         ymax=maximum(trial_frame[level])));
#	display(p)
#	draw(b, p);
#	b.finished = false;
#	Cairo.show_page(c);
#end

#Cairo.finish(s)

p = plot(trial_melt, ygroup=:variable, x=time_symbol, y=:value, 
         Geom.subplot_grid(Geom.point, free_y_axis=true, free_x_axis=true), 
         Scale.x_continuous(minvalue=0, 
                            maxvalue=maximum(trial_melt[time_symbol])));
draw(PDF(plotname, 24cm, 30cm), p);

