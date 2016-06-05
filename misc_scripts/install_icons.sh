#! /bin/bash

# install numix icons and set folder color

echo "6
custom
3FD59F
2EAF81
2E3436" > ~/.config/numix-folders

git clone https://github.com/numixproject/numix-icon-theme
git clone https://github.com/numixproject/numix-icon-theme-circle
git clone https://github.com/numixproject/numix-folders

sudo rsync -Prad numix-icon-theme/Numix /usr/share/icons/Numix
sudo rsync -Prad numix-icon-theme-circle/Numix-Circle /usr/share/icons/Numix-Cirlce
sudo ./numix-folders/numix-folders


