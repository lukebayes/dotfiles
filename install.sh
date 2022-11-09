#!/bin/bash

set -io pipefail

SOURCEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# To run this script:
# Fetch the shell script and run it.

# TODO validate required binaries
# git-core
# python
# python-pip

echo "Running installation from $SOURCEDIR for $HOME"

cd $HOME
force=""
skipapt=false
skipvim=false

# Show help message
show_help() {
  cat << EOF

Usage: ${0##*/} [-force --help --skip-vim]
Configure a home directory for development.

  -f|--force      Force or overwrite existing files and directories
  --skip-vim      Skip vim configuration
  -h|--help       Show this message
EOF
}

# Process command line options
while [ $# -gt 0 ]; do
  case $1 in
    -f|--force)   force="-f";       shift  ;;
    --skip-vim)   skipvim=true;     shift  ;;
    -h|--help)    show_help;        exit 0 ;;
    *)            show_help;        exit 1 ;;
  esac
done

echo "Creating dotfiles directory at $SOURCEDIR"
mkdir -p $SOURCEDIR

if [$HOME == $SOURCEDIR ]; then
  >&2 echo "Cannot run install script from $HOME"
  exit 1
fi

echo "Creating symlinks to $HOME from $SOURCEDIR"

# Copy all files in dotfiles/home/* to $HOME/.[filename]
for file in $SOURCEDIR/home/*
do
  echo "ln $force -s $file \"$HOME/.${file##*/}\""
  ln $force -s $file "$HOME/.${file##*/}"
done

# Download Powerline Fonts
# TODO: Download into a specific location and copy wherever they're needed
# wget https://github.com/lukebayes/powerline/raw/develop/font/PowerlineSymbols.otf \
# https://github.com/lukebayes/powerline/raw/develop/font/10-powerline-symbols.conf

# Upgrade Python package manager
# sudo pip install -U pip
# Install Powerline using pip
# sudo pip install --user powerline-status
# mkdir -p $HOME/.config/powerline

if [ ! -e $HOME/src/solarized-dir ]; then
  # Fetch the Solarized directory theme
  git clone https://github.com/seebi/dircolors-solarized.git $HOME/src/solarized-dir || true
fi

# Install the Solarized directory theme
ln -fs $HOME/src/solarized-dir/dircolors.256dark $HOME/.dircolors

echo "Preparing to install for $(uname -s)"

if [ $(uname -s) == 'Darwin' ]; then
  # TODO: Install Powerline fonts for OS X
  echo 'Installing Darwin only features'
  mv $HOME/.bashrc $HOME/.bash_profile

  brew install fontforge --with-python

  mkdir -p $HOME/.local/src
  git clone https://github.com/Lokaltog/powerline-fontpatcher.git $HOME/.local/src/powerline-fontpatcher
  pushd $HOME/.local/src/powerline-fontpatcher
  python setup.py install
  popd
  export powerline_symbols=$HOME/.local/src/powerline-fontpatcher/fonts/powerline-symbols.sfd

  # Download and unpack Adobe SourceCodePro font
  pushd $HOME/.local/src
  wget -O SourceCodePro.zip https://www.google.com/fonts/download?kit=5CnRSlG29fo96WRM6evqx3XmVIqD4Rma_X5NukQ7EX0
  unzip SourceCodePro.zip -d SourceCodePro

  # Patch the SourceCodePro font with powerline fontpatcher
  pushd SourceCodePro
  find . -name "SourceCodePro-*.ttf" -exec powerline-fontpatcher --source-font=$powerline_symbols --no-rename {} \;
  mv *.ttf /Library/Fonts
  popd

  # Get back to $HOME
  rm -rf $HOME/.local/src/SourceCodePro
  popd

  # Adobe fonts are no longer available on Sourceforge
  # wget http://sourceforge.net/projects/sourcecodepro.adobe/files/SourceCodePro_FontsOnly-1.017.zip
  # unzip SourceCodePro_FontsOnly-1.017.zip
  # find SourceCodePro_FontsOnly-1.017/TTF -name \*.ttf -exec powerline-fontpatcher --source-font=$powerline_symbols --no-rename {} \;
  # mv *.ttf /Library/Fonts
fi

if [ $(uname -s) == 'Linux' ]; then
  echo 'Installing Linux only features'
fi

# Configure VIM
if [ $skipvim = false ]; then
  mkdir -p $HOME/.vim/bundle
  if [ -e "$HOME/.vim/bundle/vundle" ] && [ $force == "-f" ]; then
    echo "Removing Vundle"
    rm -rf $HOME/.vim/bundle/vundle
  fi

  git clone https://github.com/gmarik/Vundle.vim.git $HOME/.vim/bundle/vundle

  # echo "Installing provided VIM plugins"
  vim -c "PluginInstall!" -c "q" -c "q"
fi

# if [ ! -e $HOME/src/solarized-vim ]; then
#   # Fetch the Solarized vim theme
#   git clone https://github.com/lukebayes/vim-colors-solarized.git $HOME/src/solarized-vim || true
# fi

# Copy the shared binary files
# cp -r ./bin "$HOME/bin"

# Probably should use .zshrc instead?
# if [ $(uname -s) == 'Linux' ]; then
  # source "$HOME/.zshrc"
# fi

