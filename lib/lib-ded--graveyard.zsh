#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2025 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: DED (Functions Graveyard)
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Status:   DEPRECATED. See "Caution" below. Logic not straight-forward, it may
#           lead to bugs/maintenance issues, and it only saves 1 line of code.
# Syntax:   sys::fail [<message> ...]
# Args:     <message>   Error message strings.
# Outputs:  Log message with log level WARNING.
# Status:   return 1 (error).
# Caution:  The `return 1` statement exits the `sys::fail()` function itself.
#           The caller *must* check the return status and handle the failure
#           appropriately. When used in a short-circuit expression, the caller
#           can choose to return from the current function, or to continue with
#           additional logic. In a short-circuit expression, use short-circuit
#           chaining to control the flow, such as:
#               `{command} || sys::fail "{command} failed." || return`
# Details:
#   - Ends the operation and returns to caller with status 1 (error).
#   - Logs the <message> strings as a WARNING message.
#     If no message is provided, a default message is used.
# Notes:
#   - Useful in short-circuit expressions, such as:
#       `{command} || sys::fail "{command} failed."` || return
# -----------------------------------------------------------------------------
function ded::sys::fail() {
    local msg=${_SYS[DEFAULT_FAIL_MESSAGE]:-}
    log::warning "${@:-${msg}} ==> Returning to caller."
    return 1
}

# -----------------------------------------------------------------------------
# Status:   DEPRECATED. Deprecated when sys::fail() was deprecated.
# Syntax:   sys::return [<message> ...]
# Args:     <message>   Message strings.
# Outputs:  Log message with log level INFO.
# Status:   return 0 (success).
# Details:
#   - Ends the operation and returns to caller with status 0 (success).
#   - Logs the <message> strings as an INFO message.
#     If no message is provided, a default message is used.
# -----------------------------------------------------------------------------
function ded::sys::return() {
    local msg=${_SYS[DEFAULT_RETURN_MESSAGE]:-}
    log::info "${@:-${msg}} ==> Returning to caller."
    return 0
}

