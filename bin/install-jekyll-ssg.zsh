#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2024 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         [APP] Install Jekyll SSG
# -----------------------------------------------------------------------------

# Initialize script framework (use `dirname` and `printf` for portability).
source "$(dirname "${0}")/../lib/framework/init.zsh" || {
    printf "\e[91mError: Failed to initialize script framework.\e[0m\n"
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

    # Define state variables.
    local zshrc_updated=false

    log::info "Check if Jekyll is installed..."
    if ( jekyll -v ) ; then
        log::info "==> Jekyll is installed. Update gems."

        # Update Jekyll and Bundler gems.
        log::info "Update Jekyll gem..."
        gem update jekyll
        log::info "Update Bundler gem..."
        gem update bundler
    else
        log::info "==> Jekyll is not installed. Install Jekyll..."

        log::info "Check if Homebrew is installed..."
        if ( ! brew -v ) ; then
            log::info "==> Homebrew is not installed. Install Homebrew..."
            # Install Homebrew.
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            log::info "==> Homebrew is installed."
        fi

        # Update Homebrew.
        log::info "Update Homebrew..."
        brew update

        # Install Ruby tools.
        log::info "Install Ruby tools..."
        brew install chruby ruby-install

        # Install the latest Ruby version supported by Jeckyll.
        log::info "Install the latest Ruby version supported by Jeckyll..."
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

        log::info "Check if zsh is configured to use chruby by default..."
        if [[ "${configs}" == "${matches}" ]] ; then
            log::info "==> Zsh shell is already configured properly."
        else
            log::info "==> Zsh shell is not configured. Configure it to use chruby by default..."
            echo >> "${HOME}/.zshrc"
            echo "${header}" >> "${HOME}/.zshrc"
            echo "${configs}" >> "${HOME}/.zshrc"

            zshrc_updated=true
        fi

        # Install the latest Jekyll and Bundler gems.
        log::info "Install the latest Jekyll gem..."
        gem install jekyll
        log::info "Install the latest Bundler gem..."
        gem install bundler
    fi

    # Check versions.
    log::info "Check Ruby version 3.4.1 ..."
    ruby -v     # ruby 3.4.1
    log::info "Check Jekyll version >=4.4.1 ..."
    jekyll -v   # jekyll 4.4.1
    log::info "Check Bundler version >=2.6.9 ..."
    bundler -v  # bundler 2.6.9

    # Run Homebrew diagnostics, as an FYI.
    log::info "Run Homebrew diagnostics, as an FYI..."
    brew doctor

    # Relaunch the terminal window to apply config updates, if any.
    if [[ "${zshrc_updated}" == true ]]; then
        log::info "Load shell config updates using \"exec zsh\"..."
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

    # Set verbosity level.
    log::set_verbosity "${_APP[DEFAULT_VERBOSITY]}" # Set level to app default.
    log::set_verbosity "${verbosity}"               # Try to set to user input.
    verbosity=$(log::get_verbosity)                 # Get actual level.

    # Log script identifier to mark the start of all logging.
    log::info_header "Install Jekyll SSG (Static Site Generator)"

    # Handle help requests before validating other inputs.
    help=$(dat::validate_bool "help flag" "${help}" "${_APP[DEFAULT_HELP]}") || return 1
    if dat::is_true "${help}"; then usage; fi

    # Validate all other inputs.
    batch=$(dat::validate_bool "batch flag" "${batch}" "${_APP[DEFAULT_BATCH]}") || return 1

    # Display all processed arguments.
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
    log::info "  Batch mode:   [${batch}]"
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