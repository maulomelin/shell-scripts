#!/bin/zsh
#--------------------------------------+--------------------------------------#
# SPDX-FileCopyrightText: (c) 2025 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier: MIT
# SPDX-FileComment: Logging Library.
#--------------------------------------+--------------------------------------#
# Comments:
#   - Module namespaces: "LOG_", "BOX_".
#   - The module supports 3 log levels: ERROR, INFO, DEBUG.
#   - There are core logging functions for each level: log_error(), log_info(),
#     log_debug(); and extended ones: log_header(), log_warning(), etc.
#   - The global variable LOG_VERBOSITY controls the visibility of log levels.
#          [----------------------Log Level Visibility----------------------]
#          [Name][Level][---Verbosity---][-----------Description------------]
#                        <=0  1   2  >=3
#           ERROR   1     N   Y   Y   Y   Potential script failures.
#           INFO    2     N   N   Y   Y   Progress, status, or general info.
#           DEBUG   3     N   N   N   Y   Debugging information.
#       - A log message is displayed if its log level <= log verbosity:
#       - The default value for LOG_VERBOSITY is 2.
#   - LOG_VERBOSITY is configurable by any script that sources this module.
#   - All log levels are written out to stderr.
#   - An internal logger is used to debug all the functions in this module
#     (i.e., _debug_*_() functions). The global variable LOG_MODULE_DEBUG
#     toggles the output of internal debug information to stderr.
#--------------------------------------+--------------------------------------#

# Module config settings.
readonly LOG_TAB="  "
readonly LOG_INDENT="+ " # · . +-
readonly LOG_DATETIME_FORMAT="+%Y-%m-%dT%H:%M:%S"
readonly LOG_INTEGER_REGEX="^[+-]?[0-9]+$"
readonly LOG_MULTILINE_MERGE_AND_SPLIT=true # (Default: true)
readonly LOG_MODULE_DEBUG=false             # (Default: false)
readonly -A LOG_LEVEL=( [ERROR]=1 [INFO]=2 [DEBUG]=3 [DEFAULT]=2 )

# Module config settings (externally configurable).
LOG_VERBOSITY=${LOG_LEVEL[DEFAULT]}

# Box-drawing characters.
         #corner-top-left      #border-top       #corner-top-right
readonly BOX_CTL="+"           BOX_BT="-"        BOX_CTR="+"
         #border-left   #pad-left   #pad-right   #border-right
readonly BOX_BL="|"     BOX_PL=" "  BOX_PR=" "   BOX_BR="|"
         #corner-bottom-left   #border_bottom    #corner-bottom-right
readonly BOX_CBL="+"           BOX_BB="-"        BOX_CBR="+"

# Terminal escape sequence encoder (defined globally for performance reasons).
if [[ -t 2 ]]; then # Suppress terminal formatting if stderr is not a terminal.
    function tty_escseq() { printf "%b" "\e[${@}m" }
else
    function tty_escseq() { :; }
fi
# String formatters (defined globally for performance reasons).
fmt_reset="$(tty_escseq 0)" # Reset all attributes to normal text.
fmt_bold="$(tty_escseq 1)";         fmt_bold_reset="$(tty_escseq 22)"
fmt_dim="$(tty_escseq 2)";          fmt_dim_reset="$(tty_escseq 22)"
fmt_italic="$(tty_escseq 3)";       fmt_italic_reset="$(tty_escseq 23)"
fmt_underline="$(tty_escseq 4)";    fmt_underline_reset="$(tty_escseq 24)"
fmt_blink="$(tty_escseq 5)";        fmt_blink_reset="$(tty_escseq 25)"
fmt_reverse="$(tty_escseq 7)";      fmt_reverse_reset="$(tty_escseq 27)"
fmt_hide="$(tty_escseq 8)";         fmt_hide_reset="$(tty_escseq 28)"
fmt_strikeout="$(tty_escseq 9)";    fmt_strikeout_reset="$(tty_escseq 29)"
fmt_black="$(tty_escseq 30)";       fmt_bright_black="$(tty_escseq 90)"
fmt_red="$(tty_escseq 31)";         fmt_bright_red="$(tty_escseq 91)"
fmt_green="$(tty_escseq 32)";       fmt_bright_green="$(tty_escseq 92)"
fmt_yellow="$(tty_escseq 33)";      fmt_bright_yellow="$(tty_escseq 93)"
fmt_blue="$(tty_escseq 34)";        fmt_bright_blue="$(tty_escseq 94)"
fmt_magenta="$(tty_escseq 35)";     fmt_bright_magenta="$(tty_escseq 95)"
fmt_cyan="$(tty_escseq 36)";        fmt_bright_cyan="$(tty_escseq 96)"
fmt_white="$(tty_escseq 37)";       fmt_bright_white="$(tty_escseq 97)"

