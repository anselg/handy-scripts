#! /usr/bin/env julia

using Gadfly
using DataFrames

filename = "2016.02.19.Cell3.1.txt"

data = readcsv(filename);
frame = DataFrame(data)
names!(frame, [:Time, :Voltage, :Beat, :APD, :Target_Current, :Scaled_Current, :Output_Current, :Input_Voltage])
frame[:Time] = frame[:Time] / 1000

downsample = collect(1:500:length(frame[:Time]))
frame = frame[downsample, :]

p = plot(frame[frame[:Time] .>= 249, :], 
         x=:Time, y=:Voltage, Geom.line, 
			Guide.xlabel("Time (s)"), Guide.ylabel("Voltage (mV)"),
			Coord.Cartesian(xmax=maximum(frame[:Time]), xmin=249))

meltframe = deepcopy(frame)
delete!(meltframe, [:Beat, :Target_Current, :Scaled_Current, :Input_Voltage])
meltframe = melt(meltframe, :Time)
p = plot(meltframe[meltframe[:Time] .>= 245, :], 
         x=:Time, y=:value, color=:variable, Geom.line, 
			Guide.xlabel("Time (s)"),
			Coord.Cartesian(xmax=maximum(frame[:Time]), xmin=245))
