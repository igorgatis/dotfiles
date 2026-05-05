# ~/.zshrc - Zsh interactive shell

[[ $- != *i* ]] && return

[[ -n "${ENABLE_ZPROF-}" ]] && zmodload zsh/zprof

. "$HOME/.config/sh/interactive.sh"

[[ ! -f ~/.zshrc_local ]] || . ~/.zshrc_local

[[ -z "${ENABLE_ZPROF-}" ]] || zprof
