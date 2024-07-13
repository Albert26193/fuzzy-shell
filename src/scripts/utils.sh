#!/bin/bash

###################################################
# description: make output colorful
#          $1: input content
#      return: nothing
###################################################
FS_COLOR_RED="\033[31m"
FS_COLOR_GREEN="\033[32m"
FS_COLOR_YELLOW="\033[33m"
FS_COLOR_BLUE="\033[34m"
FS_COLOR_MAGENTA="\033[35m"
FS_COLOR_CYAN="\033[36m"
FS_COLOR_WHITE="\033[97m"
FS_COLOR_GRAY="\033[90m"
FS_COLOR_RESET="\033[0m"
FS_BACKGROUND_YELLOW="\033[43m"
FS_BACKGROUND_RED="\033[41m"
FS_BACKGROUND_GREEN="\033[42m"
FS_COLOR_WHITE="\033[97m"
FS_COLOR_BLACK="\033[1;30m"

fs_print_red_line() { printf "${FS_COLOR_RED}%s${FS_COLOR_RESET}\n" "$1"; }
fs_print_green_line() { printf "${FS_COLOR_GREEN}%s${FS_COLOR_RESET}\n" "$1"; }
fs_print_yellow_line() { printf "${FS_COLOR_YELLOW}%s${FS_COLOR_RESET}\n" "$1"; }
fs_print_blue_line() { printf "${FS_COLOR_BLUE}%s${FS_COLOR_RESET}\n" "$1"; }
fs_print_magenta_line() { printf "${FS_COLOR_MAGENTA}%s${FS_COLOR_RESET}\n" "$1"; }
fs_print_cyan_line() { printf "${FS_COLOR_CYAN}%s${FS_COLOR_RESET}\n" "$1"; }
fs_print_gray_line() { printf "${FS_COLOR_WHITE}%s${FS_COLOR_RESET}\n" "$1"; }
fs_print_white_line() { printf "${FS_COLOR_WHITE}%s${FS_COLOR_RESET}\n" "$1"; }

fs_print_red() { printf "${FS_COLOR_RED}%s${FS_COLOR_RESET} " "$1"; }
fs_print_green() { printf "${FS_COLOR_GREEN}%s${FS_COLOR_RESET} " "$1"; }
fs_print_yellow() { printf "${FS_COLOR_YELLOW}%s${FS_COLOR_RESET} " "$1"; }
fs_print_blue() { printf "${FS_COLOR_BLUE}%s${FS_COLOR_RESET} " "$1"; }
fs_print_magenta() { printf "${FS_COLOR_MAGENTA}%s${FS_COLOR_RESET} " "$1"; }
fs_print_cyan() { printf "${FS_COLOR_CYAN}%s${FS_COLOR_RESET} " "$1"; }
fs_print_gray() { printf "${FS_COLOR_WHITE}%s${FS_COLOR_RESET} " "$1"; }
fs_print_white() { printf "${FS_COLOR_WHITE}%s${FS_COLOR_RESET} " "$1"; }

fs_print_warning_line() { printf "${FS_BACKGROUND_YELLOW}${FS_COLOR_BLACK}%s${FS_COLOR_RESET}\n" "$1"; }
fs_print_error_line() { printf "${FS_BACKGROUND_RED}${FS_COLOR_BLACK}%s${FS_COLOR_RESET}\n" "$1"; }
fs_print_info_line() { printf "${FS_BACKGROUND_GREEN}${FS_COLOR_BLACK}%s${FS_COLOR_RESET}\n" "$1"; }

fs_print_warning() { printf "${FS_BACKGROUND_YELLOW}${FS_COLOR_BLACK}%s${FS_COLOR_RESET}" "$1"; }
fs_print_error() { printf "${FS_BACKGROUND_RED}${FS_COLOR_BLACK}%s${FS_COLOR_RESET}" "$1"; }
fs_print_info() { printf "${FS_BACKGROUND_GREEN}${FS_COLOR_BLACK}%s${FS_COLOR_RESET}" "$1"; }

###################################################
# description: give colorful yn_prompt
#          $1: custom prompt to print
#      return: 0: yes | 1: no
###################################################
function fs_yn_prompt() {
    local yn_input=""
    while true; do
        printf "$1 ${FS_COLOR_CYAN}[y/n]: ${FS_COLOR_RESET}"
        read yn_input
        case "${yn_input}" in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *) fs_print_red_line "Please answer yes[y] or no[n]." ;;
        esac
    done
}

###################################################
# description: print step information
#          $1: current step description
#      return: nothing
###################################################
function fs_print_step() {
    local current_step=$1
    fs_print_green_line "========================================="
    fs_print_green_line "================= STEP ${current_step} ================"
    fs_print_green_line "========================================="
}

###################################################
# description: get git root path
#      return: git root path
###################################################
function fs_get_gitroot() {
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null)

    if [[ -z "${git_root}" ]]; then
        fs_print_error_line "Error: git root not found, please run this script in your lso git repo."
        return 1
    fi

    echo "${git_root}"
    return 0
}

###################################################
# description: give current os judgement
#      return: Ubuntu | macOS | Debian | CentOS | Other
###################################################
function fs_check_os() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        local OS=$(echo $NAME | awk '{print$1}')
    elif type lsb_release >/dev/null 2>&1; then
        local OS=$(lsb_release -si)
    elif [[ -f /etc/lsb-release ]]; then
        source /etc/lsb-release
        local OS=$DISTRIB_ID
    elif [[ -f /etc/debian_version ]]; then
        local OS=Debian
    elif [[ -f /etc/centos-release ]]; then
        local OS=CentOS
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        local OS=macOS
    else
        local OS=$(uname -s)
    fi

    case $OS in
    "Ubuntu" | "Debian" | "CentOS" | "macOS")
        echo $OS
        ;;
    *)
        echo "Other"
        ;;
    esac
}

###################################################
# description: give current os architecture judgement
#      return: x86_64 | i386 | arm | aarch64 | Other
###################################################
function fs_check_arch() {
    local ARCH

    if type uname >/dev/null 2>&1; then
        ARCH=$(uname -m)
    else
        echo "Other"
        return
    fi

    case $ARCH in
    "x86_64" | "i386" | "armv6l" | "armv7l" | "aarch64")
        echo $ARCH
        ;;
    *)
        echo "Other"
        ;;
    esac
}

###################################################
# description: get actual user from SUDO
#      return: user's name
###################################################
function fs_get_user() {
    # check if exists $SUDO_USER
    if [ -n "$SUDO_USER" ]; then
        original_user=$SUDO_USER
        printf "$original_user"
    else
        current_user=$(whoami)
        printf "${current_user}"
    fi
}

###################################################
# description: get actual user from SUDO
#          $1: user name
#      return: user's name
###################################################
function fs_get_shell() {
    if [[ -z "$1" ]]; then
        fs_print_red_line "Error: user name is empty."
        return 1
    fi

    local user_shell=$(getent passwd $1 | cut -d: -f7)
    if [[ ${user_shell} =~ "bash" || ${user_shell} =~ "zsh" ]]; then
        echo "${user_shell}"
    else
        echo "no_supported_shell"
    fi

    return 0
}
