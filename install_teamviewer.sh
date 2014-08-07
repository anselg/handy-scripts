#! /bin/bash

sudo apt-get -y install gdebi
wget http://www.teamviewer.com/download/teamviewer_linux.deb
sudo gdebi -y teamviewer_linux.deb
