#!/bin/zsh
#--------------------------------------+--------------------------------------#
# SPDX-FileCopyrightText: (c) 2025 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier: MIT
# SPDX-FileComment: Deprecated Functions Boneyard.
#--------------------------------------+--------------------------------------#
# Initialize script environment.
readonly SCRIPT_DIRPATH=$(dirname "${0}")
readonly SCRIPT_FILENAME=$(basename "${ZSH_ARGZERO}")
source "${SCRIPT_DIRPATH}/../lib/init.zsh"
#--------------------------------------+--------------------------------------#

#--------------------------------------+--------------------------------------#
# STATUS: DEPRECATED. Functionality integrated into _box().
# Usage:
#   _get_display_width [<string>*]
#
# Description:
#   Return the length of the longest printed line from all input strings.
#   Given any number of strings, this utility calculates the length of the
#   longest line as printed on the screen by removing any SGR codes.
#   This can be used to format boxes or tables where the length of the longest
#   line is needed to determine the size of the bounding box and paddings.
#   To determine the longest line length in many multi-lines:
#     - First, create a multi-line from the args and then a lines array.
#           local multiline=$(_to_multiline ${@})
#           local lines=( ${(f)multiline} )
#     - Next, remove any SGR codes from the lines:
#           local clines=( ${(S)lines//$'\e'\[*m/} )
#     - Then, mask all lines with "x"s and sort the masks:
#           local masks=( ${(@O)clines//?/x} )
#       This creates something like ( xxxxxxxx xxxxx xx xx x ).
#         - "O" sorts the result in descending alphabetic order.
#         - "@" treats the result as an array.
#           In zsh "${(@)array}" is equivalent to "${array[@]}",
#           where "array[@]" expands all elements of an array.
#           ${array} can expand to array[1], depending on shell settings.
#         - "//?/x" replaces each character in the array with an "x".
#           On strings with the same character, this orders them by length.
#     - Now, fetch the first/longest element of the sorted array.
#           local longest_mask=${masks[1]:-}
#       To make it safe for empty arrays, return an empty string.
#     - Finally, calculate and return the length of the longest mask:
#           local display_width=${#longest_mask}
#           return "${display_width}"
#   We *could* combine the last few lines into one command line:
#       local display_width=${#${(@O)clines//?/x}[1]:-}
#   But this is not as easy to follow and harder to maintain.
#
# Globals:
#   LOG_DEBUG
#
# Options:
#   <string>        A list of strings.
#
# Outputs:
#   0               If no strings are given.
#   0               If the longest string is empty.
#   <display_w>     If the longest string is not empty.
#--------------------------------------+--------------------------------------#
function DEPRECATED_get_display_width() {
    _log_info_ "Calculate the display width of all input strings."

    local multiline=$(_to_multiline ${@})   # Make a multi-line from the args.
    local lines=(${(f)multiline})           # Create an array of lines.
    local clines=(${(S)lines//$'\e'\[*m/})  # Remove SGR codes from the lines.
    local masks=(${(@O)clines[@]//?/x})     # Mask and sort the clean lines.
    local longest_mask=${masks[1]:-}        # Fetch the first/longest mask.
    local display_width=${#longest_mask}    # Calculate that mask's length.
    echo "${display_width}"                 # Return the display width.

    # DEBUG
    if [[ ${LOG_DEBUG:-false } == true ]]; then
        _log_debug_ "Plaintext lines:"
        local i; for ((i = 1; i<=${#lines[@]}; i++)); do
            _log_debug_ "  [${i}]: [${clines[i]}][${#clines[i]}] <-- [${lines[i]}][${#lines[i]}]"
        done
        _log_debug_ "sorted masks: (${(qq)masks[@]})"
        _log_debug_ "longest mask: [${(qq)longest_mask}]"
        _log_debug_ "display width: [${display_width}]"
    fi
}

#--------------------------------------+--------------------------------------#
# STATUS: DEPRECATED. Inefficient design.
# Synopsis:
#   is_item_in_list <item> <li> [<li>*]
#
# Description:
#   - Checks if <item> is in the list of items (<li>+) by comparing <item>
#     against every list item <li>.
#   - It needs at least 1 list item for a valid scan.
#
# Arguments:
#   <item>      The item to check.
#   <li>        List item to scan. At least one must be present.
#
# Returns:
#   2           Error: Wrong number of arguments (< 2).
#   1           Failure: Item not found in the list.
#   0           Success: Item found in the list.
#
# Comment:
#   - This function can be used in if (...) conditionals because
#     the clause looks for a return code instead of a return value.
#
# References:
#   https://stackoverflow.com/questions/2875424/correct-way-to-check-for-a-command-line-flag-in-bash
#--------------------------------------+--------------------------------------#
function DEPRECATED_is_item_in_list() {

    # Check for the required number of arguments.
    if (( ${#} < 2 )); then
        return 2  # Error: wrong number of arguments (< 2).
    fi

    # Check the list of arguments for the option.
    local item="${1}"   # Capture the item to check for.
    shift               # The rest of the arguments are in ${@}.
    local li
    for li in "${@}"; do
        if [[ "${item}" == "${li}" ]]; then
            return 0  # Success: option found in list.
        fi
    done
    return 1  # Failure: option not found in list.
}

#--------------------------------------+--------------------------------------#
# STATUS: DO NOT USE / BAD DESIGN. Message is scavenged if <suffix> is missing.
# Synopsis:
#   _wrap [<prefix>] [<string>*] [<suffix>]
#
# Description:
#   - Appends a <prefix> and a <suffix> string to every line in a log message.
#   - The log message is created from all input <string>s.
#
# Globals:
#   LOG_TAB
#
# Arguments:
#   <prefix>    A prefix string.
#   <string>    A list of strings.
#   <suffix>    A suffix string.
#
# Output:
#   - A multiline string.
#--------------------------------------+--------------------------------------#
function DEPRECATED_wrap() {
    _debug_start_ "Append prefix and suffix labels around a message."

    # Extract the prefix and suffix strings.
    _debug_info_ "Extract the prefix and suffix strings..."
    local prefix=${1:-}                     # Get the prefix argument, if any.
    if (( $# >= 1 )); then shift; fi        # Shift to remaining args, if any.
    local suffix=""                         # Get the suffix argument, if any.
    if (( ${#@} >= 1 )); then
        suffix=${@[-1]}
        shift -p                            # Shift to string args, if any.
    fi
    _debug_info_ "${LOG_TAB}prefix: [${prefix}][${#prefix}]"
    _debug_info_ "${LOG_TAB}suffix: [${suffix}][${#suffix}]"

    # Normalize inputs into a single multiline string.
    _debug_info_ "Normalize inputs into a single multiline string..."
    local multiline=$(_to_multiline ${@})   # Make a multiline from the args.

    # Process the multiline.
    _debug_info_ "Append a suffix to every line and store in a new string..."
    local lines=(${(f)multiline})           # Create an array of lines.
    local i line out=""                     # Label each line.
    for i in {1..${#lines:-1}}; do          # ":-1" to force at least one pass.
        line="${prefix}${lines[i]:-}${suffix}"
        out+=${line}"\n"
        _debug_info_ "${LOG_TAB}[${line}]"
    done

    # Return a multiline.
    _debug_info_ "Generate a suffixed multiline from the new string..."
    multiline=$(_to_multiline ${out})       # Create a new multiline.
    echo "${multiline}"                     # Return the new multiline.
}
