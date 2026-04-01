#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2024 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: APP (Export Repo)
# -----------------------------------------------------------------------------

# Initialize the script environment (use portable `dirname` and `printf`).
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
    [DEFAULT_BATCH]=${REG[FALSE]}
    [DEFAULT_HELP]=${REG[FALSE]}
    [DATETIME]="${(%):-"%D{${REG[FORMAT_DATETIME_SLUG]}}"}"
    [DEFAULT_REPO]="https://github.com/pages-themes/primer"
    [DEFAULT_DIR]="${PWD}"
)

# Display help documentation and exit. Invoked as needed.
function usage() {
# ----------------- 79-character ruler to align usage() text ------------------
    cat << EOF
Usage:

    ${ZSH_ARGZERO:A:t} [-r=<repo>] [-d=<dir>] [-v=<level>] [-b] [-h]

Description:

    Copies a Git <repo> into an eponymous directory under <dir>.
    The target dir is a slug of the <repo> name and a unique datetime stamp.
    For example:

        --repo=https://github.com/pages-theme/primer

    yields the target directory:

        github.com--pages-themes--primer--19950624T181853/

    This allows multiple exports of the same <repo> under <dir>.

Options:

    -r=<repo>, --repo=<repo>
        A Git URL to a repository to export.
        Defaults to the Jekyll Primer theme on GitHub:

            ${_APP[DEFAULT_REPO]}

    -d=<dir>, --dir=<dir>
        Target directory where the repository will be exported to.
        Relative paths will be based off the current working directory.
        Defaults to the current working directory:

            ${_APP[DEFAULT_DIR]}

    -v=<level>, --verbosity=<level>
        Sets the display threshold for logging level.
        Defaults to [${REG[DEFAULT_VERBOSITY]}] if not present or invalid.

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
    local repo="${2}"
    local dir="${3}"

    # Generate a unique directory name based on the repo name by slugifying
    # and timestamping it. Since this is geared towards GitHub-hosted repos,
    # we use the 3 trailing pathname components (domain/user_name/repo_name).
    # It *should* work on repo URLs, remotes, and local paths...caveat emptor.
    local s
    s="${repo:t3}"                      # Extract trailing pathname components.
    s="${s// /}"                        # Collapse all spaces.
    s=${s//\//--}                       # Replace slashes with double dashes.
    s="${s}--${_APP[DATETIME]}"         # Append a datetime stamp.
    local export_dir="${s}"

    # Display script settings.
    log::info "Script settings:"
    log::info "  Source repo:  [${repo}]"
    log::info "  Target dir:   [${dir}]"
    log::info "  Export dir:   [${export_dir}]"

    # Create the target folder.
    log::info "Create the target folder..."
    mkdir -p "${dir}" || sys::abort "Cannot create the target directory ${dir}."

    # Change to the target directory.
    log::info "Change to the target directory [${dir}]..."
    pushd "${dir}" || sys::abort "Cannot change to directory ${dir}."

    # Clone the repo to the target directory and remove the .git directory.
    log::info "Clone the source repository to the export directory [${export_dir}]..."
    git clone --depth=1 "${repo}" "${export_dir}" || sys::abort "Cannot clone repository ${repo} to ${export_dir}."
    log::info "Remove all Git metadata..."
    rm -rf ./"${export_dir}"/.git || sys::abort "Cannot remove .git directory from ${export_dir}."

    # Go back to the original directory.
    log::info "Return to the original directory..."
    popd || sys::abort "Cannot return to the original directory."

    log::info "==> Done."
}

# Parse and validate CLI arguments. This is the script's entry point.
function main() {

    # Parse all CLI arguments.
    local dir repo
    local help batch verbosity
    local args=( "${@}" ) args_used=() args_ignored=()
    while (( $# )); do
        case "$1" in
            (-h|--help)          help=true           ; args_used+=(${1}) ;;
            (-b|--batch)         batch=true          ; args_used+=(${1}) ;;
            (-v=*|--verbosity=*) verbosity="${1#*=}" ; args_used+=(${1}) ;;
            (-d=*|--dir=*)       dir="${1#*=}"       ; args_used+=(${1}) ;;
            (-r=*|--repo=*)      repo="${1#*=}"      ; args_used+=(${1}) ;;
            (*)                                        args_ignored+=(${1}) ;;
        esac
        shift
    done

    # Set verbosity level.
    log::set_verbosity "${_APP[DEFAULT_VERBOSITY]}" # Set level to app default.
    log::set_verbosity "${verbosity}"               # Try to set to user input.
    verbosity=$(log::get_verbosity)                 # Get actual level.

    # Log script identifier to mark the start of all logging.
    log::info_header "Export Repository"

    # Handle help requests before validating other inputs.
    help=$(dat::validate_bool "help flag" "${help}" "${_APP[DEFAULT_HELP]}") || return 1
    if dat::is_true "${help}"; then usage; fi

    # Validate all other inputs.
    batch=$(dat::validate_bool "batch flag" "${batch}" "${_APP[DEFAULT_BATCH]}") || return 1
    dir=$(dat::validate_path "target dir" "${dir}" "${_APP[DEFAULT_DIR]}") || return 1
    repo=$(dat::validate_url "repo url" "${repo}" "${_APP[DEFAULT_REPO]}") || return 1

    # Display processed arguments.
    log::info "Arguments processed:"
    log::info "  Input:        [${args}]"
    log::info "  Used:         [${args_used}]"
    log::info "  Ignored:      [${args_ignored}]"
    log::info "Default settings:"
    log::info "  Source repo:  [${_APP[DEFAULT_REPO]}]"
    log::info "  Target dir:   [${_APP[DEFAULT_DIR]}]"
    log::info "  Verbosity:    [${_APP[DEFAULT_VERBOSITY]}]"
    log::info "  Batch:        [${_APP[DEFAULT_BATCH]}]"
    log::info "  Help:         [${_APP[DEFAULT_HELP]}]"
    log::info "Effective settings:"
    log::info "  Source repo:  [${repo}]"
    log::info "  Target dir:   [${dir}]"
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
    local -a args=( "${batch}" "${repo}" "${dir}" )
    if [[ "${#args}" != "${#args:#}" ]]; then
        sys::abort "Invalid state: Empty args."
    fi

    # Execute core logic.
    run "${args[@]}"
}

# Invoke main() with all CLI arguments.
main "${@}"
