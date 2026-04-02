#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText:   (c) 2026 Mauricio Lomelin <maulomelin@gmail.com>
# SPDX-License-Identifier:  MIT
# SPDX-FileComment:         Setup: Jekyll Static Site Generator (SSG)
# -----------------------------------------------------------------------------

function () {
    # --------------------------------------
    log::info_header "Setup: Jekyll"
    #   - https://jekyllrb.com/docs/installation/
    # --------------------------------------

    # Jekyll is a Ruby gem. Ruby needs to be installed first.
    if ! command -v ruby &> /dev/null ; then
        log::error "Error installing Jekyll: Ruby is not installed."
        log::error "Install Ruby and try again."
        return 1
    fi

    # Update or install Jekyll and Bundler gems.
    if command -v jekyll &> /dev/null ; then
        log::info "Jekyll is installed. Updating it..."
        gem update jekyll
        gem update bundler
    else
        log::info "Jekyll is not installed. Installing it..."
        gem install jekyll
        gem install bundler
    fi

    # Check versions.
    log::info "Check Ruby version 3.4.1:"
    ruby -v     # ruby 3.4.1
    log::info "Check Jekyll version >=\"4.4.1\":"
    jekyll -v   # jekyll 4.4.1
    log::info "Check Bundler version >=\"2.6.9\":"
    bundler -v  # bundler 2.6.9

} || return 1