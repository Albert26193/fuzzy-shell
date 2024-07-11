#!/bin/bash

###################################################
# description: uninstall fuzzy-shell files from ~/.fuzzy_shell
#       input: none
#      return: 0: succeed | 1: failed
###################################################
function fs_uninstall {
    local git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    local util_file_path="${git_root}/copy/scripts/utils.sh"

    if [[ ! -f "${util_file_path}" ]]; then
        printf "%s\n" "${util_file_path} do not exist."
        printf "%s\n" "Exit Now..."
        return 1
    else
        source "${util_file_path}"
    fi

    # Check if the script is executed as root
    if [[ "$(id -u)" -eq 0 ]]; then
        fs_print_error_line "Please Don't run this script as root." >&2
        return 1
    fi

    local target_dir="${HOME}/.fuzzy_shell"

    if [[ ! -d "${target_dir}" ]]; then
        fs_print_warning_line "${target_dir} not existed, exits now."
        exit 1
    fi

    if ! fs_yn_prompt "Do you want to REMOVE ${fs_COLOR_GREEN}${target_dir}(install dir)${fs_COLOR_RESET} ?"; then
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
