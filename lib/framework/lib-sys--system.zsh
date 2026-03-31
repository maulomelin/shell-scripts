#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2024 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: SYS (System)
# -----------------------------------------------------------------------------

# Initialize private registry.
typeset -gA _SYS=(
    [DEFAULT_TERMINATE_MESSAGE]="Script completed successfully."
    [DEFAULT_ABORT_MESSAGE]="Catastrophic failure."
    [DEFAULT_RETURN_MESSAGE]="Operation completed successfully."
    [DEFAULT_FAIL_MESSAGE]="Operation failed."
)

# -----------------------------------------------------------------------------
# Syntax:   sys::terminate [<msg> ...]
# Args:     <msg>       Message strings.
# Outputs:  Logs <msg> at log level INFO.
# Status:   exit 0 (ok).
# Details:
#   - Ends the script and exits with status 0 (success).
#   - Logs the <message> strings as an INFO message.
#     If no message is provided, a default message is used.
#   - Use to terminate a script "nicely":
#       `if [[ ... ]]; then sys::terminate "User declined to proceed."; fi`
# -----------------------------------------------------------------------------
function sys::terminate() {
    local msg=${_SYS[DEFAULT_TERMINATE_MESSAGE]:-}
    log::info "${@:-${msg}} ==> Ending script."
    exit 0
}

# -----------------------------------------------------------------------------
# Syntax:   sys::abort [<msg> ...]
# Args:     <msg>       Message strings.
# Outputs:  Logs <msg> at log level ERROR.
# Status:   exit 1 (abort).
# Details:
#   - Ends the script and exits with status 1 (error).
#   - Logs the <msg> strings as an ERROR message.
#     If no message is provided, a default message is used.
#   - Useful in short-circuit expressions, such as:
#       `{command} || sys::abort "Error with {command}."`
# -----------------------------------------------------------------------------
function sys::abort() {
    local msg=${_SYS[DEFAULT_ABORT_MESSAGE]:-}
    log::error "${@:-${msg}} ==> Aborting script."
    exit 1
}