#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2025 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: APP (Application Script Template)
# SPDX-FileComment: <text>
#   This is the base template for Zsh shell scripts.
#   Configure the script by addressing all "TODO" tasks.
#   TODO: Delete this "SPDX-FileComment" block and all "TODO" tasks before use.
# </text>
# -----------------------------------------------------------------------------

# Initialize the script environment (use portable `dirname` and `printf`).
source "$(dirname "${0}")/../lib/init.zsh" || {
    printf "\e[91mError: Failed to initialize script environment.\e[0m\n"
    exit 1
}

# Prevent execution if the script is being sourced.
if [[ ${ZSH_EVAL_CONTEXT} == *:file* ]]; then
    echo "\e[91mError: The script [${(%):-%x}] must be executed, not sourced.\e[0m"
    return 1    # Abort sourcing and return to the caller with error.
fi

# Initialize private registry.
typeset -gA _APP=(
    [BATCH_REGEX]="^(true|false)$"
    [DEFAULT_BATCH]=false
    [AFFIRMATIVE_REGEX]="^[yY]([eE][sS])?$"
    [DEFAULT_VERBOSITY]="a" #3
    # TODO: Define additional constants and settings here.
)

# Display help documentation and exit. Invoked as needed.
function usage() {
# ----------------- 79-character ruler to align usage() text ------------------
    cat << EOF
Usage:

    ${ZSH_ARGZERO:A:t} [-v=<level>] [-b] [-h]

Description:

    # TODO: Write a brief description of the script here.

Options:

    # TODO: Document additional script parameters/flags here.

    -v=<level>, --verbosity=<level>
        Sets the display threshold for logging level.
        Defaults to [${_APP[DEFAULT_VERBOSITY]}] if not present or invalid.

            Log Message    |   Verbosity Level
              Display      |  0   1   2   3   4
        -------------------+--------------------
                0/Alert    |  Y   Y   Y   Y   Y
          Log   1/Error    |  N   Y   Y   Y   Y
         Level  2/Warning  |  N   N   Y   Y   Y
                3/Info     |  N   N   N   Y   Y
                4/Debug    |  N   N   N   N   Y

    -b, --batch
        Force non-interactive mode to perform actions without confirmation.
        Defaults to [${_APP[DEFAULT_BATCH]}] if not present.

    -h, --help
        Display this help message and exit.
EOF
    exit 0
}

# Implement core logic. Invoked by main().
function run() {

    # Map function arguments to local variables.
    # TODO: Map additional function arguments to local variables here.
    local batch="${1}"

    # TODO: Implement script's core logic here.
    log_info_header "log_header()"
    log_debug "log_debug()"
    log_info "log_info()"
    log_warning "log_warning()"
    log_error "log_error()"
    log_alert "log_alert()"
}

# Parse and validate CLI arguments. This is the script's entry point.
function main() {

    # Parse all CLI arguments.
    # TODO: Declare local variables for additional parameters/flags here.
    local help batch verbosity
    local -a args=( "${@}" ) args_used=() args_ignored=()
    while (( $# )); do
        case "$1" in
            (-h|--help)          help=true           ; args_used+=(${1}) ;;
            (-b|--batch)         batch=true          ; args_used+=(${1}) ;;
            (-v=*|--verbosity=*) verbosity="${1#*=}" ; args_used+=(${1}) ;;
            # TODO: Parse additional parameters/flags here.
            (*)                                        args_ignored+=(${1}) ;;
        esac
        shift
    done

    # Display usage information if requested.
    if [[ "${help}" == true ]]; then usage; fi

    # Validate and set the verbosity mode.
    log_set_verbosity "${_APP[DEFAULT_VERBOSITY]}"      # Set to app default.
    log_set_verbosity "${verbosity}"                    # Change if valid.
    verbosity=$(log_get_verbosity)

    # Validate and set batch mode.
    batch=${batch:-${_APP[DEFAULT_BATCH]}}              # Set to user value.
    if [[ ! ${batch} =~ ${_APP[BATCH_REGEX]} ]]; then   # Reset if invalid.
        log_warning "Invalid batch flag [${batch}]. Setting to default [${_APP[DEFAULT_BATCH]}]."
        batch=${_APP[DEFAULT_BATCH]}
    fi

    # TODO: Validate/initialize additional parameters/flags here.

    # Display all processed arguments.
    log_info_header "# TODO: Give the script a short, friendly name here."
    log_info "Default settings:"
    log_info "  Batch mode:  [${_APP[DEFAULT_BATCH]}]"
    log_info "  Verbosity:   [${_APP[DEFAULT_VERBOSITY]}]"
    # TODO: Include default settings for additional parameters/flags here.
    log_info "Arguments processed:"
    log_info "  Input:       [${args}]"
    log_info "  Used:        [${args_used}]"
    log_info "  Ignored:     [${args_ignored}]"
    log_info "Effective settings:"
    log_info "  Batch mode:  [${batch}]"
    log_info "  Verbosity:   [${verbosity}]"
    # TODO: Include values for additional parameters/flags here.

    # Prompt user for confirmation, unless in batch mode.
    if [[ "${batch}" == true ]]; then
        log_warning "Batch mode enabled. Proceeding with script."
    else
        read "response?Proceed? (y/N): "
        if [[ ! ${response} =~ ${_APP[AFFIRMATIVE_REGEX]} ]]; then
            log_info "Exiting script."
            exit 0
        fi
    fi

    # Check that all variables passed to run() exist.
    # TODO: Check additional variables passed to run() here.
    if [[ -z "${batch}" ]]; then
        log_error "Invalid internal state. Aborting script."
        exit 1
    fi

    # Execute the core logic.
    # TODO: Pass additional variables to run() here.
    run "${batch}"
}

# Invoke main() with all CLI arguments.
main "${@}"