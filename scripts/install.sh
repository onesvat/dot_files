#!/usr/bin/env bash
# install.sh — Provision all tools for a fresh Fedora or macOS workstation.
# Run once after cloning the repo. Safe to re-run (idempotent).
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
os="$(uname -s)"

info() { printf '\n[install] %s\n' "$*"; }
skip() { printf '[skip]    %s\n' "$*"; }
warn() { printf '[warn]    %s\n' "$*"; }
die()  { printf '[error]   %s\n' "$*" >&2; exit 1; }

have() {
  command -v "$1" >/dev/null 2>&1
}

prepend_path() {
  local dir="$1"

  [[ -d "$dir" ]] || return 0

  case ":$PATH:" in
    *":$dir:"*) ;;
    *) export PATH="$dir:$PATH" ;;
  esac
}

load_homebrew_env() {
  local brew_bin=""

  if have brew; then
    brew_bin="$(command -v brew)"
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    brew_bin="/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    brew_bin="/usr/local/bin/brew"
  fi

  [[ -n "$brew_bin" ]] || return 1
  eval "$("$brew_bin" shellenv)"
}

install_homebrew() {
  info "homebrew"
  if load_homebrew_env; then
    skip "homebrew already installed"
    return 0
  fi

  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_homebrew_env || die "Homebrew installed but brew is still not on PATH"
}

install_system_packages() {
  case "$os" in
    Linux)
      info "dnf packages"
      sudo dnf install -y \
        fzf bat direnv glow tealdeer navi ghostty btop \
        ripgrep fd-find jq yq \
        zsh git gh
      ;;
    Darwin)
      install_homebrew

      info "homebrew packages"
      brew install \
        fzf bat direnv glow tealdeer navi btop \
        ripgrep fd jq yq \
        zsh git gh

      if brew list --cask ghostty >/dev/null 2>&1; then
        skip "ghostty already installed"
      elif ! brew install --cask ghostty; then
        warn "ghostty cask unavailable; skipping"
      fi
      ;;
    *)
      die "unsupported OS: $os"
      ;;
  esac
}

prepend_path "$HOME/.local/share/mise/shims"
prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.atuin/bin"
prepend_path "$HOME/.cargo/bin"

install_system_packages

# ── 2. mise ───────────────────────────────────────────────────────────────────
info "mise"
if ! have mise; then
  curl -fsSL https://mise.run | sh
else
  skip "mise already installed"
fi
prepend_path "$HOME/.local/bin"

# ── 3. Symlink dotfiles (needed before mise install reads config) ─────────────
info "bootstrap symlinks"
"$repo_root/scripts/bootstrap.sh"

# ── 4. mise-managed runtimes and tools ───────────────────────────────────────
info "mise install (python, node, delta, just, xh, bottom, dust)"
have mise || die "mise is not available on PATH"
mise install
prepend_path "$HOME/.local/share/mise/shims"

# ── 5. Node tooling via corepack ─────────────────────────────────────────────
info "corepack / pnpm"
have corepack || die "corepack is not available on PATH after mise install"
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
if ! have starship; then
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
else
  skip "starship already installed"
fi

# ── 8. atuin ─────────────────────────────────────────────────────────────────
info "atuin"
if ! have atuin; then
  curl -fsSL https://setup.atuin.sh | sh
else
  skip "atuin already installed"
fi
prepend_path "$HOME/.atuin/bin"

# ── 9. zoxide ────────────────────────────────────────────────────────────────
info "zoxide"
if ! have zoxide; then
  curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
  skip "zoxide already installed"
fi

# ── 10. Rust + cargo tools ───────────────────────────────────────────────────
info "Rust / cargo"
if ! have cargo; then
  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
else
  skip "cargo already installed"
fi
prepend_path "$HOME/.cargo/bin"

info "cargo tools (eza, csvlens, aichat)"
for tool in eza csvlens aichat; do
  if ! have "$tool"; then
    cargo install "$tool" --locked
  else
    skip "$tool already installed"
  fi
done

# ── 11. tealdeer cache ───────────────────────────────────────────────────────
info "tealdeer (tldr) cache update"
tldr --update || true

printf '\n[install] Done. Start a new shell to pick up PATH and completions.\n'
