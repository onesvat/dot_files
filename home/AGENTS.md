# Agent Guide

## Runtimes
- `mise` manages all language runtimes and CLI tools. Do not install languages via `apt`, `dnf`, `brew`, or `nvm`. Global pins live in `~/.config/mise/config.toml`; projects pin via `.mise.toml`.

## Python
- Use `uv` for everything: `uv init`, `uv add <pkg>`, `uv run <cmd>`, `uv sync`.
- No `pip install`, no manual `venv`. Commit `uv.lock`.

## JavaScript / TypeScript
- Use `pnpm` (enabled via `corepack`). No `npm`, no `yarn`.
- Use `pnpm dlx` instead of `npx`.

## Shell
- Scripts start with `#!/usr/bin/env bash` and `set -euo pipefail`.

## Preferred CLIs
- `rg` over `grep`, `fd` over `find`, `eza` over `ls`, `delta` for diffs, `gh` for GitHub, `just` for task runners.
