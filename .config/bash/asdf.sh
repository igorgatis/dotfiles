if command -v asdf &> /dev/null; then
  asdf set python system
  asdf set nodejs system
  export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
  . <(asdf completion bash)
fi
