#! /bin/bash

sudo apt-get -y install nodejs npm automake libgtk-3-dev gnome-themes-standard \
	ruby ruby-sass

if ! [ -f /bin/node ]; then sudo ln -s /bin/nodejs /bin/node; fi

sudo npm -g install gulp

# install arc theme
git clone https://github.com/horst3180/arc-theme
cd arc-theme
npm install && ./autogen.sh --prefix=/usr && gulp && make && sudo make install
cd ../

# install numix theme (git)
git clone https://github.com/numixproject/numix-gtk-theme numix-theme
cd numix-theme
make && sudo make install
cd ../

# set a theme
gsettings set org.gnome.desktop.interface gtk-theme "Arc"
gsettings set org.gnome.desktop.wm.preferences theme "Arc"

#gsettings set org.cinnamon.desktop.interface gtk-theme "Arc"
#gsettings set org.cinnamon.desktop.interface gtk-theme "Arc"
#gsettings set org.cinnamon.theme theme "Arc" ???
