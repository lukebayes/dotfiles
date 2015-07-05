#!/bin/bash
set -io pipefail

cd $HOME
dotfiles="$HOME/src/dotfiles"
force=""

# Show help message
show_help() {
  cat << EOF

Usage: ${0##*/} [-f --help]
Configure a home directory for development.

  -f          Force or overwrite existing files and directories
  --help   Show this message
EOF
}

# Process command line options
while getopts "f" opt; do
  case "$opt" in
    h) show_help exit 0;;
    f) force="-f";;
    ?) show_help exit 1;;
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