# -----------------------------------------------------------------------------
# Status:   DEPRECATED. Functionality integrated into log::_box().
# Syntax:   log::get_display_width [<string> ...]
# Args:     <string>    A list of strings.
# Outputs:  The length of the longest printed line from all <string>s.
#           0, if no strings are given, or if the longest string is empty.
# Status:   Default status.
# Details:
#   - Given any number of strings, this utility calculates the length of the
#     longest line as printed on the screen by removing any SGR codes.
#   - Used to format boxes or tables where the length of the longest line is
#     needed to determine the size of the bounding box and paddings.
#   - To determine the longest line length in many multi-lines:
#       1. Create a multi-line from the args and then a lines array.
#            local multiline=$(_to_multiline ${@})
#            local lines=( ${(f)multiline} )
#       2. Remove any SGR codes from the lines:
#            local clines=( ${(S)lines//$'\e'\[*m/} )
#       3. Mask all lines with "x"s and sort the masks:
#            local masks=( ${(@O)clines//?/x} )
#          This creates something like ( xxxxxxxx xxxxx xx xx x ).
#            - "O" sorts the result in descending alphabetic order.
#            - "@" treats the result as an array.
#              In zsh "${(@)array}" is equivalent to "${array[@]}",
#              where "array[@]" expands all elements of an array.
#              ${array} can expand to array[1], depending on shell settings.
#            - "//?/x" replaces each character in the array with an "x".
#              On strings with the same character, this orders them by length.
#       4. Fetch the first/longest element of the sorted array.
#            local longest_mask=${masks[1]:-}
#          To make it safe for empty arrays, return an empty string.
#       5. Calculate and return the length of the longest mask:
#            local display_width=${#longest_mask}
#            return "${display_width}"
#   - Alternatively, we *could* combine the these into one command line:
#       local display_width=${#${(@O)clines//?/x}[1]:-}
#     But this is not as easy to follow and harder to maintain.
# -----------------------------------------------------------------------------
function ded::log::get_display_width() {
    __debug_start "Calculate the display width of all input strings."

    local multiline=$(_to_multiline ${@})   # Make a multi-line from the args.
    local lines=(${(f)multiline})           # Create an array of lines.
    local clines=(${(S)lines//$'\e'\[*m/})  # Remove SGR codes from the lines.
    local masks=(${(@O)clines[@]//?/x})     # Mask and sort the clean lines.
    local longest_mask=${masks[1]:-}        # Fetch the first/longest mask.
    local display_width=${#longest_mask}    # Calculate that mask's length.
    echo "${display_width}"                 # Return the display width.

    # DEBUG
    if [[ ${LOG_DEBUG:-false } == true ]]; then
        __debug_info "Plaintext lines:"
        local i; for ((i = 1; i<=${#lines[@]}; i++)); do
            __debug_info "  [${i}]: [${clines[i]}][${#clines[i]}] <-- [${lines[i]}][${#lines[i]}]"
        done
        __debug_info "sorted masks: (${(qq)masks[@]})"
        __debug_info "longest mask: [${(qq)longest_mask}]"
        __debug_info "display width: [${display_width}]"
    fi
}

# -----------------------------------------------------------------------------
# Status:   DEPRECATED. Inefficient design. Originally in LOG::.
# Syntax:   log::_is_item_in_list <item> <li> [<li> ...]
# Args:     <item>  Item to check.
#           <li>    List item to scan. One required.
# Outputs:  None.
# Status:   return 0 (success) if item found in the list.
#           return 1 (failure) if item not found in the list.
#           return 2 (error) if wrong number of arguments (< 2).
# Details:
#   - Checks if <item> is in the list by comparing <item> against every <li>.
#   - It needs at least 1 list item for a valid scan.
# Notes:
#   - This function can be used in `if (...)` conditionals because
#     the clause looks for a return code instead of a return value.
# Sources:
#   https://stackoverflow.com/questions/2875424/correct-way-to-check-for-a-command-line-flag-in-bash
# -----------------------------------------------------------------------------
function ded::log::_is_item_in_list() {
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

# -----------------------------------------------------------------------------
# Status:   DEPRECATED. DO NOT USE. BAD DESIGN. Originally in LOG::.
#           Message is scavenged if <suffix> is missing.
# Syntax:   log::_wrap [<prefix>] [<string>*] [<suffix>]
# Args:     <prefix>    A prefix string.
#           <string>    A list of strings.
#           <suffix>    A suffix string.
# Outputs:  A multiline string.
# Status:   Default status.
# Details:
#   - Appends a <prefix> and a <suffix> string to every line in a log message.
#   - The log message is created from all input <string>s.
# -----------------------------------------------------------------------------
function ded::log::_wrap() {
    __debug_start "Append prefix and suffix labels around a message."

    # Extract the prefix and suffix strings.
    __debug_info "Extract the prefix and suffix strings..."
    local prefix=${1:-}                     # Get the prefix argument, if any.
    if (( $# >= 1 )); then shift; fi        # Shift to remaining args, if any.
    local suffix=""                         # Get the suffix argument, if any.
    if (( ${#@} >= 1 )); then
        suffix=${@[-1]}
        shift -p                            # Shift to string args, if any.
    fi
    __debug_info "${LOG_TAB}prefix: [${prefix}][${#prefix}]"
    __debug_info "${LOG_TAB}suffix: [${suffix}][${#suffix}]"

    # Normalize inputs into a single multiline string.
    __debug_info "Normalize inputs into a single multiline string..."
    local multiline=$(_to_multiline ${@})   # Make a multiline from the args.

    # Process the multiline.
    __debug_info "Append a suffix to every line and store in a new string..."
    local lines=(${(f)multiline})           # Create an array of lines.
    local i line out=""                     # Label each line.
    for i in {1..${#lines:-1}}; do          # ":-1" to force at least one pass.
        line="${prefix}${lines[i]:-}${suffix}"
        out+=${line}"\n"
        __debug_info "${LOG_TAB}[${line}]"
    done

    # Return a multiline.
    __debug_info "Generate a suffixed multiline from the new string..."
    multiline=$(_to_multiline ${out})       # Create a new multiline.
    echo "${multiline}"                     # Return the new multiline.
}
