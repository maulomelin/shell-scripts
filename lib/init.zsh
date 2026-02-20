#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2025 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: n/a (Initialization Script)
# -----------------------------------------------------------------------------

# Fail fast if not running under zsh.
#   - ${ZSH_NAME} is only set if the script is running under zsh.
#   - Test condition using single brackets for portability.
#   - Use "printf" for portability.
if [ -z "${ZSH_NAME}" ] ; then
    printf "\e[91m"
    printf "Error: This script requires zsh.\n"
    printf "\n"
    printf "  - To run it in a zsh shell, either:\n"
    printf -- "      - Invoke it with zsh:  \`$ zsh script.zsh\`\n"
    printf -- "      - Execute it directly: \`$ chmod +x script.zsh ; ./script.zsh\`\n"
    printf "\n"
    printf "  - To use a different shell, modify scripts accordingly.\n"
    printf "\n"
    printf "\e[0m"
    return 1
fi

# Prevent direct execution. This script is designed to be sourced.
if [[ ${ZSH_EVAL_CONTEXT} != *:file* ]]; then
    echo "\033[91mError: This script must be sourced, not executed.\033[0m"
    return 1
fi

# Enable strict error handling and debugging.
#   - Use full option names ("The Z Shell Manual" v5.9, § 16, pg. 111).
setopt ERR_EXIT        # Exit on errors.
setopt NO_UNSET        # Exit on undefined variables.
setopt PIPE_FAIL       # Fail if any command in a pipeline fails.
setopt TYPESET_SILENT  # Silence variable re-declarations.
#setopt XTRACE         # DEBUG: Trace command execution and expansion.

# Source common libraries.
#   - Source libraries only if no function name collisions are found.
#   - Run checks inside an anonymous function to keep the global scope clean.
function () {

    # Common libraries.
    local lib_dirpath="${${(%):-%x}:A:h}"
    local -a libs=(
        "lib-ded--graveyard.zsh"
        "lib-err--error-handling.zsh"
        "lib-log--logging.zsh"
        "lib-reg--global-registry.zsh"
        "lib-sys--system-info.zsh"
        # TODO: Add new libraries here.
    )

    # -----------------------------------------------------------------------------
    # Syntax:   _extract_function_names_from_file <file>
    # Args:     <file>      A file name.
    # Outputs:  An array of function names found inside <file> using regexes.
    # Returns:  Default exit status.
    # Notes:    This function extracts function names to check for name collisions.
    #           Locally scoped functions are likely intended to shadow an original.
    #           If we assume indented function definitions to be locally scoped and
    #           non-indented to be original, indented definitions escape detection.
    # -----------------------------------------------------------------------------
    function _extract_function_names_from_file() {
        local file=${1:-}
        # Define RegEx patterns to extract function names (fnames) from files.
        local re_pre="^function[[:space:]]+"               # Left of fname.
        local re_fn="[a-zA-Z0-9_]+"                        # fname.
        local re_post="[[:space:]]*\(\)[[:space:]]+\{.*$"  # Right of fname.
        # Get an array of function names from the given file.
        local -a fnames=( ${(f)"$( grep -E "${re_pre}${re_fn}${re_post}" "${file}" | sed -E "s/${re_pre}// ; s/${re_post}//" )"} )
        echo "${fnames}"
    }

    # Create a function name registry.
    #   - Functional schema: fnmap[fn] => { (int)count, (str)sources }
    #   - Implement as parallel associative arrays managed by local functions.
    local -A fn_count   # The number of sources for a given fn.
    local -A fn_sources # The list of sources a given fn is found in.

    # -----------------------------------------------------------------------------
    # Syntax:   _fnmap_add_source_to_function_names <source> [<fname> ...]
    # Args:     <source>    A source string.
    #           <fname>     A list of function names.
    # Outputs:  None
    # Returns:  Default exit status.
    # Details:
    #   - Appends <source> to the list of sources of each function name in the
    #     fnmap registry. If no function name index is found, one is added.
    #   - Updates the count of <source>s added to a function name.
    # -----------------------------------------------------------------------------
    function _fnmap_add_source_to_function_names() {
        local source=${1}           # Map source argument to local variable.
        local -a fns=( "${@:2}" )   # Map list of function names to an array.
        local fn
        for fn in ${fns}; do
            fn_count[${fn}]=$(( ${fn_count[${fn}]:-0} + 1 ))
            fn_sources[${fn}]=${fn_sources[${fn}]:-}${fn_sources[${fn}]:+, }${source}
        done
    }

    # -----------------------------------------------------------------------------
    # Syntax:   _fnmap_validate_fnames
    # Args:     None.
    # Outputs:  An error message for every duplicate in the function name registry.
    # Returns:  0 on success (no duplicates found).
    #           1 on error (duplicates found).
    # -----------------------------------------------------------------------------
    function _fnmap_validate_fnames() {
        local duplicates=false
        local fn
        for fn in ${(k)fn_count}; do
            if (( fn_count[${fn}] > 1 )); then
                echo "\e[91mError: Function name duplicates detected:"
                echo "    Function:\t${fn}()"
                echo "    Sources:\t${fn_sources[${fn}]}"
                echo "==> Revise function names to avoid collisions."
                echo "\e[0m"
                duplicates=true
            fi
        done
        if [[ "${duplicates}" == true ]]; then
            return 1    # Exit function with an error.
        else
            return 0    # Exit function with status ok.
        fi
    }

    # -----------------------------------------------------------------------------
    # Syntax:   _fnmap_print
    # Args:     None.
    # Outputs:  Pretty-prints the function name registry to stdout, in JSON format:
    #           { "fnmap": { "<fname>": { "count": int, "sources": str } } }
    # Returns:  Default exit status.
    # -----------------------------------------------------------------------------
    function _fnmap_print() {
        echo "{"
        echo "  \"fnmap\": {"
        local fn
        for fn in ${(k)fn_count}; do
            echo "    \"${fn}\": {"
            echo "      \"count\": ${fn_count[${fn}]},"
            echo "      \"sources\": \"${fn_sources[${fn}]}\""
            echo "    }"
        done
        echo "  }"
        echo "}"
    }

    # Process all libraries.
    local -a fns
    local lib
    for lib in ${libs[@]}; do
        fns=( $(_extract_function_names_from_file "${lib_dirpath}/${lib}") )
        _fnmap_add_source_to_function_names "${lib}" "${fns[@]}"
    done

    # Process the executable script.
    fns=( $(_extract_function_names_from_file "${ZSH_ARGZERO:A}") )
    _fnmap_add_source_to_function_names "${ZSH_ARGZERO:A:t}" "${fns[@]}"

    # Process the environment.
    fns=( ${(k)functions} )
    _fnmap_add_source_to_function_names "(environment)" "${fns[@]}"

    # DEBUG: Print function name registry.
    #_fnmap_print

    # Validate function names and exit function if collisions are detected.
    _fnmap_validate_fnames || return 1

    # Source common libraries if no collisions were detected.
    local lib
    for lib in "${libs[@]}" ; do
        source "${lib_dirpath}/${lib}"
    done

} || return 1   # Catch and return any errors to the caller.