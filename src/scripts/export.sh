#!/bin/bash

###################################################
# description: source execute files
#       input: none
#      return: 0: success | 1: fail
###################################################
function fs_source_scripts {
    local script_file="${HOME}/.fuzzy_shell/scripts"
    local source_list=(
        "${HOME}/.fuzzy_shell/scripts/fzf/fzf_search.sh"
        "${HOME}/.fuzzy_shell/scripts/fzf/fzf_history.sh"
        "${HOME}/.fuzzy_shell/config.env"
    )

    if [[ ! -d "${script_file}" ]]; then
        printf "%s\n" "${script_file} do not exist. Install fuzzy-shell first."
        printf "%s\n" "Exit Now..."
        return 1
    fi

    for item in "${source_list[@]}"; do
        if [[ ! -f "${item}" ]]; then
            printf "%s\n" "${item} do not exist. Install fuzzy-shell first."
            printf "%s\n" "Exit Now..."
            return 1
        else
            source "${item}"
        fi
    done
}

###################################################
# description: export fuzzy function for usr interface
#          $1: [option]
#          $2: [args]
#          $2: [argw
#      return: 0: success | 1: fail
###################################################
function fuzzy {
    # check if fuzzy-shell functions exist
    local functions_to_check=(
        "fuzzy_shell_search"
        "fuzzy_shell_history"
        "fuzzy_shell_jump"
        "fuzzy_shell_edit"
    )
    for item in "${functions_to_check[@]}"; do
        if ! type "${item}" >/dev/null 2>&1; then
            printf "%s\n" "${item} do not exist. Install fuzzy-shell first."
            printf "%s\n" "Exit Now..."
            return 1
        fi
    done

    # parse input args
    case "$1" in
    "--search" | "-s")
        fuzzy_shell_search "$2" "$3"
        ;;
    "--history" | "-H")
        fuzzy_shell_history
        ;;
    "--jump" | "-j")
        fuzzy_shell_jump "$2" "$3"
        ;;
    "--edit" | "-e")
        fuzzy_shell_edit "$2" "$3"
        ;;
    "--help" | "-h" | *)
        printf "%s\n" "Usage: fuzzy [option] [args]"
        printf "%s\n" "Options:"
        printf "%s\n" "  -s, --search [keyword1] [keyword2], namely fuzzy search"
        printf "%s\n" "  -H, --history                     , namely fuzzy history search"
        printf "%s\n" "  -j, --jump [keyword1] [keyword2]  , namely fuzzy jump"
        printf "%s\n" "  -e, --edit [keyword1] [keyword2]  , namely fuzzy edit"
        ;;
    esac
}

fs_source_scripts
