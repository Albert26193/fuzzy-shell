###################################################
# description: install dependency for macos
#       input: none
#      return: 0: success | 1: fail
###################################################
function fs_install_dependency_mac {
	# Check if the script is executed as root
	if [[ "$(id -u)" -eq 0 ]]; then
		fs_print_error_line "DO NOT run this script as root." >&2
		return 1
	fi

	# check if installed brew
	if ! command -v brew &>/dev/null; then
		fs_print_red_line "brew not installed, install it."
		return 1
	fi

	# get all install list
	local all_install_list=(
		"fd"
		"fzf"
	)
	local to_install_list=()
	for package in "${all_install_list[@]}"; do
		if ! command -v "$package" &>/dev/null; then
			fs_print_red "[ X ]"
			fs_print_red "${package}"
			fs_print_white_line "is not installed"
			to_install_list+=("${package}")
		else
			fs_print_green "[ √ ]"
			fs_print_blue "${package}"
			fs_print_white_line "is already installed."
		fi
	done

	# if all dependency installed, exit now
	if [[ ${#to_install_list[@]} -eq 0 ]]; then
		fs_print_green_line "All dependency installed, exit now..."
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
		brew install "${to_install_list[@]}"
	else
		fs_print_white_line "do not install dependency, exit now..."
		return 1
	fi
}

###################################################
# description: install dependency for linux(x86)
#       input: none
#      return: 0: success | 1: fail
###################################################
function fs_install_dependency_linux {
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

	declare local -A tool_alternatives=(
		["fd"]="fdfind"
		["fzf"]="fzf"
	)

	local to_install_list=()
	for package in "${!tool_alternatives[@]}"; do
		local is_installed=false
		local alternative="${tool_alternatives[${package}]}"

		if command -v "${package}" &>/dev/null || { [[ -n "${alternative}" ]] && command -v "${alternative}" &>/dev/null; }; then
			is_installed=true
		fi

		if ! ${is_installed}; then
			fs_print_red "[ X ]"
			fs_print_red "${package}"
			fs_print_white_line "is not installed"
			to_install_list+=("${package}")
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

	# hint to install manually
	fs_print_warning_line "STRONGLY recommend that you manually install the required dependencies by package manager (like apt/yum etc.) "
	fs_print_yellow_line "If you want to simplify the installation process, fuzzy_shell also provides binary files."
	if fs_yn_prompt "Do you want to ${FS_COLOR_GREEN}install all dependency${FS_COLOR_RESET} with provided binary files?"; then
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
# description: install dependency
#       input: none
#      return: 0: success | 1: fail
###################################################
function fs_install_dependency {
	# check if current os is Linux
	case "$(fs_check_os)" in
	"Ubuntu" | "Debian" | "CentOS")
		if ! fs_install_dependency_linux; then
			# fs_print_error_line "install dependency for linux failed."
			return 1
		fi
		;;
	"macOS")
		if ! fs_install_dependency_mac; then
			# fs_print_error_line "install dependency for mac failed."
			return 1
		fi
		;;
	*)
		if fs_yn_prompt "your OS is not supported, just treat is as Linux, do you want to continue?"; then
			fs_print_white_line "continue to install dependency ..."
			if ! fs_install_dependency_linux; then
				# fs_print_error_line "install dependency for linux failed."
				return 1
			fi
		else
			fs_print_white_line "exit now..."
			return 1
		fi
		;;
	esac

	return 0
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
	local user_home=$(eval echo ~"${actual_user}")
	if [[ -z "${user_home}" ]]; then
		fs_print_error_line "Error: actual user not found."
		return 1
	fi

	# get target dir
	local target_dir="${user_home}/.fuzzy_shell"
	if [[ ! -d "${target_dir}" ]]; then
		# fs_print_warning_line "${target_dir} not existed, create it"
		bash -c "mkdir ${target_dir}"
	fi

	# copy to target dir
	if [[ ! -d "${git_root}/src" ]]; then
		fs_print_error_line "${git_root}/src not existed, please check."
		return 1
	fi

	if [[ $(ls -A "${target_dir}") ]]; then
		if ! fs_yn_prompt "\n${target_dir} is not empty, \nDo you want to ${FS_COLOR_GREEN}reinstall it${FS_COLOR_RESET} ?"; then
			fs_print_white_line "Exit Now..."
			return 1
		fi
		bash -c "rm -r ${target_dir}/*"
	fi

	# copy files (install)
	bash -c "cp -r ${git_root}/src/* ${target_dir}"
	# chown to actual user
	if [[ $(fs_check_os) =~ "macOS" ]]; then
		bash -c "chown -R ${actual_user}:staff ${target_dir}"
	else
		local user_group=$(id -gn "${actual_user}")
		if [[ -z "${user_group}" ]]; then
			fs_print_red_line "get user group failed."
			return 1
		fi
		bash -c "chown -R ${actual_user}:${user_group} ${target_dir}"
	fi

	# check if installed successfully
	if [[ -d "${target_dir}/scripts" ]] &&
		[[ -f "${target_dir}/config.env" ]]; then
		fs_print_white "installed files successfully."
		echo -e ""
	else
		printf '%s\n' "${target_dir} installed failed."
		return 1
	fi

	# add fuzzy-shell script to shellrc
	local user_shell=$(fs_get_shell "${actual_user}")
	if [[ -z "${user_shell}" ]]; then
		fs_print_red_line "get user shell failed."
		return 1
	elif [[ "${user_shell}" =~ "no_supported_shell" ]]; then
		fs_print_red_line "shell type NOT supported. "
		return 1
	fi

	if ! fs_add_to_shellrc "${user_shell}"; then
		fs_print_red_line "add fuzzy-shell script to ${user_shell}rc failed."
		return 1
	fi

	fs_print_green_line "fuzzy-shell has installed sucessfully. Congratulations! 🍺️"
	return 0
}

###################################################
# description: linke file to /usr/bin
#       input: none
#      return: 0: succeed | 1: failed
###################################################
function fs_link_to_bin {
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
function fs_add_to_shellrc {
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

	# add fuzzy-shell script to shellrc
	echo -e "---------------------------------------------\n"
	fs_print_info_line "TIP: "
	fs_print_white_line "have already added below to your ~/.${user_shell}rc:"
	fs_print_green_line '#------------------- fuzzy-shell -------------------'
	fs_print_green_line '   source ${HOME}/.fuzzy_shell/scripts/export.sh'
	fs_print_green_line '   alias "fs"="fuzzy --search'
	fs_print_green_line '   alias "fj"="fuzzy --jump"'
	fs_print_green_line '   alias "fe"="fuzzy --edit"'
	fs_print_green_line '   alias "fh"="fuzzy --history"'

	echo -e "" >>"${user_shellrc}"
	echo '#------------------- fuzzy-shell -------------------
source "${HOME}/.fuzzy_shell/scripts/export.sh"
alias "fs"="fuzzy --search"
alias "fj"="fuzzy --jump"
alias "fe"="fuzzy --edit"
alias "hh"="fuzzy --history"
' >>"${user_shellrc}"

	fs_print_white_line "then, exec source ${user_shellrc} to make it work."
}

###################################################
# description: main function
#       input: none
#      return: 0: succeed | 1: failed
###################################################
function main {
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
	if [[ $(fs_check_os) =~ "macOS" ]] && [[ "$(id -u)" -eq 0 ]]; then
		fs_print_error_line "DO NOT run this script as root." >&2
		return 1
	fi

	# check zsh or bash version
	fs_check_user_shell_version &&
		fs_install_dependency &&
		fs_install_files

	return 0
}

main
