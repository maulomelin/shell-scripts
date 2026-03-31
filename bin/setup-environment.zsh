#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2025 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: APP (Application Script Template)
# -----------------------------------------------------------------------------

# Initialize script environment (use `dirname` and `printf` for portability).
source "$(dirname "${0}")/../lib/init.zsh" || {
    printf "\e[91mError: Failed to initialize script environment.\e[0m\n"
    exit 1
}

# Prevent script sourcing.
if [[ ${ZSH_EVAL_CONTEXT} == *:file* ]]; then
    log::warning "The script [${(%):-%x}] must be executed, not sourced."
    return 1
fi

# Initialize private registry.
typeset -gA _APP=(
    [DEFAULT_VERBOSITY]=${REG[DEFAULT_VERBOSITY]}
    [DEFAULT_BATCH]=${REG[DEFAULT_BATCH]}
    [DEFAULT_HELP]=${REG[DEFAULT_HELP]}
    [USER_NAME]="Mauricio Lomelin"
    [USER_EMAIL]="maulomelin@gmail.com"
)

# Display help documentation and exit. Invoked as needed.
function usage() {
# ----------------- 79-character ruler to align usage() text ------------------
    cat << EOF
Usage:

    ${ZSH_ARGZERO:A:t} [-v=<level>] [-b] [-h]

Description:

    Sets up a new environment by installing software, configuring tools, and
    setting system paths.

Options:

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

    -h, --help
        Display this help message and exit.
EOF
    exit 0
}

# Implement core logic. Invoked by main().
function run() {

    # Map function arguments to local variables.
    local batch="${1}"

    local manifest_dirpath="${${(%):-%x}:A:h:h}/lib/manifests"
    local -a manifests=(
        "000--core.zsh"
        "010--shell.zsh"
        "020--chrome.zsh"
        "030--github-cli.zsh"
        "040--python-uv.zsh"
        "050--node-nvm.zsh"
        "060--ruby-chruby.zsh"
        "070--vscode.zsh"
        "080--productivity-apps.zsh"
        # TODO: Add new manifests here.
    )
    local manifest script
    for manifest in "${manifests[@]}"; do
        script="${manifest_dirpath}/${manifest}"
        source "${script}" || {
            log::error "Failed to source [${script}]"
            log::error "Check the manifest file."
        }
    done
}

# Parse and validate CLI arguments. This is the script's entry point.
function main() {

    # Parse all CLI arguments.
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

    # Set verbosity level.
    log::set_verbosity "${_APP[DEFAULT_VERBOSITY]}" # Set level to app default.
    log::set_verbosity "${verbosity}"               # Try to set to user input.
    verbosity=$(log::get_verbosity)                 # Get actual level.

    # Handle help requests before validating other inputs.
    help=$(dat::validate_bool "help flag" "${help}" "${_APP[DEFAULT_HELP]}") || return 1
    if dat::is_true "${help}"; then usage; fi

    # Validate all other inputs.
    batch=$(dat::validate_bool "batch flag" "${batch}" "${_APP[DEFAULT_BATCH]}") || return 1

    # Display all processed arguments.
    log::info_header "# TODO: Give the script a short, friendly name here."
    log::info "Arguments processed:"
    log::info "  Input:        [${args}]"
    log::info "  Used:         [${args_used}]"
    log::info "  Ignored:      [${args_ignored}]"
    log::info "Default settings:"
    log::info "  Verbosity:    [${_APP[DEFAULT_VERBOSITY]}]"
    log::info "  Batch:        [${_APP[DEFAULT_BATCH]}]"
    log::info "  Help:         [${_APP[DEFAULT_HELP]}]"
    log::info "Effective settings:"
    log::info "  Verbosity:    [${verbosity}]"
    log::info "  Batch:        [${batch}]"
    log::info "  Help:         [${help}]"

    # Prompt user for confirmation, unless in batch mode.
    if dat::is_true "${batch}"; then
        log::warning "Batch mode enabled. Proceeding with script."
    else
        read "response?Proceed? (y/N): "
        if ! dat::is_yes "${response}"; then
            sys::terminate "User declined to proceed."
        fi
    fi

    # Check that all variables are populated before executing core logic.
    local -a args=( "${batch}" )
    if [[ "${#args}" != "${#args:#}" ]]; then
        sys::abort "Invalid state: Empty args."
    fi

    # Execute core logic.
    run "${args[@]}"
}

# Invoke main() with all CLI arguments.
main "${@}"