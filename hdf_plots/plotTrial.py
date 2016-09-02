#! /usr/bin/env python

##########################################################################
# Import modules
##########################################################################

import sys
import os
import h5py as h5
import numpy as np
import pandas as pd
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.pyplot as plt
import operator


##########################################################################
# Parse command-line input; set global parameters
##########################################################################

if (len(sys.argv) == 0):
    print("Give me an hdf file")
    sys.exit()
else:
    filename = sys.argv[1]
    trialnum = int(sys.argv[2])
    plotname = os.path.splitext(filename)[0] + "_trial" + str(trialnum) + ".png"

plt.style.use('ggplot')
np.random.seed(123)


##########################################################################
# Define methods
##########################################################################

def getNumTrials(f):
    ntrials = len(f["/"])
    print("# of Trials:\t", ntrials)
    return ntrials


def getTrial(f, n):
    trialname = "/Trial" + str(n)
    return f[trialname]


def getPeriod(f, n):
    return f["/Trial" + str(n) + "/Period (ns)"].value


def getDownsamplingRate(f, n):
    return f["/Trial" + str(n) + "/Downsampling Rate"].value


def getTrialLength(f, n):
    return f["/Trial" + str(n) + "/Trial Length (ns)"].value


def printChannelNames(f, n):
    meta = [item for item in f["/Trial" + str(n) + "/Synchronous Data"]]
    headers = [item.split(" : ")[1] for item in meta[0:len(meta) - 1]]
    idx = 0
    for header in headers:
        print(str(idx) + ". " + str(header))
        idx += 1
    return


def getChannelFrame(f, n):
    meta = [item for item in f["/Trial" + str(n) + "/Synchronous Data"]]
    raw_headers = [item.split(" : ")[1] for item in meta[0:len(meta) - 1]]
    num_headers = [int(item.split(" ")[0]) for item in meta[0:len(meta) - 1]]
    dict_headers = dict(zip(num_headers, raw_headers))
    sorted_headers = sorted(dict_headers.items(), key=operator.itemgetter(0))
    headers = [value for key, value in sorted_headers]
    data = f["/Trial" + str(n) + "/Synchronous Data/" +
             str(meta[len(meta) - 1])]
    frame = pd.DataFrame(data=np.vstack(data), columns=headers)
    return frame


##########################################################################
# Process data
##########################################################################

hdf = h5.File(os.path.join(os.path.dirname(__file__), filename), 'r')
#ntrials = int(getNumTrials(hdf))

#trialnum = int(raw_input("There are " +  str(ntrials) + " trial(s). Pick one and ENTER: "))

# if not ( trialnum <= ntrials and trialnum > 0):
#    print("Invalid input\n")
#    sys.exit()

#plotname = os.path.splitext(filename)[0] + "_trial" + str(trialnum) + ".png"

period = getPeriod(hdf, trialnum) / 1e6  # ns -> ms
frequency = 1 / period  # kHz
downsampling = getDownsamplingRate(hdf, trialnum)

frame = getChannelFrame(hdf, trialnum)
frame["Time (s)"] = np.arange(0, len(frame)) * float(period) / 1000  # ms -> s

hdf.close()


##########################################################################
# Generate plot
##########################################################################

fig = plt.figure()
frame.plot(subplots=True, x="Time (s)")
plt.tight_layout()
plt.savefig(plotname, dpi=300)
plt.close()
