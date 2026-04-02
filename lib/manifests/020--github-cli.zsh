#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Setup: GitHub CLI
# -----------------------------------------------------------------------------

function () {
    # --------------------------------------
    log::info_header "Setup: GitHub CLI"
    #   - https://cli.github.com/
    # --------------------------------------
    if command -v gh &> /dev/null ; then
        log::info "GitHub CLI is installed. Upgrading it..."
        brew upgrade gh
    else
        log::info "GitHub CLI is not installed. Installing it..."
        brew install gh
        log::info "Authenticating GitHub CLI with your GitHub account..."
        log::info "Answer \"yes\" when asked \"Authenticate Git with your GitHub credentials?\""
        log::info "A browser window will open to complete the authentication process."
        gh auth login --git-protocol https --hostname github.com --web
    fi

} || return 1