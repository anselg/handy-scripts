#! /usr/bin/env python

# Requires h5py, seaborn

import h5py as h5
import numpy as np
import pandas as pd
import seaborn as sb
from matplotlib.backends.backend_pdf import PdfPages
import statsmodels.formula.api as sm

filename = "optical-calibrate.h5"
plotname = "optical-calibrate.pdf"
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
	
def simStupidCell(cin):
	absMaxC = 5
	a1 = -10
	a2 = 0
	b1 = 1
	b2 = 1.24
	#print min(cin["Voltage Output (V)"])
	#return ((a1*cin["Voltage Output (V)"] + a2) / (a1*min(cin["Voltage Output (V)"]) + a2))
	return ((a1*cin["Voltage Output (V)"] + a2) / (a1*min(cin["Voltage Output (V)"]) + a2)) * b1*(1-np.exp(-cin["LED Output (V)"]/b2))

hdf = h5.File(filename, 'r')

getNumTrials(hdf)

period = getPeriod(hdf, trialnum) # in ns
downsampling = getDownsamplingRate(hdf, trialnum)
length = getTrialLength(hdf, trialnum) # in ns
frame = getChannelFrame(hdf, trialnum)
frame["Sim. Current Input (A)"] = simStupidCell(frame)
meltyframe = pd.melt(frame, "Time (ms)")

hdf.close()

ledmax = max(frame["LED Output (V)"])
ledmin = min(frame["LED Output (V)"])
vmax = max(frame["Voltage Output (V)"])
vmin = min(frame["Voltage Output (V)"])
cmax = max(frame["Current Input (A)"])
cmin = min(frame["Current Input (A)"])

vdepends = frame.loc[ frame["LED Output (V)"] == ledmax, : ]
vdepends["Ones"] = np.ones(len(vdepends))
lm = sm.OLS(vdepends["Sim. Current Input (A)"], vdepends[["Voltage Output (V)", "Ones"]]).fit()
ldepends = frame.loc[ frame["LED Output (V)"] > 0.0, : ]
ldepends["Adj. Current Input (A)"] = ldepends["Sim. Current Input (A)"] / ( (lm.params[0]*ldepends["Voltage Output (V)"]+lm.params[1])/(lm.params[0]*min(vdepends["Voltage Output (V)"])+lm.params[1]) )
ldepends["Log Adj. Current Input (A)"] = (np.log(1-ldepends["Adj. Current Input (A)"]))
ldepends["Log LED Output (V)"] = (np.log(1-ldepends["LED Output (V)"]))
ldepends["Ones"] = np.ones(len(ldepends))
lm = sm.OLS(ldepends["Log Adj. Current Input (A)"], ldepends[["LED Output (V)", "Ones"]]).fit()
1/lm.params[0]

# gennerate plots
with PdfPages(plotname) as pdf:
    p = sb.lmplot(x="Voltage Output (V)", y="Sim. Current Input (A)", data=vdepends, size=5, aspect=2, fit_reg=True)
    pdf.savefig(p.fig)

    p = sb.lmplot(x="LED Output (V)", y="Sim. Current Input (A)", data=ldepends, size=5, aspect=2, fit_reg=True)
    pdf.savefig(p.fig)

    p = sb.lmplot(x="LED Output (V)", y="Adj. Current Input (A)", data=ldepends, size=5, aspect=2, fit_reg=True)
    pdf.savefig(p.fig)

    p = sb.lmplot(x="LED Output (V)", y="Log Adj. Current Input (A)", data=ldepends, size=5, aspect=2, fit_reg=True)
    pdf.savefig(p.fig)

#    p = sb.lmplot(x="Log LED Output (V)", y="Adj. Current Input (A)", data=ldepends, size=5, aspect=2, fit_reg=True)
#    pdf.savefig(p.fig)

#    p = sb.lmplot(x="Log LED Output (V)", y="Log Adj. Current Input (A)", data=ldepends, size=5, aspect=2, fit_reg=True)
#    pdf.savefig(p.fig)

#    for field in meltyframe['variable'].unique():
#        p = sb.lmplot(x="Time (ms)", y=field, aspect=2, size=5, data=frame, fit_reg=False)
#        pdf.savefig(p.fig)


