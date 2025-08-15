#!/bin/bash

BREW=$(which /opt/homebrew/bin/brew || which /home/linuxbrew/.linuxbrew/bin/brew)
if [ -n "$BREW" ]; then
  eval "$($BREW shellenv)"
  export HOMEBREW_AUTO_UPDATE_SECS=2592000
fi
