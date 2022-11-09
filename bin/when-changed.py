#!/usr/bin/env python3
"""
when-changed - run a command when a file is changed

Usage: when-changed FILE COMMAND...
       when-changed FILE [FILE ...] -c COMMAND

Copyright (c) 2011, Johannes H. Jensen.
License: BSD, see LICENSE for more details.

Updated by Luke Bayes with:
* Extra whitespace between builds
* Message to indicate which file triggered the build
* De-duplicate files list to avoid multi-builds when a single file changes
"""
import sys
import os
import time

usage =  'Usage: %(prog)s FILE COMMAND...'
usage += '\n       %(prog)s FILE [FILE ...] -c COMMAND...'
description = 'Run a command when a file is changed'

def print_usage(prog):
    print(usage % {'prog': prog})

def print_help(prog):
    print_usage(prog)
    print("\n" + description)


if __name__ == '__main__':
    args = sys.argv
    prog = args.pop(0)

    if '-h' in args or '--help' in args:
        print_help(prog)
        exit(0)

    all_files = []
    command = []

    if '-c' in args:
        cpos = args.index('-c')
        all_files = args[:cpos]
        command = args[cpos+1:]
    else:
        all_files = [args[0]]
        command = args[1:]

    if not all_files or not command:
        print_usage(prog)
        exit(1)

    files = set(all_files)

    command = ' '.join(command)

    # Store initial mtimes
    try:
        mtimes = [os.stat(f).st_mtime for f in files]
    except OSError as e:
        print(e)
        exit(1)

    # Tell the user what we're doing
    if len(files) > 1:
        l = ["'%s'" % f for f in files]
        s = ', '.join(l[:-1]) + ' or ' + l[-1]
        print("When %s changes, run '%s'" % (s, command))
    else:
        print("When '%s' changes, run '%s'" % (files[0], command))

    # Start polling for changes
    while True:
        for i, f in enumerate(files):
            try:
                t = os.stat(f).st_mtime
                if t != mtimes[i]:
                    mtimes[i] = t
                    print(">> running '%s' because of change in: '%s'" %
                            (command, f))
                    os.system(command)
                    print("\n\n\n") # Put some lines between runs
            except OSError as e:
                print(e.strerror)
                # TODO: Exit here?

        time.sleep(0.8)

