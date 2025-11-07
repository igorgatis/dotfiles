if [[ -n "${ZSH_VERSION-}" ]]; then
  source "$HOME/.config/sh/zsh-autosuggestions.zsh"
fi

if [[ -n "$STARSHIP_SHELL" && -z "${DISABLE_STARSHIP-}" ]]; then
  # Prompt uses starship, let's end early.
  return
fi

source "$HOME/.config/sh/git-prompt.sh"

# Fallback for git prompt.
if ! type __git_ps1 >/dev/null 2>&1; then
  __git_ps1() {
    # On Cygwin, git is quite slow. That's why we parse HEAD manually.
    slashes=${PWD//[^\/]/}
    gitdir="$PWD"
    for (( n=${#slashes}; n>0; --n )); do
      if [[ -f "$gitdir/.git/HEAD" ]]; then
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
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "venv "
  fi
}

__ps1_setup_bash() {
  venv_p='\[\e[1;35m\]$(__ps1_venv)'
  path_p='\[\e[1;34m\]\w'
  branch_p='\[\e[1;33m\]$(__git_ps1 " [%s]")'
  end_p='\[\e[0m\] $ '
  export PS1="$venv_p$path_p$branch_p$end_p"
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
    end_p=' ❯ '
    export PS1="$venv_p$path_p$branch_p$end_p"
}

if [[ -n "${BASH_VERSION-}" ]]; then
  __ps1_setup_bash
elif [[ -n "${ZSH_VERSION-}" ]]; then
  __ps1_setup_zsh
fi

