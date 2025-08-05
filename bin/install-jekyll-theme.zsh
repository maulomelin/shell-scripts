#!/bin/zsh
#--------------------------------------+--------------------------------------#
# SPDX-FileCopyrightText: (c) 2025 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier: MIT
# SPDX-FileComment: Jekyll Theme Installer.
#--------------------------------------+--------------------------------------#
# Initialize script environment.
readonly SCRIPT_DIRPATH=$(dirname "${0}")
readonly SCRIPT_FILENAME=$(basename "${ZSH_ARGZERO}")
source "${SCRIPT_DIRPATH}/../lib/init.zsh"
#--------------------------------------+--------------------------------------#

# Configure script settings.
readonly _DEFAULT_REPO="https://github.com/pages-themes/primer"
readonly _DEFAULT_DIR="${PWD}"
readonly _DEFAULT_VERBOSITY=2
readonly _DEFAULT_BATCH=false
readonly _VERBOSITY_REGEX="^[0-3]$"
readonly _TIMESTAMP="+%Y%m%dT%H%M%S"
readonly _TEMP_FOLDER="TEMP"

# The usage() function displays help info. It is invoked as needed.
function usage() {
    echo  #--------------------------------------+--------------------------------------#
    echo "Usage:"
    echo
    echo "  ${SCRIPT_FILENAME} [-r=<repo>] [-d=<dir>] [-v=<verbosity>] [-b] [-h]"
    echo
    echo "Description:"
    echo
    echo "  Jekyll Theme Installer."
    echo "  Clones the Jekyll theme <repo> to a temp folder in project directory <dir>,"
    echo "  then copies the {_includes, _layouts, _sass, assets} folders from the local"
    echo "  repo to the project directory <dir>."
    echo "  Other folders required by the theme must be copied manually."
    echo
    echo "Options:"
    echo
    echo "  -r=<repo>, --repo=<repo>"
    echo "      A Git URL to a repository containing the desired Jekyll theme."
    echo "      If not provided, defaults to the Jekyll Primer theme on GitHub:"
    echo "      [${_DEFAULT_REPO}]"
    echo
    echo "  -d=<dir>, --dir=<dir>"
    echo "      Theme installation directory."
    echo "      Relative paths will be based off the current working directory."
    echo "      If not provided, defaults to the current working directory:"
    echo "      [${_DEFAULT_DIR}]"
    echo
    echo "  -v=<verbosity>, --verbosity=<verbosity>"
    echo "      Sets level of verbosity for script messaging."
    echo "      <verbosity> levels:"
    echo "          0   QUIET mode: Suppress all messages."
    echo "          1   ERROR mode: Only show error messages."
    echo "          2   INFO mode:  Show error and info messages."
    echo "          3   DEBUG mode: Show error, info, and debug messages."
    echo "      On invalid values, or if not provided, it defaults to [${_DEFAULT_VERBOSITY}]."
    echo
    echo "  -b, --batch"
    echo "      Force non-interactive mode. Perform actions without confirmation."
    echo
    echo "  -h, --help"
    echo "      Show this help message and exit."
    echo
    exit 1
}

