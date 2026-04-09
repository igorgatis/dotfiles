---
name: dotfiles
description: Manage yadm-tracked dotfiles. Add/remove tools, aliases, env vars. Cross-platform (macOS, Linux, Termux). Suggest tools and organization improvements.
user-invocable: true
argument-hint: [action] [details...]
allowed-tools: Read Edit Write Grep Glob Bash(sh ${CLAUDE_SKILL_DIR}/dotfiles-helper.sh *) Bash(yadm *) Bash(bash *) Bash(zsh *)
---

# Dotfiles Management

Manage a yadm-tracked dotfiles repo (github.com/igorgatis/dotfiles).
Parse the user's request from: $ARGUMENTS

## Repository Layout

Read files before editing. Key files:

| File | Scope | Purpose |
|------|-------|---------|
| `~/.config/sh/env.sh` | ALL shells | PATH, locale, brew, mise shims, cargo |
| `~/.config/sh/interactive.sh` | Interactive | Sources modules below in order |
| `~/.config/sh/aliases.sh` | Interactive | Shell-agnostic aliases |
| `~/.config/sh/tools.sh` | Interactive | `__lazy_install` definitions, helpers |
| `~/.config/sh/completion.sh` | Interactive | Tab completion for bash/zsh |
| `~/.config/sh/prompt.sh` | Interactive | Starship init + fallback prompt |
| `~/.config/sh/bash/init.sh` | Interactive | Bash history, shopt, keybindings |
| `~/.config/sh/zsh/init.sh` | Interactive | Zsh history, setopt, keybindings |
| `~/.config/sh/README.md` | Docs | Shell config documentation |
| `~/.bashrc_local` | Machine-only | Untracked bash overrides |
| `~/.zshrc_local` | Machine-only | Untracked zsh overrides |
| `~/.config/starship.toml` | Interactive | Prompt theme |
| `~/.gitconfig` | All | Git aliases and settings |
| `~/.vimrc` | Interactive | Vim config |
| `~/.tmux.conf` | Interactive | Tmux config |

## Architecture Rules

1. **env.sh** runs for ALL shells including scripts and Claude Code. Keep minimal/fast.
   Guard `__ENV_SOURCED` prevents double-sourcing.
2. **interactive.sh** sources: shell-specific init -> aliases -> completion -> tools -> prompt.
3. **Platform detection** via runtime conditionals, NOT yadm alternates:
   - `$TERMUX_VERSION` = Termux. Package manager: `pkg`
   - `uname` = Darwin = macOS. Package manager: `brew`
   - `uname` = Linux, no `$TERMUX_VERSION` = desktop Linux. Package manager: `brew`
4. **POSIX sh** in all shared files. Bash-only in bash/init.sh, zsh-only in zsh/init.sh.
5. **Local overrides** (`~/.bashrc_local`, `~/.zshrc_local`) for machine-specific, untracked config.
6. **No secrets** in tracked files. Ever.
7. **No comments** unless truly necessary. 2-space indent.

## Helper Script

Run `sh ${CLAUDE_SKILL_DIR}/dotfiles-helper.sh <action>` for quick inspection:
- `list-tools` -- show lazy-install tools and installed status
- `list-aliases` -- show all aliases
- `list-env` -- show exported env vars from env.sh
- `check-portable` -- lint shared files for POSIX issues
- `platform` -- print os/arch/pkgmgr
- `pkg-search NAME` -- search for a package across managers
- `validate` -- test bash and zsh startup

## Add a Tool

1. Read `~/.config/sh/tools.sh`.
2. Add a `__lazy_install` block:
   ```sh
   __lazy_install "toolname" \
     --init="eval \"\$(toolname init $__shell)\"" \
     --termux="pkg install toolname" \
     --linux="brew install toolname" \
     --macos="brew install toolname"
   ```
   Omit `--init` if no shell integration needed.
   Use the correct install method per platform (pkg, brew, npm, cargo, curl).
3. If tool needs PATH/env vars in non-interactive shells, add to `~/.config/sh/env.sh`
   with platform guards. PATH helper `__prepend_path` is available only in env.sh.
4. If tool needs completions, add to `~/.config/sh/completion.sh`.
5. Update `~/.config/sh/README.md` if notable.
6. Verify package names: `pkg search <name>` or `brew search <name>`.

## Remove a Tool

1. Remove `__lazy_install` block from `~/.config/sh/tools.sh`.
2. Grep for tool name across aliases.sh, env.sh, completion.sh, prompt.sh and remove references.
3. Update `~/.config/sh/README.md`.

## Add/Remove an Alias

1. Read `~/.config/sh/aliases.sh`.
2. Use POSIX syntax: `alias name='command'`
3. Platform-specific aliases use conditionals:
   ```sh
   if [ -n "$TERMUX_VERSION" ]; then
     alias name='...'
   fi
   ```

## Add/Modify Environment Variables

Decide scope:
- **All shells** (scripts, Claude Code need it): `~/.config/sh/env.sh`
- **Interactive only**: appropriate module in `~/.config/sh/`
- **Machine-specific**: `~/.bashrc_local` / `~/.zshrc_local` (untracked, remind user)

Platform-guarded example for env.sh:
```sh
if [ -n "${TERMUX_VERSION:-}" ]; then
  export VAR="termux-value"
elif [ "$(uname)" = "Darwin" ]; then
  export VAR="mac-value"
fi
```

## Suggest Tools

When asked, read current tools.sh and aliases.sh, then suggest from this catalog
(all available on macOS/Linux/Termux unless noted):

| Tool | What | pkg | brew |
|------|------|-----|------|
| fzf | Fuzzy finder | yes | yes |
| bat | Better cat | yes | yes |
| fd | Better find | yes | yes |
| ripgrep | Better grep | yes | yes |
| jq | JSON processor | yes | yes |
| zoxide | Smarter cd | yes | yes |
| eza | Better ls | no* | yes |
| delta | Better git diff | no | yes |
| tldr | Simplified man | yes | yes |
| httpie | Better curl | yes | yes |
| direnv | Per-dir env vars | yes | yes |
| lazygit | Git TUI | no | yes |
| btop | Process viewer | yes | yes |
| yq | YAML processor | no | yes |

*Check current Termux availability before recommending.

Suggest based on what's missing and what the user's workflow would benefit from.
Prefer tools available on all three platforms.

## Suggest Organization Improvements

Respect the existing modular structure. Only suggest:
- New modules if a genuinely new concern emerges
- Consolidation if files have become redundant
- Pattern improvements (e.g., better lazy-install, new helper functions)

## Portability Checklist

Before finishing any change, verify:
1. POSIX sh syntax in shared files (no `[[ ]]`, no `local` arrays, no `source`)
2. No hardcoded platform paths -- use `$HOME`, `$PREFIX`, detection
3. All three platforms covered: --termux, --linux, --macos
4. GNU vs BSD command differences handled (sed -i, date, etc.)
5. Test: `bash -i -c 'echo ok'` and `zsh -i -c 'echo ok'`

## After Changes

Show a summary of what was modified. Remind the user to commit with yadm.
Do NOT commit automatically.
