#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Setup: Google Chrome
# -----------------------------------------------------------------------------

function () {
    # --------------------------------------
    log::info_header "Setup: Google Chrome"
    # --------------------------------------
    # Use ">& /dev/null" to suppress any output; we only want the status code.
    if open -Ra "google chrome" &> /dev/null ; then
        log::info "Google Chrome is installed."
    else
        log::info "Google Chrome is not installed. Launching the download page..."
        log::info "Please install and configure it:"
        log::info "  [_] Sign in with your Google account to sync bookmarks, history, and settings."
        log::info "  [_] Set Google Chrome as the default web browser."
        log::info "  [_] Install extensions:"
        log::info "        [_] uBlock Origin"
        log::info "        [_] JSON Formatter"
        open https://www.google.com/chrome/
        read -r "?Press Enter to continue..."
    fi

} || return 1