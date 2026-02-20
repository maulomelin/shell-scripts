#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Namespace: APP (Deploy Scripts to Local Env)
# -----------------------------------------------------------------------------

# 1. Define Paths (using your REG constants if sourced, or local defaults)
local repo_dir="${0:a:h}"           # Absolute path to this repo
local target_root="${HOME}/_local"

# 2. Defensive Check: Ensure target directories exist
mkdir -p "${target_root}"/{bin,lib}

# 3. Orchestrate the Sync
# -a: archive mode (preserves permissions/times)
# -v: verbose (tells you what is happening)
# --delete: removes files in _local if deleted in repo
# --exclude: ignore git metadata and the deploy script itself
print "Deploying scripts to ${target_root}..."

rsync -av --delete \
    --exclude=".git/" \
    --exclude="deploy_local.zsh" \
    --exclude="README.md" \
    "${repo_dir}/" "${target_root}/"

# 4. Final Polish: Ensure everything in bin is executable
chmod +x "${target_root}/bin"/*

# 5. Update the Environment (The "Env" part)
if ! grep -q "${local_bin}" ~/.zshrc; then
    print "Adding ${local_bin} to ~/.zshrc..."
    echo "export PATH=\"${local_bin}:\$PATH\"" >> ~/.zshrc
    print "Environment updated — please run 'exec zsh' to apply changes."
fi


print "Deployment complete — Your ~/_local hierarchy is now in sync."