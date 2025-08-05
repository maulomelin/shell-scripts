#!/bin/zsh
#--------------------------------------+--------------------------------------#
# SPDX-FileCopyrightText: (c) 2025 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier: MIT
# SPDX-FileComment: Experiments/Prototypes Scratchpad/Sandbox/Playground/Lab.
#--------------------------------------+--------------------------------------#
# General Comments:
#   - This is a testing ground for all kinds of experiments.
#   - Every experiment is defined and named within its own function.
#   - Follow the pattern for new experiments.
#--------------------------------------+--------------------------------------#
# Initialize script environment.
readonly SCRIPT_DIRPATH=$(dirname "${0}")
readonly SCRIPT_FILENAME=$(basename "${ZSH_ARGZERO}")
source "${SCRIPT_DIRPATH}/../lib/init.zsh"
#--------------------------------------+--------------------------------------#
# TODO: Consider utility of a framework that prompts user to run any experiment
# function in this module. See function at bottom of script.
#--------------------------------------+--------------------------------------#

function experiment_0032() {
    LOG_VERBOSITY=+0010
    log_header "Something exciting!"
    log_xxx "testing"
#    display_sgr_codes
    abort
}
experiment_0032 "${@}"


function experiment_0031() {
#    log_header "Test updates to log formatting function."
    #zsh shell_scripts/scratchpad.zsh foo bar "this isn\nnnewline" "lasv\vvr\rrtn\nnx" "some t\tt done" "*"
    local format

#    LOG_VERBOSITY=3
#    LOG_VERBOSITY=
#    LOG_VERBOSITY=-0001
#    LOG_VERBOSITY=+-000
#    LOG_VERBOSITY=+0001
#    LOG_VERBOSITY=0003
#    LOG_VERBOSITY=000a
#    LOG_VERBOSITY=z
#    LOG_VERBOSITY=-99

    format="red underline uline bold blink"
#    format="red bold"
#    format="bold"
#    format=""
    log_header "echo \"\$(_format \"${format}\" \${@})\""
    log_header "${@}"
    log_start "${@}"
    log_end "${@}"
    log_info "${@}"
    log_warning "${@}"
    log_error "${@}"
    log_debug "${@}"
    log_xxx "${@}"

    #display_sgr_codes ; exit

    echo "$(_format "${format}" ${@})"

    #log_header "x=\$(_format \${@})"; x=$(_format ${@}); echo ${x}
    #log_header "x=\$(_format)"; x=$(_format); echo ${x}

#    abort
}
experiment_0031 "${@}"


