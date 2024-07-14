#!/bin/bash

###################################################
# description: fuzzy history search
#       input: none
#      return: matched command in history
###################################################
function fuzzy_shell_history {
    if ! fs_pre_source; then
        return 1
    fi
    local history_awk_script='{
        $1=""
        $2=""
        $3=""
        print $0
    }'

    local selected_command=$(history -i | fzf | awk "${history_awk_script}" | tr -d '\n' | awk '{gsub(/^ */, ""); print}')

    fs_print_white "you have selected:"
    fs_print_info_line "${selected_command}"

    if fs_yn_prompt "sure to execute the command?"; then
        eval "${selected_command}"
    else
        printf "${FS_COLOR_YELLOW}%s${FS_COLOR_RESET}\n" "NOT execute the command"
    fi
}

###################################################
# description: source execute files
#       input: none
#      return: 0: success | 1: fail
###################################################
function fs_pre_source {
    # source utils.sh
    local fs_root="${HOME}/.fuzzy_shell"
    local util_file_path="${fs_root}/scripts/utils.sh"

    if [[ ! -f "${util_file_path}" ]]; then
        printf "%s\n" "${util_file_path} do not exist. Install fuzzy-shell first."
        printf "%s\n" "Exit Now..."
        return 1
    else
        source "${util_file_path}"
    fi
    return 0
}
