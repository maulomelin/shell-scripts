#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2024 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: LOG (Logging)
# -----------------------------------------------------------------------------
# TODO: Do we write a module init routine to validate all registry variables,
#       such as verbosity? Do we need to ensure default/init values are valid
#       or trust the module author? Is the latter enough for personal scripts?
# -----------------------------------------------------------------------------

# Initialize private registry.
typeset -gA _LOG=(
    [TAB]="  "
    [INDENTATION]="+ " # · . +-
    [DATETIME_FORMAT]="+%Y-%m-%dT%H:%M:%S"
    [VERBOSITY_REGEX]="^[01234]$"
    [DEFAULT_VERBOSITY]=3
    [LOG_LEVEL_REGEX]="^[01234]$"
    [DEFAULT_LOG_LEVEL]=3
    [LOG_LEVEL_ALERT]=0
    [LOG_LEVEL_ERROR]=1
    [LOG_LEVEL_WARNING]=2
    [LOG_LEVEL_INFO]=3
    [LOG_LEVEL_DEBUG]=4
    [MULTILINE_MERGE_AND_SPLIT]=true  # (true|false) (Default: true)
    [MODULE_DEBUG]=false  # (true|false) (Default: false)
)

# Initialize public registry.
typeset -gA LOG=(
    [verbosity]=${_LOG[DEFAULT_VERBOSITY]}
)

# -----------------------------------------------------------------------------
# Syntax:   log_get_verbosity
# Args:     None.
# Outputs:  Current verbosity level from the public registry.
# Returns:  Default exit status.
# Notes:
#   - Creating a single getter/setter log_verbosity() function is difficult.
#     It needs to set a global flag and generate a return value. Using command
#     substitution to capture the return value, `x=$(log_verbosity X)`, runs
#     the function in a subshell, which makes changing global flags not persist
#     in the parent shell. Thus, we kept separate get and set functions.
# -----------------------------------------------------------------------------
function log_get_verbosity() {
    echo "${LOG[verbosity]}"
}

# -----------------------------------------------------------------------------
# Syntax:   log_set_verbosity <level>
# Args:     <level>     Verbosity level.
# Outputs:  None.
# Returns:  Default exit status.
# Caution:  This function modifies the public registry. Do not call it inside a
#           subshell, including: in a pipe `... | ...`, in parentheses `(...)`,
#           or in command substitution `$(...)`, as these create subshells and
#           registry changes will not propagate back to the parent shell.
# Details:
#   - Validates <level>. If valid, the verbosity level in the public registry
#     is set to <level>. If invalid, the verbosity level is not changed.
# -----------------------------------------------------------------------------
function log_set_verbosity() {
    local verbosity=${1:-}
    if [[ ${verbosity} =~ ${_LOG[VERBOSITY_REGEX]} ]]; then
        __debug_info "Setting verbosity level to [${verbosity}]."
        LOG[verbosity]=${verbosity}
    else
        __debug_info "Invalid verbosity level [${verbosity}]. Staying at current level [${LOG[verbosity]}]."
    fi
}

