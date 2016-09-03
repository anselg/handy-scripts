#! /usr/bin/env python

##########################################################################
# Import modules
##########################################################################

import sys
import os
import re
import h5py as h5
import numpy as np
import pandas as pd
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.pyplot as plt
import operator
import subprocess


##########################################################################
# Parse command-line input; set global parameters
##########################################################################

if (len(sys.argv) == 0):
    print("Give me an hdf file")
    sys.exit()
else:
    filename = sys.argv[1]
    trialnum = int(sys.argv[2])
    plotname = os.path.splitext(filename)[0] + ".png"

plt.style.use('ggplot')
np.random.seed(123)


##########################################################################
# Define methods
##########################################################################

def runShellCommand(command):
    output = subprocess.Popen(
        command,
        shell=True,
        stdout=subprocess.PIPE).stdout.read().strip().decode()
    return output


def getCpu():
    command = "cat /proc/cpuinfo"
    text = runShellCommand(command).split('\n')
    procline = [line for line in text if re.search("model name", line)][0]
    return procline.split(":")[1].strip()


def getGpu():
    command = "lshw -numeric -C display"
    text = runShellCommand(command).split('\n')
    product = [line for line in text if re.search("product", line)]
    vendor = [line for line in text if re.search("vendor", line)]
    driver = [line for line in text if re.search("driver", line)]
    if product and vendor and driver:
        product = product[0].split("product:")[1].strip()
        vendor = vendor[0].split("vendor:")[1].strip()
        driver = driver[0].split("configuration:")[1].strip().split(" ")[
            0].split("=")[1].strip()
        return vendor, product, driver
    else:
        return "GPU vendor not found", "GPU model not found", "GPU driver not found"


def getDaq():
    command = "lspci"
    text = runShellCommand(command).split('\n')
    daqline = [line for line in text if re.search("National", line)]
    if daqline:
        daqline = daqline[0]
        return daqline.split(":")[2].strip()
    else:
        return "DAQ not found"


def getDistro():
    command = "echo $(lsb_release -is) $(lsb_release -rs)"
    return runShellCommand(command)


def getKernel():
    command = "uname -r"
    return runShellCommand(command)


def getHostname():
    command = "uname -n"
    return runShellCommand(command)


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


def getChannelIndices(f, n):
    meta = [item for item in f["/Trial" + str(n) + "/Synchronous Data"]]
    raw_headers = [item for item in meta[0:len(meta) - 1]]
    num_headers = [int(item.split(" ")[0]) for item in meta[0:len(meta) - 1]]
    dict_headers = dict(zip(num_headers, raw_headers))
    sorted_headers = sorted(dict_headers.items(), key=operator.itemgetter(0))
    headers = [value for key, value in sorted_headers]
    ct_idx = [headers.index(channel) for channel in headers if re.match(
        r".*Performance Measurement.*Comp Time.*", channel)][0]
    pe_idx = [headers.index(channel) for channel in headers if re.match(
        r".*Performance Measurement.*Real-time Period.*", channel)][0]
    jt_idx = [headers.index(channel) for channel in headers if re.match(
        r".*Performance Measurement.*Jitter.*", channel)][0]
    return ct_idx, pe_idx, jt_idx


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

plotname = os.path.splitext(filename)[0] + "_trial" + str(trialnum) + ".png"

period = getPeriod(hdf, trialnum) / 1e6  # ns -> ms
frequency = 1 / period  # kHz
downsampling = getDownsamplingRate(hdf, trialnum)

[ct_idx, pe_idx, jt_idx] = getChannelIndices(hdf, trialnum)
frame = getChannelFrame(hdf, trialnum).iloc[:, [ct_idx, pe_idx, jt_idx]]
frame["Time (s)"] = np.arange(0, len(frame)) * float(period) / 1000  # ms -> s
frame = frame.rename(
    index=str,
    columns={
        "Comp Time (ns)": "Comp Time (us)",
        "Real-time Period (ns)": "Real-time Period (us)",
        "RT Jitter (ns)": "RT Jitter (us)"})
frame["Comp Time (us)"] = frame["Comp Time (us)"] / 1000
frame["Real-time Period (us)"] = frame["Real-time Period (us)"] / 1000
frame["RT Jitter (us)"] = frame["RT Jitter (us)"] / 1000

hdf.close()


##########################################################################
# Generate table
##########################################################################

cpu = getCpu()
daq = getDaq()
hostname = getHostname()
distro = getDistro()
kernel = getKernel()
vendor, model, driver = getGpu()

col1 = [
    "Computer",
    "Kernel",
    "CPU",
    "GPU Vendor",
    "GPU Model",
    "GPU Driver",
    "DAQ",
    "RT Freq"]
col2 = [
    hostname + " (" + distro + ")",
    kernel,
    cpu,
    vendor,
    model,
    driver,
    daq,
    str(frequency) + " kHz"]
col2 = [[value] for value in col2]


##########################################################################
# Generate plot
##########################################################################

f, ax = plt.subplots(4, sharex=True, figsize=(8.5, 11),
                     gridspec_kw={'height_ratios': [.7, 1, 1, 1]})
ax[0].axis('off')
table = ax[0].table(cellText=col2, rowLabels=col1, loc='center',
                    colWidths=[.8], colLoc='right', bbox=[.1, 0, .85, 1])
frame.plot(ax=ax[1], kind="scatter", x='Time (s)',
           y='Comp Time (us)', alpha=.2, marker=".", edgecolor='none')
ax[1].set_ylabel("Comp Time (us)")
frame.plot(ax=ax[2], kind="scatter", x='Time (s)',
           y='Real-time Period (us)', alpha=.2, marker=".",
           edgecolor='none')
ax[2].set_ylabel("Real-time Period (us)")
frame.plot(ax=ax[3], kind="scatter", x='Time (s)',
           y='RT Jitter (us)', alpha=.2, marker=".", edgecolor='none')
ax[3].set_ylabel("RT Jitter (us)")
ax[3].set_xlabel("Time (s)")
f.tight_layout()
plt.savefig(plotname, dpi=80)
plt.close()
