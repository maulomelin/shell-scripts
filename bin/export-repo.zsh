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
    [DATETIME]="${(%):-"%D{%Y%m%dT%H%M%S}"}" # "The Z Shell Manual" v5.9, § 13.2.4, pg. 42.
    [DEFAULT_VERBOSITY]=3
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
    local repo="${1}"
    local dir="${2}"
    local batch="${3}"

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
    log_info "Script settings:"
    log_info "  Source repo: [${repo}]"
    log_info "  Target dir:  [${dir}]"
    log_info "  Export dir:  [${export_dir}]"

    # Create the target folder.
    log_info "Create the target folder..."
    mkdir -p "${dir}" || err_abort "Cannot create the target directory ${dir}."

    # Change to the target directory.
    log_info "Change to the target directory [${dir}]..."
    pushd "${dir}" || err_abort "Cannot change to directory ${dir}."

    # Clone the repo to the target directory and remove the .git directory.
    log_info "Clone the source repository to the export directory [${export_dir}]..."
    git clone --depth=1 "${repo}" "${export_dir}" || err_abort "Cannot clone repository ${repo} to ${export_dir}."
    log_info "Remove all Git metadata..."
    rm -rf ./"${export_dir}"/.git || err_abort "Cannot remove .git directory from ${export_dir}."

    # Go back to the original directory.
    log_info "Return to the original directory..."
    popd || err_abort "Cannot return to the original directory."

    log_info "==> Done."
}

# Parse and validate CLI arguments. This is the script's entry point.
function main() {

    # Parse all CLI arguments.
    local help batch verbosity dir repo
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

    # Display usage information if requested.
    if [[ "${help}" == true ]]; then usage; fi

    # Validate and set the verbosity mode.
    log_set_verbosity "${_APP[DEFAULT_VERBOSITY]}"  # Set to app default.
    log_set_verbosity "${verbosity}"                # Change if valid.
    verbosity=$(log_get_verbosity)

    # Validate batch mode and set to default if invalid.
    if [[ -z ${batch} ]]; then
        batch=${_APP[DEFAULT_BATCH]}
    else
        if [[ ! ${batch} =~ ${_APP[BATCH_REGEX]} ]]; then
            log_warning "Invalid batch flag [${batch}]. Setting to default [${_APP[DEFAULT_BATCH]}]."
            batch=${_APP[DEFAULT_BATCH]}
        fi
    fi

    # Validate the target directory and set to default if invalid.
    dir=${dir/#"~"/${HOME}} # Expand leading "^~" to the home directory.
    dir=${dir:A}            # Absolute path via history expansion modifier.
    dir="${dir:-${_DEFAULT_DIR}}"

    # Validate the source repository by setting to default if missing.
    repo="${repo:-${_APP[DEFAULT_REPO]}}"

    # Display processed arguments.
    log_info_header "Repository Exporter"
    log_info "Default settings:"
    log_info "  Source repo: [${_APP[DEFAULT_REPO]}]"
    log_info "  Target dir:  [${_APP[DEFAULT_DIR]}]"
    log_info "  Batch mode:  [${_APP[DEFAULT_BATCH]}]"
    log_info "  Verbosity:   [${_APP[DEFAULT_VERBOSITY]}]"
    log_info "Arguments processed:"
    log_info "  Input:       [${args}]"
    log_info "  Used:        [${args_used}]"
    log_info "  Ignored:     [${args_ignored}]"
    log_info "Effective settings:"
    log_info "  Source repo: [${repo}]"
    log_info "  Target dir:  [${dir}]"
    log_info "  Batch mode:  [${batch}]"
    log_info "  Verbosity:   [${verbosity}]"

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
    if [[ -z "${repo}" || -z "${dir}" || -z "${batch}" ]]; then
        log_error "Invalid internal state. Check default settings."
        exit 1
    fi

    # Execute the core logic.
    run "${repo}" "${dir}" "${batch}"
}

# Invoke main() with all CLI arguments.
main "${@}"
