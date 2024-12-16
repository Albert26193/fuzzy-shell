#!/bin/bash

###################################################
# description: fuzzy search
#       input: $1: search keyword 1
#       input: $2: search keyword 2
#       input: $3: search keyword 3
#        echo: matched file(search result)
#      return: 0: success | 1: fail
###################################################
function fuzzy_shell_search {
    local fd_command="fd"

    # alias wont work, if fdfind exits , should use it
    if command -v "fdfind" &>/dev/null; then
        fd_command="fdfind"
    fi

    # variable load
    local fs_var_file="${HOME}/.fuzzy_shell/config.env"

    if [[ ! -f "${fs_var_file}" ]]; then
        printf "%s" "${fs_var_file} not exist, please check it."
        return 1
    fi

    if [[ -z "${FS_SEARCH_DIRS}" ]] || [[ -z "${FS_SEARCH_PREVIEW}" ]] || [[ -z "${FS_EDITOR}" ]]; then
        printf "%s\n" "some of env variable is empty, please check it in ${HOME}/.fuzzy_shell/config.env."
        printf "%s\n" "Now, try to source ${fs_var_file} ..."
        if [[ -f "${fs_var_file}" ]]; then
            source "${fs_var_file}"
        else
            printf "%s" "${fs_var_file} not exist, please check it."
            return 1
        fi
    fi

    # load to local variable
    local fs_search_dirs=(${FS_SEARCH_DIRS[@]})
    local fs_search_ignore_dirs=(${FS_SEARCH_IGNORE_DIRS[@]})
    local fs_search_preview=${FS_SEARCH_PREVIEW}
    local fs_editor=${FS_EDITOR}

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
            fzf --query="$1$2$3" --ansi --preview-window 'right:40%:wrap' --preview "$preview_command"
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
#       input: $3: search keyword 3
#      return: 0: success | 1: fail
###################################################
function fuzzy_shell_jump {
    local target_file="$(fuzzy_shell_search $1 $2 $3)"
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
#       input: $3: search keyword 3
#      return: 0: success | 1: fail
###################################################
function fuzzy_shell_edit {
    local target_file="$(fuzzy_shell_search $1 $2 $3)"
    local father_dir=$(dirname "${target_file}")

    if [[ -z "${target_file}" ]]; then
        return 1
    fi

    local editor=${FS_EDITOR}
    if [[ -z "${FS_EDITOR}" ]]; then
        printf "%s" "env ${FS_EDITOR} is empty, please check it."
        return 1
    fi

    if ! command -v ${editor} 2>&1 >/dev/null; then
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
    printf "\n"

    if [[ ${totalNum} -le 35 ]]; then
        ls -al | tail -n +2
    elif [[ ${totalNum} -ge 101 ]]; then
        echo "files in current directory is more than 100"
    else
        ls -a
    fi
    return 0
}
