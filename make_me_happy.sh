#! /bin/bash

###############################################################################
# Create a .vimrc so that you don't go insane.
###############################################################################

cd ~/
if [ -f ".vimrc" ]; then
	cp .vimrc .vimrc-$(date +%Y%m%d)
fi
echo "set background=dark
set title
set titlestring=%t
set tabstop=3
set shiftwidth=3
set smarttab
set smartindent
set hlsearch
set incsearch
set showmatch
syntax on" > .vimrc


###############################################################################
# Append a "sl" alias so that you don't go insane. 
###############################################################################

if [ -f ".bashrc" ]; then
	cp .bashrc .bashrc-$(date +%Y%m%d)
fi
echo "alias sl='ls -r'" >> .bashrc
echo "alias happymake='make -j`nproc` && sudo make install'" >> .bashrc


###############################################################################
# Create a .npmrc so that npm won't need root privileges.
###############################################################################

if [ -f ".npmrc" ]; then
	cp .npmrc .npmrc-$(date +%Y%m%d)
fi
echo "prefix = /home/$(whoami)/.npm_modules/" > .npmrc


###############################################################################
# Install RVM so that you can use whatever ruby version you want. 
###############################################################################

if ! [ -d ".rvm" ]; then
	gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
	curl -sSL https://get.rvm.io | bash
fi


###############################################################################
# Install Numix and make it blue.
###############################################################################

sudo apt-get install shimmer-themes gnome-tweak-tool
#sudo find /usr/share/themes/Numix -type f -exec sed -e "s/d64937/4682b4/g" {} +
sudo find ./usr/share/themes/Numix -type f \( -iname '*.svg' -o -iname '*.css' -o -iname '*.scss' \) -exec sed -i "s/#d64937/#4682b4/g" {} \;
# ^- this might break...


###############################################################################
# Make the OS insult you, you masochist.
###############################################################################

sudo bash -c "Defaults insults >> /etc/sudoers" # <- and so the sysadmins weep.
