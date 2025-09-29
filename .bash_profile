# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

if [[ "$OSTYPE" == "darwin"* ]]; then
  export BASH_SILENCE_DEPRECATION_WARNING=1
  source ~/.bashrc
fi
