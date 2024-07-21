#!/bin/bash

###################################################
# description: fuzzy history search
#       input: none
#      return: matched command in history
###################################################
function fuzzy_shell_history {
    # if ! fs_pre_source; then
    #     return 1
    # fi
    local history_awk_script='{
        $1=""
        $2=""
        $3=""
        print $0
    }'

    local selected_command=$(history -i | fzf | awk "${history_awk_script}" | tr -d '\n' | awk '{gsub(/^ */, ""); print}')

    printf "%s" "you have selected: "
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

###################################################
# description: give colorful yn_prompt
#          $1: custom prompt to print
#      return: 0: yes | 1: no
###################################################
function fs_yn_prompt {
    local fs_color_cyan="\033[36m"
    local fs_color_reset="\033[0m"
    local yn_input=""
    while true; do
        printf "$1 ${fs_color_cyan}[y/n]: ${fs_color_reset}"
        read yn_input
        case "${yn_input}" in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *) fs_print_red_line "Please answer yes[y] or no[n]." ;;
        esac
    done
}

###################################################
# description: print information
#          $1: information to print
#      return: 0: yes
###################################################
function fs_print_info_line {
    local fs_background_green="\033[42m"
    local fs_color_black="\033[1;30m"
    local fs_color_reset="\033[0m"
    printf "${fs_background_green}${fs_color_black}%s${fs_color_reset}\n" "$1"
    return 0
}