# -----------------------------------------------------------------------------
# Syntax:   log_(alert|error|warning|info|debug)[_<modifier>] [<string> ...]
# Args:     <string>    A list of strings to be joined, formatted, and
#                       displayed by the logging function used.
# Outputs:  Formatted text to stderr, if the log level is <= current verbosity.
#           Otherwise, no output is produced.
# Returns:  Default exit status.
# Details:
#   - There are five logging levels:
#       +-----------+----------------------------+
#       | Log Level | Recommended Message Type   |
#       +-----------+----------------------------+
#       | 0/Alert   | Required messaging.        |
#       | 1/Error   | Script failures.           |
#       | 2/Warning | Potential script failures. |
#       | 3/Info    | General info, status.      |
#       | 4/Debug   | Debug info.                |
#       +-----------+----------------------------+
#   - Each logging function, log_*(), defines its logging level and a pipeline
#     of formatting functions to format a log message before printing.
#       - Core logging functions are named after the log levels:
#           log_alert(), log_error(), log_warning(), log_info(), log_debug()
#       - Modifier logging functions simply define different formatting
#         at their respective log level:
#           log_info_header(), log_info_start(), etc.
#   - The verbosity level sets the display threshold for logging levels.
#     A log message is displayed only if its log level <= verbosity level:
#       +------------------+---------------------+
#       |   Log Message    |   Verbosity Level   |
#       |     Display      |  0   1   2   3   4  |
#       +------------------+---------------------+
#       |        0/Alert   |  Y   Y   Y   Y   Y  |
#       |  Log   1/Error   |  N   Y   Y   Y   Y  |
#       | Level  2/Warning |  N   N   Y   Y   Y  |
#       |        3/Info    |  N   N   N   Y   Y  |
#       |        4/Debug   |  N   N   N   N   Y  |
#       +------------------+---------------------+
#   - Formatting functions format a log message by adding string prefixes
#     and/or changing its display attributes via embedded SGR codes.
# -----------------------------------------------------------------------------
function log_alert()       { _print ${_LOG[LOG_LEVEL_ALERT]}   "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "blink"         "$(_prefix "[ALERT] " "$(_indent "${@}")")")")" }
function log_error()       { _print ${_LOG[LOG_LEVEL_ERROR]}   "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_red"    "$(_prefix "[ERROR] " "$(_indent "${@}")")")")" }
function log_warning()     { _print ${_LOG[LOG_LEVEL_WARNING]} "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_orange" "$(_prefix "[WARN]  " "$(_indent "${@}")")")")" }
function log_info()        { _print ${_LOG[LOG_LEVEL_INFO]}    "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_green"  "$(_prefix "[INFO]  " "$(_indent "${@}")")")")" }
function log_info_header() { _print ${_LOG[LOG_LEVEL_INFO]}    "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_green"  "$(_prefix "[INFO]  " "$(_indent "$(_box "${@}")")")")")" }
function log_info_start()  { _print ${_LOG[LOG_LEVEL_INFO]}    "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_green"  "$(_prefix "[INFO]  " "$(_indent "$(_prefix "START: " "${@}")")")")")" }
function log_info_end()    { _print ${_LOG[LOG_LEVEL_INFO]}    "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_green"  "$(_prefix "[INFO]  " "$(_indent "$(_prefix "END: "   "${@}")")")")")" }
function log_info_xxx()    { _print ${_LOG[LOG_LEVEL_INFO]}    "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "cyan"          "$(_prefix "[INFO]  " "$(_indent "${@}")")")")" }
function log_debug()       { _print ${_LOG[LOG_LEVEL_DEBUG]}   "$(_prefix "$(_format "dim" "$(_timestamp)")" "$(_format "bright_blue"   "$(_prefix "[DEBUG] " "$(_indent "${@}")")")")" }

