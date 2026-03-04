<!-- 
[![Linkedin](https://linkedin-follow-icon)](https://www.linkedin.com/in/mauriciolomelin)
[![Scratchpad/Notepad/Notebook/...](https://site-follow-icon)](https://maulomelin.github.io)
-->

# My Shell Script Framework.

## Command Scripts

* [bin/export-repo.zsh](bin/export-repo.zsh): Exports a repo to a target directory and removes any Git metadata.
* [bin/install-jekyll-ssg.zsh](bin/install-jekyll-ssg.zsh): Installs/updates Jekyll and Bundler to their latest versions.
* [bin/script-template.zsh](bin/script-template.zsh): Script template for application scripts.
* [bin/install-shell-scripts.zsh](bin/install-shell-scripts.zsh): Installs and updates all these personal shell scripts in the shell environment.

## Utility Libraries

* [lib/init.zsh](lib/init.zsh): Sets up the shell environment and sources all lib utilities below.
* [lib/lib-dat--data-type-safety.zsh](/lib/lib-dat--data-type-safety.zsh): Data sanitizers - various predicates, normalizers, validators, assertions, and converters.
* [lib/lib-env--environment.zsh](lib/lib-sys--system-info.zsh): Access to environment information.
* [lib/lib-err--error-handling.zsh](lib/lib-err--error-handling.zsh): Error handling utilities.
* [lib/lib-log--logging.zsh](lib/lib-log--logging.zsh): Structured logging for apps and libraries.
* [lib/lib-reg--global-registry.zsh](lib/lib-reg--global-registry.zsh): Global registry of constants.
* [lib/lib-sys--system.zsh](lib/lib-sys--system-info.zsh): Process and execution control.
* [lib/lib-ded--graveyard.zsh](lib/lib-ded--graveyard.zsh): Graveyard of discarded code worth keeping around for reference.

## Style Guide

My scripts share a consistent look, feel, and flow because every script I write follows a set of rules that define a common design language. This is my personal style guide. It embraces defensive coding techniques and structural guidelines that make my code easier to write, read, and maintain.

The rules are straightforward and apply to both application and library scripts:

* **Favor readability over cleverness.**

    * When I go back to a script, a clever trick today will only waste my time deciphering it in the future, whereas readable code that is well commented lets me work without a steep learning curve.

* **Favor Zsh builtins over external commands.**

    * I have lately favored Z shell because I work mostly on macOS. Z shell builtins can be used to replace many external commands. I prefer Zsh builtins because they remove an external dependency from my scripts. For example:

        ```sh
        local fmt_datetime="%Y%m%dT%H%M%S"
        local datetime script

        # Do this:
        datetime="${(%):-"%D{${fmt_datetime}}"
        script="${ZSH_ARGZERO:A:t}"

        # Instead of this:
        datetime="$(date ${fmt_datetime})"
        script="$(basename "${ZSH_ARGZERO}")"
        ```

    * I only use portable code (i.e., POSIX compliant) when absolutely necessary. This helps me reference a single document source for how the script operates: <a href="https://zsh.sourceforge.io/" target="_blank">The Z Shell Manual</a>).

* **Assign a unique 3-character namespace code to every script.**

    * The namespace code is a unique 3-character string assigned to each script (e.g., "APP", "LOG", "SYS"). I capture it in the filename, in the file's comment header, and the code is used by other rules - they are a core part of how my scripts are architected and managed.

* **Use `lib-{namespace}--{short_description}.zsh` for all script library filenames.**

    * Any script file under `~/_local/lib/`, such as `lib-log--{short_description}.zsh` or `lib-sys--{short_description}.zsh`. This convention ensures namespaces are unique across all libraries.

* **Use `{short_description}.zsh` for all script executable filenames.**

    * Any script file under `~/_local/bin/`, such as `export-repo.zsh` or `install-jekyll-ssg.zsh`. Try to use a leading verb.

* **Use a `.zsh` extension for Z shell scripts and appropriate extension for other interpreters.**

    * Use appropriate file extensions for all shell scripts (e.g., `*.sh`, `*.bash`, `*.ksh`). This is a best practice for explicitly indicating the intended interpreter at the file level.

* **Start all script files with `#!/usr/bin/env zsh`.**

    * This is supposed to make scripts more portable, but I do this for explicit identification. I run scripts by invoking the zsh interpreter explicitly with `$ zsh script.zsh`, bypassing the shebang. The shebang is there for direct execution with `$ ./script.zsh` (requires `$ chmod +x script.zsh` first), and to clarify the interpreter when only looking at the code.

My scripts use a namespaced architecture. Since shell scripts share a global namespace, this is a defensive practice I leverage to reduce potential naming conflicts across scripts, to make library functions discoverable, and to reduce global namespace pollution by encapsulating all global variables. Here is what this entails:

* **Use `{namespace}::{fname}()` for all public script function names.**

    * Make sure the namespace prefix is in lower-case (e.g., `log::info()`, `log::error()`). Given unique namespaces, this eliminates the likelihood of name collisions.

* **Define all functions starting with the regex pattern `^function [a-zA-Z0-9_:]+\(\) \{$`.**

    * Because shell scripts share a global namespace, my initialization script checks to make sure all function names are unique across all libraries, executable, and environment. Using this function prototype pattern as the first line of any function definition ensures it will be picked up.

* **Use `_{fname}()` for all private script function names.**

    * The convention and only requirement is to use a leading underscore (e.g., `_to_multiline()`) for functions private to a module. Without any additional constraints, there is no guarantee that private function names are unique across all scripts. I could enforce namespace prefixes on all private functions to make them unique (e.g., `_log_to_multiline()`). However, it turns out this makes scripts harder to read and maintain. Thus, I relaxed this requirement and instead added code in the initialization script to run a check on all files to make sure all function names are unique - readability over elaborate schemes. I will cover this later.

* **Use the map `[_]{namespace}[]` as a module registry to hold global variables.**

    * I implement module registries using global associative arrays to hold all global variables used by a module. By convention I use `_{namespace}` for private entries, and `{namespace}` for public entries. This encapsulation adds only 2 variables per module to the global namespace, thus limiting global namespace pollution.

        ```sh
        # file: lib_fbr.zsh

        typeset -gA _FBR        # Private registries are named "_{namespace}".
        _FBR[SETTING]=3         # Private constants are in upper-case.
        _FBR[state]="a"         # Private mutables are in lower-case.

        typeset -gA FBR         # Public registries are named "{namespace}".
        FBR[DEFAULT_STATE]="X"  # Public constants are in upper-case.
        FBR[variance]=0.1       # Public mutables are in lower-case.
        ```

* **Use `{namespace}::(get|set)_{variable}()` getter/setter functions to access public variables across modules.**

    * For example, `log::get_verbosity()`, `log::set_verbosity()`. This abstraction ensures I can validate any new values, I can update other state variables as needed, and it decouples users of that API from needing to worry about the internal workings of a module - standard API stuff.

When writing the actual logic of a script, there are a few rules and common patterns that make them easier to maintain.

* **Write a header comment for all public functions in a library.**

    * Even if the function is obvious, this is a good habit to keep. This should be the only documentation a developer needs to read to learn how to use the library; they should not need to read code. This is an example of the header comment block I use:

        ```sh
        # -----------------------------------------------------------------------------
        # Syntax:   function_name <req_arg> ... [<opt_arg> ...]
        # Args:     <req_arg>  Brief description of required arguments.
        #           <opt_arg>  Brief description of optional arguments.
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

    * The `local` builtin does not propagate the exit code from a command substitution, so a declaration will shadow the exit status of the subshell. In the "Do not do this" example below, the `return` short-circuit will never be triggered.

        ```sh
        # Do this:
        local x
        x=$(dat::as_bool ...) || return 1

        # Do not do this:
        local x=$(dat::as_bool ...) || return 1
        ```

* **Always check return values and bubble up status codes.**

    * Use logical AND or check for errors manually.

        ```sh
        # Do this:
        cp source.txt target.txt && echo "Success"

        # Do this:
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

        # Do this:
        do_something "${foo[@]}"

        # Doable (but not preferred):
        do_something "${(@)foo}"

        # Do not do this:
        do_something "${foo}"
        ```

In general:

* **Be kind to yourself.**

    * Write your scripts with future maintainability in mind because you will be the one coming back to your own scripts later on. Follow best practices. Use common design patterns. Choose meaningful and descriptive variable names. Document code describing what it does, not how it works. Use "TODO:" and "DEBUG:" comments freely. Be consistent. Keep things simple and straightforward.