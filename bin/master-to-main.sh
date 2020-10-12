#!/usr/bin/bash

echo "Switching to master"
git checkout master

echo "Pull Updates"
git pull

echo "Create main branch"
git branch -m master main

echo "Push main branch"
git push -u origin main

echo "Wire main as default"
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main

echo "UPDATE GITHUB NOW and then run:"
echo "git push origin --delete master"

