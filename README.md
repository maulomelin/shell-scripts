<!-- 
[![Linkedin](https://linkedin-follow-icon)](https://www.linkedin.com/in/mauriciolomelin)
[![Scratchpad/Notepad/Notebook/...](https://site-follow-icon)](https://maulomelin.github.io)
-->

# My Shell Script Framework

## Shell Scripts Installer

To install the shell scripts on your local machine, run the following command in your terminal:

```sh
curl -fsSL https://raw.githubusercontent.com/maulomelin/shell-scripts/HEAD/install.zsh | zsh
```

This will install scripts under `~/_local/`:

```sh
~/_local/
├── bin/                            # Executable script root.
│   └── ...                         # Various command scripts.
└── lib/                            # Common library root.
    ├── framework/                  # Bespoke script framework.
    │   ├── init.zsh                # Framework initialization script.
    │   └── lib/                    # Namespaced framework utility libraries.
    │       ├── log--logging.zsh    # Logging utilities.
    │       ├── sys--system.zsh     # Script control utilities.
    │       └── ...                 # Various utility libraries.
    └── manifests/                  # Scripted setup manifests for apps/tools/configs.
```

## Style Guide

My scripts share a consistent look, feel, and flow because every script I write follows a set of rules that define a common design language. This is my personal style guide. It embraces defensive coding techniques and structural guidelines that make my code easier to write, read, and maintain.

The rules are straightforward and apply to both application and library scripts:

* **Favor readability over cleverness.**

    * When I go back to a script, a clever trick today will only waste my time deciphering it in the future, whereas readable code that is well commented lets me work without a steep learning curve.

* **Write for Z shell (zsh).**

    * I have lately favored writing for Z shell because it is the default interactive shell on macOS (I work mostly on macOS), and I find it easier to use over other shells.

    * I can reference a single document source for how the script operates: <a href="https://zsh.sourceforge.io/" target="_blank">The Z Shell Manual</a>).

    * I only use portable code (i.e., POSIX compliant) when absolutely necessary.

* **Use a `.zsh` extension for Z shell scripts and appropriate extension for other interpreters.**

    * Use appropriate file extensions for all shell scripts (e.g., `*.sh`, `*.bash`, `*.ksh`). This is a best practice for explicitly indicating the intended interpreter at the file level.

* **Use descriptive names on all script filenames.**

    * Scripts should be easy to recognize by looking at their filename, whether it is a command script or a library script. `lib/framework/lib/cfg--config-mgmt.zsh` or `bin/install-shell-scripts.zsh` are easy to recognize at a glance.

* **Start all script files with `#!/usr/bin/env zsh`.**

    * This is supposed to make scripts more portable, but I do this for explicit identification. I run scripts by invoking the zsh interpreter explicitly with `$ zsh script.zsh`, bypassing the shebang. The shebang is there for direct execution with `$ ./script.zsh` (requires `$ chmod +x script.zsh` first), and to clarify the interpreter when only looking at the code.

* **Favor Zsh builtins over external commands.**

    * Z shell builtins can be used to replace many external commands. I prefer Zsh builtins because they remove an external dependency from my scripts. For example:

        ```sh
        local fmt_datetime="%Y%m%dT%H%M%S"
        local datetime script

        # DO THIS:
        datetime="${(%):-"%D{${fmt_datetime}}"
        script="${ZSH_ARGZERO:A:t}"

        # DOABLE (but not preferred):
        datetime="$(date ${fmt_datetime})"
        script="$(basename "${ZSH_ARGZERO}")"
        ```

My scripts use a namespaced architecture. Since shell scripts share a global namespace, this is a defensive practice I leverage to reduce potential naming conflicts across scripts, to make library functions discoverable, and to reduce global namespace pollution by encapsulating all global variables. Here is what this entails:

* **Assign a unique 3-character namespace code to every framework utility library.**

    * The namespace code is a unique 3-character string assigned to each framework utility library (e.g., "LOG", "SYS", "DAT"). I capture it in the filename, in the file's comment header, and the code is used by other rules - they are a core part of how my framework is architected and managed.

* **Use `{namespace}--{description}.zsh` for all framework utility library filenames.**

    * Any script file under `~/_local/lib/framework/lib/`, such as `log--logging.zsh` or `sys--system.zsh`. This convention ensures namespaces are unique across all libraries.

* **Use `{namespace}::{fname}()` for all public function names.**

    * Make sure the namespace prefix is in lower-case (e.g., `log::info()`, `log::error()`). Given unique namespaces, this eliminates the likelihood of name collisions.

* **Define all functions starting with the regex pattern `^function [a-zA-Z0-9_:]+\(\) \{$`.**

    * Because shell scripts share a global namespace, the initialization script checks to make sure all function names are unique across all libraries, executable, and environment. Using this function prototype pattern as the first line of any function definition ensures it will be picked up.

    * Why do we anchor a function name to the beginning of a line (i.e., with `^function...`)? Locally scoped functions (i.e., those inside other functions) are likely intended to shadow an original function within that scope. If we assume that indented functions are locally scoped and non-indented functions are globally scoped, then we ignore the indented ones.

        ```sh
        function log::info_x() { ... }      # Global function - Check for collisions.

        function experiment() {
            function log::info_x() {        # Shadow function - Ignore for collisions.
                echo "${@}" >&2
            }
            log::info_x "shadow log"        # Uses shadow function.
        }
        ```

* **Use `_{fname}()` for all private script function names.**

    * The convention and only requirement is to use a leading underscore (e.g., `_to_multiline()`) for functions private to a module. Without any additional constraints, there is no guarantee that private function names are unique across all scripts. I could have enforced namespace prefixes on all private functions to make them unique (e.g., `_log::to_multiline()`). However, it turns out this makes scripts harder to read and maintain. Thus, I relaxed this requirement and instead added code in the initialization script to run a check on all files to make sure all function names are unique - readability over elaborate schemes.

* **Use the map `[_]{namespace}[]` as a module registry to hold global variables.**

    * I implement module registries using global associative arrays to hold all global variables used by a module. By convention I use `_{namespace}` for private entries, and `{namespace}` for public entries. This encapsulation adds only 2 variables per module to the global namespace, thus limiting global namespace pollution.

        ```sh
        # file: fbr--foobar.zsh

        typeset -gA _FBR=(      # Private registries are named "_{namespace}".
            [SETTING]=3         # Private constants are in upper-case.
            [state]="a"         # Private mutables are in lower-case.
        )

        typeset -gA FBR=(       # Public registries are named "{namespace}".
            [DEFAULT_STATE]="X" # Public constants are in upper-case.
            [variance]=0.1      # Public mutables are in lower-case.
        )
        ```

* **Use `{namespace}::(get|set)_{variable}()` getter/setter functions to access public variables across modules.**

    * For example, `log::get_verbosity()`, `log::set_verbosity()`. This abstraction ensures I can validate any new values, I can update other state variables as needed, and it decouples users of that API from needing to worry about the internal workings of a module - standard API stuff.

When writing the actual logic of a script, there are a few rules and common patterns that make them easier to maintain.

* **Write a header comment for all public functions in a library.**

    * Even if the function is obvious, this is a good habit to keep. This should be the only documentation a developer needs to read to learn how to use the library; they should not need to read code. This is an example of the header comment block I use:

        ```sh
        # -----------------------------------------------------------------------------
        # Syntax:   function_name <req> ... [<opt> ...]
        # Args:     <req>       Brief description of required arguments.
        #           <opt>       Brief description of optional arguments.
        # Outputs:  Describe the output of the function and some of the logic used to
        #           generate different outputs based on different conditions.
        # Status:   Describe any return and exit status codes.
        # Details:
        #   - Bulleted specification of the function, as needed.
        # -----------------------------------------------------------------------------
        function function_name() { ... }
        ```

* **Use explicit type declarations.**

    * Declare every variable used, and always use explicit flags to clarify the intent of the variable being declared. Not only does this serve as self-documenting code, but it makes it obvious when reading code what scope and underlying data structure you're dealing with.

        ```sh
        # Local scope.      # Global scope.
        local scalar    ;   typeset -g global_scalar
        local -a array  ;   typeset -ga global_array
        local -A map    ;   typeset -gA global_map
        ```

* **Keep declaration and assignment as separate statements.**

    * The `local` builtin does not propagate the exit code from a command substitution, so a declaration will shadow the exit status of the subshell. In the "DO NOT DO THIS" example below, the `return` short-circuit will never be triggered.

        ```sh
        # DO THIS:
        local x
        x=$(dat::as_bool ...) || return 1

        # DO NOT DO THIS:
        local x=$(dat::as_bool ...) || return 1
        ```

* **Narrow the scope of variable declarations as much as possible.**

    * Shell scripts share a global namespace. Because of this, limiting the scope of any variable to the block of code that needs it prevents namespace pollution, avoids name collisions, and makes it easier to read and maintain scripts.

    * If a variable is only used in a local scope, declare it locally with `local {variable}`:

        ```sh
        function foo() {    # Inside a function.
            local var       # Without the `local` keyword, "var" becomes global.
            # ...
        }

        function () {       # Inside an anonymous function.
            local var       # Without the `local` keyword, "var" becomes global.
            # ...
        }
        ```

    * If a private variable is used across functions, define it in the private registry and access it directly within the module:

        ```sh
        typeset -gA _FBR=(              # Private registry for module "Foobar (FBR)".
            _FBR[MIN_COUNT]=0           # Private constant.
            _FBR[count]=0               # Private variable/mutable.
        )

        function _increment_count() {   # Increment counter.
            (( _FBR[count]++ ))
        }
        function _decrement_count() {   # Decrement counter down to MIN_COUNT.
            (( _FBR[count] > _FBR[MIN_COUNT] )) && (( _FBR[count]-- ))
        }
        ```

        Writing getter/setter functions for accessing private variables within a module is overkill for my personal scripts.

    * Use anonymous functions to declare code that executes right away and clears out any locally-scoped variables when complete.

* **Always check return values and bubble up status codes.**

    * Use logical AND or check for errors manually.

        ```sh
        # DO THIS:
        cp source.txt target.txt && echo "Success"

        # DO THIS:
        cp source.txt target.txt || return $?
        echo "Success"
        ```

    * When short-circuiting a response, always bubble up any error status codes (i.e., `some_action || return 1` until you get to the top level. At the top level, one can then create traps to handle the error.

    * TODO: I still need to decide on a standard way to bubble up status codes:
        * Simplify things and always execute a `return 1`.
        * Be transparent and use the original code via `$?`.
        * Customize the meaning of an error by executing a custom `return {n}`.

* **When passing an array, always do it explicitly.**

    * Reference arrays explicitly via `"${foo[@]}"` or `"${(@)foo}"` (we prefer the former). Referencing an array with `"${foo}"` is equivalent to accessing a scalar value, which results in the first item. This will cause loops and passing arrays into functions to only treat the first element of the array. In double quotes, array elements are put into separate words, so that `"${foo[@]}"` is the same as `"${foo[1]}" "${foo[2]}" ...`.

        ```sh
        local -a foo=( "${@}" )

        # DO THIS:
        do_something "${foo[@]}"

        # DOABLE (but not preferred):
        do_something "${(@)foo}"

        # DO NOT DO THIS:
        do_something "${foo}"
        ```

In general:

* **Be kind to yourself.**

    * Write your scripts with future maintainability in mind because you will be the one coming back to your own scripts later on. Follow best practices. Use common design patterns. Choose meaningful and descriptive variable names. Document code describing what it does, not how it works. Use "TODO:" and "DEBUG:" comments freely. Be consistent. Keep things simple and straightforward.