if command -v llm &> /dev/null; then
  export LLM_USER_PATH=~/.config/io.datasette.llm
  function _concise_llm() {
    llm -t concise "$@"
  }
  alias ll=_concise_llm
fi
