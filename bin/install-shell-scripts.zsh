#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: APP (Install Scripts to Local Env)
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
    [DEFAULT_HELP]=${REG[FALSE]}
    [DEFAULT_SOURCE_DIR]="${PWD:h}"         # Parent of working directory.
    [DEFAULT_TARGET_DIR]="${HOME}/_local/"  # ~/_local/
    [DEFAULT_DELETE]=${REG[FALSE]}
    [DEFAULT_DRYRUN]=${REG[FALSE]}
)

# Display help documentation and exit. Invoked as needed.
function usage() {
# ----------------- 79-character ruler to align usage() text ------------------
    cat << EOF
Usage:

    ${ZSH_ARGZERO:A:t} [-s=<source>] [-t=<target>] [-d] [-v=<level>] [-b] [-h]

Description:

    Installs scripts from the <source> into <target> by:
      1) Copying files from <source>/(bin,lib) into <target>/(bin,lib).
      2) Ensuring all files in <target>/bin are executable.
      3) Updating the environment by adding <target>/bin to the shell's PATH.

    Any <target> directories are created as necessary.
    Contents of <target> are synced with <source>.
    If <d> is set, files in <target> not in <source> are deleted.
    If <target>/bin is not already in the PATH, it is added to ~/.zshrc.

Options:

    -s=<source>, --source=<source>
        Source directory containing the scripts to install.
        Defaults to the parent of the current working directory, \${PWD}/..:

            ${_APP[DEFAULT_SOURCE_DIR]}

    -t=<target>, --target=<target>
        Target directory where the scripts will be installed in.
        Defaults to \${HOME}/_local/:

            ${_APP[DEFAULT_TARGET_DIR]}

    -d, --delete
        Delete extraneous files and directories from the target directory.
        If unset, only files also present in <source> will be overwritten.
        Setting it is equivalent to a clean install of the {bin,lib} folders.

    -n, --dry-run
        Show list of actions without taking any.

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
    local source="${2}"
    local target="${3}"
    local delete="${4}"
    local dryrun="${5}"

    # Create the "rsync" command arguments.
    local opt_delete=$(dat::is_true "${delete}" && echo "--delete" || echo "")
    local opt_dryrun=$(dat::is_true "${dryrun}" && echo "--dry-run" || echo "")
    local -a opts=(
        "--recursive"           # Recurse into directories.
        "--links"               # Copy symlinks as symlinks.
        "--dirs"                # Transfer directories without recursing.
        "--itemize-changes"     # Output a change-summary for all updates.
        "--verbose"             # Increase verbosity.
        "${opt_delete}"         # Delete files in {target} not in {source}.
        "${opt_dryrun}"         # Show list of actions without taking any.
    )
    opts=( "${opts[@]:#}" ) # Remove empty elements.

    # Rsync: "{source}/{bin,lib}/" --> "{target}".
    #   - "rsync" errors out if src does not exist, so do each src separately.
    #   - "rsync" creates target dirs as needed, so no need to run "mkdir".
    local src
    for src in "${source}"/{bin,lib}; do
        log::info "Rsync [${src}] --> [${target}]"
        if [[ -d "${src}" ]]; then
            rsync "${opts[@]}" "${src}" "${target}"
        fi
    done

    # Complete installation only if this is not a dry-run.
    if ! dat::is_true "${dryrun}"; then

        # Make every file in {target}/bin/ an executable.
        log::info "Making every file in ${target}/bin/ an executable..."
        chmod -R +x "${target}/bin"/* && log::info "  ==> Done." || log::warning "  ==> ERROR!"

        # Update the ~/.zshrc environment file.
        local config_label="Personal Shell Scripts"
        local -a scripts_config_array=(
            "# Prepend personal scripts to PATH, to prioritize over system defaults."
            "export PATH=\"${target}/bin:\${PATH}\""
        )
        local scripts_config="${(F)scripts_config_array}"
        cfg::update_manifest "${HOME}/.zshrc" "${scripts_config}" "${config_label}"

        # Final message.
        log::info "Installation complete: ${target}/{bin,lib} is now in sync."
        log::info "Don't forget to run \"exec zsh\" to apply any config changes."
    fi
}

# Parse and validate CLI arguments. This is the script's entry point.
function main() {

    # Parse all CLI arguments.
    local source target delete dryrun
    local help batch verbosity
    local -a args=( "${@}" ) args_used=() args_ignored=()
    while (( $# )); do
        case "$1" in
            (-h|--help)          help=true           ; args_used+=(${1}) ;;
            (-b|--batch)         batch=true          ; args_used+=(${1}) ;;
            (-v=*|--verbosity=*) verbosity="${1#*=}" ; args_used+=(${1}) ;;
            (-s=*|--source=*)    source="${1#*=}"    ; args_used+=(${1}) ;;
            (-t=*|--target=*)    target="${1#*=}"    ; args_used+=(${1}) ;;
            (-d|--delete)        delete=true         ; args_used+=(${1}) ;;
            (-n|--dry-run)       dryrun=true         ; args_used+=(${1}) ;;
            (*)                                        args_ignored+=(${1}) ;;
        esac
        shift
    done

    # Set verbosity level.
    log::set_verbosity "${_APP[DEFAULT_VERBOSITY]}" # Set level to app default.
    log::set_verbosity "${verbosity}"               # Try to set to user input.
    verbosity=$(log::get_verbosity)                 # Get actual level.

    # Log script identifier to mark the start of all logging.
    log::info_header "Install Shell Scripts"

    # Handle help requests before validating other inputs.
    help=$(dat::validate_bool "help flag" "${help}" "${_APP[DEFAULT_HELP]}") || return 1
    if dat::is_true "${help}"; then usage; fi

    # Validate all other inputs.
    batch=$(dat::validate_bool "batch flag" "${batch}" "${_APP[DEFAULT_BATCH]}") || return 1
    delete=$(dat::validate_bool "delete flag" "${delete}" "${_APP[DEFAULT_DELETE]}") || return 1
    dryrun=$(dat::validate_bool "dry-run flag" "${dryrun}" "${_APP[DEFAULT_DRYRUN]}") || return 1
    source=$(dat::validate_path "source dir" "${source}" "${_APP[DEFAULT_SOURCE_DIR]}") || return 1
    target=$(dat::validate_path "target dir" "${target}" "${_APP[DEFAULT_TARGET_DIR]}") || return 1

    # Abort on source directory issues.
    if [[ ! -d "${source}" ]]; then
        sys::abort "Source directory does not exist: [${source}]"
    fi

    # Abort on target directory issues.
    if [[ "${target}" == "${source}" ]]; then
        sys::abort "Target directory cannot be the same as source: [${source}]"
    fi
    if [[ -f "${target}" ]]; then
        sys::abort "Target is an existing file: [${target}]"
    fi

    # Display all processed arguments.
    log::info "Arguments processed:"
    log::info "  Input:        [${args}]"
    log::info "  Used:         [${args_used}]"
    log::info "  Ignored:      [${args_ignored}]"
    log::info "Default settings:"
    log::info "  Source:       [${_APP[DEFAULT_SOURCE_DIR]}]"
    log::info "  Target:       [${_APP[DEFAULT_TARGET_DIR]}]"
    log::info "  Delete:       [${_APP[DEFAULT_DELETE]}]"
    log::info "  Dry Run:      [${_APP[DEFAULT_DRYRUN]}]"
    log::info "  Verbosity:    [${_APP[DEFAULT_VERBOSITY]}]"
    log::info "  Batch:        [${_APP[DEFAULT_BATCH]}]"
    log::info "  Help:         [${_APP[DEFAULT_HELP]}]"
    log::info "Effective settings:"
    log::info "  Source:       [${source}]"
    log::info "  Target:       [${target}]"
    log::info "  Delete:       [${delete}]"
    log::info "  Dry Run:      [${dryrun}]"
    log::info "  Verbosity:    [${verbosity}]"
    log::info "  Batch:        [${batch}]"
    log::info "  Help:         [${help}]"

    # Issue warnings about the source and target directories.
    if [[ ! -d "${source}/bin" ]]; then
        log::warning "Source /bin/ folder does not exist: /bin/ will not be synced."
    fi
    if [[ ! -d "${source}/lib" ]]; then
        log::warning "Source /lib/ folder does not exist: /lib/ will not be synced."
    fi

    # Issue warnings about the delete flag.
    if dat::is_true "${delete}"; then
        log::warning "Delete flag is set: Extraneous content on target dir will be deleted."
    fi

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
    local -a args=( "${batch}" "${source}" "${target}" "${delete}" "${dryrun}" )
    if [[ "${#args}" != "${#args:#}" ]]; then
        sys::abort "Invalid state: Empty args."
    fi

    # Execute core logic.
    run "${args[@]}"
}

# Invoke main() with all CLI arguments.
main "${@}"