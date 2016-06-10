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
    headers = meta[0:3]
    data = f["/Trial" + str(n) + "/Synchronous Data/" + str(meta[len(meta)-1])]
    frame = pd.DataFrame(data=np.vstack(data), columns=headers)
    frame["Time (ms)"] = range(0, len(frame))
    return frame

hdf = h5.File(filename, 'r')

getNumTrials(hdf)
#data = getTrial(hdf, trialnum)

period = getPeriod(hdf, trialnum) # in ns
downsampling = getDownsamplingRate(hdf, trialnum)
length = getTrialLength(hdf, trialnum) # in ns
frame = getChannelFrame(hdf, trialnum)

hdf.close()

# gennerate plots
with PdfPages(plotname) as pdf:
    p = sb.lmplot('Time (ms)', '3 Optical Clamp Protocol 11 : LED Output (V)', data=frame, fit_reg=False)
    pdf.savefig(p.fig)
    p = sb.lmplot('Time (ms)', '2 Optical Clamp Protocol 11 : Voltage Output (V)', data=frame, fit_reg=False)
    pdf.savefig(p.fig)
    p = sb.lmplot('2 Optical Clamp Protocol 11 : Voltage Output (V)', '1 Optical Clamp Protocol 11 : Current Input (A)', data=frame, fit_reg=False)
    pdf.savefig(p.fig)
    p = sb.lmplot('3 Optical Clamp Protocol 11 : LED Output (V)', '1 Optical Clamp Protocol 11 : Current Input (A)', data=frame, fit_reg=False)
    pdf.savefig(p.fig)


