export BASH_SILENCE_DEPRECATION_WARNING=1
# If the shell is interactive and .bashrc exists
if [[ $- == *i* && -f ~/.bashrc ]]; then
    . ~/.bashrc
fi
