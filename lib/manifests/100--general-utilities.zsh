#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Setup: General Utilities
# -----------------------------------------------------------------------------

function () {
    # Check if Homebrew is installed.
    if ! command -v brew &> /dev/null ; then
        log::error "Error installing General Utilities: Homebrew is not installed."
        log::error "Please install Homebrew and try again."
        return 1
    fi

    # --------------------------------------
    log::info_header "Setup: Wine (run Windows applications on macOS)"
    #   - https://www.winehq.org/
    # --------------------------------------
    # brew install --cask wine-stable
    log::info "Installation of Wine is disabled because it does not pass the macOS Gatekeeper check !"
    log::info "To install Wine manually with Homebrew:"
    log::info "  $ brew install --cask wine-stable"

    # --------------------------------------
    log::info_header "Setup: VLC media player"
    #   - https://www.videolan.org/vlc/
    # --------------------------------------
    brew install --cask vlc

} || return 1