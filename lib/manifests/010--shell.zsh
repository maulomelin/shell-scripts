#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Setup: Visual Studio Code (VSCode)
# -----------------------------------------------------------------------------

function () {
    # --------------------------------------
    log::info_header "Setup: Shell prompt"
    #   - https://zsh.sourceforge.io/Guide/zshguide02.html#l19
    #   - https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
    #   - https://dev.to/cassidoo/customizing-my-zsh-prompt-3417
    #   - https://orrsella.com/2013/10/08/zsh-promp-format-with-date-time-and-current-directory/
    #   - https://github.com/ohmyzsh/ohmyzsh/wiki/themes
    # --------------------------------------
    local prompt_label="Shell Prompt"
    local -a prompt_config_array=(
        "# https://zsh.sourceforge.io/Guide/zshguide02.html#l19"
        "#PROMPT=\"%n@%m %1~ %# \"     # Original prompt"
        "#PROMPT=\"%F{green}[%~] {%?} [%D] %# %f\""
        "PROMPT=\"%B%F{226}[%?][%~] %# %f%b\""
    )
    local prompt_config="${(F)prompt_config_array}"
    cfg::update_manifest "${HOME}/.zshrc" "${prompt_config}" "${prompt_label}"

    # --------------------------------------
    log::info_header "TODO: Setup: Shell aliases"
    log::info_header "TODO: Setup: Shell functions"
    # --------------------------------------
}