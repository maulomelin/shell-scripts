#!/bin/zsh
#--------------------------------------+--------------------------------------#
# SPDX-FileCopyrightText: (c) 2025 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier: MIT
# SPDX-FileComment: Shell Script Environment Initializer.
#--------------------------------------+--------------------------------------#
# TODO: Consider supporting a global environment flag to enable "set -x".
# For example: `if [[ -n "${TRACE}" ]]; then set -x; fi` below. Reconcile with
# LOG_LEVEL and LOG_VERBOSITY, and review "-v" option in bin/*.zsh scripts.
#--------------------------------------+--------------------------------------#

# Fail fast if not running under zsh.
# - ${ZSH_NAME} is only set if the script is running under a zsh shell.
# - Test condition using single brackets for POSIX compatibility.
# - Use "echo" for POSIX compatibility.
if [ -z "${ZSH_NAME}" ] ; then
    echo  #--------------------------------------+--------------------------------------#
    echo "\033[91mError: This script requires zsh.\033[0m"
    echo
    echo "To run it in a zsh shell, either:"
    echo "- Invoke it with zsh:\t\`$ zsh script.zsh\`"
    echo "- Execute it directly:\t\`$ chmod +x script.zsh ; ./script.zsh\`"
    echo
    echo "To use a different shell, modify scripts accordingly."
    echo
    exit 1
fi

# Enable strict error handling and debugging.
set -e  # Exit on errors.
set -u  # Exit on undefined variables.
set -o pipefail  # Fail if any command in a pipeline fails.
#set -x  # Enable xtrace command tracing for debugging.

# Load common libraries.
readonly LIB_DIRPATH=$(dirname "${0}")
source "${LIB_DIRPATH}/init-logging.zsh"
source "${LIB_DIRPATH}/init-common.zsh"
source "${LIB_DIRPATH}/init-sysinfo.zsh"