#--------------------------------------+--------------------------------------#
# Synopsis:
#   log_(info|debug|warning|error|...) [<string>*]
#
# Description:
#   - Each logging function defines a pipeline of formatting functions that
#     format a log message before being printed to an appropriate stream.
#       - The log message is created by combining all input <string>s.
#       - The standard stream for all log messages is stderr.
#       - Formatting functions modify a log message by adding string prefixes
#         and/or changing its display attributes via embedded SGR codes.
#           - Although most formatting is doable with _format() and _prefix()
#             alone, additional formatting utilities exist:
#               - _box() does not fit the format/prefix model.
#               - _timestamp() and _indent() ensure output consistency.
#   - The module supports 3 different log levels: ERROR, INFO, DEBUG.
#   - The global variable LOG_VERBOSITY controls the visibility of log levels.
#          [----------------------Log Level Visibility----------------------]
#          [Name][Level][---Verbosity---][-----------Description------------]
#                        <=0  1   2  >=3
#           ERROR   1     N   Y   Y   Y   Potential script failures.
#           INFO    2     N   N   Y   Y   Progress, status, or general info.
#           DEBUG   3     N   N   N   Y   Debugging information.
#   - LOG_VERBOSITY is configurable by any script that sources this module.
#
# Globals:
#   LOG_VERBOSITY
#   LOG_LEVEL[]
#
# Arguments:
#   <string>    A list of strings.
#
# Output:
#   - Prints a log-formatted message to stderr, if the verbosity level allows.
#     If LOG_VERBOSITY is not set, or is set to an unrecognized value,
#     it defaults to LOG_LEVEL[DEFAULT].
#
# Comments:
#   - Some logging functions were created for convenience in reading the
#     output on a terminal (e.g., log_header(), log_start(), log_end()).
#--------------------------------------+--------------------------------------#
# Core logging functions.
function log_error()   { _print ${LOG_LEVEL[ERROR]} "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_red"    "$(_prefix "[ERROR] " "$(_indent "${@}")")")")" }
function log_warning() { _print ${LOG_LEVEL[ERROR]} "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_yellow" "$(_prefix "[ WARN] " "$(_indent "${@}")")")")" }
function log_info()    { _print ${LOG_LEVEL[INFO]}  "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_green"  "$(_prefix "[ INFO] " "$(_indent "${@}")")")")" }
function log_header()  { _print ${LOG_LEVEL[INFO]}  "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_green"  "$(_prefix "[ INFO] " "$(_indent "$(_box "${@}")")")")")" }
function log_debug()   { _print ${LOG_LEVEL[DEBUG]} "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_white"  "$(_prefix "[DEBUG] " "$(_indent "${@}")")")")" }

# Convenient logging functions.
function log_start()   { _print ${LOG_LEVEL[INFO]}  "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_green"  "$(_prefix "[ INFO] " "$(_indent "$(_prefix "START: " "${@}")")")")")" }
function log_end()     { _print ${LOG_LEVEL[INFO]}  "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_green"  "$(_prefix "[ INFO] " "$(_indent "$(_prefix "END: "   "${@}")")")")")" }
function log_xxx()     { _print ${LOG_LEVEL[INFO]}  "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "cyan"          "$(_prefix "[XXXXX] " "$(_indent "${@}")")")")" }

