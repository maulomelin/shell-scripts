#!/bin/zsh
#--------------------------------------+--------------------------------------#
# SPDX-FileCopyrightText: (c) 2025 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier: MIT
# SPDX-FileComment: Common Utilities Library.
#--------------------------------------+--------------------------------------#

# Module config settings.
readonly DEFAULT_ABORT_MESSAGE="Catastrophic failure."

#--------------------------------------+--------------------------------------#
# Synopsis:
#   abort [<string>*]
#
# Description:
#   - Logs the given strings as error messages and aborts the script.
#   - If no message is provided, a default error message is used.
#
# Globals:
#   ABORT_MESSAGE_DEFAULT
#
# Arguments:
#   <string>    A list of strings.
#
# Outputs:
#   - Prints an error message and returns an error code.
#
# Returns:
#   1           Error.
#--------------------------------------+--------------------------------------#
function abort() {
    log_error "${@:-${DEFAULT_ABORT_MESSAGE:-}} ==> Aborting script."
    exit 1
}
