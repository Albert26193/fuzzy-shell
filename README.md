# Fuzzy Shell Documentation

<img src="https://img.shields.io/badge/shell-bash-blue" alt="bash" style="display: inline-block;" />&nbsp;
<img src="https://img.shields.io/badge/shell-zsh-green" alt="zsh" style="display: inline-block;" />&nbsp;
<img src="https://img.shields.io/badge/tool-linux-blue" alt="linux" style="display: inline-block;" />&nbsp;
<img src="https://img.shields.io/badge/tool-mac-green" alt="mac" style="display: inline-block;" />&nbsp;

- Doc Site: [fuzzy shell doc site](https://fuzzy.albert.cool/)
- 中文站点：[fuzzy shell 文档](https://fuzzy.albert.cool/zh/)

> [!TIP]
> 1. `fuzzy_shell` combines the `fd` and `fzf` tools, making it more user-friendly.
> 2. `fuzzy_shell` offers fuzzy jumping, editing, and file searching capabilities.

## 1. Installation

### 1.1 Quick Start

```sh
# clone the repo
git clone https://github.com/Albert26193/fuzzy-shell.git

# install 
cd fuzzy_shell && sudo bash install/install.sh
```

- After installation, if you see the following configuration automatically added to `~/.bashrc` or `~/.zshrc`, the installation is successful 🎉:

```sh
# ~/.bashrc or ~/.zshrc

#------------------- fuzzy-shell -------------------
source "${HOME}/.fuzzy_shell/scripts/export.sh"
alias "fs"="fuzzy --search"
alias "fj"="fuzzy --jump"
alias "fe"="fuzzy --edit"
alias "fh"="fuzzy --history"
```
Run `source ~/.bashrc` or `source ~/.zshrc` to make the configuration effective.
Type `fj` or `fuzzy --jump` to use the fuzzy jump feature.

### 1.2 Dependencies

- For MacOS users, `brew` needs to be pre-installed.
- The minimum version requirement for `zsh` is `5.2.0`, and for `bash` is `4.4.0`
- It's recommended to pre-install `fd` and `fzf` using a package manager. If not pre-installed, you can use the `fd` and `fzf` binary files that come with `fuzzy_shell`

## 2. Usage
Your shell configuration file (`~/.bashrc` or `~/.zshrc`) has already added aliases for `fuzzy_shell`, which can be used directly.
Enter `fuzzy --help` to view help information.

```sh
# fuzzy --help
Usage: fuzzy [option] [args]
Options:
  -s, --search [keyword1] [keyword2] [keyword3], namely fuzzy search
  -H, --history                              , namely fuzzy history search
  -j, --jump [keyword1] [keyword2] [keyword3], namely fuzzy jump
  -e, --edit [keyword1] [keyword2] [keyword3], namely fuzzy edit
```
> [!NOTE]
> - The following three features, `fuzzy jump`, `fuzzy edit`, and `fuzzy search`, will call the `fd` and `fzf` tools. `fd` is used for file searching, and `fzf` is used for interactive file selection.
> - The index range, ignore files, etc., can be configured in `~/.fuzzy_shell/config.env`.
> - Path parameters do not need to match precisely, only fuzzy matching is required.


### 2.1 Fuzzy Jump

- `fuzzy jump` is used for fuzzy jumping to a specified directory or the directory containing a specified file.

```sh
# fuzzy jump to the directory which contains 'keyword1' and 'keyword2', 'keyword3'
fuzzy --jump keyword1 keyword2 keyword3
```

### 2.2 fuzzy edit Fuzzy Edit

- `fuzzy edit` is used for fuzzy editing of specified files.
- The default editor is `vim`, which can be configured in `~/.fuzzy_shell/config.env`, such as `nvim`, etc.

```sh
# fuzzy edit the file which contains 'keyword1' and 'keyword2', 'keyword3'
fuzzy --edit keyword1 keyword2 keyword3
```

### 2.3  Fuzzy Search

- `fuzzy search` is used for fuzzy searching of specified files.

```sh
# fuzzy search the file which contains 'keyword1' and 'keyword2', 'keyword3'
fuzzy --search keyword1 keyword2 keyword3
```
- Its return result can be passed as an argument to other commands. For example, trying to delete the `some-file` file in the `my-path` directory:

```sh
rm $(fuzzy --search my-path some-file)

# If you have made an alias in shellrc (~/.zshrc or ~/.bashrc), it can be simplified to
rm $(fs my-path some-file)
```

> [!NOTE]
> - `fuzzy history` will call `fzf` and `history`. `history` is used to retrieve historical records, and `fzf` is used for interactive file selection.

### 2.4 fuzzy history Fuzzy History Search

- `fuzzy history` is used for fuzzy searching of current shell history records.
- No parameters are needed, just call it directly.

```sh
# fuzzy search the history
fuzzy --history
```

## 3. Configuration

- The configuration file for `fuzzy_shell` is located at `~/.fuzzy_shell/config.env`, where you can configure the search range of `fd`, ignore files, etc.
- Four parameters can be configured:
  1. `fs_search_dir`: Search range, i.e., the search path for `fd`.
  2. `fs_search_ignore_dirs`: Ignore files, i.e., the ignore files for `fd`.
  3. `fs_preview`: Whether to enable the preview feature, generally recommended to be enabled unless there's severe lag.
  4. `fs_editor`: Editor, i.e., the editor for `fuzzy edit`.

- The default configuration is as follows:

```sh
# ~/.fuzzy_shell/config.env
#!/bin/bash

# in which dir to search
fs_search_dirs=(
    "${HOME}"
    #"CodeSpace"
)

# within search range, which dir to ignore
fs_search_ignore_dirs=(
    "Downloads"
    "Desktop"
    "Documents"
    ".git"
    ".local"
    ".m2"
    ".gradle"
    ".wns"
    ".nvm"
    ".npm"
    ".nrm"
    ".red-hat"
    ".oh-my-zsh"
    ".github"
    ".cache"
    ".cargo"
    ".rustup"
    ".vscode"
    ".vscode-insiders"
    ".vscode-server-insiders"
    ".vscode-server"
    ".vscode-oss"
    ".vscode-oss-insiders"
    "lib"
    "node_modules"
    "pkg"
    "bin"
    "dist"
    "pkgs"
    "from-github"
    "assets"
    "image"
    "images"
    "static"
    "data"
    "raycast"
    "zlt-*"
    "anaconda3"
    "miniconda3"
    "Applications"
    "Library"
    "Movies"
    "Music"
    "Pictures"
    "Public"
    "Remote"
    "Zotero"
    "EVPlayer2_download"
)

# search preview or not, true: preview | false: not preview
# if your machine is not powerful enough(RAM <= 1GiB), set it to false
# otherwise, set it to true(Recommend)
fs_search_preview=true
#fs_search_preview=false

fs_editor="vim"
# fs_editor="nvim"
```

## 4. Notes

### 4.1 Uninstallation

- If you no longer need `fuzzy_shell`, you can uninstall it with the following command:

```sh
cd fuzzy_shell && sudo bash install/uninstall.sh
```

- After uninstallation, the configuration in `~/.bashrc` or `~/.zshrc` needs to be manually cleaned up.

### 4.2 Supported Operating Systems

- Supports `x86_64` architecture `Linux` systems.
- Supports `x86_64/arm64` architecture `MacOS` systems.
- Currently tested systems:
  - `Ubuntu 18.04/22.04`
  - `CentOS 7/8`
  - `Debian 10/11/12`

### 4.3 Supported Shells

- Supports `bash` and `zsh`
- The minimum version requirement for `bash` is `4.4.0`, and for `zsh` is `5.2.0`
- Currently does not support `fish`, and there are no plans to support `fish` in the future

## 5. Future Plans

- Add fuzzy grep functionality.
- Add support for `git`, such as fuzzy searching for `reflog/branch/commit`, etc.
- Add support for `docker`, such as fuzzy searching for docker containers, images, etc.


## 6. Acknowledgements

- This project is just a small shell script of a few hundred lines, and the main work should be credited to the support of the `fd` and `fzf` tools.
- fd project link: [fd](https://github.com/sharkdp/fd)
- fzf project link: [fzf](https://github.com/junegunn/fzf)
