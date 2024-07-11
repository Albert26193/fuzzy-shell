###################################################
# description: install fuzzy-shell files to ~/.fuzzy_shell
#       input: none
#      return: 0: succeed | 1: failed
###################################################
function fs_install_files {
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
	if [[ "$(id -u)" -eq 0 ]]; then
		fs_print_error_line "Don't run this script as root." >&2
		return 1
	fi

	local target_dir="${HOME}/.fuzzy_shell"
	if [[ ! -d "${target_dir}" ]]; then
		fs_print_warning_line "${target_dir} not existed, create it"
		bash -c "mkdir ${target_dir}"
	fi

	if ! fs_yn_prompt "Do you want to copy ${FS_COLOR_GREEN}${git_root}/src (current dir)${FS_COLOR_RESET} to ${FS_COLOR_GREEN}${target_dir}(install dir)${FS_COLOR_RESET} ?"; then
		fs_print_white_line "Exit Now..."
		return 1
	fi

	if [[ ! -d "${git_root}/src" ]]; then
		fs_print_error_line "${git_root}/src not existed, please check."
		return 1
	fi

	if [[ $(ls -A "${target_dir}") ]]; then
		fs_print_green_line "ls -al ${target_dir} as below:"
		ls -al "${target_dir}"
		fs_print_warning_line "You should keep ${target_dir} empty."
		if ! fs_yn_prompt "${target_dir} is not empty, do you want to remove all files in it and continue?"; then
			fs_print_info_line "You should keep ${target_dir} empty. Remove all files in it manaully."
			fs_print_white_line "Exit Now..."
			return 1
		fi
		bash -c "rm -rf ${target_dir}/*"
		fs_print_green_line "${target_dir} is clear now."
	fi

	bash -c "cp -r ${git_root}/src/* ${target_dir}"

	if [[ -d "${target_dir}/scripts" ]] &&
		[[ -f "${target_dir}/config.env" ]]; then
		fs_print_white "copy successfully, ls -al"
		fs_print_info "${target_dir}"
		fs_print_white_line " as below:"
		ls -al "${target_dir}"
	else
		printf '%s\n' "${target_dir} copy failed."
	fi

	fs_print_green_line "fuzzy-shell files are deployed to ${target_dir} sucessfully. Congratulations! 🍺️"

	# check if has installed
	if cat "${HOME}/.zshrc" | grep -q ".fuzzy_shell"; then
		fs_print_white_line "already have fuzzy-shell script in ~/.zshrc"
		return 0
	fi

	echo -e "---------------------------------------------\n"
	fs_print_info_line "TIP: "
	fs_print_white_line "have already added below to your ~/.zshrc:"
	fs_print_green_line "   source ${HOME}/.fuzzy_shell/scripts/export.sh"
	fs_print_green_line "   source ${HOME}/.fuzzy_shell/config.env"
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
#------------------- fuzzy-shell -------------------' >>"${HOME}/.zshrc"

	fs_print_white_line "then, exec 'source ~/.zshrc'"

	return 0
}

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
	if [[ "$(id -u)" -eq 0 ]]; then
		fs_print_error_line "DO NOT run this script as root." >&2
		return 1
	fi

	if ! command -v brew &>/dev/null; then
		fs_print_red_line "brew not installed, install it."
		return 1
	fi

	local all_install_list=(
		"fd"
		"fzf"
	)

	local to_install_list=()
	for package in "${all_install_list[@]}"; do
		if ! which "$package" &>/dev/null; then
			echo "[ X ] $package is not installed"
			to_install_list+=("$package")
		else
			echo "[ √ ] $package is already installed."
		fi
	done

	# 如果所有依赖都已安装，则退出
	if [[ ${#to_install_list[@]} -eq 0 ]]; then
		echo "All dependency installed, exit now..."
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
			fs_link_to_bin "${item}"
		done
	else
		fs_print_white_line "do not install dependency, exit now..."
		return 1
	fi
}

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

fs_install_dependency
fs_install_files
