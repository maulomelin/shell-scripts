#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Setup: Python (uv)
# -----------------------------------------------------------------------------

function () {
    # --------------------------------------
    log::info_header "Setup: Python"
    #   - Use Python version manager (uv).
    #   - https://docs.astral.sh/uv/
    # --------------------------------------
    curl -LsSf https://astral.sh/uv/install.sh | sh
    uv python install       # Install the current stable version.
    log::info "Listing Python versions available with uv:"
    uv python list
}