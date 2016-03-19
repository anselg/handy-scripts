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
trial_names = convert(Array{Symbol, 1}, trial_names);
trial_data = [ trial_data[end][i][j] 
               for i in 1:length(trial_data[end]), 
                   j in 1:length(trial_data[end][1]) ];

trial_frame = DataFrame(trial_data);
names!(trial_frame, trial_names);

close(hdf);

################################################################################
# Tweak the data as needed.
################################################################################

# If :Time is not already defined, add it to the frame using the period and 
# downsampling rate. 
time_idx = convert(Array{Bool, 1}, 
                   [contains(string(name), "Time") for name in trial_names ]);
time_symbol = sub(trial_names, time_idx)[1]; # yeah... not the best coding... 

if isempty(time_idx)
	trial_frame[:Time] = collect(1:length(trial_frame[1])) * 
	                     period / downsampling_rate / 1000000000; # ns->s
	time_symbol=symbol("Time (s)");
else 
	# Current protocols pace 500 beats at 500ms BCL before starting. 
	trial_frame = trial_frame[trial_frame[time_symbol] .>= 250000, :]
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

s = Cairo.CairoPDFSurface(plotname, 720.0, 300.0);
c = Cairo.CairoContext(s);
b = Compose.CAIROSURFACE(s);

# Plot everything.
p = plot(trial_melt, x=time_symbol, y=:value, color=:variable, Geom.line, 
         Guide.ylabel("Value"), 
         Coord.Cartesian(xmax=maximum(trial_melt[time_symbol]), 
                         xmin=minimum(trial_melt[time_symbol]),
                         ymin=minimum(trial_melt[:value]),
                         ymax=maximum(trial_melt[:value])));
draw(b, p);
b.finished = false;
Cairo.show_page(c);

# Plot each variable against time in individual plots. Using levels from 
# trial_melt instead of names(trial_frame) prevents plotting time against time. 
for level in levels(trial_melt[:variable])
	p = plot(trial_frame, x=time_symbol, y=level, Geom.line,
	         Coord.Cartesian(xmax=maximum(trial_frame[time_symbol]), 
	                         xmin=minimum(trial_frame[time_symbol]),
	                         ymin=minimum(trial_frame[level]),
	                         ymax=maximum(trial_frame[level])));
#	display(p)
	draw(b, p);
	b.finished = false;
	Cairo.show_page(c);
end

Cairo.finish(s)

################################################################################
# Old junk code.
################################################################################

#p = plot(frame[frame[:Time] .>= 249, :], 
#         x=:Time, y=:Voltage, Geom.line, 
#         Guide.xlabel("Time (s)"), Guide.ylabel("Voltage (mV)"),
#         Coord.Cartesian(xmax=maximum(frame[:Time]), xmin=249))

#meltframe = deepcopy(frame)
#delete!(meltframe, [:Beat, :Target_Current, :Scaled_Current, :Input_Voltage])
#meltframe = melt(meltframe, :Time)
#p = plot(meltframe[meltframe[:Time] .>= 245, :], 
#         x=:Time, y=:value, color=:variable, Geom.line, 
#         Guide.xlabel("Time (s)"),
#         Coord.Cartesian(xmax=maximum(frame[:Time]), xmin=245))
