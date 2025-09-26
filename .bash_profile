if [ -f ~/.bash_debug ]; then
  echo "Script called from: ${BASH_SOURCE[1]:-unknown} (line ${BASH_LINENO[0]:-unknown}): $-"
  echo "__BASHRC_LOADED=${__BASHRC_LOADED:-}"
  echo "PS1=${PS1:-}"
  echo "PROMPT_COMMAND=${PROMPT_COMMAND:-}"
fi

# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

export BASH_SILENCE_DEPRECATION_WARNING=1
[[ -f ~/.bashrc ]] && source ~/.bashrc
