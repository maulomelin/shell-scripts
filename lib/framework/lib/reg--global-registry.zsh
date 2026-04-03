#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2024 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment: <text>  [REG] Global Registry
#   - Access the global registry directly via ${REG[<key>]}.
#   - Implemented as a read-only associative array, making all values immutable
#     and getter functions unecessary.
# </text>
# -----------------------------------------------------------------------------

# Initialize public registry.
typeset -grA REG=(
    # Regular Expressions (REGEX_).
    #   - Booleans: "The Z Shell Manual" v5.9, § 20.3.3, pg. 261.
    #   - Use `[[ ${x:l} =~ ${regex} ]]` for case-insensitive string matching.
    [REGEX_BOOLEAN]="^(true|false|on|off|yes|no|1|0)$"
    [REGEX_TRUE]="^(true|on|yes|1)$"
    [REGEX_FALSE]="^(false|off|no|0)$"
    [REGEX_YES]="^y(es)?$"

    # Allowed paths are somewhat restrictive compared to real-world baselines.
    #   - macOS allows any keyboard character to be in a full path.
    #   - Keep "-" at the end of a bracket to avoid defining a character range.
    #   - To resolve potential ambiguities, internally we handle allowed paths
    #     as absolute paths and resolve any symlinks.
    [REGEX_ALLOWEDPATH]="^/([a-zA-Z0-9._/~-]+/?)*$"

    # These are in the script template and thus part of every script.
    [REGEX_VERBOSITY]="^[01234]$"
    [REGEX_LOG_LEVEL]="^[01234]$"
    [REGEX_BATCH]="^(true|false)$"

    # Log levels (LOG_LEVEL_).
    [LOG_LEVEL_ALERT]=0
    [LOG_LEVEL_ERROR]=1
    [LOG_LEVEL_WARNING]=2
    [LOG_LEVEL_INFO]=3
    [LOG_LEVEL_DEBUG]=4

    # String formats (FORMAT_).
    #   - "The Z Shell Manual" v5.9, § 13.2.4, pg. 42.
    [FORMAT_DATETIME_ISO8601]="%Y-%m-%dT%H:%M:%S"
    [FORMAT_DATETIME_SLUG]="%Y%m%dT%H%M%S"    # Milliseconds: "%." or "%3.".

    # Default values (DEFAULT_).
    [DEFAULT_LOG_LEVEL]=3
    [DEFAULT_VERBOSITY]=3
    [DEFAULT_BATCH]=false
    [DEFAULT_HELP]=false

    # Normalized values.
    [TRUE]=1
    [FALSE]=0
)