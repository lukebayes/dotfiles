#!/bin/bash
set -io pipefail

SOURCEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Running installation from $SOURCEDIR"
exit 0

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
  --skip-apt      Skip apt-get update and installation
  --skip-vim      Skip vim configuration
  -h|--help       Show this message
EOF
}

# Process command line options
while [ $# -gt 0 ]; do
  case $1 in
    -f|--force)   force="-f";       shift  ;;
    --skip-apt)   skipapt=true;     shift  ;;
    --skip-vim)   skipvim=true;     shift  ;;
    -h|--help)    show_help;        exit 0 ;;
    *)            show_help;        exit 1 ;;
  esac
done

if [ ! -f $HOME/.ssh/github_rsa.pub ]; then
  echo "ERROR: You must have an SSH public key at $HOME/.ssh/github_rsa.pub"
  exit 1
fi

echo "Creating dotfiles directory at $SOURCEDIR"
mkdir -p "$SOURCEDIR"

# Enable as final step
# git clone https://github.com/lukebayes/dotfiles.git $SOURCEDIR

echo "Creating symlinks to $HOME from $SOURCEDIR"

# Copy all files in dotfiles/home/* to $HOME/.[filename]
for file in $SOURCEDIR/home/*
do
  echo "ln $force -s $file \"$HOME/.${file##*/}\""
  ln $force -s $file "$HOME/.${file##*/}"
done

if [ $skipapt != false ] && [ ! shopt -oq posix ]; then
# Install binaries
sudo apt-get update && \
  sudo apt-get install \
  git-core \
  python-pip
fi

# Upgrade pip
pip install -U pip
pip install --user git+git://github.com/lukebayes/powerline
pip install git+git://github.com/lukebayes/powerline

wget https://github.com/lukebayes/powerline/raw/develop/font/PowerlineSymbols.otf \
  https://github.com/lukebayes/powerline/raw/develop/font/10-powerline-symbols.conf

sudo mv PowerlineSymbols.otf /usr/share/fonts/
sudo fc-cache -vf
sudo mv 10-powerline-symbols.conf /etc/fonts/conf.d/

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

# Set up the Tomorrow Night shell theme
./$SOURCEDIR/setup-theme.sh

source $HOME/.bashrc

