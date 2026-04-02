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

    # Install the current stable versions of uv and Python.
    curl -LsSf https://astral.sh/uv/install.sh | sh
    uv python install

    # Check versions.
    log::info "Check uv version >=\"0.4.0\":"
    uv --version  # uv 0.4.0
    log::info "Check Python version >=\"3.12.0\":"
    uv python --version  # Python 3.12.0
    log::info "Listing Python versions available with uv:"
    uv python list

} || return 1