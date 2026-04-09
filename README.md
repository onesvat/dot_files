# dot_files

Shared shell dotfiles for desktop and `htpc`.

## Layout

- `home/` mirrors the files that will eventually live under `$HOME`
- `scripts/bootstrap.sh` prepares symlinks from this repo into a target home
- `scripts/check.sh` validates the repo in an isolated temp environment
- `scripts/install.sh` provisions all tools on a fresh Fedora or macOS machine

## What is included

- shared `.zshenv`, `.zprofile`, `.zshrc`
- `starship.toml` — prompt configuration
- `mise/config.toml` — pinned runtimes and tools
- `ghostty/config` — terminal theme and cursor settings
- `atuin/config.toml` — history search settings
- `glow/glow.yml` — markdown viewer settings
- `.gitconfig` — git identity, delta pager, merge settings
- `aichat/config.yaml.example` — template for local LLM client config
- `firecrawl.env.example` — template for Firecrawl API config

## Deploy from scratch

On a fresh Fedora or macOS machine:

```bash
git clone <repo> ~/Code/dot_files
cd ~/Code/dot_files
./scripts/install.sh
```

`install.sh` installs all tools, creates symlinks, updates the tldr cache, and on macOS bootstraps Homebrew if needed. It is safe to re-run.

After install, run `atuin login` to restore shell history sync.

## Runtime policy

- `mise` is the runtime manager
- `uv` is the Python workflow tool
- `pnpm` via `corepack` is the default Node package manager
- `npx` is for one-shot commands only

The shared `mise` config pins:

- `python = "3.12"`
- `node = "24"`

## Validation

Run:

```bash
./scripts/check.sh
```

This uses a temporary `ZDOTDIR`, `XDG_CONFIG_HOME`, and `XDG_CACHE_HOME` so the repo can be tested without modifying live dotfiles.

## Deployment (symlinks only)

To just deploy or refresh symlinks without reinstalling tools:

```bash
./scripts/bootstrap.sh
```

Dry run:

```bash
./scripts/bootstrap.sh --dry-run
```
