#!/bin/zsh
#--------------------------------------+--------------------------------------#
# SPDX-FileCopyrightText: (c) 2025 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier: MIT
# SPDX-FileComment: System Information Library.
#--------------------------------------+--------------------------------------#

#--------------------------------------+--------------------------------------#
# Synopsis:
#   display_sgr_codes
#
# Description:
#   - Display SGR codes in a table for reference/lookup.
#   - Text on a terminal can be formatted by embedding ANSI escape sequences
#     into an output string. The escape sequence supported by "echo"/"print"
#     is the Select Graphic Rendition (SGR) sequence, with the following form:
#           <ESC>[<attribs>m
#     where:
#           <ESC> = {`\e`, `\033`, `\1xB`}
#           <attribs> = <code>[;<code>]*
#     For example:
#           \e[1;91;4mBright red underlined text\e0m
#     Note: <ESC>="\1xB" does not work in our environment.
#   - The following table is a high-level summary of codes:
#       Codes       Effect
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
#       38;5;<n>    8-bit/256-color foreground (<n>=[0-255])
#       38;2;<rgb>  24-bit/true color foreground (<rgb> --> <r>;<g>;<b>)
#       40-47       Basic background colors
#       48;5;<n>    8-bit/256-color background (<n>=[0-255])
#       48;2;<rgb>  24-bit/true color background (<rgb> --> <r>;<g>;<b>)
#       90-97       Basic bright foreground colors
#       100-107     Basic bright background colors
#
# Outputs:
#   - A table showing all SGR codes from 0-255, including all 8-bit foreground
#     color and 8-bit background color codes.
#
# References:
#   https://en.wikipedia.org/wiki/ANSI_escape_code#SGR
#   https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
#   https://strasis.com/documentation/limelight-xe/reference/ecma-48-sgr-codes
#   https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
#--------------------------------------+--------------------------------------#
function display_sgr_codes() {
    local i
    for i in $(seq 0 255) ; do
        printf "\e[${i}mSGR Escape Sequence: \\\e[${i}m\e[0m"
        printf "\t"
        printf "\e[38;5;${i}mSGR Escape Sequence: \\\e[38;5;${i}m\e[0m"
        printf "\t"
        printf "\e[48;5;${i}mSGR Escape Sequence: \\\e[48;5;${i}m\e[0m"
        printf "\n"
    done
}

#--------------------------------------+--------------------------------------#
# Synopsis:
#   _print_shell_variables [<file>]
#
# Description:
#   - Display shell environment variables to stdout or to a specified file.
#
# Arguments:
#   <file>      If a file is specified, output is sent to it, else to stdout.
#               If the file exists, it is overwritten; else, a new one created.
# Outputs:
#   - The shell environment variables are echoed to stdout or to a file.
#--------------------------------------+--------------------------------------#
function display_shell_variables() {
    local output="${1:-/dev/stdout}"
    printf "\n=====> SHELL VARIABLES (\`$ set\`) <=====\n" > "${output}"
    set >> "${output}"
    printf "\n=====> ENVIRONMENT VARIABLES (\`$ env\`) <=====\n" >> "${output}"
    env >> "${output}"
}
