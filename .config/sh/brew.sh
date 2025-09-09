BREW=$(which /opt/homebrew/bin/brew || which /home/linuxbrew/.linuxbrew/bin/brew)
if [ -n "$BREW" ]; then
  eval "$($BREW shellenv)"
  export HOMEBREW_AUTO_UPDATE_SECS=2592000
else
  brew() {
    if [[ -n "$TERMUX_VERSION" ]]; then
      echo "Brew is not available on Termux. Use pkg instead."
    else
      echo "Homebrew is not installed. Run:"
      echo 'bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    fi
  }
fi
