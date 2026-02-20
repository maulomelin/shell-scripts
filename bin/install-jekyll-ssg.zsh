#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2024 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: APP (Install Jekyll SSG)
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
    [DEFAULT_VERBOSITY]=3
)

# Display help documentation and exit. Invoked as needed.
function usage() {
# ----------------- 79-character ruler to align usage() text ------------------
    cat << EOF
Usage:

    ${ZSH_ARGZERO:A:t} [-v=<level>] [-b] [-h]

Description:

    Jekyll Static Site Generator (SSG) Installer.
    Checks for Jekyll. If installed, it updates the Jekyll and Bundler gems
    to their latest versions. Otherwise, it installs Homebrew, Ruby, updates
    the shell config, and then installs the latest Jekyll and Bundler gems.

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
        Defaults to [${_APP[DEFAULT_BATCH]}] if not present.

    -h, --help
        Display this help message and exit.
EOF
    exit 0
}

# Implement core logic. Invoked by main().
function run() {

    # Map function arguments to local variables.
    local batch="${1}"

    # Define state variables.
    local zshrc_updated=false

    log_info "Check if Jekyll is installed..."
    if ( jekyll -v ) ; then
        log_info "==> Jekyll is installed. Update gems."

        # Update Jekyll and Bundler gems.
        log_info "Update Jekyll gem..."
        gem update jekyll
        log_info "Update Bundler gem..."
        gem update bundler
    else
        log_info "==> Jekyll is not installed. Install Jekyll..."

        log_info "Check if Homebrew is installed..."
        if ( ! brew -v ) ; then
            log_info "==> Homebrew is not installed. Install Homebrew..."
            # Install Homebrew.
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            log_info "==> Homebrew is installed."
        fi

        # Update Homebrew.
        log_info "Update Homebrew..."
        brew update

        # Install Ruby tools.
        log_info "Install Ruby tools..."
        brew install chruby ruby-install

        # Install the latest Ruby version supported by Jeckyll.
        log_info "Install the latest Ruby version supported by Jeckyll..."
        ruby-install ruby 3.4.1

        # Configure zsh shell to use "chruby" by default.
        # Unquoted here-document delimiter allows param expansion on $(...).
        local header="# Use chruby by default."
        local configs=$(cat <<EOS
source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh
source $(brew --prefix)/opt/chruby/share/chruby/auto.sh
chruby ruby-3.4.1
EOS
        )
        local matches=$(grep -F "${configs}" "${HOME}/.zshrc")

        log_info "Check if zsh is configured to use chruby by default..."
        if [[ "${configs}" == "${matches}" ]] ; then
            log_info "==> Zsh shell is already configured properly."
        else
            log_info "==> Zsh shell is not configured. Configure it to use chruby by default..."
            echo >> "${HOME}/.zshrc"
            echo "${header}" >> "${HOME}/.zshrc"
            echo "${configs}" >> "${HOME}/.zshrc"

            zshrc_updated=true
        fi

        # Install the latest Jekyll and Bundler gems.
        log_info "Install the latest Jekyll gem..."
        gem install jekyll
        log_info "Install the latest Bundler gem..."
        gem install bundler
    fi

    # Check versions.
    log_info "Check Ruby version 3.4.1 ..."
    ruby -v     # ruby 3.4.1
    log_info "Check Jekyll version >=4.4.1 ..."
    jekyll -v   # jekyll 4.4.1
    log_info "Check Bundler version >=2.6.9 ..."
    bundler -v  # bundler 2.6.9

    # Run Homebrew diagnostics, as an FYI.
    log_info "Run Homebrew diagnostics, as an FYI..."
    brew doctor

    # Relaunch the terminal window to apply config updates, if any.
    if [[ "${zshrc_updated}" == true ]]; then
        log_info "Load shell config updates..."
        exec zsh    # "exec zsh" or "source ~/.zshrc"
    fi
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

    # Display processed arguments.
    log_info_header "Jekyll SSG (Static Site Generator) Installer/Updater"
    log_info "Default settings:"
    log_info "  Batch mode:  [${_APP[DEFAULT_BATCH]}]"
    log_info "  Verbosity:   [${_APP[DEFAULT_VERBOSITY]}]"
    log_info "Arguments processed:"
    log_info "  Input:       [${args}]"
    log_info "  Used:        [${args_used}]"
    log_info "  Ignored:     [${args_ignored}]"
    log_info "Effective settings:"
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
    if [[ -z "${batch}" ]]; then
        log_error "Invalid internal state. Aborting script."
        exit 1
    fi

    # Execute the core logic.
    run "${batch}"
}

# Invoke main() with all CLI arguments.
main "${@}"