#! /bin/bash
set -e

# install numix icons and set folder color

echo "6
custom
3FD59F
2EAF81
2E3436" > ~/.config/numix-folders

git clone https://github.com/numixproject/numix-icon-theme
git clone https://github.com/numixproject/numix-icon-theme-circle
git clone https://github.com/numixproject/numix-icon-theme-square
git clone https://github.com/numixproject/numix-folders

sudo rsync -Prad numix-icon-theme/Numix/ /usr/share/icons/Numix
sudo rsync -Prad numix-icon-theme-circle/Numix-Circle/ /usr/share/icons/Numix-Circle
sudo rsync -Prad numix-icon-theme-square/Numix-Square/ /usr/share/icons/Numix-Square
sudo ./numix-folders/numix-folders

sudo sed -i 's/PUBLICSHARE/#PUBLICSHARE/g' /etc/xdg/user-dirs.defaults
sudo sed -i 's/TEMPLATE/#TEMPLATE/g' /etc/xdg/user-dirs.defaults
rm -rf ~/Public
rm -rf ~/Templates

mkdir -p ~/Projects
mkdir -p ~/Sync
gvfs-set-attribute ~/Projects/ -t string metadata::custom-icon-name folder-projects
gvfs-set-attribute ~/Sync/ -t string metadata::custom-icon-name folder-cloud

#gsettings set org.gnome.desktop.interface icon-theme "Numix-Circle"
#gsettings set org.cinnamon.desktop.interface icon-theme "Numix-Circle"
