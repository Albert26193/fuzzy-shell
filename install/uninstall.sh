#!/bin/bash

###################################################
# description: uninstall fuzzy-shell files from ~/.fuzzy_shell
#       input: none
#      return: 0: succeed | 1: failed
###################################################
function fs_uninstall {
    # source utils.sh
    local git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    local util_file_path="${git_root}/src/scripts/utils.sh"

    if [[ ! -f "${util_file_path}" ]]; then
        printf "%s\n" "${util_file_path} do not exist."
        printf "%s\n" "Exit Now..."
        return 1
    else
        source "${util_file_path}"
    fi

    # Check if the script is executed as root
    if [[ ! "$(id -u)" -eq 0 ]]; then
        fs_print_error_line "Please run this script as root or sudo." >&2
        return 1
    fi

    # remove bin files
    local to_check_list=("fzf" "fd")
    for item in "${to_check_list[@]}"; do
        if [[ -L "/usr/bin/${item}" ]]; then
            bash -c "rm /usr/bin/${item}"
            fs_print_green_line "${item} is removed."
        fi
    done

    # get actual user
    local actual_user=$(fs_get_user)
    if [[ -z "${actual_user}" ]]; then
        fs_print_error_line "Error: actual user not found."
        return 1
    fi

    # get actual user home
    local user_home=$(su - ${actual_user} -c "printf '%s' \"\$HOME\"")
    if [[ -z "${user_home}" ]]; then
        fs_print_error_line "Error: actual user not found."
        return 1
    fi

    # get target dir
    local target_dir="${user_home}/.fuzzy_shell"
    if [[ ! -d "${target_dir}" ]]; then
        fs_print_warning_line "${target_dir} not existed, exits now."
        return 1
    fi

    if ! fs_yn_prompt "Do you want to REMOVE ${FS_COLOR_GREEN}${target_dir}(install dir)${FS_COLOR_RESET} ?"; then
        fs_print_white_line "Exit Now..."
        return 1
    else
        bash -c "rm -r ${target_dir}"
        fs_print_green_line "${target_dir} is clear now."
    fi

    fs_print_green_line "fuzzy-shell files are cleared sucessfully. You have uninstalled it! 🔧️"
    return 0
}

fs_uninstall
