#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2024 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: ERR (Error Handling)
# -----------------------------------------------------------------------------

# TODO: Add more utilities, such as:
#       die()           Terminate script.
#       cleanup()       Handle the EXIT or ERR traps using the `trap` command.
#       register_tmp()  Register of tmp dirs for cleanup() to delete upon exit.
#       print_stack()   Self-explanatory.
#       assert_cmd()    Check if tool is installed and available before using.
#       assert_dir()    Check if dir exists w/proper permissions before using.
#       assert_file()   Check if file exists w/proper permissions before using.

# Initialize private registry.
typeset -gA _ERR=(
    [DEFAULT_ABORT_MESSAGE]="Catastrophic failure."
)

# -----------------------------------------------------------------------------
# Syntax:   err_abort [<message> ...]
# Args:     <message>   Error message strings.
# Outputs:  Error message to stderr.
# Returns:  1 (error).
# Details:
#   - Logs the given <message> strings as error messages and aborts the script.
#   - If no message is provided, a default error message is used.
# Notes:
#   - Useful in short-circuit evaluation expressions, such as:
#       `{command} || err_abort "{command} failed."`
# -----------------------------------------------------------------------------
function err_abort() {
    local msg=${_ERR[DEFAULT_ABORT_MESSAGE]:-}
    log_error "${@:-${msg}} ==> Aborting script."
    exit 1
}