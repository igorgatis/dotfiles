# Check for starship prompt
if [[ -n "$DISABLE_STARSHIP" ]]; then
  : # Skip starship initialization
elif command -v starship &> /dev/null; then
  if [[ -n "${BASH_VERSION-}" ]]; then
    eval "$(starship init bash)"
  elif [[ -n "${ZSH_VERSION-}" ]]; then
    eval "$(starship init zsh)"
  fi
  return
fi

starship() {
  echo "Starship prompt not found. To install:"
  if [[ -n "$TERMUX_VERSION" ]]; then
    echo "pkg install starship"
  else
    echo "brew install starship"
  fi
}

source "$HOME/.config/sh/git-prompt.sh"

# Fallback for git prompt.
if ! type __git_ps1 >/dev/null 2>&1; then
  __git_ps1() {
    # On Cygwin, git is quite slow. That's why we parse HEAD manually.
    slashes=${PWD//[^\/]/}
    gitdir="$PWD"
    for (( n=${#slashes}; n>0; --n )); do
      if [ -f "$gitdir/.git/HEAD" ]; then
        ref=$(cat "$gitdir/.git/HEAD")
        echo " [${ref##*/}]"
        return
      fi
      gitdir="$gitdir/.."
    done
  }
fi

export VIRTUAL_ENV_DISABLE_PROMPT=1
__ps1_venv() {
  if [ "$VIRTUAL_ENV" != "" ]; then
    echo "venv "
  fi
}

__ps1_setup_bash() {
  venv_p='\[\e[1;35m\]$(__ps1_venv)'
  path_p='\[\e[1;34m\]\w'
  branch_p='\[\e[1;33m\]$(__git_ps1 " [%s]")'
  end_p='\[\e[0m\] $ '
  export PS1="$title_p$venv_p$path_p$branch_p$end_p"
}

__setup_zsh_autosuggestions() {
    plugin_file="$HOME/.config/sh/zsh-autosuggestions.zsh"
    if [[ -f "$plugin_file" ]]; then
        source "$plugin_file"
    else
        autosuggest() {
            echo "zsh-autosuggestions not found. Install now? (Y/n)"
            read -r response
            if [[ -z "$response" || "$response" =~ ^[yY]$ ]]; then
                curl -o "$plugin_file" https://raw.githubusercontent.com/zsh-users/zsh-autosuggestions/master/zsh-autosuggestions.zsh
            fi
        }
    fi
}

__ps1_setup_zsh() {
    autoload -Uz vcs_info
    precmd_functions+=( vcs_info )
    setopt prompt_subst
    zstyle ':vcs_info:git:*' formats ' [%b]'
    zstyle ':vcs_info:*' enable git
    venv_p='%F{magenta}%B$(__ps1_venv)%b%f'
    path_p='%F{blue}%B%~%b%f'
    branch_p='%F{yellow}%B$vcs_info_msg_0_%b%f'
    end_p=' > '
    export PS1="$venv_p$path_p$branch_p$end_p"
}

if [[ -n "${BASH_VERSION-}" ]]; then
  __ps1_setup_bash
elif [[ -n "${ZSH_VERSION-}" ]]; then
  __ps1_setup_zsh
  __setup_zsh_autosuggestions
fi