# -----------------------------------------------------------------------------
# Syntax:   _print <level> [<string> ...]
# Args:     <level>     Log level integer.
#           <string>    A list of strings.
# Outputs:  Sends all strings to stderr if <level> is <= current verbosity.
#           Otherwise, no output is produced.
# Returns:  Default exit status.
# Details:
#   - If <level> is not an integer, the default verbosity level is used.
# -----------------------------------------------------------------------------
function _print() {
    # Set up local variables from module registry for easier access.
    local verbosity=${LOG[verbosity]:-}

    # Validate the log level and set to default if invalid.
    local level=${1:-}
    if [[ ! ${level} =~ ${_LOG[LOG_LEVEL_REGEX]} ]]; then
        log_alert "Invalid log level [${level}]. Setting it to default [${_LOG[DEFAULT_LOG_LEVEL]}]."
        level=${_LOG[DEFAULT_LOG_LEVEL]}
    fi

    # Print the message if its log level is <= the current verbosity level.
    if (( $# >= 1 )); then shift; fi        # Shift to the message, if any.
    if (( level <= verbosity )); then       # Print only if level <= verbosity.
        echo "${@}" >&2
    fi
}

# -----------------------------------------------------------------------------
# Syntax:   _format [<format> [<string> ...]]
# Args:     <format>    Whitespace-delimited format codes.
#           <string>    A list of strings.
# Outputs:  A multiline string where each line is one <format>ed <string>.
# Returns:  Default exit status.
# Details:
#   - A format code represents embedded SGR code prefixes & suffixes.
#   - Formatting prefixes & suffixes are applied to every <string>.
#   - All formatted strings are joined into a single multiline string.
# -----------------------------------------------------------------------------
function _format() {
    __debug_start "Apply formatting to the message."

    # Set up local variables from module registry for easier access.
    local -r tab=${_LOG[TAB]}

    # Define terminal escape sequence encoder.
    # TODO: Consider suppressing it if stderr is not a terminal:
    #       if [[ -t 2 ]] { function tty_escseq() { printf "%b" "\e[${@}m" } } else { function tty_escseq() { :; } }
    function tty_escseq() { printf "%b" "\e[${@}m" }

    # Extract the format codes.
    __debug_info "Extract format codes..."
    local format=${1:-}                     # Get the format string, if any.
    local codes=(${=format})                # Split string to get format codes.
    if (( $# >= 1 )); then shift; fi        # Shift to string args, if any.
    __debug_info "Format string: [${format}]"
    __debug_array ${codes}

    # Normalize inputs into a single multiline string.
    __debug_info "Normalize inputs into a single multiline string..."
    local multiline=$(_to_multiline ${@})   # Make a multiline from the args.

    # Process the multiline.
    __debug_info "Create an array of lines and apply all format codes to each line in the array..."
    local lines=(${(f)multiline})           # Create an array of lines.
    local i out="" prefix suffix
    for (( i = 1; i <= ${#codes}; i++ )); do
        # Determine string formatters to apply.
        case "${codes[i]}" in
            (bold)           prefix=$(tty_escseq 1);          suffix=$(tty_escseq 22) ;;
            (dim)            prefix=$(tty_escseq 2);          suffix=$(tty_escseq 22) ;;
            (italic)         prefix=$(tty_escseq 3);          suffix=$(tty_escseq 23) ;;
            (underline)      prefix=$(tty_escseq 4);          suffix=$(tty_escseq 24) ;;
            (blink)          prefix=$(tty_escseq 5);          suffix=$(tty_escseq 25) ;;
            (reverse)        prefix=$(tty_escseq 7);          suffix=$(tty_escseq 27) ;;
            (hide)           prefix=$(tty_escseq 8);          suffix=$(tty_escseq 28) ;;
            (strikeout)      prefix=$(tty_escseq 9);          suffix=$(tty_escseq 29) ;;
            (black)          prefix=$(tty_escseq 30);         suffix=$(tty_escseq 0) ;;
            (red)            prefix=$(tty_escseq 31);         suffix=$(tty_escseq 0) ;;
            (green)          prefix=$(tty_escseq 32);         suffix=$(tty_escseq 0) ;;
            (yellow)         prefix=$(tty_escseq 33);         suffix=$(tty_escseq 0) ;;
            (blue)           prefix=$(tty_escseq 34);         suffix=$(tty_escseq 0) ;;
            (magenta)        prefix=$(tty_escseq 35);         suffix=$(tty_escseq 0) ;;
            (cyan)           prefix=$(tty_escseq 36);         suffix=$(tty_escseq 0) ;;
            (white)          prefix=$(tty_escseq 37);         suffix=$(tty_escseq 0) ;;
            (bright_black)   prefix=$(tty_escseq 90);         suffix=$(tty_escseq 0) ;;
            (bright_red)     prefix=$(tty_escseq 91);         suffix=$(tty_escseq 0) ;;
            (bright_green)   prefix=$(tty_escseq 92);         suffix=$(tty_escseq 0) ;;
            (bright_yellow)  prefix=$(tty_escseq 93);         suffix=$(tty_escseq 0) ;;
            (bright_blue)    prefix=$(tty_escseq 94);         suffix=$(tty_escseq 0) ;;
            (bright_magenta) prefix=$(tty_escseq 95);         suffix=$(tty_escseq 0) ;;
            (bright_cyan)    prefix=$(tty_escseq 96);         suffix=$(tty_escseq 0) ;;
            (bright_white)   prefix=$(tty_escseq 97);         suffix=$(tty_escseq 0) ;;
            (orange)         prefix=$(tty_escseq "38;5;208"); suffix=$(tty_escseq 0) ;;
            (bright_orange)  prefix=$(tty_escseq "38;5;214"); suffix=$(tty_escseq 0) ;;
            (orangered)      prefix=$(tty_escseq "38;5;202"); suffix=$(tty_escseq 0) ;;
            (*)              prefix="";                       suffix=""
                             __debug_info "Unknown format code [${codes[i]}]" ;;
        esac

        __debug_info "Apply format code [${codes[i]}] to every line in the array..."
        local j
        for (( j = 1; j <= ${#lines}; j++ )); do
            __debug_info "${tab}${codes[i]}: [${lines[j]}] ==> [${prefix}${lines[j]}${suffix}]"
            lines[j]="${prefix}${lines[j]}${suffix}"
        done
    done

    # Return a multiline.
    __debug_info "Join all lines into a single multiline string using newline as a separator..."
    local multiline=${(F)lines}             # Generate the multiline string.
    __debug_multiline ${multiline}
    echo "${multiline}"                     # Return the multiline string.
}

# -----------------------------------------------------------------------------
# Syntax:   _prefix [<prefix>] [<string> ...]
# Args:     <prefix>    A sprefix string.
#           <string>    A list of strings.
# Outputs:  A multiline string where each line is <prefix> + <string>.
# Returns:  Default exit status.
# Details:
#   - The <prefix> string is prepended to every <string>.
#   - All prefixed strings are joined into a single multiline string.
# -----------------------------------------------------------------------------
function _prefix() {
    __debug_start "Append a prefix label to a message."

    # Set up local variables from module registry for easier access.
    local -r tab=${_LOG[TAB]}

    # Extract the prefix.
    __debug_info "Extract the prefix..."
    local prefix=${1:-}                     # Get the prefix argument, if any.
    if (( $# >= 1 )); then shift; fi        # Shift to string args, if any.
    __debug_info "${tab}prefix: [${prefix}]"

    # Normalize inputs into a single multiline string.
    __debug_info "Normalize inputs into a single multiline string..."
    local multiline=$(_to_multiline ${@})   # Make a multiline from the args.

    # Process the multiline.
    __debug_info "Prepend a prefix to every line and store in a new string..."
    local lines=(${(f)multiline})           # Create an array of lines.
    local i line out=""                     # Label each line.
    for i in {1..${#lines:-1}}; do          # ":-1" to force at least one pass.
        line="${prefix}${lines[i]:-}"
        out+=${line}"\n"
        __debug_info "${tab}[${line}]"
    done

    # Return a multiline.
    __debug_info "Generate a prefixed multiline from the new string..."
    multiline=$(_to_multiline ${out})       # Create a new multiline.
    echo "${multiline}"                     # Return the new multiline.
}

# -----------------------------------------------------------------------------
# Syntax:   _timestamp [<string> ...]
# Args:     <string>    A list of strings.
# Outputs:  A multiline string where each line is {datetime}stamp + <string>.
# Returns:  Default exit status.
# Details:
#   - A datetime string is prepended to every <string>.
#   - All timestamped strings are joined into a single multiline string.
# -----------------------------------------------------------------------------
function _timestamp() {
    __debug_start "Timestamp a message by adding a date/time prefix."

    # Set up local variables from module registry for easier access.
    local -r tab=${_LOG[TAB]}
    local -r datetime_format=${_LOG[DATETIME_FORMAT]}

    # Normalize inputs into a single multiline string.
    __debug_info "Normalize inputs into a single multiline string..."
    local multiline=$(_to_multiline ${@})   # Make a multiline from the args.

    # Process the multiline.
    __debug_info "Timestamp every line and store in a new string..."
    local lines=(${(f)multiline})           # Create an array of lines.
    local i line out=""                     # Datetime-stamp each line.
    for i in {1..${#lines:-1}}; do          # ":-1" to force at least one pass.
        line="[$(date ${datetime_format})]${lines[i]:-}"
        out+=${line}"\n"
        __debug_info "${tab}[${line}]"
    done

    # Return a multiline.
    __debug_info "Generate a timestamped multiline from the new string..."
    multiline=$(_to_multiline ${out})       # Create a new multiline.
    echo "${multiline}"                     # Return the new multiline.
}

# -----------------------------------------------------------------------------
# Syntax:   _box [<string> ...]
# Args:     <string>    A list of strings.
# Outputs:  A multiline string where each line is a <string> and additional
#           lines, prefixes, and suffixes that box all lines with ASCII chars.
#           If no strings are given, an empty box is rendered.
# Returns:  Default exit status.
# Details:
#   - To draw a box around various lines of text:
#       1. Find the longest <string> and calculate the width of the box.
#            - Remove all SGR codes from each <string> before measuring
#              because formatting codes take space but do not render.
#       2. Draw the top line.
#       3. Make each line {left_border} + <string> + {right_border}.
#       4. Draw the bottom line.
#   - All "boxed" strings are joined into a single multiline string.
# -----------------------------------------------------------------------------
function _box() {
    __debug_start "Draw a box around a message."

    # Set up local variables from module registry for easier access.
    local -r tab=${_LOG[TAB]}

    # Define box-drawing characters.
          #corner-top-left      #border-top       #corner-top-right
    local BOX_CTL="+"           BOX_BT="-"        BOX_CTR="+"
          #border-left   #pad-left   #pad-right   #border-right
    local BOX_BL="|"     BOX_PL=" "  BOX_PR=" "   BOX_BR="|"
          #corner-bottom-left   #border_bottom    #corner-bottom-right
    local BOX_CBL="+"           BOX_BB="-"        BOX_CBR="+"

    # Normalize inputs into a single multiline string.
    __debug_info "Normalize inputs into a single multiline string..."
    local multiline=$(_to_multiline ${@})   # Make a multiline from the args.

    # Process the multiline.
    __debug_info "Create an array of display lines and dimensionalize the box..."
    local lines=(${(f)multiline})           # Create an array of lines.
    local clines=(${(S)lines//$'\e'\[*m/})  # Remove SGR codes for clean lines.
    local masks=(${(@O)clines[@]//?/x})     # Mask and sort the clean lines.
    local content_box_w=${#masks[1]:-}      # Fetch the longest line's length.
    local padding_box_w=$(( ${#BOX_PL} + ${content_box_w} + ${#BOX_PR} ))
    __debug_info "Box dimensions:"
    __debug_info "${tab}[content box] = [${content_box_w}]"
    __debug_info "${tab}[padding box] = [${padding_box_w}]"
    __debug_info "Draw a box around all lines and store in a new string..."
    local i line padding_len padding out="" # Draw a box around all lines.
    line="${BOX_CTL}${(pr:$padding_box_w::$BOX_BT:):-}${BOX_CTR}"   # top.
    out+=${line}"\n"
    __debug_info "${tab}[${line}]"
    for i in {1..${#lines:-1}}; do          # ":-1" to force at least one pass.
        padding_len=$(( ${content_box_w} - ${#clines[i]:-} ))
        padding=${(pr:$padding_len::$BOX_PR:):-}
        line="${BOX_BL}${BOX_PL}${lines[i]:-}${padding}${BOX_PR}${BOX_BR}"
        out+=${line}"\n"
        __debug_info "${tab}[${line}]"
    done
    line="${BOX_CBL}${(pr:$padding_box_w::$BOX_BB:):-}${BOX_CBR}"   # bottom.
    out+=${line}"\n"
    __debug_info "${tab}[${line}]"

    # Return a multiline.
    __debug_info "Generate the boxed multiline from the new string..."
    multiline=$(_to_multiline ${out})       # Create a new multiline.
    echo "${multiline}"                     # Return the new multiline.
}

# -----------------------------------------------------------------------------
# Syntax:   _indent [<string> ...]
# Args:     <string>    A list of strings.
# Outputs:  A multiline string where each line is {indent}+{caller}+<string>.
#           {indent} is based on the calling function's call depth.
#           {caller} is the name of the function making this request.
# Returns:  Default exit status.
# Details:
#   - The {indent} string is configurable in the module's registry.
#   - Total indentation equals one {indent} for every nested function call.
#   - The {caller} name is pulled from the call stack, funcstack[@]:
#           funcstack[1]=self
#           funcstack[2]=caller
#           funcstack[3]=caller's parent
#           funcstack[4+]=caller's grand+-parents
#     This function is designed to be invoked by loggers, so use funcstack[3].
#   - All "indented" strings are joined into a single multiline string.
# -----------------------------------------------------------------------------
function _indent() {
    __debug_start "Indent the message based on the function call stack."

    # Set up local variables from module registry for easier access.
    local -r tab=${_LOG[TAB]}
    local -r indentation=${_LOG[INDENTATION]}

    # Normalize inputs into a single multiline string.
    __debug_info "Normalize inputs into a single multiline string..."
    local multiline=$(_to_multiline ${@})   # Make a multiline from the args.

    # Process the multiline.
    __debug_info "Calculate the prefix and indent:"
    local lines=(${(f)multiline})           # Create an array of lines.
    local lvl=3                             # Set level for caller's parent.
    local caller                            # Get logger's caller's name.
    if [[ -z ${funcstack[lvl]:-} ]]; then
        caller=${ZSH_ARGZERO:A:t}": "
    else
        caller=${funcstack[${lvl}]}"(): "
    fi
    local i indent=""                       # Generate the indent string.
    for (( i = lvl + 1; i <= ${#funcstack[@]}; i++ )); do
        indent+=${indentation}
    done
    __debug_info "${tab}caller=[${caller}]"
    __debug_info "${tab}indent=[${indent}]"
    __debug_info "Prefix and indent every line and store in a new string..."
    local i line out=""                     # Indent and prefix each line.
    for i in {1..${#lines:-1}}; do          # ":-1" to force at least one pass.
        line="${indent}${caller}${lines[i]:-}"
        out+=${line}"\n"
        __debug_info "${tab}[${line}]"
    done

    # Return a multiline.
    __debug_info "Generate the prefixed/indented multiline from the string..."
    multiline=$(_to_multiline ${out})       # Create a new multiline.
    echo "${multiline}"                     # Return the new multiline.
}

# -----------------------------------------------------------------------------
# Syntax:   _to_multiline [<string> ...]
# Args:     <string>    A list of strings.
# Outputs:  A multiline string where each line is one <string>.
# Returns:  Default exit status.
# Details:
#   - A multiline is an $'\n'-delimited string created from all <string>s.
#     It is a single string whose "escape sequences" (e.g., "\n") have been
#     converted into "control characters" (e.g., $'\n'). We use multistrings
#     to process log messages uniformly and reliably.
#   - "Escape sequences" are textual representation of control characters
#     (e.g. "\n" for newline, "\t" for tab).
#   - "Control characters" are non-printable special characters
#     (e.g., $'\b\ rings a a bell, $'\e'[1mABC$'\e'[0m makes "ABC" bold).
#   - Shell commands like "echo" and "printf" can recognize and convert
#     escape sequences into control characters (e.g., "\n" --> $'\n').
#   - We normalize escape sequences to avoid handling multiple escape formats:
#     I.e., `${string//'\e'/ESC}` and/or/vs. `${string//$'\e'/ESC}`.
#   - To convert a list of strings into a single multiline string:
#       1. Create an array of input strings with escape sequences converted
#          into control characters so we only handle ctrl chars:
#            local args=(); printf -v args "%b" ${@}
#            - "printf", "echo" convert the same esc_seq's --> ctrl_char's.
#            - "-v" with an array stores each arg as an array element.
#            - "%b" makes "printf" recognize and convert esc-seq --> ctrl-char.
#       2. Normalize the array by changing ctrl chars to print-friendly chars:
#            - Always replace ctrl_char with ctrl_char, to avoid reconverting.
#            - See escape sequences recognized by both "echo" and "printf" in
#              "The Z Shell Manual", v5.9, pgs. 148, 162, 192.
#            - This can get complicated, since sequences like "\r\f" == "\n"
#              but we want to keep it simple, so we do simple char replacement.
#            - The logging framework sometimes uses the plaintext version of a
#              message to calculate things like display width. Some chars like
#              vertical tabs (i.e., $'\v') or backspaces (i.e., $'\b') would
#              give incorrect results. Thus, only replace control chars that
#              can change the structure of the corresponding plaintext string:
#                  \a bell             --> remove, else "sound" takes 1 space.
#                  \b backspace        --> remove, not supported by multiline.
#                  \c suppress line    --> ignore; only "echo" recognizes it.
#                  \e escape           --> n/a; used to encode SGR codes.
#                  \f form feed        --> convert to $'\n'.
#                  \n newline          --> n/a; used as line delimiter.
#                  \r carriage return  --> convert to $'\n'.
#                  \t horizontal tab   --> convert to ${_LOG[TAB]} (N spaces).
#                  \v vertical tab     --> convert to $'\n'.
#                  \\ backslash        --> n/a; control char (CC) width 1.
#                  \0NNN char code in octal             --> n/a; CC width 1.
#                  \xNN char code in hex                --> n/a; CC width 1.
#                  \uNNNN unicode char code in hex      --> n/a; CC width 1.
#                  \UNNNNNNNN unicode char code in hex  --> n/a; CC width 1.
#                    - Some Unicode characters are wider than 1 character,
#                      but to keep it simple we will assume width 1 for all.
#            - HINT: To debug ctrl_chars, change them to text to print them:
#                args=( ${args//$'\e'/ESC} )
#                args=( ${args//$'\u'/UNICODE} )
#       3. Convert the array into lines. Since the function takes any number
#          of strings and each string can have any number of embedded newlines,
#          there are two ways to convert the array:
#           a) Treat each arg as its own line, split each arg at newlines,
#              and then merge all resulting lines into a multiline:
#                local lines=( ${(@f)${args}} )
#           b) Merge all args into a single string, split the merged string at
#              newlines, and then merge all resulting lines into a multiline:
#                local lines=( ${(f)${args}} )
#          This option is configurable via a registry entry:
#            _LOG[MULTILINE_MERGE_AND_SPLIT]=(true|false)  # (Default: false)
#       4. Join the resulting lines into a single multiline string
#          using the newline control character:
#            local multiline=${(F)lines}
# Sources:
#   - See escape sequences in "The Z Shell Manual", v5.9, pgs. 148, 162, 192.
#     https://zsh.sourceforge.io/Doc/zsh_us.pdf
# -----------------------------------------------------------------------------
function _to_multiline() {
    __debug_start "Convert input strings into a single multiline string."

    # Set up local variables from module registry for easier access.
    local -r tab=${_LOG[TAB]}
    local -r multiline_merge_and_split=${_LOG[MULTILINE_MERGE_AND_SPLIT]}

    __debug_info "Convert escape sequences --> control characters in every input string..."
    local args=(); printf -v args "%b" ${@} # Convert esc_seqs --> ctrl_chars.
    args=( ${args//$'\a'/} )                # Remove bell sound.
    args=( ${args//$'\b'/} )                # Remove backspace.
    args=( ${args//$'\f'/$'\n'} )           # form feed --> newline.
    args=( ${args//$'\r'/$'\n'} )           # carriage return --> newline.
    args=( ${args//$'\t'/${tab}} )          # horizontal tab --> spaces.
    args=( ${args//$'\v'/$'\n'} )           # vertical tab --> newline.
    #args=( ${args//$'\e'/ESC} )            # DEBUG: Output SGR codes.
    if [[ ${multiline_merge_and_split:-true} == false ]]; then
        __debug_info "Generate lines by splitting individual input strings by newline..."
        local lines=( ${(@f)${args}} )      # Split args into lines.
    else
        __debug_info "Generate lines by concatenating all input strings, then splitting by newline..."
        local lines=( ${(f)${args}} )       # Merge args then split into lines.
    fi
    __debug_info "Join all lines into a single multiline string using newline as a separator..."
    local multiline=${(F)lines}             # Generate the multiline string.
    __debug_multiline ${multiline}
    echo "${multiline}"                     # Return the multiline string.
}

# -----------------------------------------------------------------------------
# Syntax:   __debug_start [<string> ...]
#           __debug_info [<string> ...]
#           __debug_info [<string> ...]
#           __debug_multiline [<string> ...]
#           __print [<string> ...]
# Args:     <string>    A list of strings.
# Outputs:  Prints simple log-formatted messages to stderr.
# Returns:  Default exit status.
# Details:
#   - A very simple, internal logger used to debug the logging module itself.
#   - It can be toggled via a registry flag: _LOG[MODULE_DEBUG]=(true|false).
# -----------------------------------------------------------------------------
function __debug_start() { __print "START: ${@}" }
function __debug_info()  { __print "${@}" }
function __debug_array() {
    __print "Array details:"

    # Set up local variables from module registry for easier access.
    local -r tab=${_LOG[TAB]}

    if (( ${#@} == 0 )); then
        __print "${tab}[]: Empty array."
    else
        local x array=(${@})
        for (( x = 1; x <= ${#array[@]}; x++ ))
            do __print "${tab}[${x}]: [${array[x]}]"
        done
    fi
}
function __debug_multiline() {
    __print "Multiline string details:"

    # Set up local variables from module registry for easier access.
    local -r tab=${_LOG[TAB]}

    local lines=(${(f)@})
    if (( ${#lines} == 0 )); then
        __print "${tab}[]: Empty multiline."
    else
        local x
        for (( x = 1; x <= ${#lines[@]}; x++ ))
            do __print "${tab}[${x}]: [${lines[x]}][${#lines[x]}]"
        done
    fi
}
function __print() {

    # Set up local variables from module registry for easier access.
    local -r indentation=${_LOG[INDENTATION]}
    local -r datetime_format=${_LOG[DATETIME_FORMAT]}
    local -r module_debug=${_LOG[MODULE_DEBUG]}

    if [[ ${module_debug:-false} == true ]]; then
        local message="${@}"                # Get the log message.
        local lvl=3                         # Set level for logger's caller.
        local caller                        # Get logger's caller's name.
        if [[ -z ${funcstack[lvl]:-} ]]; then
            caller=${ZSH_ARGZERO:A:t}": "
        else
            caller=${funcstack[${lvl}]}"(): "
        fi
        local i indent=""                   # Generate the indent string.
        for (( i = lvl + 1; i <= ${#funcstack[@]}; i++ )); do
            indent+=${indentation}
        done
        message="[$(date ${datetime_format})] [DEBUG] ${indent}${caller}${message}"
        echo "${message}" >&2               # Print the message to stderr.
    fi
}