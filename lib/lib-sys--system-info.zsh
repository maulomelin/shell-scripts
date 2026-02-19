#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2024 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: SYS (System Info)
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Syntax:   sys_shell_variables [<file>]
# Args:     <file>  File to write output to.
# Outputs:  Shell environment variables to stdout, or to <file> if provided.
# Returns:  Default exit status.
# Details:
#   - If <file> is not provided, output is written to stdout.
#   - If <file> is present, output is sent to it, else to stdout.
#   - If <file> exists, it is overwritten; else, a new one created.
# -----------------------------------------------------------------------------
function sys_shell_variables() {
    local output="${1:-/dev/stdout}"
    printf "\n=====> SHELL VARIABLES (\`$ set\`) <=====\n" > "${output}"
    set >> "${output}"
    printf "\n=====> ENVIRONMENT VARIABLES (\`$ env\`) <=====\n" >> "${output}"
    env >> "${output}"
}

# -----------------------------------------------------------------------------
# Syntax:   sys_sgr_codes
# Args:     None.
# Outputs:  A table showing all SGR codes from 0-255, to stderr.
#           Includes all 8-bit foreground and background color codes.
# Returns:  Default exit status.
# Notes:
#   - Text on a terminal is formatted by adding ANSI escape sequences to an
#     output string. The escape sequence supported by "echo" and "print" is
#     the Select Graphic Rendition (SGR) sequence. It has the following form:
#           <ESC>[<attribs>m
#     where:
#           <ESC> = {`\e`, `\033`, `\1xB`}
#           <attribs> = <code>[;<code>]*
#     For example:
#           \e[1;91;4mBright red underlined text\e0m
#     Note: <ESC>="\1xB" does not work in our environment.
#   - The following table is a high-level summary of codes:
#       Code        Effect
#       -----------------------------------------------------------------------
#       0           Reset all attributes
#       1           Bold/Bright
#       2           Faint/Dim
#       3           Italic
#       4           Underline
#       5           Blink
#       7           Inverse/Reverse (swap fore/background)
#       8           Conceal (hides, regardless of colors)
#       22          un-Dim/un-Bold
#       30-37       Basic foreground colors
#       38;5;{n}    8-bit/256-color foreground ({n}=[0-255] Xterm Number)
#       38;2;{rgb}  24-bit/true color foreground ({rgb} --> {r};{g};{b})
#       40-47       Basic background colors
#       48;5;{n}    8-bit/256-color background ({n}=[0-255] Xterm Number)
#       48;2;{rgb}  24-bit/true color background ({rgb} --> {r};{g};{b})
#       90-97       Basic bright foreground colors
#       100-107     Basic bright background colors
# Sources:
#   https://en.wikipedia.org/wiki/ANSI_escape_code#SGR
#   https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
#   https://strasis.com/documentation/limelight-xe/reference/ecma-48-sgr-codes
#   https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
#   https://www.ditig.com/256-colors-cheat-sheet
# -----------------------------------------------------------------------------
function sys_sgr_codes() {
    local label="SGR Escape Sequence"
    local -a escseq=(
        "Display Attributes"
        "8-bit Foreground Color"
        "8-bit Background Color"
    )
    local i
    for i in $(seq 0 255) ; do
        escseq+=(
            "\e[${i}m \\\e[${i}m ${label} \\\e[0m \e[0m"
            "\e[38;5;${i}m \\\e[38;5;${i}m ${label} \\\e[0m \e[0m"
            "\e[48;5;${i}m \\\e[48;5;${i}m ${label} \\\e[0m \e[0m"
        )
    done
    print -aC3 "${escseq[@]}"
}