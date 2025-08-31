if command -v asdf &> /dev/null; then
  export ASDF_PYTHON_VERSION=system
  export ASDF_NODEJS_VERSION=system
  export ASDF_GOLANG_VERSION=system
  export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
  . <(asdf completion bash)
fi
