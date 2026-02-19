#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2024 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: REG (Global Registry)
# SPDX-FileComment: <text>
#   Access the global registry directly via ${REG[<key>]}.
#   It is implemented as a read-only associative array.
#   This makes all values immutable and makes getter functions unecessary.
# </text>
# -----------------------------------------------------------------------------

# Initialize public registry.
typeset -grA REG=(
    [DATETIME_FORMAT]="+%Y-%m-%dT%H:%M:%S"
    [AFFIRMATIVE_REGEX]="^[yY]([eE][sS])?$"
    [LOG_LEVEL_REGEX]="^[01234]$"
    [DEFAULT_LOG_LEVEL]=3
    [VERBOSITY_REGEX]="^[01234]$"
    [DEFAULT_VERBOSITY]=3
    [BATCH_REGEX]="^(true|false)$"
    [DEFAULT_BATCH]=false
)