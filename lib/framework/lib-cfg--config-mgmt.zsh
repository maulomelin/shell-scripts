#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: CFG (Configuration Management)
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Syntax:   cfg::update_manifest <config_file> <config_block> <block_label>
# Args:     <config_file>   Path to a config file.
#           <config_block>  Multiline of config entries.
#           <block_label>   Label for the config block.
# Outputs:  None.
# Status:   return 0 (success).
#           return 1 (failure) if unable to carry out task.
# Details:
#   - Checks if the config file contains the config block.
#       - If the config block is present, no changes are made.
#       - If the config block is missing, it is written to the end of the file.
#           - The block label is used to create a fenced block.
#             The fenced block is written to the config file.
#   - Although a fenced block is written out, we only check if the config
#     block is present. This allows the fencing markers to be changed
#     without creating redundant entries of the same config block.
# -----------------------------------------------------------------------------
function cfg::update_manifest() {
    local min_args=3
    if (( $# < min_args )); then
        log::error "Unable to update manifest: Insufficient args (min: ${min_args}): (${(j:, :)@})"
        return 1
    fi
    local config_file=$1    # Path to config file to update.
    local config_block=$2   # Multiline of config entries.
    local block_label=$3    # Label for the config block.

    local manifest="$(<> ${config_file})"
    if [[ "${manifest}" == *"${config_block}"* ]]; then
        log::info "Config [${block_label}] already in [${config_file}]."
    else
        log::info "Config [${block_label}] not in [${config_file}]. Updating..."
        local fenced_block_array=(
            "# >>> ${block_label}"
            "${config_block}"
            "# <<< ${block_label}"
        )
        local fenced_block="${(F)fenced_block_array}"
        echo "\n${fenced_block}" >> "${config_file}" || {
            log::error "Failed to update [${config_file}] with config [${block_label}]."
            return 1
        }
    fi
}

