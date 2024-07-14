#!/bin/bash

###################################################
# description: fuzzy search
#       input: $1: search range
#       input: $2: ignore dirs
#       input: $3: search keyword
#       input: $4: another search keyword
#        echo: matched file(search result)
#      return: 0: success | 1: fail
###################################################
function fuzzy_shell_search {
    local fd_command="fd"
    local bat_command="bat"

    # variable load
    local fs_var_file="${HOME}/.fuzzy_shell/config.env"

    if [[ -z "${fs_search_dirs}" ]] || [[ -z "${fs_search_preview}" ]] || [[ -z "${fs_editor}" ]]; then
        printf "%s" "some of env variable is empty, please check it in "${HOME}/.fuzzy_shell/config.env".\n"
        printf "%s" "Now, try to source ${fs_var_file} ..."
        if [[ -f "${fs_var_file}" ]]; then
            source "${fs_var_file}"
        else
            printf "%s" "${fs_var_file} not exist, please check it."
            return 1
        fi
    fi

    # exclude dirs
    local exclude_args=()
    for dir in "${fs_search_ignore_dirs[@]}"; do
        dir=$(bash -c "echo ${dir}")
        exclude_args+=("--exclude" ${dir})
    done

    local preview_command=""
    if [[ "${fs_search_preview}" == "true" ]]; then
        preview_command="printf 'Name: \033[1;32m %s \033[0m\n' {}; if [[ -d {} ]]; then printf 'Type: \033[1;32m %s \033[0m\n' 'Dir'; tree -L 2 {}; else printf 'Type: \033[1;32m %s \033[0m\n' 'File'; head -n 50 {} | cat; fi"
    else
        preview_command="echo {};if [[ -d {} ]]; then ls -al {}; else head -n 50 {}; fi"

    fi

    local target_file=$(
        printf "%s\n" "${fs_search_dirs[@]}" |
            xargs -I {} ${fd_command} --hidden ${exclude_args[@]} --search-path {} |
            fzf --query="$1$2" --ansi --preview-window 'right:40%' --preview "$preview_command"
    )

    if [[ -z "${target_file}" ]]; then
        echo ""
        echo "exit fuzzy search ..." >&2
        return 1
    else
        echo "${target_file}"
    fi

    return 0
}

###################################################
# description: jump to dir by fuzzy search result
#       input: $1: search keyword 1
#       input: $2: search keyword 2
#      return: 0: success | 1: fail
###################################################
function fuzzy_shell_jump {
    local target_file="$(fuzzy_shell_search $1 $2)"
    if [[ -d "${target_file}" ]]; then
        cd "${target_file}" && fs_show_files
    elif [[ -f "${target_file}" ]]; then
        local father_dir=$(dirname "${target_file}")
        cd "${father_dir}" && fs_show_files
    else
        return 1
    fi

    return 0
}

###################################################
# description: edit file by fuzzy search result
#       input: $1: search keyword 1
#       input: $2: search keyword 2
#      return: 0: success | 1: fail
###################################################
function fuzzy_shell_edit {
    local target_file="$(fuzzy_shell_search $1 $2)"
    local father_dir=$(dirname "${target_file}")

    if [[ -z "${target_file}" ]]; then
        return 1
    fi

    if [[ -z "${fs_editor}" ]]; then
        printf "%s" "env ${fs_editor} is empty, please check it."
        return 1
    fi

    local editor=$(bash -c "echo ${fs_editor}")

    if ! command -v ${editor}; then
        printf "%s" "${editor} is NOT executable, please check it."
        return 1
    fi

    cd ${father_dir} && ${editor} ${target_file}

    if [[ $? -eq 0 ]]; then
        return 1
    fi

    return 0
}

###################################################
# description: show files in current directory
#       input: none
#      return: 0: success | 1: fail
###################################################
function fs_show_files {
    local currentPath=$(pwd)
    local normalFileNum=$(ls -al | tail -n +4 | grep "^-" | wc -l | tr -d ' ')
    local dirFileNum=$(ls -al | tail -n +4 | grep "^d" | wc -l | tr -d ' ')
    local totalNum=$((${normalFileNum} + ${dirFileNum}))

    printf "\033[1;30m\033[44mjump to: \033[1;30m\033[42m%s\033[0m\n" "${currentPath}"
    printf "\033[1;30m\033[44mfile count: \033[1;30m\033[42m%s\033[0m\n" "${totalNum}"
    printf "%s\n" "---------"

    if [[ ${totalNum} -le 35 ]]; then
        ls -al | tail -n +2
    elif [[ ${totalNum} -ge 101 ]]; then
        echo "files in current directory is more than 100"
    else
        ls -a
    fi
    return 0
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
