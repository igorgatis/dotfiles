# First, setup PATH
if [[ -d "/opt/homebrew/bin" ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
elif [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi
export PATH="$HOME/go/bin:$PATH"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Then utilities
DAILY_CHECK=0
daily_file="$HOME/.config/sh/.daily_check"
if [[ ! -f "$daily_file" || $(find "$daily_file" -mtime +1 2>/dev/null) ]]; then
  touch "$daily_file"
  DAILY_CHECK=1
fi

__install_inst() {
  if [[ -n "$TERMUX_VERSION" ]]; then
    echo "pkg install $1"
  else
    echo "brew install ${2-$1}"
  fi
}

# Finally setup tools themselves

if ! command -v brew >/dev/null 2>&1; then
  brew() {
    if [[ -n "$TERMUX_VERSION" ]]; then
      echo "Brew is not available on Termux. Use pkg instead."
    else
      echo "Homebrew is not installed. Run:"
      echo 'bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    fi
  }
else
  eval "$(brew shellenv)"
  export HOMEBREW_AUTO_UPDATE_SECS=2592000
fi

if ! command -v yadm >/dev/null 2>&1; then
  yadm() {
    __install_inst yadm
  }
else
  if [[ $DAILY_CHECK ]]; then
    if [[ -n "$(yadm status --porcelain)" ]]; then
      echo "yadm: pending local changes."
    elif ! yadm diff --quiet HEAD origin/main; then
      echo "yadm: remote changes available."
    else
      (yadm fetch >/dev/null 2>&1) & disown
    fi
  fi
fi

if ! command -v bat >/dev/null 2>&1; then
  bat() {
    __install_inst bat
  }
fi

if ! command -v z >/dev/null 2>&1; then
  z() {
    __install_inst zoxide
  }
fi

if ! command -v claude &> /dev/null; then
  claude() {
    if [[ -n "$TERMUX_VERSION" ]]; then
      echo "npm install -g @anthropic-ai/claude-code"
    else
      echo 'brew install --cask claude-code'
    fi
  }
fi

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
  ${flags} "${*}"
}

if ! command -v asdf &> /dev/null; then
  asdf() {
    if [[ -n "$TERMUX_VERSION" ]]; then
      echo "go install github.com/asdf-vm/asdf/cmd/asdf@latest"
    else
      echo "brew install asdf"
    fi
  }
else
  export ASDF_PYTHON_VERSION=system
  export ASDF_NODEJS_VERSION=system
  export ASDF_GOLANG_VERSION=system
  if [[ -n "${BASH_VERSION-}" ]]; then
    eval "$(asdf completion bash)"
  elif [[ -n "${ZSH_VERSION-}" ]]; then
    eval "$(asdf completion zsh)"
  fi
fi
