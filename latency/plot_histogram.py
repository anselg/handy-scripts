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
    plotname = os.path.splitext(filename)[0] + ".svg"

plt.style.use('ggplot')


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


def unwrapHistogram(f):
    f["Count"] = f["Count"] - 1
    latencies = []
    for idx, row in f.iterrows():
        latencies.extend([row["Latency (us)"]] * int(row["Count"]))
    df = pd.DataFrame(latencies, columns=["Latency (us)"])
    return df


##########################################################################
# Process data
##########################################################################

#filename = "test_rt_histdata_4.1.18_30min.txt"

raw_data = pd.read_csv(
    filename,
    sep=" ",
    comment="#",
    names=[
        "Latency (us)",
        "Count"])
data = unwrapHistogram(raw_data.copy(deep=True))


##########################################################################
# Generate table
##########################################################################

cpu = getCpu()
daq = getDaq()
hostname = getHostname()
distro = getDistro()
kernel = getKernel()
vendor, model, driver = getGpu()
frequency = 10.0

col1 = ["Computer", "Kernel", "CPU", "GPU Vendor", "GPU Model", "GPU Driver", "RT Freq"]
col2 = [
    hostname + " (" + distro + ")",
    kernel,
    cpu,
    vendor, 
    model,
    driver,
    str(frequency) + " kHz"]


##########################################################################
# Generate plot
##########################################################################

f, ax = plt.subplots(2, gridspec_kw={'height_ratios': [1, 2.5]}, figsize=(8, 8))
ax[0].axis('tight')
ax[0].axis('off')
table = ax[0].table(cellText=np.transpose(
    np.vstack([col1, col2])), loc='center')
celld = table.get_celld()
[celld[x, y].set_width(.10) for x, y in celld if y == 0]
[celld[x, y].set_width(.40) for x, y in celld if y == 1]
table.scale(1.5, 1.5)
data.hist("Latency (us)", bins=50, ax=ax[1])
ax[1].set_title("")
ax[1].set_yscale('log')
ax[1].set_ylabel('Count')
ax[1].set_xlabel('Latency (us)')
plt.tight_layout()
plt.savefig(plotname, dpi=300)
plt.close()
