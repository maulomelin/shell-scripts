#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2024 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: ERR (Error Handling)
# -----------------------------------------------------------------------------
# TODO: Add utilities to this library, such as:
#       cleanup()       Handle the EXIT or ERR traps using the `trap` command.
#       register_tmp()  Register of tmp dirs for cleanup() to delete upon exit.
#       print_stack()   Self-explanatory.
#       assert_cmd()    Check if tool is installed and available before using.
#       assert_dir()    Check if dir exists w/proper permissions before using.
#       assert_file()   Check if file exists w/proper permissions before using.
#       assert_var()    Check if variable is set and non-empty before using.
#       restart()       Restart the script environment via `exec $0 "$@"`.
# -----------------------------------------------------------------------------
