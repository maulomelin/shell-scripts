#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2025 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Install command for personal shell scripts
# SPDX-FileComment: <text>
#   To install the shell scripts, run the following command in your terminal:
#   $ curl -fsSL https://raw.githubusercontent.com/maulomelin/shell-scripts/HEAD/install.zsh | zsh
# </text>
# -----------------------------------------------------------------------------

{ # This safety block ensures the entire script is downloaded.

# Fail fast if not running under zsh.
#   - Single brackets and "printf" for portability.
if [ -z "${ZSH_NAME}" ]; then
    printf "Error: This script must be run under zsh." >&2
    exit 1
fi

# Fail fast if not running on macOS.
#   - Installation point is macOS-specific, so check for Darwin kernel.
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This installation is only supported on macOS." >&2
    exit 1
fi

# Fail fast if Git is not installed.
if ! command -v git &> /dev/null ; then
    echo "Error: Git is required to install the shell scripts. Please install Git and try again." >&2
    exit 1
fi

# Run the installation under an anonymous function to avoid polluting the global namespace.
function () {
    # 1. Create a secure, unique temporary directory.
    local temp_dirpath=$(mktemp -d -t "shell-scripts--${(%):-"%D{%Y%m%dT%H%M%S}"}") || {
        echo "Error: Failed to create a temporary directory." >&2
        exit 1
    }
    echo "Created temporary directory [${temp_dirpath}]"

    # 2. Set a trap to delete the temporary directory on exit.
    #   - Define it using "trap" to ensure local variables are in scope.
    trap "
        echo 'Deleting temporary directory [${temp_dirpath}]'
        rm -rf '${temp_dirpath}' || echo 'Warning: Failed to remove temporary directory [${temp_dirpath}]'
    " EXIT INT TERM

    # 3. Clone the repository into the temporary directory.
    local repo="https://github.com/maulomelin/shell-scripts"
    git clone --depth=1 "${repo}" "${temp_dirpath}" || {
        echo "Error: Failed to clone the repository." >&2
        exit 1
    }
    echo "Cloned repository [${repo}] into [${temp_dirpath}]"

    # 4. Run the setup script from the cloned repository.
    zsh "${temp_dirpath}/bin/install-shell-scripts.zsh" || {
        echo "Error: Failed to run the setup script." >&2
        exit 1
    }
}

} # This safety block ensures the entire script is downloaded.