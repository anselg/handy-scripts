#! /bin/bash
set -eu

# Install zsh and use antigen (needs work) to set up a zsh theme.
sudo apt-get install zsh zsh-antigen

# Copy over the zshrc here to your home directory.
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc-bak
cp zshrc ~/.zshrc

# Set zsh to be the default shell.
chsh -s /bin/zsh
