#! /usr/bin/env julia

################################################################################
# This script plots all timeseries data from an HDF file. 
#
# Global variables defined below.
################################################################################
using Gadfly
using DataFrames
using HDF5

filename = "2016.02.19.Cell3.1.h5";
trial_num = 1;
num_points = 10000 # maximum number of points to plot

################################################################################
# Open the HDF file and read the data into a DataFrame. 
################################################################################

hdf = h5open(filename, "r");

trial_basestring = string("/Trial", trial_num, "/Synchronous Data/")
trial = hdf[trial_basestring];

period = convert(Float64, read(hdf["/Trial1/Period (ns)"])) # ns
downsampling_rate = convert(Int64, read(hdf["/Trial1/Downsampling Rate"]))
date = read(hdf["/Trial1/Date"])

trial_data = [ read(hdf[string(trial_basestring, elem)]) 
               for elem in names(trial) ];
trial_names = [ split(trial_data[idx], ": ")[2] 
                for idx in 1:length(trial_data)-1 ];
trial_names = convert(Array{Symbol, 1}, trial_names);
trial_data = [ trial_data[end][i][j] 
               for i in 1:length(trial_data[end]), 
                   j in 1:length(trial_data[end][1]) ];

trial_frame = DataFrame(trial_data)
names!(trial_frame, trial_names)

close(hdf)

################################################################################
# Tweak the data as needed.
################################################################################

# If :Time is not already defined, add it to the frame using the period and 
# downsampling rate. 
time_idx = convert(Array{Bool, 1}, [ contains(string(name), "Time") for name in trial_names ])
time_symbol = sub(trial_names, time_idx)[1] # yeah... not the best coding... 

if isempty(time_idx)
	trial_frame[:Time] = collect(1:length(trial_frame[1])) * 
	                     iperiod / downsampling_rate / 1000000000 # ns->s
	time_symbol=symbol("Time (s)")
end

# Downsample the data before it's plotted to reduce the file size and speed up 
# execution. 
factor = ceil(Int, length(trial_frame[1])/num_points)
trial_frame = trial_frame[collect(1:factor:length(trial_frame[1])), :]

# melt() the DataFrame
trial_melt = deepcopy(trial_frame)
trial_melt = melt(trial_melt, time_symbol)

################################################################################
# Generate plots. 
################################################################################

# Plot everything.
p = plot(trial_melt, x=time_symbol, y=:value, color=:variable, Geom.line, 
         Guide.ylabel("Value"), 
         Coord.Cartesian(xmax=maximum(trial_melt[time_symbol]), 
                         xmin=minimum(trial_melt[time_symbol]),
                         ymin=minimum(trial_melt[:value]),
                         ymax=maximum(trial_melt[:value])))

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
#			Guide.xlabel("Time (s)"),
#			Coord.Cartesian(xmax=maximum(frame[:Time]), xmin=245))
