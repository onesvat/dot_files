#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_root="$repo_root/home"
real_home="${HOME}"
base_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

zdotdir="$tmp_dir/zdotdir"
xdg_config="$tmp_dir/.config"
xdg_cache="$tmp_dir/.cache"
mkdir -p "$zdotdir" "$xdg_config" "$xdg_cache" \
  "$xdg_config/mise" "$xdg_config/ghostty" "$xdg_config/atuin" "$xdg_config/glow"

ln -s "$source_root/.zshenv" "$zdotdir/.zshenv"
ln -s "$source_root/.zprofile" "$zdotdir/.zprofile"
ln -s "$source_root/.zshrc" "$zdotdir/.zshrc"
ln -s "$source_root/.config/starship.toml" "$xdg_config/starship.toml"
ln -s "$source_root/.config/mise/config.toml" "$xdg_config/mise/config.toml"
ln -s "$source_root/.config/ghostty/config" "$xdg_config/ghostty/config"
ln -s "$source_root/.config/atuin/config.toml" "$xdg_config/atuin/config.toml"
ln -s "$source_root/.config/glow/glow.yml" "$xdg_config/glow/glow.yml"

run_zsh() {
  PATH="$base_path" \
  HOME="$real_home" \
  ZDOTDIR="$zdotdir" \
  XDG_CONFIG_HOME="$xdg_config" \
  XDG_CACHE_HOME="$xdg_cache" \
  zsh "$@"
}

printf 'syntax      '
run_zsh -n "$source_root/.zshenv"
run_zsh -n "$source_root/.zprofile"
run_zsh -n "$source_root/.zshrc"
printf 'ok\n'

printf 'startup     '
run_zsh -i -c exit >/dev/null
printf 'ok\n'

printf 'bindings    '
ctrl_r="$(run_zsh -i -c "bindkey '^R'")"
up_key="$(run_zsh -i -c "bindkey '^[[A'")"
down_key="$(run_zsh -i -c "bindkey '^[[B'")"

if [[ "$ctrl_r" != *"atuin-search"* ]]; then
  printf 'failed\n' >&2
  printf 'Expected Ctrl-R to use Atuin, got: %s\n' "$ctrl_r" >&2
  exit 1
fi

case "$up_key" in
  *history-substring-search-up*|*atuin-up-search*|*up-line-or-beginning-search*) ;;
  *)
    printf 'failed\n' >&2
    printf 'Unexpected Up binding: %s\n' "$up_key" >&2
    exit 1
    ;;
esac

case "$down_key" in
  *history-substring-search-down*|*down-line-or-history*|*down-line-or-beginning-search*) ;;
  *)
    printf 'failed\n' >&2
    printf 'Unexpected Down binding: %s\n' "$down_key" >&2
    exit 1
    ;;
esac
printf 'ok\n'

printf 'helpers     '
helpers_output="$(run_zsh -i -c "alias py; alias dc; whence -w ll; whence -w with_firecrawl")"
if [[ "$helpers_output" != *"py=python3"* ]] || [[ "$helpers_output" != *"dc='docker compose'"* ]]; then
  printf 'failed\n' >&2
  printf 'Missing helper aliases\n' >&2
  exit 1
fi
printf 'ok\n'

printf 'nonint      '
nonint_output="$(run_zsh -lc 'whence -w with_firecrawl')"
if [[ "$nonint_output" != *"with_firecrawl: function"* ]]; then
  printf 'failed\n' >&2
  printf 'with_firecrawl is not available in non-interactive shells\n' >&2
  exit 1
fi
printf 'ok\n'

printf 'starship    '
STARSHIP_CONFIG="$xdg_config/starship.toml" \
HOME="$real_home" \
SSH_CONNECTION="1" \
starship explain >/dev/null
printf 'ok\n'

printf 'bootstrap   '
"$repo_root/scripts/bootstrap.sh" --dry-run --target-home "$tmp_dir/home" >/dev/null
printf 'ok\n'

printf 'node        '
run_zsh -lc 'command -v node >/dev/null && node -v'
printf 'python      '
run_zsh -lc 'command -v python3 >/dev/null && python3 --version'
