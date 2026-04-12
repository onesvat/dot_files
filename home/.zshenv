# Shared non-interactive-safe Zsh environment.

typeset -gU path PATH

typeset -a _onur_path_entries
typeset -a _onur_path_existing

_onur_path_entries=(
  "$HOME/.local/share/mise/shims"
  "$HOME/.local/bin"
  "$HOME/.atuin/bin"
  "$HOME/.cargo/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "$HOME/.npm-global/bin"
  "$HOME/.opencode/bin"
  "$HOME/.lmstudio/bin"
  "$HOME/.browser-use-env/bin"
)

_onur_path_existing=()
for _onur_path_dir in "${_onur_path_entries[@]}"; do
  [[ -d "$_onur_path_dir" ]] && _onur_path_existing+=("$_onur_path_dir")
done

path=("${_onur_path_existing[@]}" "${path[@]}")
unset _onur_path_dir _onur_path_entries _onur_path_existing

_run_with_env_file() {
  local label="$1"
  local env_file="$2"
  shift 2

  if [[ $# -eq 0 ]]; then
    print -u2 "$label: usage: $label <command> [args...]"
    return 2
  fi

  if [[ ! -r "$env_file" ]]; then
    print -u2 "$label: missing $env_file"
    return 1
  fi

  (
    set -a
    source "$env_file"
    set +a
    "$@"
  )
}

with_firecrawl() {
  local env_file="${XDG_CONFIG_HOME:-$HOME/.config}/firecrawl.env"
  _run_with_env_file "with_firecrawl" "$env_file" "$@"
}

firecrawl() {
  local env_file="${XDG_CONFIG_HOME:-$HOME/.config}/firecrawl.env"
  local firecrawl_bin="${commands[firecrawl]:-}"

  if [[ -z "$firecrawl_bin" ]]; then
    print -u2 "firecrawl: command not found"
    return 127
  fi

  _run_with_env_file "firecrawl" "$env_file" "$firecrawl_bin" "$@"
}

if [[ -x "$HOME/.browser-use-env/bin/browser-use" ]]; then
  browser-use() {
    local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$EUID}"
    local display_value="${DISPLAY:-:1}"
    local xauthority_value="${XAUTHORITY:-$runtime_dir/gdm/Xauthority}"

    DISPLAY="$display_value" \
    XAUTHORITY="$xauthority_value" \
    XDG_RUNTIME_DIR="$runtime_dir" \
    command "$HOME/.browser-use-env/bin/browser-use" --headed --profile "Default" "$@"
  }
fi

if [[ -z "${MISE_ACTIVATED:-}" ]] && command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
  export MISE_ACTIVATED=1
fi

if [[ -z "${EDITOR:-}" ]]; then
  for candidate in nvim vim nano vi; do
    if command -v "$candidate" >/dev/null 2>&1; then
      export EDITOR="$candidate"
      break
    fi
  done
fi

export VISUAL="${VISUAL:-$EDITOR}"
