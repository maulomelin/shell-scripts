#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Setup: Ruby (chruby)
# -----------------------------------------------------------------------------

function () {
    # --------------------------------------
    log::info_header "Setup: Ruby (chruby)"
    #   - Use Ruby version manager (chruby).
    #   - https://github.com/postmodern/chruby
    # --------------------------------------

    # Check if Homebrew is installed.
    if ! command -v brew &> /dev/null ; then
        log::error "Error installing Ruby: Homebrew is not installed."
        log::error "Please install Homebrew and try again."
        return 1
    fi

    # Install chruby and ruby-install.
    brew install chruby
    brew install ruby-install

    # Install Ruby.
    ruby-install ruby 3.4.1     # The version we use for Jekyll.
    ruby-install ruby           # The current stable version of Ruby.

    # Configure chruby in .zshrc.
    local chruby_label="Ruby version manager (chruby)"
    local -a chruby_config_array=(
        "source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh"
        "source $(brew --prefix)/opt/chruby/share/chruby/auto.sh"
        "chruby ruby-3.4.1"
    )
    local chruby_config="${(F)chruby_config_array}"
    cfg::update_config "${HOME}/.zshrc" "${chruby_config}" "${chruby_label}" || {
        log::error "Failed to set the Ruby config in [${HOME}/.zshrc]."
        log::error "Check the config and try again."
        return 1
    }
    log::info "Run \"exec zsh\" to apply config updates."

} || return 1