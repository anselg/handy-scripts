#! /usr/bin/env python

# Why the FUCK does anyone abuse spaces in such an unconscionable manner?! Fuck! AAAAAHHHHH.
# Ahem, ... 
# Back to work. 

import sys

num_tabs = 0;

f = open(sys.argv[1], "r")
data = f.read()
f.close()
data = data.split("\n");
for i in range(0, len(data)):
	data[i] = data[i].strip()
newdata = []
indent_flag = False

for i in range(0, len(data)):
	newline = ""
	if (data[i] == "}"):
		for j in range(0, num_tabs-1):
			newline = "\t" + newline
		newline = newline + data[i]
		newdata.append(newline)
	elif indent_flag == True:
		for j in range(0, num_tabs+1):
			newline = "\t" + newline
		newline = newline + data[i]
		newdata.append(newline)
		indent_flag = False
	else:
		for j in range(0, num_tabs):
			newline = "\t" + newline
		newline = newline + data[i]
		newdata.append(newline)

	for j in range(0, len(data[i])):
		if data[i][j] == "{":
			num_tabs+=1
		elif data[i][j] == "}":
			num_tabs-=1;
		if num_tabs < 0:
			print("What the FUCK? ", num_tabs)

	if ((data[i][0:3] == "for")|(data[i][0:2] == "if")) & ~("{" in data[i]):
		indent_flag = True

f = open("outfile.cpp", "w")
for i in range(0, len(newdata)):
	f.write(newdata[i])
	f.write("\n")
f.close()
