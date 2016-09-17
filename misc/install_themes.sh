#! /bin/bash
set -e

sudo apt-get -y install \
  nodejs npm automake libgtk-3-dev gnome-themes-standard ruby ruby-sass \
  ruby-bundler inkscape

if ! [ -f /use/bin/node ]; 
  then sudo ln -s /usr/bin/nodejs /usr/bin/node
fi

sudo npm -g install gulp

# install arc theme
git clone https://github.com/horst3180/arc-theme
cd arc-theme
npm install && ./autogen.sh --prefix=/usr && gulp && make && sudo make install
cd ../

# install adampta theme
git clone https://github.com/tista500/adapta
cd adapta
./autogen-sh && make -j`nproc` && sudo make install
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
