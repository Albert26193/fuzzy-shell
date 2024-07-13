###################################################
# description: install dependency
#       input: none
#      return: 0: success | 1: fail
###################################################
function fs_install_dependency() {
    # load config file
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
        fs_print_error_line "run this script with ROOT or SUDO" >&2
        return 1
    fi

    # check if current arch is x86_64
    if ! fs_check_arch | grep -q "x86_64"; then
        fs_print_red "only support x86_64 arch, current arch is:"
        fs_print_white_line "$(fs_check_arch)"
        return 1
    fi

    local all_install_list=(
        "fd"
        "fzf"
    )

    local to_install_list=()
    for package in "${all_install_list[@]}"; do
        if ! which "$package" &>/dev/null; then
            fs_print_red "[ X ]"
            fs_print_red "${package}"
            fs_print_white_line "is not installed"
            to_install_list+=("$package")
        else
            fs_print_green "[ √ ]"
            fs_print_green "${package}"
            fs_print_white_line "is installed"
        fi
    done

    if [[ ${#to_install_list[@]} -eq 0 ]]; then
        echo "All dependency installed!"
        return 0
    fi

    # if have dependency not installed, install it
    printf "\n"
    fs_print_yellow "🔧Here is the list of packages to install: "
    printf "${FS_COLOR_CYAN}%s${FS_COLOR_RESET} " "${to_install_list[@]}"
    printf "\n"
    fs_print_cyan_line "total count to install: ${#to_install_list[@]}"
    if fs_yn_prompt "Do you want to ${FS_COLOR_GREEN}install all dependency${FS_COLOR_RESET}?"; then
        fs_print_white_line "install dependency ..."
        for item in "${to_install_list[@]}"; do
            if fs_link_to_bin "${item}"; then
                fs_print_green_line "${item} installed successfully."
            else
                fs_print_red_line "${item} installed failed."
            fi
        done
    else
        fs_print_white_line "do not install dependency, exit now..."
        return 1
    fi
}

###################################################
# description: install fuzzy-shell files to ~/.fuzzy_shell
#       input: none
#      return: 0: succeed | 1: failed
###################################################
function fs_install_files {
    local git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    local util_file_path="${git_root}/src/scripts/utils.sh"

    # source utils file
    if [[ ! -f "${util_file_path}" ]]; then
        printf "%s\n" "${util_file_path} do not exist."
        printf "%s\n" "Exit Now..."
        return 1
    else
        source "${util_file_path}"
    fi

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
        fs_print_warning_line "${target_dir} not existed, create it"
        bash -c "mkdir ${target_dir}"
    fi
    if ! fs_yn_prompt "\ninstall: Do you want to \ncopy ${FS_COLOR_GREEN}${git_root}/src (current dir)${FS_COLOR_RESET} \nto ${FS_COLOR_GREEN}${target_dir}(install dir)${FS_COLOR_RESET} ?"; then
        fs_print_white_line "Exit Now..."
        return 1
    fi

    # copy to target dir
    if [[ ! -d "${git_root}/src" ]]; then
        fs_print_error_line "${git_root}/src not existed, please check."
        return 1
    fi
    if [[ $(ls -A "${target_dir}") ]]; then
        fs_print_blue_line "ls -al ${target_dir} as below:"
        echo -e ""
        ls -al "${target_dir}"
        fs_print_warning_line "You should keep ${target_dir} empty."
        if ! fs_yn_prompt "\n${target_dir} is not empty, \ndo you want to remove all files in it and continue?"; then
            fs_print_info_line "You should keep ${target_dir} empty. Remove all files in it manaully."
            fs_print_white_line "Exit Now..."
            return 1
        fi
        bash -c "rm -r ${target_dir}/*"
        fs_print_green_line "${target_dir} is clear now."
    fi
    bash -c "cp -r ${git_root}/src/* ${target_dir}"
    # chown to actual user
    chown "${actual_user}:${actual_user}" "${target_dir}/config.env"

    if [[ -d "${target_dir}/scripts" ]] &&
        [[ -f "${target_dir}/config.env" ]]; then
        fs_print_white "copy successfully"
        # fs_print_white "copy successfully, ls -al"
        # fs_print_info "${target_dir}"
        # fs_print_white_line " as below:"
        echo -e "\n"
        # ls -al "${target_dir}"
    else
        printf '%s\n' "${target_dir} copy failed."
    fi

    local user_shell=$(fs_get_shell "${actual_user}")
    if [[ -z "${user_shell}" ]]; then
        fs_print_red_line "get user shell failed."
        return 1
    fi

    if ! fs_add_to_shellrc "${user_shell}"; then
        fs_print_red_line "add fuzzy-shell script to ${user_shell}rc failed."
        return 1
    fi

    fs_print_green_line "fuzzy-shell files are deployed to ${target_dir} sucessfully. Congratulations! 🍺️"

    return 0
}

###################################################
# description: linke file to /usr/bin
#       input: none
#      return: 0: succeed | 1: failed
###################################################
function fs_link_to_bin() {
    local git_root="$(git rev-parse --show-toplevel 2>/dev/null)"

    local src="${git_root}/install/bin/${1}"
    local dest="/usr/bin/${1}"

    if [[ ! -f "$src" ]]; then
        echo "Source file $src does not exist."
        return 1
    fi

    if [[ -e "$dest" ]]; then
        echo "Soft link $dest already exists."
        return 1
    fi

    ln -s "$src" "$dest" && echo "Soft link created for $1"
}

###################################################
# description: add fuzzy-shell script to shellrc
#       input: none
#      return: 0: succeed | 1: failed
###################################################
function fs_add_to_shellrc() {
    if [[ -z "${user_shell}" || -z "${user_home}" ]]; then
        fs_print_red_line "some param is empty."
        return 1
    fi

    if [[ "${user_shell}" =~ "zsh" ]]; then
        user_shell="zsh"
    elif [[ "${user_shell}" =~ "bash" ]]; then
        user_shell="bash"
    else
        fs_print_red_line "shell type NOT supported. "
        return 1
    fi

    local user_shellrc="${user_home}/.${user_shell}rc"
    if [[ ! -f "${user_shellrc}" ]]; then
        fs_print_red_line "${user_shellrc} not found."
        return 1
    fi

    # check if already have fuzzy-shell script in ${user_shellrc}
    if cat "${user_shellrc}" | grep -q ".fuzzy_shell"; then
        fs_print_white_line "already have fuzzy-shell script in ${user_shellrc}"
        return 0
    fi

    # add fuzzy-shell script to ~/.zshrc
    echo -e "---------------------------------------------\n"
    fs_print_info_line "TIP: "
    fs_print_white_line "have already added below to your ~/.zshrc:"
    fs_print_green_line '   source ${HOME}/.fuzzy_shell/scripts/export.sh'
    fs_print_green_line '   source ${HOME}/.fuzzy_shell/config.env'
    fs_print_green_line "   alias "fs"="fuzzy_shell_search""
    fs_print_green_line "   alias "fj"="fuzzy_shell_jump""
    fs_print_green_line "   alias "fe"="fuzzy_shell_edit""
    fs_print_green_line "   alias "hh"="fuzzy_shell_history""

    echo '#------------------- fuzzy-shell -------------------
source "${HOME}/.fuzzy_shell/scripts/export.sh"
source "${HOME}/.fuzzy_shell/config.env"
alias "fs"="fuzzy_shell_search"
alias "fj"="fuzzy_shell_jump"
alias "fe"="fuzzy_shell_edit"
alias "hh"="fuzzy_shell_history"
' >>"${user_shellrc}"

    fs_print_white_line "then, exec "source ${user_shellrc}" to make it work."
}

fs_install_dependency &&
    fs_install_files
