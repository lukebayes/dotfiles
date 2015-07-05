#!/bin/bash
set -io pipefail

cd $HOME
dotfiles="$HOME/src/dotfiles"
force=""
skipvim=false

# Show help message
show_help() {
  cat << EOF

Usage: ${0##*/} [-force --help --skip-vim]
Configure a home directory for development.

  -f|--force      Force or overwrite existing files and directories
  --skip-vim  Skip vim configuration
  -h|--help   Show this message
EOF
}

# Process command line options
while [ $# -gt 0 ]; do
  case $1 in
    -f|--force)   force="-f";       shift  ;;
    --skip-vim)   skipvim=true;     shift  ;;
    -h|--help)    show_help;         exit 0;;
    *)            show_help;         exit 1;;
  esac
done

if [ ! -f $HOME/.ssh/github_rsa.pub ]; then
  echo "ERROR: You must have an SSH public key at $HOME/.ssh/github_rsa.pub"
  exit 1
fi

echo "Creating dotfiles directory at $dotfiles"
mkdir -p "$dotfiles"

# Enable as final step
# git clone https://github.com/lukebayes/dotfiles.git $dotfiles

echo "Creating symlinks to $HOME from $dotfiles"

# Copy all files in dotfiles/home/* to $HOME/.[filename]
for file in $dotfiles/home/*
do
  echo "ln $force -s $file \"$HOME/.${file##*/}\""
  ln $force -s $file "$HOME/.${file##*/}"
done

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

