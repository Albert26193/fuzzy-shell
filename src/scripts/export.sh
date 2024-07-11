#!/bin/bash

###################################################
# description: source execute files
#       input: none
#      return: 0: success | 1: fail
###################################################
function fs_source_user() {

    # Check if the script is sourced
    local script_file="${HOME}/.fuzzy_shell/scripts"

    if [[ ! -d "${script_file}" ]]; then
        printf "%s\n" "${script_file} do not exist. Install fuzzy-shell first."
        printf "%s\n" "Exit Now..."
        return 1
    fi

    source "${script_file}/fzf/fzf_history.sh"
    source "${script_file}/fzf/fzf_search.sh"
}

fs_source_user
