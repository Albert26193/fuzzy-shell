#!/bin/bash

###################################################
# description: fuzzy history search
#       input: none
#      return: matched command in history
###################################################
function fuzzy_shell_history() {
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
        if [[ "$(which pbcopy)" ]] && fs_yn_prompt "copy the command into your OS clip board?"; then
            eval "echo "${selected_command}" | pbcopy"
            printf "%s\n" "first line in OS clip board:"
            printf "${FS_COLOR_GREEN}%s${FS_COLOR_RESET}\n" "$(pbpaste >&1)"
            echo "just paste it"
        else
            printf "${FS_COLOR_YELLOW}%s${FS_COLOR_RESET}\n" "Exit Now..."
        fi
    fi
}
