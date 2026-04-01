#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2024 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         [DAT] Data Types
# -----------------------------------------------------------------------------
# This library provides a variety of data type safety utilities.
# The table below is a summary the different type-safe functions:
#
#   TYPE                SYNTAX
#   Predicate           is_xxx <name> <arg>
#                       has_xxx <name> <arg>
#   Normalization       as_xxx <name> <arg> [<arg> ...]
#   Validation          validate_xxx <name> <arg> [<arg> ...]
#   Assertion           assert_xxx <name> <arg>
#   Conversion          to_xxx <name> <arg> <type>
#
# and their corresponding outputs and returns/exits:
#
#   FUNCTION        OUTPUTS     STATUS
#   is_, has_       none        return 0 (success) or return 1 (failure)
#   as_             value       return 0 (success) or return 1 (fail-safe)
#   to_             value       return 0 (success)
#   validate_       value       return 0 (success) or exit 1 (abort)
#   assert_         none        return 0 (success) or exit 1 (abort)
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Syntax:   dat::validate_url <name> <arg> [<arg> ...]
# Args:     <name>      Label to use in log messages.
#           <arg>       A list of arguments.
# Outputs:  A URL string to stdout if a valid URL <arg> is found.
# Status:   return 0 (success) if an <arg> is a valid URL.
#           exit 1 (abort) if no valid URL <arg> is found.
# Details:
#   - A valid URL is one that can be reached using:
#       `curl --head --silent --fail --location --output /dev/null "{url}"`
#   - Loops through all <arg>s until a valid URL is found, then
#     that URL is outputted.
#   - If all <arg>s fail, the script is aborted.
#   - Use to validate user inputs on assignments with a default value:
#       `var=$(validate_url "{name}" "${input}" "${default}") || return 1`
#     Don't forget to bubble up any non-zero status codes.
# -----------------------------------------------------------------------------
function dat::validate_url() {
    # Validate number of function arguments.
    local name="${1:-}"
    local min_args=2
    if (( $# < min_args )); then
        sys::abort "Cannot validate \"${name}\": Insufficient args (min: ${min_args}): (${(j:, :)@})"
    fi
    shift   # Remove name from the args array ${@}.

    # Try to validate any arg.
    log::debug "Attempting to validate \"${name}\" with args=(${(j:, :)@})"
    local arg
    for arg in "${@}"; do
        if [[ -z "${arg}" ]]; then
            log::debug "  [${arg}] is not a valid URL."
        else
            if curl --head --silent --fail --location --output /dev/null "${arg}"; then
                log::debug "  [${arg}] is a valid URL."
                echo "${arg}"
                return 0
            else
                log::debug "  [${arg}] is not a valid URL."
            fi
        fi
    done
    log::debug "  ==> No valid URL args."

    # Invalid args. Abort the script.
    sys::abort "Unable to validate \"${name}\": No valid URL args."
}

# -----------------------------------------------------------------------------
# Syntax:   dat::validate_path <name> <arg> [<arg> ...]
# Args:     <name>      Label to use in log messages.
#           <arg>       A list of arguments.
# Outputs:  A fullpath string to stdout if an allowed path <arg> is found.
# Status:   return 0 (success) if an <arg> is valid.
#           exit 1 (abort) if no allowed path <arg> is found.
# Details:
#   - Loops through all <arg>s until an allowed full path is found, then
#     that full path is outputted.
#   - If all <arg>s fail, the script is aborted.
#   - Use to validate user inputs on assignments with a default value:
#       `var=$(validate_path "{name}" "${input}" "${default}") || return 1`
#     Don't forget to bubble up any non-zero status codes.
# Caution:  Paths of the form "~xxx" are treated as literals. They are not
#           expanded to "/Users/xxx". They expand to "/Users/{user}/~xxx".
# -----------------------------------------------------------------------------
function dat::validate_path() {
    # Validate number of function arguments.
    local name="${1:-}"
    local min_args=2
    if (( $# < min_args )); then
        sys::abort "Cannot validate \"${name}\": Insufficient args (min: ${min_args}): (${(j:, :)@})"
    fi
    shift   # Remove name from the args array ${@}.

    # Try to validate any arg.
    log::debug "Attempting to validate \"${name}\" with args=(${(j:, :)@})"
    local arg fullpath
    for arg in "${@}"; do
        fullpath=$(dat::to_fullpath "${arg}")
        if dat::is_allowedpath "${fullpath}"; then
            log::debug "  [${fullpath}] is an allowed path."
            dat::as_allowedpath "${name}" "${fullpath}"
            return 0
        else
            log::debug "  [${fullpath}] is not an allowed path."
        fi
    done
    log::debug "  ==> No allowed path args."

    # Invalid args. Abort the script.
    sys::abort "Unable to validate \"${name}\": No allowed path args."
}

# -----------------------------------------------------------------------------
# Syntax:   dat::as_allowedpath <name> <arg> [<arg> ...]
# Args:     <name>      Label to use in log messages.
#           <arg>       A list of arguments.
# Outputs:  A normalized fullpath string to stdout.
# Status:   return 0 (success) if an allowed path <arg> is found.
#           return 1 (fail-safe) if all <arg>s fail and fail-safe is triggered.
# Details:
#   - Loops through all <arg>s until an allowed full path is found, then
#     that full path is outputted.
#   - If all <arg>s fail, it uses an opinionated built-in fail-safe that
#     guarantees an output:
#       - Create a temp dir using the script's name and a datetime suffix:
#           `/tmp/${ZSH_ARGZERO:A:t}--${REG[FORMAT_DATETIME_SLUG]}`
#         The datetime slug's resolution is small enough to be unique.
#   - Use to normalize variables:
#       `var=$(as_allowedpath "{name}" "${user_input}" "{fallback}")`
# -----------------------------------------------------------------------------
function dat::as_allowedpath() {
    # Validate number of function arguments.
    local name="${1:-}"
    local min_args=2
    if (( $# < min_args )); then
        sys::abort "Cannot normalize \"${name}\": Insufficient args (min: ${min_args}): (${(j:, :)@})"
    fi
    shift   # Remove name from the args array ${@}.

    # Normalize any arg.
    log::debug "Normalizing \"${name}\" with args=(${(j:, :)@})"
    local arg fullpath
    for arg in "${@}"; do
        fullpath=$(dat::to_fullpath "${arg}")
        if dat::is_allowedpath "${fullpath}"; then
            log::debug "  [${fullpath}] is an allowed path."
            log::debug "  ==> \"${name}\" set to [${fullpath}]."
            echo "${fullpath}"
            return 0
        else
            log::debug "  [${fullpath}] is not an allowed fullpath."
        fi
    done
    log::debug "  ==> No allowed path args."

    # Execute fail-safe fall-through.
    #   - Create a temp dir using the script's name and a datetime suffix:
    #       `/tmp/{script_name}--${datetime_slug}`
    log::alert "Fail-safe triggered: Check programmed defaults for \"${name}\"."
    log::debug "Fail-safe triggered: Generate temp dir."
    local base="/tmp/${ZSH_ARGZERO:A:t:r}--${(%):-"%D{${REG[FORMAT_DATETIME_SLUG]}}"}"
    log::debug "  Temp dir: [${base}]"
    local fullpath=$(dat::to_fullpath "${base}")
    log::debug "  ==> \"${name}\" set to [${fullpath}]."
    echo "${fullpath}"
    return 1
}

# -----------------------------------------------------------------------------
# Syntax:   dat::to_fullpath <arg>
# Args:     <arg>       The string to transform into a fullpath.
# Outputs:  A fullpath string to stdout.
# Status:   Default status.
# Details:
#   - Expands "^~/" to the home directory (i.e., "${HOME}").
#   - Resolves symbolic links (e.g., "/tmp" --> "/private/tmp").
# Caution:  Does not convert "~user" --> "/Users/{user}".
# -----------------------------------------------------------------------------
# TODO: Consider adding a "~user" --> "/Users/{user}" transform for macOS.
# -----------------------------------------------------------------------------
function dat::to_fullpath() {
    local arg="${1:-}"
    arg="${arg/#\~\//${HOME}/}" # Expand "^~/" to the home directory.
    arg="${arg:A}"              # Turn into absolute path and resolve symlinks.
    echo "${arg}"
}

# -----------------------------------------------------------------------------
# Syntax:   dat::is_allowedpath <arg>
# Args:     <arg>       The path to check.
# Outputs:  None.
# Status:   return 0 (success) if <arg> is an allowed path.
#           return 1 (failure) if <arg> is not an allowed path.
# -----------------------------------------------------------------------------
function dat::is_allowedpath() {
    local arg="${1:-}"
    if [[ "${arg}" =~ ${REG[REGEX_ALLOWEDPATH]} ]]; then
        return 0
    else
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Syntax:   dat::validate_bool <name> <arg> [<arg> ...]
# Args:     <name>      Label to use in log messages.
#           <arg>       A list of arguments.
# Outputs:  A normalized boolean value to stdout if a boolean <arg> is found.
# Status:   return 0 (success) if a boolean <arg> is found.
#           exit 1 (abort) if no boolean <arg> is found.
# Details:
#   - Loops through all <arg>s until a boolean string is found, then
#     that boolean is normalized to a strict boolean value and outputted.
#   - If all <arg>s fail, the script is aborted.
#   - Use to validate user inputs on assignments with a default value:
#       `var=$(validate_bool "{name}" "${input}" "${default}") || return 1`
#     Don't forget to bubble up any non-zero status codes.
# -----------------------------------------------------------------------------
function dat::validate_bool() {
    # Validate number of function arguments.
    local name="${1:-}"
    local min_args=2
    if (( $# < min_args )); then
        sys::abort "Cannot validate \"${name}\": Insufficient args (min: ${min_args}): (${(j:, :)@})"
    fi
    shift   # Remove name from the args array ${@}.

    # Try to validate any arg.
    log::debug "Attempting to validate \"${name}\" with args=(${(j:, :)@})"
    local arg
    for arg in "${@}"; do
        if dat::is_bool "${arg}"; then
            log::debug "  [${arg}] is a boolean."
            dat::as_bool "${name}" "${arg}"
            return 0
        else
            log::debug "  [${arg}] is not a boolean."
        fi
    done
    log::debug "  ==> No boolean args."

    # Invalid args. Abort the script.
    sys::abort "Unable to validate \"${name}\": No boolean args."
}

# -----------------------------------------------------------------------------
# Syntax:   dat::as_bool <name> <arg> [<arg> ...]
# Args:     <name>      Label to use in log messages.
#           <arg>       A list of arguments.
# Outputs:  A normalized boolean value to stdout.
# Status:   return 0 (success) if a boolean <arg> is found.
#           return 1 (fail-safe) if all <arg>s fail and fail-safe is triggered.
# Details:
#   - Strings used as booleans: {true, false, on, off, yes, no, 1, 0}.
#     Source: "The Z Shell Manual" v5.9, § 20.3.3, pg. 261.
#   - Loops through all <arg>s until it a boolean string is found, then
#     that boolean is normalized to a strict boolean and outputted.
#   - If all <arg>s fail, it uses an opinionated built-in fail-safe that
#     guarantees an output:
#       - "TRUE" if there is any non-empty <arg>s.
#       - "FALSE" if all <arg>s are empty.
#   - Use to normalize variables:
#       `var=$(as_bool "{name}" "${user_input}" "{fallback}")`
# -----------------------------------------------------------------------------
function dat::as_bool() {
    # Validate number of function arguments.
    local name="${1:-}"
    local min_args=2
    if (( $# < min_args )); then
        sys::abort "Cannot normalize \"${name}\": Insufficient args (min: ${min_args}): (${(j:, :)@})"
    fi
    shift   # Remove name from the args array ${@}.

    # Normalize any arg.
    log::debug "Normalizing \"${name}\" with args=(${(j:, :)@})"
    local arg
    for arg in "${@}"; do
        if dat::is_bool "${arg}"; then
            log::debug "  [${arg}] is a boolean."
            if dat::is_true "${arg}"; then
                log::debug "  ==> \"${name}\" set to \"TRUE\"."
                echo "${REG[TRUE]}"
            else
                log::debug "  ==> \"${name}\" set to \"FALSE\"."
                echo "${REG[FALSE]}"
            fi
            return 0
        else
            log::debug "  [${arg}] is not a boolean."
        fi
    done
    log::debug "  ==> No boolean args."

    # Execute fail-safe fall-through.
    #   - Treat any non-empty <arg> as "TRUE", and all empty <arg>s as "FALSE".
    #   - Use ${name:#pattern} to remove empty elements from an array, and
    #     ${#spec} to get its size. "The Z Shell Manual" v5.9, § 14.3, pg. 53.
    log::alert "Fail-safe triggered: Check programmed defaults for \"${name}\"."
    log::debug "Fail-safe triggered: Any non-empty arg is truthy."
    log::debug "  Args: [${#@}](${(j:, :)@}) --> Non-empty args: [${#@:#}](${(j:, :)@:#})"
    if [[ "${#@:#}" > 0 ]]; then
        log::debug "  ==> \"${name}\" set to "TRUE"."
        echo "${REG[TRUE]}"
    else
        log::debug "  ==> \"${name}\" set to "FALSE"."
        echo "${REG[FALSE]}"
    fi
    return 1
}

# -----------------------------------------------------------------------------
# Syntax:   dat::is_bool <arg>
# Args:     <arg>       The argument to check.
# Outputs:  None.
# Status:   return 0 (success) if <arg> is a boolean.
#           return 1 (failure) if <arg> is not a boolean.
# -----------------------------------------------------------------------------
function dat::is_bool() {
    local arg="${1:-}"
    if [[ "${arg:l}" =~ ${REG[REGEX_BOOLEAN]} ]]; then
        return 0
    else
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Syntax:   dat::is_true <arg>
# Args:     <arg>       The argument to check.
# Outputs:  None.
# Status:   return 0 (success) if <arg> is truthy.
#           return 1 (failure) if <arg> is not truthy.
# -----------------------------------------------------------------------------
function dat::is_true() {
    local arg="${1:-}"
    if [[ "${arg:l}" =~ ${REG[REGEX_TRUE]} ]]; then
        return 0
    else
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Syntax:   dat::is_yes <arg>
# Args:     <arg>       The argument to check.
# Outputs:  None.
# Status:   return 0 (success) if <arg> is "yes".
#           return 1 (failure) if <arg> is not "yes".
# -----------------------------------------------------------------------------
function dat::is_yes() {
    local arg="${1:-}"
    if [[ "${arg:l}" =~ ${REG[REGEX_YES]} ]]; then
        return 0
    else
        return 1
    fi
}