#! /bin/python

# Requires h5py, seaborn

import h5py as h5
import numpy as np
import pandas as pd
import seaborn as sb
from matplotlib.backends.backend_pdf import PdfPages

filename = "test.h5"
plotname = "test.pdf"
trialnum = 1


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

def getChannelFrame(f, n):
    meta = [ item for item in f["/Trial" + str(n) + "/Synchronous Data"] ]
    headers = [ item.split(" : ")[1] for item in meta[0:3] ]
    data = f["/Trial" + str(n) + "/Synchronous Data/" + str(meta[len(meta)-1])]
    frame = pd.DataFrame(data=np.vstack(data), columns=headers)
    frame["Time (ms)"] = range(0, len(frame))
    return frame

hdf = h5.File(filename, 'r')

getNumTrials(hdf)

period = getPeriod(hdf, trialnum) # in ns
downsampling = getDownsamplingRate(hdf, trialnum)
length = getTrialLength(hdf, trialnum) # in ns
frame = getChannelFrame(hdf, trialnum)
meltyframe = pd.melt(frame, "Time (ms)")

hdf.close()

# gennerate plots
with PdfPages(plotname) as pdf:
#    p = sb.lmplot(x="Time (ms)", y="value", hue="variable", data=meltyframe, size=5, aspect=2, fit_reg=False)
#    pdf.savefig(p.fig)

    for field in meltyframe['variable'].unique():
        p = sb.lmplot(x="Time (ms)", y=field, aspect=2, size=5, data=frame, fit_reg=False)
        pdf.savefig(p.fig)

