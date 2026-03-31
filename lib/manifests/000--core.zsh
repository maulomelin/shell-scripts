#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Setup: Core Environment Tools
# -----------------------------------------------------------------------------

function () {
    # --------------------------------------
    log::info_header "Setup: Xcode Command Line Tools"
    #   - Set this up first. It is a dependency for Homebrew and other tools.
    # --------------------------------------
    if xcode-select -p &> /dev/null ; then
        log::info "Xcode Command Line Tools are installed."
    else
        log::info "Xcode Command Line Tools are not installed. Installing them..."
        xcode-select --install
        log::info "Please follow the prompts to complete the installation."
        read -r "?Press Enter to continue after installation is complete..."
    fi

    # --------------------------------------
    log::info_header "Setup: Homebrew"
    #   - Assumes Homebrew is installed in (/usr/local/bin/brew).
    # --------------------------------------
    if command -v brew &> /dev/null ; then
        log::info "Homebrew is installed. Updating it..."
        brew update
    else
        log::error "Homebrew is not installed. Installing it..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Load Homebrew into the current zsh shell session.
        # Note: We cannot call `$ brew --prefix` because it is not available
        #       in the current shell session yet. So we check the default
        #       installation path for macOS/Intel (i.e., /usr/local/bin/brew).
        if [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv zsh)"
        else
            log::error "Homebrew was installed but not found at /usr/local/bin/brew."
            sys::abort "Check the Homebrew installation and try again."
        fi
    fi

    # --------------------------------------
    log::info_header "Setup: Common CLI Tools"
    # --------------------------------------
    brew install coreutils      # GNU Coreutils
    brew install curl           # CLI URL
    brew install wget           # WWW Get
    brew install tree           # List folders graphically

    # --------------------------------------
    log::info_header "Setup: Git"
    # --------------------------------------
    if command -v git &> /dev/null ; then
        log::info "Git is installed."
    else
        log::info "Git is not installed. Installing it..."
        brew install git
    fi

    # Configure Git user.name and user.email.
    local user_name user_email
    user_name="$(git config get --global user.name)"
    user_email="$(git config get --global user.email)"
    if [[ -n "${user_name}" && -n "${user_email}" ]]; then
        log::info "Git is already configured with:"
        log::info "  user.name=[${user_name}]"
        log::info "  user.email=[${user_email}]"
    else
        if [[ -n "${_APP[USER_NAME]}" && -n "${_APP[USER_EMAIL]}" ]]; then
            log::info "Configuring Git with:"
            log::info "  user.name=[${_APP[USER_NAME]}]"
            log::info "  user.email=[${_APP[USER_EMAIL]}]"
            git config set --global user.name "${_APP[USER_NAME]}"
            git config set --global user.email "${_APP[USER_EMAIL]}"
        else
            log::warning "The app variables USER_NAME and USER_EMAIL were not configured."
            log::warning "Please configure Git with your name and email address:"
            log::warning "  \$ git config set --global user.name \"<your name>\""
            log::warning "  \$ git config set --global user.email \"<your email>\""
            read -r "?Press Enter to continue..."
        fi
    fi
    log::info "Git configuration:"
    git config --global --list

    # --------------------------------------
    log::info_header "Setup: Homebrew Maintenance"
    # --------------------------------------
    brew upgrade        # Upgrade installed software to newest versions.
    brew cleanup        # Remove old, unused versions of installed packages.
    brew doctor || {    # Check the system for potential issues.
        log::warning "Homebrew doctor found potential issues."
        log::warning "Please review the output above and address any warnings or errors."
        read -r "?Press Enter to continue..."
    }
}