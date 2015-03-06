#
# The Real-Time eXperiment Interface (RTXI)
# Copyright (C) 2011 Georgia Institute of Technology, University of Utah, Weill Cornell Medical College
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Created by Yogi Patel <yapatel@gatech.edu> 2014.1.31
#

#!/bin/bash

# Check to see if inxi, R, and stress are installed
echo "----->Checking for dependencies needed to run stress test."
if ! $(dpkg-query -Wf'${db:Status-abbrev}' "inxi" 2>/dev/null | grep -q '^i'); 
	then sudo apt-get -y install inxi
fi
if ! $(dpkg-query -Wf'${db:Status-abbrev}' "stress" 2>/dev/null | grep -q '^i'); 
	then sudo apt-get -y install stress
fi
if ! $(dpkg-query -Wf'${db:Status-abbrev}' "r-base" 2>/dev/null | grep -q '^i'); 
	then sudo apt-get -y install r-base
fi
echo ""

echo "----->Running latency test under load. Please wait 30 minutes."
echo "----->Do not interrupt."
echo "----->If you do interrupt, stop stressing the system by running:"
echo "      $ pkill stress"

# Get system information
DISTRO_NAME=`lsb_release -is`
DISTRO_VERSION=`lsb_release -rs`
RT_KERNEL=`uname -r`
HOSTNAME=`uname -n`
RATE_KHZ=10
PROCESSOR=$(cat /proc/cpuinfo | grep "model name" | uniq | cut -d":" -f2 | \
            sed 's/ \+/ /g' | sed -e 's/^\  *//' -e 's/\ *$//')
GRAPHICS_CARD=$(lspci | grep VGA | uniq | cut -d":" -f3 | \
                sed 's/ \+/ /g' | sed -e 's/^\  *//' -e 's/\ *$//')
GRAPHICS_DRIVER=$(lshw -c display | grep configuration | cut -d":" -f2 | cut -d"=" -f2 | cut -d" " -f1 | sed 's/ \+/ /g' | sed -e 's/^\  *//' -e 's/\ *$//')

echo $PROCESSOR
echo $GRAPHICS_CARD
echo $GRAPHICS_DRIVER

# Run latency test under dynamic load
#stress --cpu 2 --vm 1 --hdd 1 --timeout 1800 & 
sudo /usr/xenomai/bin/./latency -s -h -p 100 -B 1 -H 200000 -T 10 -g histdata.txt | tee test_rt_kernel.log

# Check if R is installed
hash Rscript 2>/dev/null || { echo >&2 "R is needed for me to plot stats.\nYou can always do that yourself, too."; exit 0; }

Rscript analyzeHistdata.r

exit 0
