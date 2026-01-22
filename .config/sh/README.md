# Shell Configuration

Managed with [yadm](https://yadm.io). Supports bash and zsh on Linux, macOS, and Termux.

## Structure

```
~/.profile              # Login env: PATH, brew, mise shims
~/.bash_profile         # Bash login: sources .profile + .bashrc
~/.bashrc               # Bash interactive: sources interactive.sh
~/.zshenv               # All zsh (including non-interactive): sources .profile
~/.zshrc                # Zsh interactive: sources interactive.sh

~/.config/sh/
  env.sh                # Environment: PATH, locale, brew, mise shims
  interactive.sh        # Interactive entry point, sources shell-specific + common
  aliases.sh            # Shell-agnostic aliases
  prompt.sh             # Prompt setup (starship or fallback)
  completion.sh         # Tab completion
  tools.sh              # Lazy tool installation helpers
  bash/
    init.sh             # Bash: history, shopt, keybindings
  zsh/
    init.sh             # Zsh: history, setopt, keybindings
  git-prompt.sh         # Git prompt integration (third-party)
  git-completion.bash   # Git completion (third-party)
  zsh-autosuggestions.zsh  # Fish-like suggestions (third-party)
```

## Design Principles

1. **Non-interactive shells get tools** - Claude Code, scripts, and other non-interactive
   contexts need access to mise-managed tools. Solved by:
   - Zsh: `.zshenv` sources `.profile` (always runs)
   - Bash: `BASH_ENV` points to `env.sh` (set in `.profile`)

2. **Single source of truth** - Environment setup lives in `env.sh`, sourced everywhere.
   Guard variable `__ENV_SOURCED` prevents double-sourcing.

3. **Shell-specific code is isolated** - `bash/init.sh` and `zsh/init.sh` contain only
   code that genuinely differs. No conditionals in the main flow.

4. **Fast startup** - `env.sh` is minimal since it runs for every shell. Heavy setup
   (lazy installs, prompts) only runs for interactive shells.

5. **Idempotent PATH** - `__prepend_path` checks for duplicates before adding.

6. **Local overrides** - `~/.bashrc_local` and `~/.zshrc_local` sourced if present.

## Shell Loading Order

| Context                  | Bash                          | Zsh                        |
|--------------------------|-------------------------------|----------------------------|
| Login interactive        | .bash_profile -> .bashrc      | .zshenv -> .zshrc          |
| Non-login interactive    | .bashrc                       | .zshenv -> .zshrc          |
| Non-interactive          | BASH_ENV (env.sh)             | .zshenv                    |

## Tool Activation

- **mise**: Shims added to PATH in `env.sh` (works everywhere). Full activation with
  hooks in `interactive.sh` (better UX for interactive use).
- **brew**: Detected and initialized in `env.sh`.
- **starship**: Activated in `tools.sh`, with fallback prompt in `prompt.sh`.

## Platform Notes

- **macOS**: Brew at `/opt/homebrew` (ARM) or `/usr/local` (Intel)
- **Linux**: Brew at `/home/linuxbrew/.linuxbrew` or `~/.linuxbrew`
- **Termux**: Uses zsh by default. No brew, uses `pkg` instead.

## Adding New Tools

Use the `__lazy_install` function in `tools.sh`:

```bash
__lazy_install "toolname" \
  --init="initialization command" \
  --termux="pkg install toolname" \
  --linux="brew install toolname" \
  --macos="brew install toolname"
```

## Troubleshooting

**Tools not found in non-interactive shell (Claude Code, scripts):**
- Check that `~/.profile` exists and sources `env.sh`
- For bash: verify `BASH_ENV` is exported in `.profile`
- For zsh: verify `.zshenv` sources `.profile`

**Slow shell startup:**
- Run `time zsh -i -c exit` or `time bash -i -c exit`
- Enable profiling: `ENABLE_ZPROF=1 zsh` (zsh only)
- Check if brew/mise are installed (lazy install prompts add delay)

**PATH issues:**
- Check order with `echo $PATH | tr ':' '\n'`
- Verify `__ENV_SOURCED` guard isn't blocking: `unset __ENV_SOURCED` and re-source
