#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Setup: Visual Studio Code (VSCode)
# -----------------------------------------------------------------------------

function () {
    # --------------------------------------
    log::info_header "Setup: Visual Studio Code (VSCode)"
    #   - https://code.visualstudio.com/
    # --------------------------------------
    # Install the VSCode app.
    if open -Ra "visual studio code" &> /dev/null ; then
        log::info "VSCode is installed."
    else
        log::info "Please configure VSCode:"
        log::info "  [_] Log in with GitHub account."
        log::info "  [_] Turn on \"Settings Sync\" to preserve settings across devices."
        log::info "  [_] Verify/install extensions:"
        log::info "       [_] Python (by Microsoft)"
        log::info "       [_] Pylance (by Microsoft)"
        log::info "       [_] Python Debugger (by Microsoft)"
        log::info "       [_] GitHub Copilot (by GitHub)"
        log::info "       [_] GitHub Copilot Chat (by GitHub)"
        log::info "       [_] GitHub Repositories (by GitHub)"
        log::info "       [_] Remote Repositories (by Microsoft)"
        log::info "       [_] GitLens"
        log::info "       [_] Prettier - Code formatter"
        log::info "       [_] ESLint"
        log::info "       [_] Jupyter"
        log::info "       [_] Markdown All in One"
        log::info "       [_] PowerShell"
        log::info "       [_] Tailwind CSS IntelliSense"
        log::info "       [_] Azure extensions (if using Azure cloud)"
        log::info "       [_] AWS extensions (if using AWS cloud)"
        log::info "       [_] <add more here>"
        open https://code.visualstudio.com/
        read -r "?Press Enter to continue..."
    fi

    # Check VSCode's CLI tool (code). Add it to the PATH if not already there.
    if command -v code &> /dev/null ; then
        log::info "The VSCode CLI tool (code) is in the \${PATH}."
    else
        log::info "The VSCode CLI tool (code) is not in the \${PATH}. Adding it..."
        local vscode_label="Visual Studio Code (code)"
        local -a vscode_config_array=(
            "export PATH=\"\${PATH}:/Applications/Visual Studio Code.app/Contents/Resources/app/bin\""
        )
        local vscode_config="${(F)vscode_config_array}"
        cfg::update_manifest "${HOME}/.zprofile" "${vscode_config}" "${vscode_label}"
    fi
}