if command -v asdf &> /dev/null; then
  export ASDF_PYTHON_VERSION=system
  export ASDF_NODEJS_VERSION=system
  export ASDF_GOLANG_VERSION=system
  export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
  if [[ -n "${BASH_VERSION-}" ]]; then
    . <(asdf completion bash)
  elif [[ -n "${ZSH_VERSION-}" ]]; then
    . <(asdf completion zsh)
  fi
else
  asdf() {
    echo "asdf is not installed. Run:"
    if [[ -n "$TERMUX_VERSION" ]]; then
      echo "go install github.com/asdf-vm/asdf/cmd/asdf@latest"
    else
      echo "brew install asdf"
    fi
  }
fi
