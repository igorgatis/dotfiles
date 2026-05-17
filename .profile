# ~/.profile - Login shell environment
# Sourced by: .bash_profile, .zshenv

__TRACE_NAME=.profile; . "$HOME/.config/sh/trace.sh"

. "$HOME/.config/sh/env.sh"

# Enable env.sh for non-interactive bash (scripts, Claude Code)
export BASH_ENV="$HOME/.config/sh/env.sh"
