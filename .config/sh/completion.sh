if [[ -n "${BASH_VERSION-}" ]]; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
  fi
  source "$HOME/.config/sh/git-completion.bash"
  # Make target completion.
  complete -W "\`grep -oE '^[a-zA-Z0-9_.-]+:([^=]|$)' ?akefile | sed 's/[^a-zA-Z0-9_.-]*$//'\`" make

  # Hack to make 'git dd' complete to branch names.
  _git_dd() { _git_diff ; }
  _git_p() { _git_diff ; }
elif [[ -n "${ZSH_VERSION-}" ]]; then
  autoload -Uz compinit
  # Full security check once a day - bash compatible version
  if [[ ! -f ~/.zcompdump || $(find ~/.zcompdump -mtime +1 2>/dev/null) ]]; then
    compinit
  else
    compinit -C
  fi
fi
