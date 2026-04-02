#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Setup: Node.js (nvm)
# -----------------------------------------------------------------------------

function () {
    # --------------------------------------
    log::info_header "Setup: Node.js (nvm)"
    #   - Use Node version manager (nvm).
    #   - https://nodejs.org/
    # --------------------------------------
    # Install nvm.
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
    \. "$HOME/.nvm/nvm.sh"  # In lieu of restarting the shell.
    log::info "Verify nvm version >= \"0.40.4\"..."
    nvm --version

    # Install the latest LTS version of Node.js (and npm).
    nvm install --lts
    log::info "Verify Node.js version >= \"v24.14.1\"..."
    node -v     # Verify Node.js version >= "v24.14.1".
    log::info "Verify npm version >= \"11.11.0\"..."
    npm -v      # Verify npm version >= "11.11.0".

} || return 1