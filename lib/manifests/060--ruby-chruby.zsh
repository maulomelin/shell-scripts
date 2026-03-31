#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Setup: Ruby (chruby)
# -----------------------------------------------------------------------------

function () {
    # --------------------------------------
    log::info_header "Setup: Ruby"
    #   - Use Ruby version manager (chruby).
    #   - https://github.com/postmodern/chruby
    # --------------------------------------
    brew install chruby
    brew install ruby-install
    ruby-install ruby 3.4.1 # Install the version we use for Jekyll.

    # Configure chruby in .zshrc.
    local chruby_label="Ruby version manager (chruby)"
    local -a chruby_config_array=(
        "source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh"
        "source $(brew --prefix)/opt/chruby/share/chruby/auto.sh"
        "chruby ruby-3.4.1"
    )
    local chruby_config="${(F)chruby_config_array}"
    cfg::update_manifest "${HOME}/.zshrc" "${chruby_config}" "${chruby_label}"
}