#!/bin/sh

# diff is called by git with 7 parameters:
# path old-file old-hex old-mode new-file new-hex new-mode

# side-by-side diff with custom options:
# /usr/bin/sdiff -w200 -l "$2" "$5"; echo >/dev/null

# diff -W 200 -y "$2" "$5"; echo >/dev/null

vim -d "$2" "$5"; echo >/dev/null

