---
name: tools-inventory
description: Discover all installed tools, packages, and runtimes. Use when an agent needs to know what's available before suggesting installs or writing scripts.
user-invocable: true
argument-hint: [filter]
allowed-tools: Read Grep Glob Bash(sh ${CLAUDE_SKILL_DIR}/discover.sh *)
---

# Tools Inventory

Discover what's installed on this system. Optional filter: $ARGUMENTS

## Quick Start

Run the discovery script:
```sh
sh ${CLAUDE_SKILL_DIR}/discover.sh $ARGUMENTS
```

This outputs a structured inventory covering: platform, system packages, runtimes,
global CLI tools (npm/go/cargo/pip/uv), repo-local version overrides, and shell aliases.

If $ARGUMENTS is provided, only matching sections are shown.

## When to Use Manual Commands

The script covers the common cases. Use manual commands when you need:
- Deeper inspection of a specific tool's config
- To check if a tool supports a specific flag on this platform
- To resolve conflicts between global and repo-local versions

## Repo-Local Tool Overrides

When in a project directory, these files pin versions that override globals:

| File | Manager | What it controls |
|------|---------|-----------------|
| `.mise.toml` / `.tool-versions` | mise | Any runtime (node, python, go, etc.) |
| `.nvmrc` / `.node-version` | nvm/mise/fnm | Node.js version |
| `.python-version` | pyenv/mise | Python version |
| `.go-version` | mise | Go version |
| `package.json` engines | npm/pnpm | Node version constraint |
| `pyproject.toml` requires-python | uv/pip | Python version constraint |
| `rust-toolchain.toml` | rustup | Rust toolchain |
| `go.mod` go directive | go | Minimum Go version |

## Key Gotchas for Agents

- **Don't suggest installing what's already there.** Run this inventory first.
- **Repo-local versions win.** If `.mise.toml` says node 20 but global is 22,
  the project uses 20. Don't upgrade it without understanding why.
- **Termux != standard Linux.** Many packages exist but some have quirks:
  no systemd, different paths ($PREFIX instead of /usr), proot needed for /tmp.
- **`brew leaves` vs `brew list`**: leaves shows what the USER installed,
  list includes all deps. Use leaves for inventory.
- **mise shims**: `~/.local/share/mise/shims` is on PATH for non-interactive shells.
  `mise activate` provides hooks for interactive shells. Both resolve to the same tools.
- **Lazy installs**: tools.sh may define stub functions for tools not yet installed.
  A stub means the tool is KNOWN but NOT INSTALLED. Check with `command -v`.