# Log message display.
function _print() {
    local verbosity=${LOG_VERBOSITY:-}      # Validate LOG_VERBOSITY as an int.
    if [[ ! ${verbosity} =~ ${LOG_INTEGER_REGEX} ]]; then
        verbosity=${LOG_LEVEL[DEFAULT]}
    fi
    local level=${1:-LOG_LEVEL[DEFAULT]}    # Get the message's log level.
    if (( $# >= 1 )); then shift; fi        # Shift to the message, if any.
    if (( level <= verbosity )); then       # Print only if level <= verbosity.
        echo "${@}" >&2
    fi
}

#--------------------------------------+--------------------------------------#
# Synopsis:
#   _format [<format> [<string>*]]
#
# Description:
#   - Applies a pre-defined <format> to every line in a log message.
#   - The log message is created from all input <string>s.
#
# Globals:
#   LOG_TAB
#
# Arguments:
#   <format>    A string with whitespace-delimited format codes to apply.
#   <string>    A list of strings.
#
# Output:
#   - A multiline string.
#--------------------------------------+--------------------------------------#
function _format() {
    _debug_start_ "Apply formatting to the message."

    # Extract the format codes.
    _debug_info_ "Extract format codes..."
    local format=${1:-}                     # Get the format string, if any.
    local codes=(${=format})                # Split string to get format codes.
    if (( $# >= 1 )); then shift; fi        # Shift to string args, if any.
    _debug_info_ "Format string: [${format}]"
    _debug_array_ ${codes}

    # Normalize inputs into a single multiline string.
    _debug_info_ "Normalize inputs into a single multiline string..."
    local multiline=$(_to_multiline ${@})   # Make a multiline from the args.

    # Process the multiline.
    _debug_info_ "Create an array of lines and apply all format codes to each line in the array..."
    local lines=(${(f)multiline})           # Create an array of lines.
    local i j out="" prefix suffix
    for (( i = 1; i <= ${#codes}; i++ )); do
        case "${codes[i]}" in
            (bold)           prefix=${fmt_bold};           suffix=${fmt_bold_reset} ;;
            (dim)            prefix=${fmt_dim};            suffix=${fmt_dim_reset} ;;
            (italic)         prefix=${fmt_italic};         suffix=${fmt_italic_reset} ;;
            (underline)      prefix=${fmt_underline};      suffix=${fmt_underline_reset} ;;
            (blink)          prefix=${fmt_blink};          suffix=${fmt_blink_reset} ;;
            (reverse)        prefix=${fmt_reverse};        suffix=${fmt_reverse_reset} ;;
            (hide)           prefix=${fmt_hide};           suffix=${fmt_hide_reset} ;;
            (strikeout)      prefix=${fmt_strikeout};      suffix=${fmt_strikeout_reset} ;;
            (black)          prefix=${fmt_black};          suffix=${fmt_reset} ;;
            (red)            prefix=${fmt_red};            suffix=${fmt_reset} ;;
            (green)          prefix=${fmt_green};          suffix=${fmt_reset} ;;
            (yellow)         prefix=${fmt_yellow};         suffix=${fmt_reset} ;;
            (blue)           prefix=${fmt_blue};           suffix=${fmt_reset} ;;
            (magenta)        prefix=${fmt_magenta};        suffix=${fmt_reset} ;;
            (cyan)           prefix=${fmt_cyan};           suffix=${fmt_reset} ;;
            (white)          prefix=${fmt_white};          suffix=${fmt_reset} ;;
            (bright_black)   prefix=${fmt_bright_black};   suffix=${fmt_reset} ;;
            (bright_red)     prefix=${fmt_bright_red};     suffix=${fmt_reset} ;;
            (bright_green)   prefix=${fmt_bright_green};   suffix=${fmt_reset} ;;
            (bright_yellow)  prefix=${fmt_bright_yellow};  suffix=${fmt_reset} ;;
            (bright_blue)    prefix=${fmt_bright_blue};    suffix=${fmt_reset} ;;
            (bright_magenta) prefix=${fmt_bright_magenta}; suffix=${fmt_reset} ;;
            (bright_cyan)    prefix=${fmt_bright_cyan};    suffix=${fmt_reset} ;;
            (bright_white)   prefix=${fmt_bright_white};   suffix=${fmt_reset} ;;
            (*)              prefix="";                    suffix=""
                             _debug_info_ "Unknown format code [${codes[i]}]" ;;
        esac

        _debug_info_ "Apply format code [${codes[i]}] to every line in the array..."
        for (( j = 1; j <= ${#lines}; j++ )); do
            _debug_info_ "${LOG_TAB}${codes[i]}: [${lines[j]}] ==> [${prefix}${lines[j]}${suffix}]"
            lines[j]="${prefix}${lines[j]}${suffix}"
        done
    done

    # Return a multiline.
    _debug_info_ "Join all lines into a single multiline string using newline as a separator..."
    local multiline=${(F)lines}             # Generate the multiline string.
    _debug_multiline_ ${multiline}
    echo "${multiline}"                     # Return the multiline string.
}

#--------------------------------------+--------------------------------------#
# Synopsis:
#   _prefix [<prefix>] [<string>*]
#
# Description:
#   - Prepends a <prefix> string to every line in a log message.
#   - The log message is created from all input <string>s.
#
# Globals:
#   LOG_TAB
#
# Arguments:
#   <prefix>    A prefix string.
#   <string>    A list of strings.
#
# Output:
#   - A multiline string.
#
# Comments:
#   - Although "$(_multiline "[FOOBAR]" "${@}")" could be used to prepend the
#     list of args with "[FOOBAR]", it would only do so once at the start of
#     the multiline; _prefix() prepends a prefix at the start of every line.
#--------------------------------------+--------------------------------------#
function _prefix() {
    _debug_start_ "Append a prefix label to a message."

    # Extract the prefix.
    _debug_info_ "Extract the prefix..."
    local prefix=${1:-}                     # Get the prefix argument, if any.
    if (( $# >= 1 )); then shift; fi        # Shift to string args, if any.
    _debug_info_ "${LOG_TAB}prefix: [${prefix}]"

    # Normalize inputs into a single multiline string.
    _debug_info_ "Normalize inputs into a single multiline string..."
    local multiline=$(_to_multiline ${@})   # Make a multiline from the args.

    # Process the multiline.
    _debug_info_ "Prepend a prefix to every line and store in a new string..."
    local lines=(${(f)multiline})           # Create an array of lines.
    local i line out=""                     # Label each line.
    for i in {1..${#lines:-1}}; do          # ":-1" to force at least one pass.
        line="${prefix}${lines[i]:-}"
        out+=${line}"\n"
        _debug_info_ "${LOG_TAB}[${line}]"
    done

    # Return a multiline.
    _debug_info_ "Generate a prefixed multiline from the new string..."
    multiline=$(_to_multiline ${out})       # Create a new multiline.
    echo "${multiline}"                     # Return the new multiline.
}

#--------------------------------------+--------------------------------------#
# Synopsis:
#   _timestamp [<string>*]
#
# Description:
#   - Appends a datetime prefix to every line in a log message.
#   - The log message is created from all input <string>s.
#
# Globals:
#   LOG_DATETIME_FORMAT
#   LOG_TAB
#
# Arguments:
#   <string>    A list of strings.
#
# Output:
#   - A multiline string.
#--------------------------------------+--------------------------------------#
function _timestamp() {
    _debug_start_ "Timestamp a message by adding a date/time prefix."

    # Normalize inputs into a single multiline string.
    _debug_info_ "Normalize inputs into a single multiline string..."
    local multiline=$(_to_multiline ${@})   # Make a multiline from the args.

    # Process the multiline.
    _debug_info_ "Timestamp every line and store in a new string..."
    local lines=(${(f)multiline})           # Create an array of lines.
    local i line out=""                     # Datetime-stamp each line.
    for i in {1..${#lines:-1}}; do          # ":-1" to force at least one pass.
        line="[$(date ${LOG_DATETIME_FORMAT})]${lines[i]:-}"
        out+=${line}"\n"
        _debug_info_ "${LOG_TAB}[${line}]"
    done

    # Return a multiline.
    _debug_info_ "Generate a timestamped multiline from the new string..."
    multiline=$(_to_multiline ${out})       # Create a new multiline.
    echo "${multiline}"                     # Return the new multiline.
}

#--------------------------------------+--------------------------------------#
# Synopsis:
#   _box [<string>*]
#
# Description:
#   - Draw a box around a log message.
#   - The log message is created from all input <string>s.
#
# Globals:
#   BOX_CTL       BOX_BT       BOX_CTR
#   BOX_BL   BOX_PL    BOX_PR   BOX_BR
#   BOX_CBL       BOX_BB       BOX_CBR
#   LOG_TAB
#
# Arguments:
#   <string>    A list of strings.
#
# Output:
#   - A multiline string with a box around it, drawn with ASCII characters.
#     If no input strings are provided, an empty box is rendered.
#--------------------------------------+--------------------------------------#
function _box() {
    _debug_start_ "Draw a box around a message."

    # Normalize inputs into a single multiline string.
    _debug_info_ "Normalize inputs into a single multiline string..."
    local multiline=$(_to_multiline ${@})   # Make a multiline from the args.

    # Process the multiline.
    _debug_info_ "Create an array of display lines and dimensionalize the box..."
    local lines=(${(f)multiline})           # Create an array of lines.
    local clines=(${(S)lines//$'\e'\[*m/})  # Remove SGR codes for clean lines.
    local masks=(${(@O)clines[@]//?/x})     # Mask and sort the clean lines.
    local content_box_w=${#masks[1]:-}      # Fetch the longest line's length.
    local padding_box_w=$(( ${#BOX_PL} + ${content_box_w} + ${#BOX_PR} ))
    _debug_info_ "Box dimensions:"
    _debug_info_ "${LOG_TAB}[content box] = [${content_box_w}]"
    _debug_info_ "${LOG_TAB}[padding box] = [${padding_box_w}]"
    _debug_info_ "Draw a box around all lines and store in a new string..."
    local i line padding_len padding out="" # Draw a box around all lines.
    line="${BOX_CTL}${(pr:$padding_box_w::$BOX_BT:):-}${BOX_CTR}"   # top.
    out+=${line}"\n"
    _debug_info_ "${LOG_TAB}[${line}]"
    for i in {1..${#lines:-1}}; do          # ":-1" to force at least one pass.
        padding_len=$(( ${content_box_w} - ${#clines[i]:-} ))
        padding=${(pr:$padding_len::$BOX_PR:):-}
        line="${BOX_BL}${BOX_PL}${lines[i]:-}${padding}${BOX_PR}${BOX_BR}"
        out+=${line}"\n"
        _debug_info_ "${LOG_TAB}[${line}]"
    done
    line="${BOX_CBL}${(pr:$padding_box_w::$BOX_BB:):-}${BOX_CBR}"   # bottom.
    out+=${line}"\n"
    _debug_info_ "${LOG_TAB}[${line}]"

    # Return a multiline.
    _debug_info_ "Generate the boxed multiline from the new string..."
    multiline=$(_to_multiline ${out})       # Create a new multiline.
    echo "${multiline}"                     # Return the new multiline.
}

#--------------------------------------+--------------------------------------#
# Synopsis:
#   _indent [<string>*]
#
# Description:
#   - Indents every line in a log message with the calling function's call
#     depth and prefixes it with that function's name.
#   - The log message is created from all input <string>s.
#   - The indentation corresponds to one tab for every nested function call.
#   - We use funcstack[@] to access the call stack:
#           funcstack[1]=self
#           funcstack[2]=caller
#           funcstack[3]=caller's parent
#           funcstack[4+]=caller's grand-parents
#     This function is designed to be invoked by loggers, so use funcstack[3].
#
# Globals:
#   SCRIPT_FILENAME
#   LOG_INDENT
#   LOG_TAB
#
# Arguments:
#   <string>    A list of strings.
#
# Output:
#   - A multiline string.
#--------------------------------------+--------------------------------------#
function _indent() {
    _debug_start_ "Indent the message based on the function call stack."

    # Normalize inputs into a single multiline string.
    _debug_info_ "Normalize inputs into a single multiline string..."
    local multiline=$(_to_multiline ${@})   # Make a multiline from the args.

    # Process the multiline.
    _debug_info_ "Calculate the prefix and indent:"
    local lines=(${(f)multiline})           # Create an array of lines.
    local lvl=3                             # Set level for caller's parent.
    local caller                            # Get logger's caller's name.
    if [[ -z ${funcstack[lvl]:-} ]]; then
        caller=${SCRIPT_FILENAME:-SCRIPT_FILENAME}": "
    else
        caller=${funcstack[${lvl}]}"(): "
    fi
    local i indent                          # Generate the indent string.
    for (( i = lvl + 1; i <= ${#funcstack[@]}; i++ )); do
        indent+=${LOG_INDENT}
    done
    _debug_info_ "${LOG_TAB}caller=[${caller}]"
    _debug_info_ "${LOG_TAB}indent=[${indent}]"
    _debug_info_ "Prefix and indent every line and store in a new string..."
    local line out=""                       # Indent and prefix each line.
    for i in {1..${#lines:-1}}; do          # ":-1" to force at least one pass.
        line="${indent}${caller}${lines[i]:-}"
        out+=${line}"\n"
        _debug_info_ "${LOG_TAB}[${line}]"
    done

    # Return a multiline.
    _debug_info_ "Generate the prefixed/indented multiline from the string..."
    multiline=$(_to_multiline ${out})       # Create a new multiline.
    echo "${multiline}"                     # Return the new multiline.
}

#--------------------------------------+--------------------------------------#
# Usage:
#   _to_multiline [<string>*]
#
# Description:
#   - Converts all input strings into a single multiline log message.
#       - A multiline is a single string whose escape sequences (e.g., "\n")
#         have been converted into control characters (e.g., $'\n').
#       - It is a $'\n'-delimited string created from all input <string>s.
#       - This enables any logging utility function to process them uniformly
#         and reliably.
#   - Background:
#       - An "Escape Sequence" (esc_seq) is the plaintext representation of a
#         control character, such as "\n" (for newline) or "\t" (for tab),
#         that users typically type as inputs into a script.
#         These sequences are 2+ characters usually start with a backslash.
#       - A "Control Character" (ctrl_char) is non-printable special character
#         that is used to control some aspect of a device (e.g., $'\b\ rings a
#         a bell), format text (e.g., $'\v' renders a vertical tab), or embed
#         text formatting (e.g., $'\e'[1mABC$'\e'[0m renders "ABC" in bold).
#       - Shell commands like "echo" and "printf" can recognize and convert
#         escape sequences into control characters (e.g., "\n" --> $'\n').
#       - Without normalizing escape sequences, more logic is required across
#         utility functions to hande both "\e" and $'\e' because user strings
#         have escape sequences, while strings from functions have control
#         characters, and each requires a different substitution command
#         (i.e., "${string//'\e'/ESC}" vs. "${string//$'\e'/ESC}").
#   - To convert a list of strings into a single multiline string:
#       - First, create an array of input strings, converting escape sequences
#         (e.g., "\n") into control characters (i.e., $'\n'):
#             local args=(); printf -v args "%b" ${@}
#         This conversion ensures we can consistently and reliably process only
#         control characters in a string.
#           - "printf", "echo" convert the same esc_seq's --> ctrl_char's.
#           - "-v" with an array stores each arg as an array element.
#           - "%b" makes "printf" recognize and convert esc-seq --> ctrl-char.
#       - Next, normalize every string in the array by changing ctrl_chars to
#         print-friendly replacements for this logging framework.
#           - Always replace ctrl_char with ctrl_char, to avoid reconverting.
#           - See escape sequences recognized by both "echo" and "printf" in
#             "The Z Shell Manual", v5.9, pgs. 148, 162, 192.
#           - This can get complicated, since sequences like "\r\f" == "\n"
#             but we want to keep it simple, so we do simple char replacement.
#           - The logging framework sometimes uses the plaintext version of a
#             message to calculate things like display width. Some chars like
#             vertical tabs (i.e., $'\v') or backspaces (i.e., $'\b') would
#             yield incorrect results. Thus, we only replace control chars that
#             would change the structure of the corresponding plaintext string:
#                 \a bell             --> remove, else "sound" takes 1 space.
#                 \b backspace        --> remove, not supported by multiline.
#                 \c suppress line    --> ignore; only "echo" recognizes it.
#                 \e escape           --> n/a; used to encode SGR codes.
#                 \f form feed        --> convert to $'\n'.
#                 \n newline          --> n/a; used as line delimiter.
#                 \r carriage return  --> convert to $'\n'.
#                 \t horizontal tab   --> convert to ${LOG_TAB} (N "spaces").
#                 \v vertical tab     --> convert to $'\n'.
#                 \\ backslash        --> n/a; control char (CC) width 1.
#                 \0NNN char code in octal             --> n/a; CC width 1.
#                 \xNN char code in hex                --> n/a; CC width 1.
#                 \uNNNN unicode char code in hex      --> n/a; CC width 1.
#                 \UNNNNNNNN unicode char code in hex  --> n/a; CC width 1.
#                   - Some Unicode characters are wider than 1 character,
#                     but to keep it simple we will assume width 1 for all.
#           - HINT: To debug ctrl_chars, change them to text to print them:
#                 args=( ${args//$'\e'/ESC} )
#                 args=( ${args//$'\u'/UNICODE} )
#       - Then, convert the array into lines. Since the function takes any
#         number of string args, and each string arg can have any number of
#         embedded newlines, there are two ways to convert the array:
#           1) Treat each arg as its own line, split each arg at newlines,
#              and then merge all resulting lines into a multiline:
#                 local lines=( ${(@f)${args}} )
#           2) Merge all args into a single string, split the merged string at
#              newlines, and then merge all resulting lines into a multiline:
#                 local lines=( ${(f)${args}} )
#         This option is configurable via a module config setting:
#             LOG_MULTILINE_MERGE_AND_SPLIT=(true|false)  # (Default: false)
#       - Finally, join the resulting lines into a single multiline string
#         using the newline control character:
#             local multiline=${(F)lines}
#
# Globals:
#   LOG_MULTILINE_MERGE_AND_SPLIT
#   LOG_TAB
#
# Arguments:
#   <string>    A list of strings.
#
# Output:
#   - A multiline string.
#
# References:
#   - See escape sequences in "The Z Shell Manual", v5.9, pgs. 148, 162, 192.
#     https://zsh.sourceforge.io/Doc/zsh_us.pdf
#--------------------------------------+--------------------------------------#
function _to_multiline() {
    _debug_start_ "Convert input strings into a single multiline string."

    _debug_info_ "Convert escape sequences --> control characters in every input string..."
    local args=(); printf -v args "%b" ${@} # Convert esc_seqs --> ctrl_chars.
    args=( ${args//$'\a'/} )                # Remove bell sound.
    args=( ${args//$'\b'/} )                # Remove backspace.
    args=( ${args//$'\f'/$'\n'} )           # form feed --> newline.
    args=( ${args//$'\r'/$'\n'} )           # carriage return --> newline.
    args=( ${args//$'\t'/${LOG_TAB}} )      # horizontal tab --> spaces.
    args=( ${args//$'\v'/$'\n'} )           # vertical tab --> newline.
    #args=( ${args//$'\e'/ESC} )            # DEBUG
    if [[ ${LOG_MULTILINE_MERGE_AND_SPLIT:-true} == false ]]; then
        _debug_info_ "Generate lines by splitting individual input strings by newline..."
        local lines=( ${(@f)${args}} )      # Split args into lines.
    else
        _debug_info_ "Generate lines by concatenating all input strings, then splitting by newline..."
        local lines=( ${(f)${args}} )       # Merge args then split into lines.
    fi
    _debug_info_ "Join all lines into a single multiline string using newline as a separator..."
    local multiline=${(F)lines}             # Generate the multiline string.
    _debug_multiline_ ${multiline}
    echo "${multiline}"                     # Return the multiline string.
}

#--------------------------------------+--------------------------------------#
# Usage:
#   _debug_start_ [<string>*]
#   _debug_info_ [<string>*]
#   _debug_multiline_ [<string>*]
#
# Description:
#   - A very simple, internal logger used to debug functions in logging module.
#
# Globals:
#   SCRIPT_FILENAME
#   LOG_DATETIME_FORMAT
#   LOG_MODULE_DEBUG
#   LOG_TAB
#
# Options:
#   <string>    A list of strings to log.
#
# Output:
#   - Prints simple log-formatted messages to stderr.
#--------------------------------------+--------------------------------------#
function _debug_start_() { _print_ "START: ${@}" }
function _debug_info_()  { _print_ "${@}" }
function _debug_array_() {
    _print_ "Array details:"
    if (( ${#@} == 0 )); then
        _print_ "${LOG_TAB}[]: Empty array."
    else
        local x array=(${@})
        for (( x = 1; x <= ${#array[@]}; x++ ))
            do _print_ "${LOG_TAB}[${x}]: [${array[x]}]"
        done
    fi
}
function _debug_multiline_() {
    _print_ "Multiline string details:"
    local lines=(${(f)@})
    if (( ${#lines} == 0 )); then
        _print_ "${LOG_TAB}[]: Empty multiline."
    else
        local x
        for (( x = 1; x <= ${#lines[@]}; x++ ))
            do _print_ "${LOG_TAB}[${x}]: [${lines[x]}][${#lines[x]}]"
        done
    fi
}
function _print_() {
    if [[ ${LOG_MODULE_DEBUG:-false} == true ]]; then
        local message="${@}"                # Get the log message.
        local lvl=3                         # Set level for logger's caller.
        local caller                        # Get logger's caller's name.
        if [[ -z ${funcstack[lvl]:-} ]]; then
            caller=${SCRIPT_FILENAME}": "
        else
            caller=${funcstack[${lvl}]}"(): "
        fi
        local i indent=""                   # Generate the indent string.
        for (( i = lvl + 1; i <= ${#funcstack[@]}; i++ )); do
            indent+=${LOG_TAB}
        done
        message="[$(date ${LOG_DATETIME_FORMAT})] [DEBUG] ${indent}${caller}${message}"
        echo "${message}" >&2               # Print the message to stderr.
    fi
}