# The process() function implements the core logic. It is invoked by main().
function process() {

    # No need to sanitize or validate inputs; main() takes care of it.
    local repo=${1}
    local dir=${2}

    # Generate a unique temp folder name based on the repo name by slugifying
    # and timestamping it. Since this is geared towards GitHub-hosted Jekyll
    # themes, we use the 3 trailing pathname components (domain/uname/theme).
    # It *should* work on repo URLs, remotes, and local paths...caveat emptor.
    local s
    s="${repo:t3}"                      # Extract trailing pathname components.
    s="${s// /}"                        # Collapse all spaces.
    s=${s//\//--}                       # Replace slashes with double dashes.
    s="${s}--$(date "${_TIMESTAMP}")"   # Append a timestamp.
    s="${_TEMP_FOLDER}/${s}"            # Place under the temp folder.
    local temp_folder="${s}"

    # Display script settings.
    log_info "Script settings:"
    log_info "  Theme repo: \t[${repo}]"
    log_info "  Install dir:\t[${dir}]"
    log_info "  Temp folder:\t[${temp_folder}]"

    # Create the project folder.
    log_info "Create the project folder..."
    mkdir -p "${dir}" || abort "Cannot create directory ${dir}."

    log_info "Change to the project root [${dir}]..."
    pushd "${dir}" || abort "Cannot change to directory ${dir}."

    # Clone the theme repo to the temp folder and remove the .git directory.
    log_info "Clone the theme repository to the temp folder [${temp_folder}]..."
    git clone --depth=1 "${repo}" "${temp_folder}" || abort "Cannot clone repository ${repo} to ${temp_folder}."
    log_info "Remove the .git directory to avoid cluttering the project with git metadata..."
    rm -rf ./"${temp_folder}"/.git || abort "Cannot remove .git directory from ${temp_folder}."

    # Bootstrap the theme by copying the necessary files to the project root.
    log_info "Copy theme files to the project root [${dir}]..."
    cp -R "${temp_folder}"/_includes .
    cp -R "${temp_folder}"/_layouts .
    cp -R "${temp_folder}"/_sass .
    cp -R "${temp_folder}"/assets .

    log_info "==> Done."
}

# The main() function handles input validation. It is the script's entry point.
function main() {
    log_header "Jekyll Theme Installer"

    # Parse script arguments. Extract option values using the ${name#pattern}
    # parameter expansion pattern using the "*" glob operator in the pattern.
    local args=( "${@}" )
    local ignored=()
    local used=()
    local repo dir verbosity batch help
    while (( $# )); do
        case "$1" in
            (-r=*|--repo=*)      repo="${1#*=}"      ; used+=(${1}) ;;
            (-d=*|--dir=*)       dir="${1#*=}"       ; used+=(${1}) ;;
            (-v=*|--verbosity=*) verbosity="${1#*=}" ; used+=(${1}) ;;
            (-b|--batch)         batch=true          ; used+=(${1}) ;;
            (-h|--help)          help=true           ; used+=(${1}) ;;
            (*)                                        ignored+=(${1}) ;;
        esac
        shift
    done

    # Display usage information if requested.
    if [[ "${help}" == true ]]; then
        usage
    fi

    # Set the global verbosity mode.
    if [[ ! "${verbosity}" =~ ${_VERBOSITY_REGEX} ]]; then
        verbosity=${_DEFAULT_VERBOSITY}
    fi
    LOG_VERBOSITY=${verbosity}

    # Convert dir into an absolute path (step by step for maintenance).
    dir=${dir/#"~"/${HOME}} # Expand "~" to the home directory, if present.
    dir=${dir:a}            # Absolute path with a history expansion modifier.

    # Initialize the effective variables, using defaults where necessary.
    repo="${repo:-${_DEFAULT_REPO}}"
    dir="${dir:-${_DEFAULT_DIR}}"
    batch="${batch:-${_DEFAULT_BATCH}}"

    # Display processed arguments.
    log_info "Arguments processed:"
    log_info "  Input args:\t[${args}]"
    log_info "  Used/Ignored:\t[${used}]/[${ignored}]"
    log_info "Effective settings:"
    log_info "  Theme repo:\t[${repo}] (default: [${_DEFAULT_REPO}])"
    log_info "  Install dir:\t[${dir}] (default: [${_DEFAULT_DIR}])"
    log_info "  Verbosity:\t[${verbosity}] (default: [${_DEFAULT_VERBOSITY}])"
    log_info "  Batch mode:\t[${batch}] (default: [${_DEFAULT_BATCH}])"

    # Make sure all required variables are populated.
    if [[ -z "${repo}" || -z "${dir}" || -z "${verbosity}" || -z "${batch}" ]]; then
        abort "Invalid internal state. Check default settings."
    fi

    # Prompt user for confirmation, unless in batch mode.
    if [[ "${batch}" == true ]]; then
        log_info "Batch mode enabled. Proceed with cloning..."
    else
        echo "Theme repo:\t[${repo}]"
        echo "Install dir:\t[${dir}]"
        if read -q "confirm?Proceed? (y/N): "; then
            echo
            log_info "Install Jeckyll theme..."
        else
            echo
            abort "Jeckyll theme aborted."
        fi
    fi

    # Execute the core logic.
    process "${repo}" "${dir}"
}

# Call the main() script function.
main "${@}"
