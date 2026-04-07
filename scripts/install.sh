#!/usr/bin/env bash
# install.sh — Provision all tools for a fresh Fedora workstation.
# Run once after cloning the repo. Safe to re-run (idempotent).
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info()    { printf '\n[install] %s\n' "$*"; }
skip()    { printf '[skip]    %s\n' "$*"; }

# ── 1. DNF system packages ────────────────────────────────────────────────────
info "dnf packages"
sudo dnf install -y \
  fzf bat direnv glow tealdeer navi ghostty \
  ripgrep fd-find jq yq \
  zsh git gh

# ── 2. mise ───────────────────────────────────────────────────────────────────
info "mise"
if ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
else
  skip "mise already installed"
fi

# ── 3. Symlink dotfiles (needed before mise install reads config) ─────────────
info "bootstrap symlinks"
"$repo_root/scripts/bootstrap.sh"

# ── 4. mise-managed runtimes and tools ───────────────────────────────────────
info "mise install (python, node, delta, just, xh, bottom, dust)"
mise install

# ── 5. Node tooling via corepack ─────────────────────────────────────────────
info "corepack / pnpm"
corepack enable

# ── 6. zinit ─────────────────────────────────────────────────────────────────
info "zinit"
zinit_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$zinit_dir" ]]; then
  git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$zinit_dir"
else
  skip "zinit already cloned"
fi

# ── 7. starship ──────────────────────────────────────────────────────────────
info "starship"
if ! command -v starship >/dev/null 2>&1; then
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
else
  skip "starship already installed"
fi

# ── 8. atuin ─────────────────────────────────────────────────────────────────
info "atuin"
if ! command -v atuin >/dev/null 2>&1; then
  curl -fsSL https://setup.atuin.sh | sh
else
  skip "atuin already installed"
fi

# ── 9. zoxide ────────────────────────────────────────────────────────────────
info "zoxide"
if ! command -v zoxide >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
  skip "zoxide already installed"
fi

# ── 10. Rust + cargo tools ────────────────────────────────────────────────────
info "Rust / cargo"
if ! command -v cargo >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env"
else
  skip "cargo already installed"
fi

info "cargo tools (eza, csvlens, aichat)"
for tool in eza csvlens aichat; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    cargo install "$tool" --locked
  else
    skip "$tool already installed"
  fi
done

# ── 11. tealdeer cache ───────────────────────────────────────────────────────
info "tealdeer (tldr) cache update"
tldr --update || true

printf '\n[install] Done. Start a new shell to pick up PATH and completions.\n'
