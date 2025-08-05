#!/bin/zsh
#--------------------------------------+--------------------------------------#
# SPDX-FileCopyrightText: (c) 2025 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier: MIT
# SPDX-FileComment: Jekyll Static Site Generator (SSG) Installer.
#--------------------------------------+--------------------------------------#
# Initialize script environment.
readonly SCRIPT_DIRPATH=$(dirname "${0}")
readonly SCRIPT_FILENAME=$(basename "${ZSH_ARGZERO}")
source "${SCRIPT_DIRPATH}/../lib/init.zsh"
#--------------------------------------+--------------------------------------#

# Configure script settings.
readonly _DEFAULT_VERBOSITY=2
readonly _VERBOSITY_REGEX="^[0-3]$"

# The usage() function displays help info. It is invoked as needed.
function usage() {
    echo  #--------------------------------------+--------------------------------------#
    echo "Usage:"
    echo
    echo "  ${SCRIPT_FILENAME} [-v=<verbosity>] [-h]"
    echo
    echo "Description:"
    echo
    echo "  Jekyll Static Site Generator (SSG) Installer."
    echo "  Checks for Jekyll. If installed, it updates the Jekyll and Bundler gems"
    echo "  to their latest versions. Otherwise, it installs Homebrew, Ruby, updates"
    echo "  the shell config, and then installs the latest Jekyll and Bundler gems."
    echo
    echo "Options:"
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
    echo "  -h, --help"
    echo "      Show this help message and exit."
    echo
    exit 1
}

# The process() function implements the core logic. It is invoked by main().
function process() {

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
            echo "${pattern}" >> "${HOME}/.zshrc"

            # Relaunch the terminal window to apply the config updates
            log_info "Load shell config updates..."
            source ~/.zshrc # "exec zsh" or "source ~/.zshrc"
        fi

        # Install the latest Jekyll and Bundler gems
        log_info "Install the latest Jekyll gem..."
        gem install jekyll
        log_info "Install the latest Bundler gem..."
        gem install bundler
    fi

    # Check versions
    log_info "Check Ruby version 3.4.1 ..."
    ruby -v     # ruby 3.4.1
    log_info "Check Jekyll version >=4.4.1 ..."
    jekyll -v   # jekyll 4.4.1
    log_info "Check Bundler version >=2.6.9 ..."
    bundler -v  # bundler 2.6.9

    # Run Homebrew diagnostics, as an FYI.
    log_info "Run Homebrew diagnostics, as an FYI..."
    brew doctor

    log_info "==> Done."
}

# The main() function handles input validation. It is the script's entry point.
function main() {
    log_header "Jekyll SSG (Static Site Generator) Installer/Updater"

    # Parse script arguments.
    local args=( "${@}" )
    local ignored=()
    local used=()
    local verbosity help
    while (( $# )); do
        case "$1" in
            (-v=*|--verbosity=*) verbosity="${1#*=}" ; used+=(${1}) ;;
            (-h|--help)          help=true           ; used+=(${1}) ;;
            (*)                                        ignored+=(${1}) ;;
        esac
        shift
    done

    # Display usage information if requested.
    if [[ "${help}" == "true" ]]; then
        usage
    fi

    # Set the global verbosity mode.
    if [[ ! "${verbosity}" =~ ${_VERBOSITY_REGEX} ]]; then
        verbosity=${_DEFAULT_VERBOSITY}
    fi
    LOG_VERBOSITY=${verbosity}

    # Display processed arguments.
    log_info "Arguments processed:"
    log_info "  Input args:  \t[${args}]"
    log_info "  Used/Ignored:\t[${used}]/[${ignored}]"
    log_info "Effective settings:"
    log_info "  Verbosity:   \t[${verbosity}] (default: [${_DEFAULT_VERBOSITY}])"

    # Make sure all required variables are populated.
    if [[ -z "${verbosity}" ]]; then
        abort "Invalid internal state. Check default settings."
    fi

    # Execute the core logic.
    process
}

# Call the main() script function.
main "${@}"
