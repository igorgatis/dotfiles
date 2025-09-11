# First, setup PATH
if [[ -d "/opt/homebrew/bin" ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
elif [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi
export PATH="$HOME/go/bin:$PATH"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Then utilities

__lazy_install() {
  local cmd="$1"
  shift

  local init_func=""
  local install_cmd=""

  while [[ $# -gt 0 ]]; do
    case $1 in
      --init=*)
        init_func="${1#*=}"
        ;;
      --termux=*)
        if [[ -n "$TERMUX_VERSION" ]]; then
          install_cmd="${1#*=}"
        fi
        ;;
      --linux=*)
        if [[ "$(uname)" == "Linux" && -z "$TERMUX_VERSION" ]]; then
          install_cmd="${1#*=}"
        fi
        ;;
      --macos=*)
        if [[ "$(uname)" == "Darwin" ]]; then
          install_cmd="${1#*=}"
        fi
        ;;
    esac
    shift
  done

  if command -v "$cmd" >/dev/null 2>&1; then
    if [[ -n "$init_func" ]]; then
      eval "$init_func"
    fi
    return 0
  fi

  if [[ -z "$install_cmd" ]]; then
    eval "$cmd() {
      echo \"$cmd is unavailable on this OS.\"
      return 1
    }"
    return 0
  fi

  eval "$cmd() {
    read -p \"Install $cmd? [Y/n]: \" response
    case \"\$response\" in
      [yY]*|'')
        if eval \"$install_cmd\"; then
          unset -f $cmd
          if [[ -n \"$init_func\" ]]; then
            eval \"$init_func\"
          fi
          \"$cmd\" \"\$@\"
        fi
        ;;
      *)
        return 1
        ;;
    esac
  }"
}

__daily() {
  : # Skip.
}

__touch_daily_file() {
  daily_file="$HOME/.config/sh/.daily_check"
  if [[ ! -f "$daily_file" || $(find "$daily_file" -mtime +1 2>/dev/null) ]]; then
    touch "$daily_file"
    unset -f daily
    __daily() {
      "$@"
    }
  fi
}

__touch_daily_file

# Finally setup tools themselves

__brew_init() {
  eval "$(brew shellenv)"
  export HOMEBREW_AUTO_UPDATE_SECS=2592000
}

__brew_install() {
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

__lazy_install "brew" \
  --init=__brew_init \
  --linux=__brew_install \
  --macos=__brew_install

__yadm_init() {
  if [[ -n "$(yadm status --porcelain)" ]]; then
    echo "yadm: pending local changes."
  elif ! yadm diff --quiet HEAD origin/main; then
    echo "yadm: remote changes available."
  else
    (yadm fetch >/dev/null 2>&1) & disown
  fi
}

__lazy_install "yadm" \
  --init="__daily __yadm_init" \
  --termux="pkg install yadm" \
  --linux="brew install yadm" \
  --macos="brew install yadm"

__asdf_init() {
  export ASDF_PYTHON_VERSION=system
  export ASDF_NODEJS_VERSION=system
  export ASDF_GOLANG_VERSION=system
  if [[ -n "${BASH_VERSION-}" ]]; then
    eval "$(asdf completion bash)"
  elif [[ -n "${ZSH_VERSION-}" ]]; then
    eval "$(asdf completion zsh)"
  fi
}

__lazy_install "asdf" \
  --init=__asdf_init \
  --termux="go install github.com/asdf-vm/asdf/cmd/asdf@latest" \
  --linux="brew install asdf" \
  --macos="brew install asdf"

__lazy_install "claude" \
  --termux="npm install -g @anthropic-ai/claude-code" \
  --linux="brew install --cask claude-code" \
  --macos="brew install --cask claude-code"

__lazy_install "bat" \
  --termux="pkg install bat" \
  --linux="brew install bat" \
  --macos="brew install bat"

__starship_init() {
  if [[ -n "${BASH_VERSION-}" ]]; then
    eval "$(starship init bash)"
  elif [[ -n "${ZSH_VERSION-}" ]]; then
    eval "$(starship init zsh)"
  fi
}

__lazy_install "starship" \
  --init=__starship_init \
  --termux="pkg install starship" \
  --linux="brew install starship" \
  --macos="brew install starship"

ai() {
  flags="-p"
  if [[ "$1" == "-c" ]]; then
    flags+=" -c"
    shift
  fi

  echo "thinking..."
  claude --append-system-prompt \
"shell assistant. Short answers only. Never run commands or use tools. \
No markdown. If answer is a command, just print it." \
  "${flags}" "$*"
}

