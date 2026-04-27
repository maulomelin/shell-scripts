#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Setup: General Utilities
# -----------------------------------------------------------------------------

function () {
    # --------------------------------------
    log::info_header "Setup: Wine (run Windows applications on macOS)"
    #   - https://www.winehq.org/
    # --------------------------------------

    # Check if Homebrew is installed.
    if ! command -v brew &> /dev/null ; then
        log::error "Error installing Wine: Homebrew is not installed."
        log::error "Please install Homebrew and try again."
        return 1
    fi

    # Install Wine.
    log::warning "Installation of Wine is disabled because it does not pass the macOS Gatekeeper check !"
    log::info "To install Wine manually with Homebrew:"
    log::info "  $ brew install --cask wine-stable"
    # brew install --cask wine-stable

} || return 1