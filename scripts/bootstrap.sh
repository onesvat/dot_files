#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--dry-run] [--force] [--target-home PATH]

Create symlinks from repo files under home/ into a target home directory.

Options:
  --dry-run           Show planned actions only.
  --force             Replace existing files or symlinks.
  --target-home PATH  Target home directory. Defaults to $HOME.
EOF
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_root="$repo_root/home"
target_home="${HOME}"
dry_run=0
force=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=1
      ;;
    --force)
      force=1
      ;;
    --target-home)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      target_home="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

link_file() {
  local src="$1"
  local rel="${src#$source_root/}"
  local dst="$target_home/$rel"
  local dst_dir
  local current_target

  dst_dir="$(dirname "$dst")"

  if (( dry_run )); then
    printf '[dry-run] mkdir -p %s\n' "$dst_dir"
  else
    mkdir -p "$dst_dir"
  fi

  if [[ -L "$dst" ]]; then
    current_target="$(readlink "$dst")"
    if [[ "$current_target" == "$src" ]]; then
      printf 'ok      %s\n' "$dst"
      return 0
    fi

    if (( force )); then
      if (( dry_run )); then
        printf '[dry-run] rm %s\n' "$dst"
      else
        rm "$dst"
      fi
    else
      printf 'skip    %s (symlink exists)\n' "$dst"
      return 0
    fi
  elif [[ -e "$dst" ]]; then
    if (( force )); then
      if (( dry_run )); then
        printf '[dry-run] mv %s %s.bak\n' "$dst" "$dst"
      else
        mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
      fi
    else
      printf 'skip    %s (file exists)\n' "$dst"
      return 0
    fi
  fi

  if (( dry_run )); then
    printf '[dry-run] ln -s %s %s\n' "$src" "$dst"
  else
    ln -s "$src" "$dst"
    printf 'linked  %s\n' "$dst"
  fi
}

while IFS= read -r -d '' src; do
  link_file "$src"
done < <(find "$source_root" -type f -print0 | LC_ALL=C sort -z)

