#! /bin/bash
set -eu

# Install vim and some plugins to make your life easier. 
sudo apt-get update && sudo apt-get install -y \
  vim vim-ctrlp vim-fugitive vim-latexsuite vim-pathogen vim-scripts \
  vim-ultisnips vim-youcompleteme clang-format-3.8 colordiff vim-conque cream \
  powerline fonts-powerline vim-puppet vim-python-jedi git global doxygen \
  vim-snippets vim-syntastic

# Note: vim-addons relied on system ruby, so if using rvm, be sure to use it.
vim-addons install \
  align alternate ctrlp detectindent doxygen-toolkit fugitive nerd-commenter \
  pathogen powerline surround syntastic tabular latex-suite

# Copy over the vimrc here to your home directory.
[ -f ~/.vimrc ] && mv ~/.vimrc ~/.vimrc-bak
cp vimrc ~/.vimrc
