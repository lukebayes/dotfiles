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
wget https://github.com/lukebayes/powerline/raw/develop/font/PowerlineSymbols.otf \
  https://github.com/lukebayes/powerline/raw/develop/font/10-powerline-symbols.conf

# Upgrade Python package manager
pip install -U pip
# Install Powerline using pip
pip install --user git+git://github.com/lukebayes/powerline

if [ ! -e $HOME/src/solarized-dir ]; then
  # Fetch the Solarized directory theme
  git clone https://github.com/lukebayes/dircolors-solarized.git $HOME/src/solarized-dir || true
fi

# Install the Solarized directory theme
ln -fs $HOME/src/solarized-dir/dircolors.256dark $HOME/.dircolors

echo "Preparing to install for $(uname -s)"

if [ $(uname -s) == 'Darwin' ]; then
  # TODO: Install Powerline fonts for OS X
  echo "Installing OS X only features"
  mv $HOME/.bashrc $HOME/.bash_profile
fi

if [ -uname -s == 'Ubuntu' ]; then
  echo 'Installing Powerline for Linux'
  sudo mkdir -p /usr/share/fonts
  sudo mv PowerlineSymbols.otf /usr/share/fonts/
  sudo fc-cache -vf
  sudo mv 10-powerline-symbols.conf /etc/fonts/conf.d/

  if [ ! -e $HOME/src/solarized ]; then
    # Fetch the Solarized terminal theme
    git clone https://github.com/lukebayes/gnome-terminal-colors-solarized.git $HOME/src/solarized || true
  fi
  # Install the Solarized terminal theme
  $HOME/src/solarized/install.sh
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

source $HOME/.bashrc

