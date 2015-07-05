#!/bin/bash
set -io pipefail

cd $HOME
dotfiles="$HOME/src/dotfiles"

if [ ! -f $HOME/.ssh/github_rsa.pub ]; then
  echo "ERROR: You must have an SSH public key at $HOME/.ssh/github_rsa.pub"
  exit 1
fi

echo "Creating dotfiles directory at $dotfiles"
mkdir -p "$dotfiles"

# Enable as final step
# git clone https://github.com/lukebayes/dotfiles.git $dotfiles

echo "Creating symlinks to $HOME from $dotfiles"
ln -fs $dotfiles/home/gitignore .gitignore
ln -fs $dotfiles/home/gitconfig .gitconfig

for file in $dotfiles/home/*
do
  echo "FILE: $file"
done