function experiment_0030() {
    log_header "Different types of for loops."

    for i in {1..0}; do
        echo "a[${i}]"
    done
    for i in {1..1}; do
        echo "b[${i}]"
    done
    for (( i=0; i<=0; i++ )); do
        echo "c[${i}]"
    done
#    local x=
#    for i in {1..${#x:-1}}; do
    for i in {1..${#x:-}}; do
        echo "d[${i}]"
    done

}
#experiment_0030 "${@}"


function experiment_0029() {
# TODO: Create a debug function that identifies variable types automatically
# and prints them in JSON-like format (e.g., scalars, associative arrays).
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#index-parameter-expansion-flags
#   local w=1 x="a" y=("x" "y" "z")
#   local -A z=("a" 1 "b" 2 "c" 3)
#   echo ${(t)w} ${(t)x} ${(t)y} ${(t)z}
    log_header "Print out variables in JSON-like format."
    local w=1; echo "\tw=1\t\t\t\t==> [${(t)w}]"
    local x="a"; echo "\tx=\"a\"\t\t\t\t==> [${(t)x}]"
    local y=("x" "y" "z"); echo "\ty=(\"x\", \"y\", \"z\")\t\t==> [${(t)y}]"
    local -A z=("a" 1 "b" 2 "c" 3); echo "\t-A z=(\"a\" 1 \"b\" 2 \"c\" 3)\t==> [${(t)z}]"
}
#experiment_0029 "${@}"


function experiment_0028() {
    log_header "Replicate experiment_0027 using log_*() calls from the framework's logging module."
    log_start
#    local me=${funcstack[1]:-SHELL}
#    log_header "me = \${funcstack[1]:-SHELL} = [${me}]"
    local foo="bar"

    function print_funcstack() {
        log_start "I am in print_funcstack() [${foo}]"
        local x
        for x in ${funcstack[@]}; do log_debug "${x}"; done
        print_rev_funcstack
    }

    function print_rev_funcstack() {
        log_header "print_rev_funcstack()"
        log_start "I am in print_rev_funcstack()"
        local x i

        log_info "I am in print_rev_funcstack() showing you funcstack[@]:"
        for x in ${funcstack[@]}; do log_debug "\t[]: ${x}"; done

        log_info "I am in print_rev_funcstack() showing you funcstack[@] in a for{1..n} loop:"
        for ((i = 1; i<=${#funcstack[@]}; i++)); do log_debug "\t[${i}]: ${funcstack[i]}"; done

        log_info "I am in print_rev_funcstack() showing you funcstack[@] in a for{n..1} loop:"
        for ((i = ${#funcstack[@]}; i >= 1; i--)); do log_debug "\t[${i}]: ${funcstack[i]}"; done

        log_info "I am in print_rev_funcstack() showing you funcstack[@] using (Oa) parameter expansion flags:"
        for x in ${(Oa)funcstack[@]}; do log_debug "\t[]: ${x}"; done
    }

    function indirect() {
        log_start "I am in indirect()"
        print_funcstack
        print_rev_funcstack
        log_end
    }

    log_info "I am in experiment_0028()"
    indirect
    log_end
}
#experiment_0028 "${@}"


function experiment_0027() {
#    log_header "Explore printing logs with indents using the call stack array funcstack[@]."
    local me=${funcstack[1]:-SHELL}
    echo "me=[${me}]"

    function log() {
        local caller=${funcstack[2]:-SHELL}
        local i indent="" tab="+--"
        for ((i = 2; i<=${#funcstack[@]}; i++)); do indent+=${tab}; done
        if (( ${#@} == 0 )); then
            echo "${indent}${caller}()" >&2
        else
            echo "${indent}${caller}(): ${@}" >&2
        fi
    }

    log ; # local caller=${funcstack[2]:-SHELL}; echo "\n>>> ${caller}() -> ${0}() <<<\n"

    function print_funcstack() {
        log ; # local caller=${funcstack[2]:-SHELL}; echo "\n>>> ${caller}() -> ${0}() <<<\n"

        local x
        for x in ${funcstack[@]}; do log "${x}"; done
        print_rev_funcstack
    }

    function print_rev_funcstack() {
        log ; # local caller=${funcstack[2]:-SHELL}; echo "\n>>> ${caller}() -> ${0}() <<<\n"

        local x i
        log "funcstack:"
        for x in ${funcstack[@]}; do log "\t${x}"; done

        log "funcstack in a for{1..n} loop:"
        for ((i = 1; i<=${#funcstack[@]}; i++)); do log "\t${funcstack[i]}"; done

        log "funcstack in a for{n..1} loop:"
        for ((i = ${#funcstack[@]}; i >= 1; i--)); do log "\t${funcstack[i]}"; done

        log "funcstack using (Oa) parameter expansion flags:"
        for x in ${(Oa)funcstack[@]}; do log "\t${x}"; done
    }

    function indirect() {
        log ; # local caller=${funcstack[2]:-SHELL}; echo "\n>>> ${caller}() -> ${0}() <<<\n"

        print_funcstack
        print_rev_funcstack
    }

    indirect
}
#experiment_0027 "${@}"


function experiment_0026() {
    log_header "Explore splitting args newline escape sequences and escape character."

    function sgrattrib() { echo "\e[${@}m" }
    local fmt_bold="$(sgrattrib "1")"

    #zsh shell_scripts/scratchpad.zsh foo bar "this isn\nnnewline" "lasv\vvr\rrtn\nnx" "some t\tt done" "*"
    local lines=( foo bar "this isn\nnnewline" "lasv\vvr\rrtn\nnx" "some t\tt done" "*" )
    local line message=""
    for line in ${lines[@]}; do
        message+="${fmt_bold}${line}${fmt_reset}\n"
    done

    local esc_seq_str="${message}"
    for x in ${(f)esc_seq_str}; do log_debug "${0}(): 1_line: [${(l:2:)${#x}}][${x}]"; done # DEBUG
    log_info "NO  ==> \${(f)string} does not recognize the escape sequence \_n."
    for x in ${(s:\n:)esc_seq_str}; do log_debug "${0}(): 2_line: [${(l:2:)${#x}}][${x}]"; done # DEBUG
    log_info "YES ==> \${(s:\_n:)string} recognizes the escape sequence \_n."
    for x in ${(ps:\n:)esc_seq_str}; do log_debug "${0}(): 3_line: [${(l:2:)${#x}}][${x}]"; done # DEBUG
    log_info "NO  ==> \${(ps:\_n:)string} does not recognize the escape sequence \_n."
    for x in ${(ps:'\n':)esc_seq_str}; do log_debug "${0}(): 3a_line: [${(l:2:)${#x}}][${x}]"; done # DEBUG
    log_info "NO  ==> \${(ps:'\_n':)string} does not recognize the escape sequence '\_n'."
    for x in ${(ps:$'\n':)esc_seq_str}; do log_debug "${0}(): 4_line: [${(l:2:)${#x}}][${x}]"; done # DEBUG
    log_info "NO  ==> \${(ps:\$'\_n':)string} does not recognize the escape sequence \_n."

    local esc_char_str=$(echo "${message}")
    for x in ${(f)esc_char_str}; do log_debug "${0}(): 5_line: [${(l:2:)${#x}}][${x}]"; done # DEBUG
    log_info "YES ==> \${(f)string} recognizes the escape character \$'\_n'."
    for x in ${(s:\n:)esc_char_str}; do log_debug "${0}(): 6_line: [${(l:2:)${#x}}][${x}]"; done # DEBUG
    log_info "NO  ==> \${(s:\_n:)string} does not recognize the escape character \$'\_n'."
    for x in ${(ps:\n:)esc_char_str}; do log_debug "${0}(): 7_line: [${(l:2:)${#x}}][${x}]"; done # DEBUG
    log_info "YES ==> \${(ps:\_n:)string} recognizes the escape character \$'\_n'."
    for x in ${(ps:$'\n':)esc_char_str}; do log_debug "${0}(): 8_line: [${(l:2:)${#x}}][${x}]"; done # DEBUG
    log_info "NO  ==> \${(ps:$'\_n':)string} does not recognize the escape character \$'\_n'."

    log_info "SUMMARY:"
    log_info "\t\${(f)name} \t\t character - YES / sequence - NO."
    log_info "\t\${(ps:\ n:)name} \t character - YES / sequence - NO."
    log_info "\t\${(s:\ n:)name} \t character - NO / sequence - YES."
}
#experiment_0026 "${@}"


function experiment_0025() {
#    log_header "Search & replace."

    string="foo[bar]fizz[buzz]wizz[bang]cat"
    echo "original string\t\t\t[ ${string} ]"
    # [x] = x
    echo "first lbracket\t\t\t[ ${string/\[/X} ]"
    echo "all lbrackets\t\t\t[ ${string//\[/X} ]"
    echo "first set of brackets (greedy)\t[ ${string/\[*\]/X} ]"
    echo "first set of brackets (lazy)\t[ ${(S)string/\[*\]/X} ]"
    echo "all sets of brackets (greedy)\t[ ${string//\[*\]/X} ]"
    echo "all set of brackets (lazy)\t[ ${(S)string//\[*\]/X} ]"

    string=(foo bar "this isN\nNnewline" "lasV\vVR\rRtN\nNx" "some T\tT done" "*")
    converted=$(echo "${string}")
    formatted=$(echo "$(_warning ${string})")
    echo "\n\nesc seq->chars:"
    echo "[${#string[@]}][${string[@]}]"
    echo "[${#converted}][${converted}]"
    echo "[${#formatted}][${formatted}]"
    anti_f1=${(S)formatted//$'\e'/ESC}
    anti_f2=${(S)formatted//$'\e'\[*m/ESC}
    anti_f3=${(S)formatted//$'\e'\[*m/}
    echo "[${#anti_f1}][${anti_f1}]"
    echo "[${#anti_f2}][${anti_f2}]"
    echo "[${#anti_f3}][${anti_f3}]"

# 123456789012345678901234567890123456789012345678901234567890123456
# [WARNING] foo bar this isN_Nnewline lasV_RtN=VR_Nx some T=T done *
}
#experiment_0025 "${@}"


function experiment_0024() {
    log_header "Explore other escape sequences and their effects."

    #             1234567890123456789012345 [25 chars with escape sequences]
    #             1234 5678 9012 34567 8901 [21 chars with escape characters]
    local string="fooo\bbar\vbaz\nquux\teee"
    echo "string: [${#string}][${string}]"
    local mod
    printf -v mod "%b" ${string}
    echo "mod: [${#mod}][${mod}]"
    local capture
    capture=$(echo "${string}")
    echo "capture: [${#capture}][${capture}]"

    echo "capture: [${#capture}][${(V)capture}]"

    # RESULT: The captured string contains the escape characters.
}
#experiment_0024 "${@}"


function experiment_0023() {
    log_header "Explore the escape sequence \\e."

    function sgrattrib() { echo "\e[${@}m" }
    local fmt_reset="$(sgrattrib "0")"
#    local fmt_reset="\e[9m"

    local string="\e[91mfoo\tbar\e[m ${fmt_reset}baz"

    # To fix the issue, we convert escape sequences into ASCII escape characters.
    printf -v string "%b" "${string}"

    printf "printf:\t\t\t[%q]\n" "${string}"
    echo "(q)string:\t\t[${(q)string}]"
    echo "(qq)string:\t\t[${(qq)string}]"
    echo "(qqq)string:\t\t[${(qqq)string}]"
    echo "string:\t\t\t[${string}]"

    local str=${string}
    str=${str//$'\e'/ESC}   ; echo "\$slash-e:\t\t[${str}]"     # Finds ${fmt_reset}.
    str=${str//$'\t'/$'\v'}   ; echo "\$slash-t:\t\t[${str}]"     # Finds \t ASCII char.
    str=${str//'\v'/VVV}   ; echo "slash-v:\t\t[${str}]"     # Finds "\v" sequence.
    str=${str//$'\v'/VVV}   ; echo "\$slash-v:\t\t[${str}]"     # Finds \v ASCII char.
#    str=${str//$'\n'/NNN}   ; echo "slash-n:\t\t[${str}]"       # Finds...nothing
#    str=${str//'\n'/NNN}   ; echo "slash-n:\t\t[${str}]"       # Finds...nothing
#    str=${str//'\e'/ESC}    ; echo "slash-e:\t\t[${str}]"       # Finds "\e[...m" strings.
#    str=${str//'\\e'/ESC}   ; echo "slash-slash-e:\t\t[${str}]" # Finds...nothing.

    log_info "Create a multiline from an array to check how it handles newlines."
    lines=("aaa" "bbb" "ccc" "ddd")
    local multiline=${(F)lines} # Join using newline.
    echo "multiline:\t\t[${multiline}]"
    local multiline_escape_char=${multiline//$'\n'/NNN}
    echo "seek escape_char:\t\t[${multiline_escape_char}]"
    local multiline_escape_seq=${multiline//'\n'/NNN}
    echo "seek escape_seq:\t\t[${multiline_escape_seq}]"

    log_info "Create a multiline from a string with escape sequences to check how it handles newlines."
    lines="www\nxxx\nyyy\nzzz"
    local multiline=${(F)lines} # Join using newline.
    echo "multiline:\t\t[${multiline}]"
    local multiline_escape_char=${multiline//$'\n'/NNN}
    echo "multiline_escape_char:\t\t[${multiline_escape_char}]"
    local multiline_escape_seq=${multiline//'\n'/NNN}
    echo "multiline_escape_seq:\t\t[${multiline_escape_seq}]"

    # (V) parameter expansion flag makes *some* special characters visible.
    # most notably, $'\n' is not.
    echo "multiline show chars:\t\t[${(V)multiline}]"
}
#experiment_0023 "${@}"


function experiment_0022() {
    log_header "Explore command and parameter expansion."

    log_info "See IFS parameter in \"The Z Shell Manual\", v5.9, pg. 104."
    # Useful script calls for testing:
    #zsh shell_scripts/scratchpad.zsh foo bar "this isn\nnnewline" "lasv\vvr\rrtn\nnx" "some t\tt done" "*"
    #zsh shell_scripts/scratchpad.zsh foo bar "this isN\nNnewline" "lasV\vVR\rRtN\nNx" "some T\tT done" "*"

    function echo_args() { echo ${@} }
    echo "Quoted command substitution:"
    for arg in "$( echo_args ${@} )"; do echo "\t=>[${arg}]"; done
    echo "Un-Quoted command substitutionen c:"
    for arg in $( echo_args ${@} ); do echo "\t=>[${arg}]"; done

    log_info " \
    # NOTE: Use double quotes around a command substitution (i.e., "\$\(...\)") to\n
    # prevent the shell from breaking up the output into words using \$IFS\n
    # (Internal Field Separators = { space, tab, newline, NUL } by default).\n
    # This is important for multi-line strings, which would otherwise be split\n
    # into separate words using the characters in \$IFS."

}
#experiment_0022 "${@}"


function experiment_0021() {
    log_header "Use parameter expansion flags to pad strings."

    local string="string"
#    local string=( "string" "string2" )
    local length=20
    local modified_string

    log_info "Left-padding:"

    modified_string=( ${(l:20::^::X:)string} )
    echo "string: [${string}] ==> [${modified_string}]"

    modified_string=${(l:20::^:::)string}
    echo "string: [${string}] ==> [${modified_string}]"

    modified_string=${(l:20::::X:)string}
    echo "string: [${string}] ==> [${modified_string}]"

    modified_string=${(l:20:::::)string}
    echo "string: [${string}] ==> [${modified_string}]"

    modified_string=${(l:20::^:)string}
    echo "string: [${string}] ==> [${modified_string}]"

    modified_string=${(l:20:::)string}
    echo "string: [${string}] ==> [${modified_string}]"

    modified_string=${(l:20:)string}
    echo "string: [${string}] ==> [${modified_string}]"

    log_info "Right-padding:"

    modified_string=${(r:20::^::X:)string}
    echo "string: [${string}] ==> [${modified_string}]"

    modified_string=${(r:20::^:::)string}
    echo "string: [${string}] ==> [${modified_string}]"

    modified_string=${(r:20::::X:)string}
    echo "string: [${string}] ==> [${modified_string}]"

    modified_string=${(r:20:::::)string}
    echo "string: [${string}] ==> [${modified_string}]"

    modified_string=${(r:20::^:)string}
    echo "string: [${string}] ==> [${modified_string}]"

    modified_string=${(r:20:::)string}
    echo "string: [${string}] ==> [${modified_string}]"

    modified_string=${(r:20:)string}
    echo "string: [${string}] ==> [${modified_string}]"

    log_info "Center-padding:"

    modified_string=${(l:10::abcd::>:r:20::xyz::<:)string}
    echo "string: [${#${string}}][${string}] ==> [${#${modified_string}}][${modified_string}]"

    log_info "Padding a string with control characters:"
    local eseq_string="12345\e[1m678\t90\e[0m"
    echo "eseq_string: [${#eseq_string}][${eseq_string}]"
    ctrl_string=$(echo "${eseq_string}")
    echo "ctrl_string: [${#ctrl_string}][${ctrl_string}]"
    modctrl_string=${(l:20::x:)ctrl_string}
    echo "ctrl_string: [${#ctrl_string}][${ctrl_string}] ==> [${#modctrl_string}][${modctrl_string}]"

    function _visual_string() {
        local input_line="${1:-}"
        local interpreted_line
        local stripped_string
        printf -v interpreted_line "%b" "$input_line"
        stripped_string="${(S)interpreted_line//$'\e'\[[0-9;]*m/}"
        echo "${stripped_string}"
    }
    local visual_string=$(_visual_string "${eseq_string}")
    echo "visual_string: [${#visual_string}][${visual_string}]"

    log_info "==> Padding parameter expansion flags treat control characters as regular characters!"
    log_info "\tTo pad correctly we need the length of the line without them..."
    log_info "\tUse the following command: visual_line=\"\${(S)line//\$'\e'\[[0-9;]*m/}"


    function center() {
        local text="${1:-hellworld}"
        local -i columns=${COLUMNS:-$(tput cols)}
        columns=$(( columns/2 ))
        echo ${(l:${columns}::=:::r:${columns}::=:::)text}
    }
    center "Hello, World!"

    function center2() {
        local text="${1:-hellworld}"
        local pad="${2:-=}"
        local -i columns=${COLUMNS:-$(tput cols)}
        columns=$(( columns/2 ))
        echo ${(pl:${columns}::$pad:::r:${columns}::$pad:::)text}
    }
    center2 "hello" "_"

    log_info "Explore variations in how to encode padding:"

    local str mod
    # This is the baseline modified string.
    log_info "Baseline padding:"
    base=${(l:20::-::>:r:20::=::<:)string}
    echo "base string: [${#${string}}][${string}] ==> [${#${base}}][${base}]"

    # This is the string we apply the variables to.
    log_info "Mod using local variables:"
    local char_a="-"
    local char_b=">"
    local char_c="="
    local char_d="<"
    mod1=${(pl:20::$char_a::$char_b:pr:20::$char_c::$char_d:)string}
    echo "mod1 string: [${#${string}}][${string}] ==> [${#${mod1}}][${mod1}]"

    # This is the string we apply the associative array to.
    log_info "Mod using associative array variables:"
    typeset -A CHAR=(
        [a]="-"
        [b]=">"
        [c]="="
        [d]="<"
    )
    echo "CHAR[a]=[${CHAR[a]}]"
    mod2=${(pl:20::${CHAR[a]}::${CHAR[b]}:pr:20::${CHAR[c]}::${CHAR[d]}:)string}
    echo "mod2 string: [${#${string}}][${string}] ==> [${#${mod2}}][${mod2}]"

    # This is the string we use "(delim)" instead of ":delim:".
    log_info "Mod using parentheses as flag delimiters:"
    mod3=${(pl(20)(-)(>)pr(20)(=)(<))string}
    echo "mod3 string: [${#${string}}][${string}] ==> [${#${mod3}}][${mod3}]"

    # This is the string we try different flags on.
    typeset -A VARS=( [a]="-" )
    log_info "Mod using other flags..."
    mod4=${(Pl(20)(-)(>)Pr(20)(${VARS[a]})(<))string}
    echo "mod4 string: [${#${string}}][${string}] ==> [${#${mod4}}][${mod4}]"

    mod5=${(pl(20)(-)(>)pr(20)(VARS[a])(<))string}
    echo "mod5 string: [${#${string}}][${string}] ==> [${#${mod5}}][${mod5}]"
    mod6=${(Pl(20)(-)(>)Pr(20)(VARS[a])(<))string}
    echo "mod6 string: [${#${string}}][${string}] ==> [${#${mod6}}][${mod6}]"
    mod7=${(l(20)(-)(>)r(20)({VARS[a]})(<))string}
    echo "mod7 string: [${#${string}}][${string}] ==> [${#${mod7}}][${mod7}]"
    mod8=${(pl(20)(-)(>)pr(20)({VARS[a]})(<))string}
    echo "mod8 string: [${#${string}}][${string}] ==> [${#${mod8}}][${mod8}]"
    mod9=${(Pl(20)(-)(>)Pr(20)({VARS[a]})(<))string}
    echo "mod9 string: [${#${string}}][${string}] ==> [${#${mod9}}][${mod9}]"

    log_info "Just create a list of N chars..."
    y=""; x=${(l:10:)y}; echo "A:\t[${x}]"
#    x=${(l:11::x:)""}; echo "B:\t[${x}]"    # FAILS with "parameter not set"
    x=${(l:10:):-}; echo "C:\t[${x}]"
    x=${(l:10::x::y:):-}; echo "D:\t[${x}]"
    x=${(r:10::x::y:):-}; echo "E:\t[${x}]"
    x=${(r:$(( 5 + 5 ))::x::y:):-}; echo "F:\t[${x}]"
}
#experiment_0021 "${@}"


function experiment_0020() {
    log_header "Look at using exit codes given 'set -e' in our init module."

    my_function() {
        echo "This message will NOT be printed."
        return 1 # Function exits here
        echo "This message will NEVER be reached."
    }

#    my_function
    echo "Function exit status: $?"
    log_header "Experiment with _max_string_length() function."

    len=$(_max_string_length "${@}")
    exit_code=$?
    echo "output: [${len}]\texit code: [${exit_code}]"
    len=$(_max_string_length "1")
    exit_code=$?
    echo "output: [${len}]\texit code: [${exit_code}]"
    len=$(_max_string_length)
    exit_code=$?
    echo "output: [${len}]\texit code: [${exit_code}]"

    #log_header "${@}"

}
#experiment_0020 "${@}"


function experiment_0019() {
    log_header "Split args into an array using word and newline delimiter."

if false; then

    log_info "Cast args into an array, loop through array, and bracket each item:"
    local args=( ${@} )
    for x in ${args[@]}; do
        echo "[${x}]"
    done
    log_info "==> Works!"
#    echo "{\n  \"argx\": ["; for argxx in "${argx[@]}"; do echo "    \"${argxx}\","; done; echo "  ]\n}"

    log_info "Loop through the args array and split each item:"
    local args2=()
    local split_arg arg item
    for arg in ${args[@]}; do
        split_arg=( "${(s:\n:)arg}" )
#        printf "[${split_arg}] ==> [ " ; printf "[%s] " "${split_arg[@]}" ; printf "]" ; echo
        echo "[${split_arg}] ==>"
        for item in "${split_arg[@]}"; do
            echo "\t[${item}]"
        done
    done
    log_info "==> Works!"

    log_info "Explore why (f) is not working:"
    split_args=( ${(f)args} )
    split_args=( "${(s:\n:)args}" )
    echo "With an echo loop:"
    for arg in ${split_args}; do
        echo "[${arg}]"
    done
    echo "With printf lines:"
    printf "["; printf "[%s]" ${split_args}; printf "]"; echo
    log_info "==> -\(oo)/- (f) is opaque; it does not work as expected because it treats input as a single string using IFS as delimiter..."

    log_info "Loop through input args and add to an array after splitting each arg:"
    echo "args = [${@}]"
    local array=()
    local e
    for e in "${@}"; do
        array+=( "${(s:\n:)e}" )
    done
    for e in ${array} ; do echo "[${e}]" ; done
    log_info "==> Works!"

    log_info "Simplify into a single command line:"

    log_info "print out all unquoted args:"
    for e in ${@} ; do echo "[${e}]" ; done

    log_info "print out all quoted args:"
    for e in "${@}" ; do echo "[${e}]" ; done

    log_info "Loop over the unquoted array:"
    for e in ${args} ; do echo "[${e}]" ; done

    log_info "Loop over the quoted array:"
    for e in "${args}" ; do echo "[${e}]" ; done

    log_info "Split the args array with newline: \${(s:\_n:)\${@[@]}}"
    local array=( "${(s:\n:)${@[@]}}" )
    for e in ${array} ; do echo "[${e}]" ; done
    log_info "==> Works! Use this when we want args concatenated first before splitting by newline."

    log_info "Split the args array with newline, but treat each array element as a separate word: \${(@s:\_n:)\${@[@]}}"
    local array=( "${(@s:\n:)${@[@]}}" )
    for e in ${array} ; do echo "[${e}]" ; done
    log_info "==> Works! Use this when we want to treat each arg as a line and split each argument individually by newline."

fi

    log_info "Replace escape sequences before we split because we will cast some as newlines."

#    echo "Original args:"
#    for e in ${@} ; do echo "-[${e}]" ; done

    echo "Original args:"
    local args=( ${@} )
    for e in ${args} ; do echo "o[${e}]" ; done ; echo

    echo "Escaped args:"
#    args=( ${args//'\a'/} )         # TESTING
    args=( ${args//'\a'/} )         # \a bell character
    args=( ${args//'\b'/} )         # \b backspace
    args=( ${args//'\c'/} )         # \c suppress subsequent character and final newline
    args=( ${args//'\e'/} )         # \e escape
    args=( ${args//'\f'/'\n'} )     # \f form feed
    args=( ${args//'\r'/'\n'} )     # \r carriage return
    args=( ${args//'\t'/"----"} )   # \t horizontal tab
    args=( ${args//'\v'/'\n'} )     # \v vertical tab
    for e in ${args} ; do echo "e[${e}]" ; done ; echo

    local lines=( ${(@s:\n:)${args}} )  # Treat arg as individual lines and split.
    echo "Cleansed individual args as lines:"
    for e in ${lines} ; do echo "c[${e}]" ; done ; echo

    local lines=( ${(s:\n:)${args}} )   # Concatenate args into one line and split.
    echo "Cleansed concatenated args as lines:"
    for e in ${lines} ; do echo "c[${e}]" ; done ; echo

    log_info "==> Works! See models of arg individuality vs. arg concatenation above."

    # NOTE: You can test the cleansed lines using this command:
    # $ zsh scratchpad.zsh foo bar "this isn\nnnewline" "lasv\vvr\rrtn\nnx" "some t\tt done" "*"

#    log_info "banner using the scratchpad-processed args list:"
    log_header "${lines}"
#
#    log_info "banner using the raw args list:"
    log_header "${@}"
}
#experiment_0019 "${@}"


function experiment_0018() {
    log_header "Debug inputs to logging functions logging newlines."

    log_info "string = \ \\ \\\ \\\\ \\\\\ 0"
    string="\\\\0"
    echo "${string}"
    log_info "${string}"

    log_info "string = <tab>a[<esc:\_0>b<newline><esc:\_n>]<newline>c"
    string="\ta[\\\0b\\\n]\nc"
    echo ${string}
    echo "${string}"
    log_info ${string}
    log_info "${string}"

    _log "_log()" ${string}
    _log "_log() ${string}"
    _info "_info()" ${string}
    log_info "log_info()" ${string}

    log_header "this is a horizontal tab: [\t]"
    log_header "this is a vertical tab: [\v]"
    log_header "this is a newline: [\n]"

    log_info "Define a new log_xxx() to test out \_n, \_t, etc."
    function _xxx()     { echo "${fmt_cyan}${@}${fmt_reset}" }
    function log_xxx()  { echo "$(_log "$(_xxx "${@}")")" }
    log_xxx "hola" ${string}

}
#experiment_0018 "${@}"


function experiment_0017() {
    log_header "Print script dirpath and name."

    log_info "These commands respond differently inside and outside a function:"
    log_info "\t\$(dirname "\${0}")"
    log_info "\t\$(basename "\${ZSH_ARGZERO}")"
    local script_dirpath=$(dirname "${0}")            # Original script directory path.
    local script_name=$(basename "${ZSH_ARGZERO}")    # Original script filename.

    echo "[${0}] : [${script_dirpath}] / [${script_name}]"
}
#experiment_0017 "${@}"


function experiment_0016() {
    log_header "Convert a string into an absolute path using history expansion modifiers"

    local dirs=()
    dirs+="/absolute/path"
    dirs+="/absolute/path/slash/"
    dirs+="relative/path"
    dirs+="relative/path/slash/"
    dirs+="multi//slash///path/"
    dirs+="slash/rel/dir//../../dot///dots"
    dirs+="~/_dev/foobar"
    dirs+="~/_dev//abs///foo/../bar/../dir/"

    for dir in ${dirs}; do
        echo "[${dir}]"
        echo "\t\${dir}\t\t\t==>\t[${dir}]"
        echo "\t\${dir:a}\t\t==>\t[${dir:a}]"
        echo "\t\${dir:A}\t\t==>\t[${dir:A}]"
        echo "\t\${dir:P}\t\t==>\t[${dir:P}]"
        echo "\t\${dir/#"~"/\${HOME}}\t==>\t[${dir/#"~"/${HOME}}]"
        echo "\t\${\${dir/#"~"/\${HOME}}:a}\t==>\t[${${dir/#"~"/${HOME}}:a}]"
    done

    for dir in ${dirs}; do
        echo "[${dir}]"
        dir=${dir/#"~"/${HOME}} # Expand "~" to the home directory, if present.
        dir=${dir:a}            # Absolute path with a history expansion modifier.
        echo "\t==>\t[${dir}]"
    done

    log_info "Replace tilde in string:"
    local x="~/tilde"
    echo ${x}
    echo ${x/tilde/xxx}
    echo ${x/"tilde"/"xxx"}
    echo ${x/~/xxx}
    echo ${x/"~"/"xxx"}

}
#experiment_0016 "${@}"


function experiment_0015() {
    log_header "Explore discovering the types of shell parameters (manual pg. 170)"

    # Try a few different things.
    typeset -l lowercase_var="HOLA" # Always converts to lowercase on assignment
    echo "${lowercase_var}"
    my_lowercase_var="BONI"
    echo "${lowercase_var}"
    local int str char array
    typeset -p int str char array
#    echo "${functions}"
#    typeset -p "${functions}"

    function demo() {
        # Declare some variables with different types/attributes
        typeset -i my_integer=10             # Integer
        typeset -a my_array=(one two three)  # Indexed array
        typeset -A my_assoc_array=( [key1]=value1 [key2]=value2 ) # Associative array (hash)
        typeset -r my_readonly_var="immutable" # Read-only
        typeset -l my_lowercase_var="HELLO"    # Always converts to lowercase on assignment
        typeset -u my_uppercase_var="world"    # Always converts to uppercase on assignment
        typeset -x my_exported_var="PATH_VALUE" # Exported (environment variable)
        my_scalar="just a string"           # Default scalar (string)
        echo "--- Using typeset -p ---"
        # Check each variable
        typeset -p my_integer
        typeset -p my_array
        typeset -p my_assoc_array
        typeset -p my_readonly_var
        typeset -p my_lowercase_var
        typeset -p my_uppercase_var
        typeset -p my_exported_var
        typeset -p my_scalar
        typeset -p unset_var # Check an unset variable (will show an error, but helps illustrate)
        echo ""
        # Output example:
        # typeset -i my_integer="10"
        # typeset -a my_array=( 'one' 'two' 'three' )
        # typeset -A my_assoc_array=( [key1]='value1' [key2]='value2' )
        # typeset -r my_readonly_var="immutable"
        # typeset -l my_lowercase_var="hello"
        # typeset -u my_uppercase_var="WORLD"
        # typeset -x my_exported_var="PATH_VALUE"
        # typeset my_scalar="just a string"
        # typeset: no such variable: unset_var (this is output to stderr)
    }
    demo "${@}" ; exit

}
#experiment_0015 "${@}"


function experiment_0014() {
    log_header "Explore Prompting User for Input"

    echo "--- Basic Read (no explicit prompt) ---"
    echo "Please enter something:"
    read
    echo "You entered: '$REPLY'" # REPLY is the default variable for 'read'

    echo "\n--- Read into a specific variable ---"
    echo "What's your name?"
    read user_name
    echo "Hello, $user_name!"

    echo "\n--- Ask a y/n question ---"
    echo "XXX"
    if read -q "confirm?Proceed? (y/N): "; then
        echo "\nConfirm: ["${confirm}"]"
    else
        echo "NO"
    fi

    # This does not work with "-q" option because that sets the
    # return status of the command. Thus, to use it, simply put
    # it inside an if/then statement, as shown above and voila.
    # Use the pattern below WITHOUT "-q" to check other inputs.
#    read -q "confirm?Proceed? (y/N): "
#    case "${confirm}" in
#        ([yY])  echo "YES"  ;;
#        (*)     echo "NO"   ;;
#    esac

}
#experiment_0014 "${@}"


function experiment_0013() {
    log_header "Explore Parsing CLI Arguments manually"
    log_info "Requirements:"
    log_info "[P1] Support short and long flags (presence is a switch: e.g., -x, --verbose)."
    log_info "[P1] Support short and long options (param/value pair: e.g., -p=value, --param=value)."
    log_info "[P1] Mixed order of flags and/or options (e.g., -a --bar=foo -c --help)."
    log_info "[P1] Required vs. optional parameters."
    log_info "[P1] Do not assign flags as option values."
    log_info "[P1] Everything after "--" is positional."
    log_info "[P2] Different option arg/value separator (e.g., -p value vs. -p=value)."
    log_info "[P2] Chained/combined/stacked short flags (e.g., -alF vs. -a -l -F)."
    log_info "Non-requirements:"
    log_info "What do we do when we find an unexpected argument, do we flag everything after that as positional?"
    log_info "What do we do when we find an unrecognized flag or option, do we flag everything after that as positional or quit?"
    log_info "https://xpmo.gitlab.io/post/using-zparseopts/"
    log_info "try this script with the following command:"
    log_info "[ sandbox.zsh -r=foo=car -d=foo -h -z --y "single_word" --x="complex='value'" -v ]"

    # Comments/Notes:
    # - Option: 'getopts'
    #   - The command 'getopts' does not meet the requirements because when it
    #     finds an option it uses the next positional argument as its value.
    #     Thus, calls with bad params leads to bad settings, such as this:
    #     with "script.zsh -d -f file" 'getopts' interprets "-d=-f"
    #     - Earlier experiments with 'getopts' show that it does not support
    #       requirement #7.
    # - Option: 'zparseopts' 
    #   - Documentation for 'zparseopts' can be found via "$ man zshmodules"
    #     under the "THE ZSH/ZUTIL MODULE" section.
    #   - It handles "--foo=bar" (with spec "f:") but treats the argument as
    #     "=bar", which must be later parsed. This leads to a situation where
    #     the command is opaque to some of its behaviour without having a good
    #     understanding of how it works, raising some flags with respect to
    #     maintaining it over time.
    #   - Does not support stacked flags (requirement #3).
    # - Option: manual parsing
    #   - We are explicit and transparent about handling arguments, which
    #     makes it easier to maintain long-term.

    log_info "Reference: https://gist.github.com/mattmc3/804a8111c4feba7d95b6d7b984f12a53"

    function parseopts_demo() {
        local args=("${@}")
        local positional=()
        local flag_help=false
        local flag_verbose=false
        local opt_repo="repo_name"
        local opt_dir="dirpath"

        # Loop through the arguments as long as there are arguments left ($# > 0)
        # and each argument starts with a hyphen (indicating an option).
        # - Use parameter expansion to get the value after the "=".
        # - At the end of options marker (i.e., --) stop parsing options; remaining args are positional.
        # - At first bad arg, break the loop and handle positional arguments separately.
        #   All remaining arguments will be treated as positional.
        # - To extract value from a --param=value, use the parameter expansion
        #   pattern: ${name#name} (lazy match) ${name##name} (greedy match)
        #   - Use lazy match to extract only the first and allow args
        #     like "-d=foo=bar" to be extracted as "-d" ==> "foo=bar"
        #     instead of "-d=foo" ==> "bar".
        while (( $# )); do
            echo "trying: ["${1}"]"
            case "$1" in
                (--)            echo "--"; shift; positional+=("${@}"); break   ;;
                (-h|--help)     echo "h"; flag_help=true                        ;;
                (-v|--verbose)  echo "v"; flag_verbose=true                     ;;
                (-d=*|--dir=*)  echo "d"; opt_dir="${1#*=}"                     ;;
                (-r=*|--repo=*) echo "r"; opt_repo="${1#*=}"                    ;;
                (-*)            echo "-*) ["${1}"]"; positional+=("${@}"); break ;;
                (*)             echo "*) ["${1}"]"; positional+=("${@}"); break ;;
            esac
            shift
        done

        # After parsing options, remaining arguments are positional.
        # Store positional arguments in a separate array if needed.
#        positional=("${@}")

        # Display parsed values.
        echo "### Original arguments ###"
        echo "args:\t\t["${args}"]"
        echo
        echo "### Parsed arguments ###"
        echo "flag_help:\t["${flag_help}"]"
        echo "flag_verbose:\t["${flag_verbose}"]"
        echo "opt_repo:\t["${opt_repo}"]"
        echo "opt_dir:\t["${opt_dir}"]"
        echo "positional:\t["${positional}"]"
        echo

        log_info "[SUCCESS] ==> Follow the argument parsing pattern from this experiment."
    }
    parseopts_demo "${@}"

    function parseopts_demo2() {
        local args=("${@}")
        local invalid=()
        local help=false
        local force=false
        local dir
        local repo
        while (( $# )); do
            case "$1" in
                (-h|--help)     help=true       ;;
                (-f|--force)    force=true      ;;
                (-d=*|--dir=*)  dir="${1#*=}"   ;;
                (-r=*|--repo=*) repo="${1#*=}"  ;;
                (*)             invalid+=(${1}) ;;
            esac
            shift
        done
        echo "### Original arguments ###"
        echo "args:\t\t["${args}"]"
        echo
        echo "### Parsed arguments ###"
        echo "help:\t\t["${help}"]"
        echo "force:\t\t["${force}"]"
        echo "repo:\t\t["${repo}"]"
        echo "dir:\t\t["${dir}"]"
        echo "invalid:\t["${invalid}"]"
        echo
    }
    parseopts_demo2 "${@}"

}
#experiment_0013 "${@}"


function experiment_0012() {
    log_header "Explore Parsing CLI Arguments with 'zparseopts'"
    log_info "Requirements:"
    log_info "1) Flags (or switches), short and long (e.g., -x, --verbose)."
    log_info "2) Options, short and long (e.g., -p=value, --param=value)."
    log_info "3) Combined/stacked short flags (e.g., -alF vs. -a -l -F)."
    log_info "4) Mixed order of flags and/or options (e.g., -a --bar=foo -c --help)."
    log_info "5) Different option arg/value separator (e.g., -p value vs. -p=value)."
    log_info "6) Required vs. optional parameters."
    log_info "7) Do not assign flags as option values."
    log_info "https://xpmo.gitlab.io/post/using-zparseopts/"

    # Comments/Notes:
    # - Option: 'getopts'
    #   - The command 'getopts' does not meet the requirements because when it
    #     finds an option it uses the next positional argument as its value.
    #     Thus, calls with bad params leads to bad settings, such as this:
    #     with "script.zsh -d -f file" 'getopts' interprets "-d=-f"
    #     - Earlier experiments with 'getopts' show that it does not support
    #       requirement #7.
    # - Option: 'zparseopts' 
    #   - Documentation for 'zparseopts' can be found via "$ man zshmodules"
    #     under the "THE ZSH/ZUTIL MODULE" section.
    #   - It handles "--foo=bar" (with spec "f:") but treats the argument as
    #     "=bar", which must be later parsed. This leads to a situation where
    #     the command is opaque to some of its behaviour without having a good
    #     understanding of how it works, raising some flags with respect to
    #     maintaining it over time.
    #   - Does not support stacked flags (requirement #3).
    # - Option: manual parsing
    #   - We are explicit and transparent about handling arguments, which
    #     makes it easier to maintain long-term.

    log_info "EXPERIMENT: Use 'zparseopts' for zsh scripts."
    log_warning "==> Concerns about maintenance and usage of this tool."
    log_warning "Due to the opaque nature of how it operates, we would likely"
    log_warning "need refreshers every time it needs to be updated or used."
    log_warning "Experimentation steps shown below for reference."

    # Declare an associative array to specify flags and options.
    local -A spec
    # Populate the associative array.
    spec=(
        "f:"        "INPUT_FILE"
        "file:"     "INPUT_FILE"
        "o:"        "OUTPUT_FILE"
        "output:"   "OUTPUT_FILE"
        "v"         "VERBOSE_MODE"
    )
    # Print out the associative array as 'zparseopts' expects it.
    # Using parameter expansion flags, "${array[@]}" and "${(@)array}" are equivalent.
    log_info "associative array spec: (printed in JSON format by looping through all key/value pairs)"
    echo "{\n  \"spec\": {"; for k v in "${(kv)spec[@]}"; do echo "    \"${k}\": \"${v}\","; done; echo "  }\n}"
    log_info "\${spec[@]}:"
    echo ${spec[@]}
    log_info "\${(k)spec[@]}:"
    echo ${(k)spec[@]}
    log_info "\${(v)spec[@]}:"
    echo ${(v)spec[@]}
    log_info "\${(kv)spec[@]}:"
    echo ${(kv)spec[@]}
    log_info "zip up keys and values:"
    local keys=(${(k)spec[@]})
    local values=(${(v)spec[@]})
    echo ${keys:^values}
    echo ${keys:^^values}
    log_info "output keys/values with a = delimiter via a loop:"
    for k v in "${(kv)spec[@]}"
        do echo "${k}=${v}"
    done
#    log_info "output keys/values with a = delimiter via parameter expansion flags:"
#    echo ${(j:=:kv)spec}
#    echo ${(FkPkv)spec}
#    echo ${(j:\n:u::=:::kv)spec}

    function zparseopts_demo() {
        # The code sample below was found as part of a tutorial/demo.
        # It does not work, but gives enough insight to save for reference.

        # --- Global Variables ---
        APP_NAME=$(basename "$0")   # $0 registers as the function's name.
        APP_NAME=$(basename "${ZSH_ARGZERO}")
        INPUT_FILE=""
        OUTPUT_FILE=""
        VERBOSE_MODE=false

        # --- Functions ---
        demo_usage() {
            echo "Usage: ${APP_NAME} [-v] [-f <file>|--file=<file>] [-o <file>|--output=<file>]"
            echo
            echo "  -f, --file      type:option         Specify input file."
            echo "  -o, --output    type:option         Specify output file."
            echo "  -v, --verbose   type:flag/switch    Enable verbose output."
            echo "  -h, --help      type:flag/switch    Display this help message."
#            exit 1
        }

        demo_main() {
            # Define options and their corresponding array variables
            # Each element is "option_name:value_array_var_name" or "option_name"
            # -v        -> VERBOSE_MODE (boolean flag)
            # -f, --file -> INPUT_FILE (requires argument)
            # -o, --output -> OUTPUT_FILE (requires argument)
            # -h, --help -> usage (calls a function if present)
            local -A opt_spec
            opt_spec=(
                "f:"        "INPUT_FILE"    # -f requires an argument, stores in INPUT_FILE
                "file:"     "INPUT_FILE"    # --file requires an argument, also stores in INPUT_FILE
                "o:"        "OUTPUT_FILE"
                "output:"   "OUTPUT_FILE"
                "v"         "VERBOSE_MODE"  # -v is a boolean flag
                "h"         "usage"         # -h calls the usage function
                "help"      "usage"         # --help calls the usage function
            )

            # Parse options using zparseopts
            # Stores remaining arguments in `args`
            # Handles -f foo.txt and -f=foo.txt automatically for 'f:'
            # Handles --file foo.txt and --file=foo.txt automatically for 'file:'
            local args
            zparseopts -D -E -a args -- "${(kv)opt_spec[@]}" || echo "==> demo_usage()"

            # --- Process collected arguments ---

            # Check if verbose mode was enabled
            if [[ -n "$VERBOSE_MODE" ]]; then
                echo "Verbose mode enabled."
            fi

            # Check if input file was provided
            if [[ -z "$INPUT_FILE" ]]; then
                echo "Error: Input file must be specified." >&2
                echo "==> demo_usage()"
            fi

            # Set default output file if not provided
            if [[ -z "$OUTPUT_FILE" ]]; then
                echo "No output file specified. Using /dev/stdout."
                OUTPUT_FILE="/dev/stdout"
            fi

            echo "Input file: [$INPUT_FILE]"
            echo "Output file: [$OUTPUT_FILE]"
            echo "Remaining arguments: [${args[@]}]" # Arguments not consumed by options
        }
        demo_main "${@}"
    }
    zparseopts_demo "${@}"
}
#experiment_0012 "${@}"


function experiment_0011() {
    log_header "Capture multi-line output from a function with a null character delimiter"

    # Print out elements of an array, one at a time.
    log_info "Define an array explicitly and print out its elements, one at a time."
    local arr_a=("first one" "then two" "finally three")
    for x in "${arr_a[@]}"; do echo "[${x}]" ; done

    # Function that returns a null-delimited list of things.
    function str_0_delimited_items() {
        local arr_items=("one" "two items" "this is three")
        local item
        for item in "${arr_items[@]}" ; do
            printf "%s\0" "${item}"
        done
    }

    # Get the string with null-delimited items and check it.
    local str_0delim_items=$(str_0_delimited_items)
    log_info "Print out a string with null-delimited items."
    echo "[${str_0delim_items}]"

    # Experiment: Replace the null-delimiter with a semicolon using parameter expansion.
    log_info "EXPERIMENT: Replace null-character with ';' using parameter expansion \${name//pattern/repl}."
    str_semidelim_items=${str_0delim_items//$'\0'/;}
    echo "[${str_semidelim_items}]"
    log_info "[SUCCESS] ==> Works! To look for the null character use \$'\\ 0' (sans <space>)."

    # Experiment: Split using "read".
    log_info "EXPERIMENT: Split the string with null-delimited items using 'read'."
    arr_b=()
    printf "${str_0delim_items}" | while read -r -d '' item; do
        echo "str item: [${item}]"
        arr_b+="${item}"
    done
    log_info "Print array created from null-delimited input:"
    for x in "${arr_b[@]}"; do echo "arr item: [${x}]" ; done
    log_warning "[SUCCESS] ==> Works, but it uses an external command."

    # Experiment: Split using a while loop and parameter expansions.
    log_info "EXPERIMENT: Split using a while loop and parameter expansions \${name%%pattern} and \${name:#pattern}."
    local arr_c=()
    local str_tmp="${str_0delim_items}"
    while [[ "${str_tmp}" == *$'\0'* ]]; do
        part="${str_tmp%%$'\0'*}"
        arr_c+="${part}"
        str_tmp="${str_tmp#*$'\0'}"
    done
    arr_c+="$str_tmp"
    echo "# items: ${#arr_c}"
    for x in "${arr_c[@]}"; do echo "item: [${x}]" ; done
    log_warning "[SUCCESS] ==> Works, but it is verbose and funky (see the empty item)."

    # Cast a string into an array:
    # - Use parameter expansion flags to split the string.
    #     https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion-Flags
    #     split_string_n=${(f)string}   # "f" is shorthand for "ps:\n:"
    #     split_string_0=${(0)string}   # "0" is shorthand for "ps:\0:"
    # - Use the string to populate an array:
    #     string_array=( ${split_string} )
    log_info "EXPERIMENT: Use parameter expansion flag "0""
    arr_d=(${(0)str_0delim_items})      # arr_d=(${(ps:\0:)str_0delim_items})
    echo "# items: ${#arr_d}"
    for x in "${arr_d[@]}"; do echo "arr item: [${x}]" ; done
    log_info "[SUCCESS] ==> Works using parameter expansion!\nxxx"
    log_info "==> Use this pattern:"
    log_info "\tGiven a null-char delimited string:\t'str0_items'"
    log_info "\tCast into an array of items:\t\tarr_items=(\${(0)str0_items})"

    # Show issues with null character in parameter expansion substitution.
    log_info "Show issues with null character in parameter expansion substitution."
    my_string=$'part1\0part2\0part3'
    echo "${my_string}"
    echo "${my_string//\0/X}"
    echo "${my_string//'\0'/X}"
    echo "${my_string//$'\0'/X}"
}
#experiment_0011 "${@}"


function experiment_0010() {
    log_header "Set a variable to the original script filename so we can reference it"

    local SCRIPT_NAME0=$(basename "${ZSH_ARGZERO}") # Filename of original script file.
    local SCRIPT_NAME1=$(basename "$0")             # Name of current function.
    local SCRIPT_NAME2=${ZSH_ARGZERO}               # Filepath of original script file.
    local SCRIPT_NAME3=${ZSH_ARGZERO//.\//}         # Filepath of original script file.

    echo "${SCRIPT_NAME0}"
    echo "${SCRIPT_NAME1}"
    echo "${SCRIPT_NAME2}"
    echo "${SCRIPT_NAME3}"
}
#experiment_0010 "${@}"


function experiment_0009() {
    log_header "Test rendering of logging messages"

#    display_sgr_codes
    log_info "this is a sentence\nand another" "and a third"
    log_warning
    log_error
    log_debug
    _banner

    # "banner" is a syste mutility that prints out large text for banners.
    # banner "hello"

    echo "$(_info "this is a sentence\nand another")"
    log_debug
}
#experiment_0009 "${@}"


function experiment_0008() {
    log_header "Capture multi-line output from a function with a newline delimiter"

    #echo "${!my_var*}"
    # Output: my_var1 my_var2
    #exit

    # Function to generate lines of text and "return" them
    # by printing each line followed by a newline.
    get_lines_array_no_read_no_ifs() {
        # These are the "lines" you want to return.
        # Use printf "%s\n" to ensure each item is on its own line.
        printf "%s\n" "Hello, this is line one."
        printf "%s\n" "This is line two, which might contain !@#\$%^&* characters."
        printf "%s\n" "" # An empty line
        printf "%s\n" "The last line."
    }

    # --- Calling get_lines_array_no_read_no_ifs and capturing its output ---

    # 1. Execute the function within a command substitution: `$(get_lines_array_no_read_no_ifs)`
    #    This captures all the function's stdout as a single string.
    # 2. Use the 'f' parameter expansion flag: `(f)`
    #    This flag tells Zsh to split the string into an array, treating newlines as delimiters.
    # 3. Use quotes around the command substitution `"$()"`
    #    This is important! It ensures the entire output is treated as one string by the
    #    expansion, before the `f` flag processes it. Without quotes, Zsh would first
    #    perform word splitting (using IFS) on the command substitution's output, which
    #    we want to avoid.
    my_received_lines_no_ifs=( ${(f)"$(get_lines_array_no_read_no_ifs)"} )

    echo "--- Processing 'my_received_lines_no_ifs' ---"
    echo "Number of lines received: ${#my_received_lines_no_ifs[@]}"
    for i in "${!my_received_lines_no_ifs[@]}"; do
        # Print each line with its index
        echo "Line $i: '${my_received_lines_no_ifs[i]}'"
    done

    echo "\n----------------------------------------\n"
}
#experiment_0008 "${@}"


function experiment_0007() {
    log_header "Split args into distinct lines, including newline within an arg"

    #--------------------------------------+
    # Synopsis:     split_into_lines [<arg>*]
    # Description:  Splits arguments and '\n'-delimited argument values and
    #               writes out every line separately. The caller is responsible
    #               for parsing the output and pull out the individual lines.
    #               It was designed to help make multi-line banner logs since
    #               to calculate banner width we need the longest-width line.
    # Globals:      None.
    # Arguments:    <arg>   XXX
    # Outputs:      Writes output string to stdout.
    # Returns:      0
    # Example:      lines=($(split_into_lines "mary had a\nbig lamb" "she did"))
    # (FIX IT!)     for l in "${lines[@]}" ; do echo "${l}" ; done
    #--------------------------------------+
    # TODO: Look at perhaps generating a null-character-delimited output string.
    # This would be a relatively safe option since we remove it from input args.
    # TODO: Rework using ${(s)...} to split and ${(j)...} to join.
    #--------------------------------------+
    function split_into_lines() {

        local lines=()
        for arg in "$@"; do

            # Cleanse the argument from mostly non-printable characters.
            arg="${arg//'\0'/}"     # Remove null character "\0".
            arg="${arg//'\r'/}"     # Remove carriage return "\r".

            # Skip empty arguments.
            [[ -z "${arg}" ]] && continue       # Skip zero-length args.
            [[ "${arg}" == '\n' ]] && continue  # Skip newline-only args.

            # Use a parameter expansion flag to force field splitting on a newline.
            local tokens=("${(s:\n:)arg}")

            for token in "${tokens[@]}"; do
                # Skip empty tokens.
                [[ -z "${token}" ]] && continue         # Skip zero-length tokens.
                [[ "${token}" == '\n' ]] && continue    # Skip newline-only args.

                # Add valid token into our lines array.
                lines+=("${token}")
            done
        done

        # Output the results by echoing out every line separately.
        local line
        for line in "${lines[@]}"; do
            echo "${line}"
        done
    }


    split_into_lines "XXXthis one mary had" "a little\nlamb" "" "\n" "\n\n" "x\r\ny\rz" "\n\r\n"

    results=($(split_into_lines "this one mary had" "a little\nlamb" "" "\n" "\n\n" "x\r\ny\rz" "\n\r\n"))
    echo "results=${results}"
    tokens=("${(s:\0:)results}")
    for token in "${tokens[@]}"; do
        echo "[${token}]"
    done

    echo "\nTest Case: 0 (song)"        ;   split_into_lines "mary had" "a little\nlamb"
    echo "\nTest Case: A ()"            ;   split_into_lines 
    echo "\nTest Case: B (``)"          ;   split_into_lines  ""
    echo "\nTest Case: C (_)"           ;   split_into_lines  " "
    echo "\nTest Case: D (n)"           ;   split_into_lines  "\n"
    echo "\nTest Case: E (an)"          ;   split_into_lines  "a\n"
    echo "\nTest Case: F (nb)"          ;   split_into_lines  "\nb"
    echo "\nTest Case: G (anb)"         ;   split_into_lines  "a\nb"
    echo "\nTest Case: H (0 n nn)"      ;   split_into_lines  "" "\n" "\n\n"
    echo "\nTest Case: I (xrnyrz)"      ;   split_into_lines  "x\r\ny\rz"
    echo "\nTest Case: J (r)"           ;   split_into_lines  "\r"
    echo "\nTest Case: K (nrn)"         ;   split_into_lines  "\n\r\n"

}
#experiment_0007 "${@}"


function experiment_0006() {
    log_header "Check the type of a variable"

    function type_of_var() {
        local type_sig=$(declare -p "$@" 2>/dev/null)

        if [[ "${type_sig}" =~ "declare --" ]]; then
            echo "string"
        elif [[ "${type_sig}" =~ "declare -a" ]]; then
            echo "array"
        elif [[ "${type_sig}" =~ "declare -A" ]]; then
            echo "map"
        else
            echo "none"
        fi
    }

    function type_of_varx() {
        local e
        echo "Loop over each arg:"
    #    for e in "${args_array}" ; do
        for e in "${@}" ; do
            echo "->\t[${e}]"
        done

        echo "\nCast args into an array and loop over all elements:"
        local args_array=("${@}") # Cast all args into an array.
        for e in "${args_array[@]}" ; do
            echo "->\t[${e}]"
        done
    }
    #type_of_varx 1 "one string"
    #type_of_varx 2 "one very long stringX\nwithX\nnewlineX\ncharsX\nembedded"
    type_of_varx 3 "two string argsX\nwithX\nnewline" "charsX\nembedded"
    #arrx=("array" "with" "every" "word\nand\nnewline" "an" "item")
    #type_of_varx "me" "${arrx[@]}" "too"
    #type_of_varx 5 ("array" "with" "elementsX\nhavingX\nnewlines" "inX\nthem")
}
#experiment_0006 "${@}"


function experiment_0005() {
    log_header "Parse a variable and print out each element"

#    local data=("element1" "element2" "element3")
#    local data=("this" "is" "text")
    local data="this\nis\ntext"

    ## Loop through the array
    for i in "${data[@]}" ; do
        echo "[${i}]" # or do whatever with individual element of the array
    done

    # Parse a variable and process each line it contains individually.
    # - Handle the situation where the string contains "\n" or is an array.
    # - Get the type of a variable to handle different cases?
    #   - https://gist.github.com/CMCDragonkai/f1ed5e0676e53945429b

    while IFS= read -r line ; do
        echo "...[$line]..."
    done <<< "${data}"

}
#experiment_0005 "${@}"


function experiment_0004() {
    log_header "Test rendering of logging messages and other variables"

    display_sgr_codes

    log_info
    log_warning
    log_error
    log_debug

    log_header "This is a banner message"
    log_warning "This is a warning message."
    log_error "This is an error message."

    echo ${ZSH_ARGZERO}
    echo ${ZSH_ARGZERO//.\//}
#    banner "xxx"
    x=${@:-foobar}
    echo ${x}
    string=${1:-Running script}
    for (( i = 0; i < "${#string}" ; i++ )) ; do
        echo "${i}"
    done
}
#experiment_0004 "${@}"


function experiment_0003() {
    log_header "Check a .zshrc file for specific commands and add them if necessary"

    header="# Use chruby by default."
    pattern=$(cat <<EOS   # Parameter expansion of $(...) in here-document.
source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh
source $(brew --prefix)/opt/chruby/share/chruby/auto.sh
chruby ruby-3.4.1
EOS
    )
    matches=$(grep -F "${pattern}" "${HOME}/.zshrc")

    if [[ "${matches}" == "${pattern}" ]] ; then
        echo "found!"
    else
        echo "not found..."
        echo >> zshrc.txt
        echo "${header}" >> zshrc.txt
        echo "${pattern}" >> zshrc.txt
    fi

    echo >> zshrc.txt
    echo "${header}" >> zshrc.txt
    echo "${pattern}" >> zshrc.txt

    exit

    pattern=$(cat <<EOS
foo
bar
EOS
    )

    matches=$(grep -F "${pattern}" "zshrc.txt") # WORKS
    #matches=$(grep -F -z "${pattern}" "zshrc.txt")

    # Notes:
    # - Option "-z" casts the file as a single line, but not the pattern.
    # - Each line in the pattern is treated as a separate pattern.
    # 

    printf "pattern=\n${pattern}\n\n"
    printf "matches=\n${matches}\n\n"

    if [[ "${matches}" == "${pattern}" ]] ; then
        echo "matches == pattern"
    else
        echo "matches != pattern"
    fi

    exit

    if [[ -n $(grep -F -z "${pattern}" "zshrc.txt") ]] ; then
    #if [[ -n $(grep -F -z "yesmatch" "zshrc.txt") ]] ; then
    #if [[ -n $(grep -F -z "nomatch" "zshrc.txt") ]] ; then
        echo "found!"
    else
        echo "not found..."
    fi
}
#experiment_0003 "${@}"


function experiment_0002() {
    log_header "Explore parsing command line options using 'getops' (2 options)"

    # Parse command line options. A leading `:` in the optstring suppresses
    # default error messaging by `getopts` and places option name in ${OPTARG}.
    _INPUT_REPO="${1:-}"
    _INPUT_DIR="${2:-}"
    if [[ -n "${_REPO_INPUT}" && "${_REPO_INPUT}" != "-*" ]]; then
        _REPO="${_REPO_INPUT}"
    fi
    _OPTSTRING=":r:d:"
    while getopts "${_OPTSTRING}" opt; do
        case "${opt}" in
            r)  echo "[-${opt}][${OPTARG}]" ;;
            d)  echo "[-${opt}][${OPTARG}]" ;;
            :)  echo "Error: Option -${OPTARG} requires an argument." ;;
            ?)  echo "Warning: Invalid option -${OPTARG}" ;;
        esac
    done
    #shift $((OPTIND-1))
}
#experiment_0002 "${@}"


function experiment_0001() {
    log_header "Explore parsing command line options using 'getops' (1 option)"

    # --- Initialize variables with default values ---
    name="World" # Default name if -n is not provided
    # --- Parse options using getopts ---
    # The option string "n:" means:
    #   - 'n' is the option character.
    #   - ':' immediately after 'n' means -n REQUIRES an argument.
    while getopts "n:" opt; do
        case "${opt}" in
            n) # If the -n option is found
                name="${OPTARG}" # OPTARG holds the argument provided to -n
                ;;
            -) # If the -n option is found
                name="${OPTARG}" # OPTARG holds the argument provided to -n
                ;;
            ?) # If an invalid option is provided (e.g., -x)
                echo "Error: Invalid option: -${OPTARG}" >&2
                echo "Usage: $(basename "$0") [-n <name>]" >&2
                ;;
            *) # Catch-all for any other unexpected options
                echo "Error: Unexpected option -${OPTARG}" >&2
                echo "Usage: $(basename "$0") [-n <name>]" >&2
                exit 1
                ;;
        esac
    done
    # Shift off any processed options and their arguments.
    # OPTIND will point to the first argument *after* the options.
    shift $((OPTIND-1))
    # --- Main script logic ---
    echo "Hello, $name!"
    # Check if any non-option arguments were left (e.g., if user typed "./sandbox.zsh -n John extra_arg")
    if (( $# > 0 )); then
        echo "Warning: Extra arguments were provided and ignored: '$*'" >&2
    fi
}
#experiment_0001 "${@}"


#--------------------------------------+--------------------------------------#
# Framework to build a menu that runs any function in this module.
#--------------------------------------+--------------------------------------#
# "functions" is an associative array for all defined functions such that
# function[<name>]=<definition>.
# - Use the "k" parameter expansion flag to extract only the keys.
# - Use array subscript flags to perform pattern matching on the keys
#   and extract only those matching the desired functions.
# - To list all functions: print -l ${(k)functions}
# - To create a title from each function, consider this pattern:
#       local title="foobar"
#       if [[ --title ]]; then echo ${title} ; else log_header ${title} ; fi
#--------------------------------------+--------------------------------------#
function _framework_() {

    log_info "all function names with \${(k)functions}:"
    local f_names=${(k)functions}
    echo ${f_names}

    log_info "filter a bespoke array by \"exp\" with \${aa[(R)*exp*]} except "R" only matches last instance:"
    local array=("this is" "an array" "of an" "experiment" "explained")
    #txt="exp" ; local names=${array[(R)*${txt}*]}
    local names=${array[(R)*exp*]}
    echo ${names}

    log_info "filter a bespoke associative array with \$name[(flags)exp]:"
    local -A assoc_array
    assoc_array['abc']="foo"
    assoc_array['an array']="bar"
    assoc_array['of an']="wizz"
    assoc_array['experiment']="fizz"
    assoc_array[explained]="buzz"
    local keys=${(k)assoc_array} ; echo "Keys:\t["${keys}"]"
    local values=${assoc_array} ; echo "Values:\t["${values}"]"
    #local names=${(k)assoc_array[(K)"abc"]}     # Works.
    local names=${(k)assoc_array[(K)'abc']}     # Works.
    #local names=${(k)assoc_array[(K)*abc*]}     # Does not work.
    #local names=${(k)assoc_array[(K)abc]}       # Works.
    #local names=${(k)assoc_array[(K)*"ex"*]}       # .
    echo "Key-matches:\t["${names}"]"
    log_warning "==> matching depends on how the key was entered/quoted."

    local foo=(bar baz)
    echo "${(@)${foo}[1]}"
    echo "${${(@)foo}[1]}"
    echo ${(s/x/)foo}
    echo ${(j/x/s/x/)foo}
    echo ${(s/x/)foo%%1*}
}
