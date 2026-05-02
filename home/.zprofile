# Shared login-shell environment.

export LANG="en_US.UTF-8"

if [[ -d "$HOME/Applications" ]]; then
  typeset -gU path PATH
  path=("$HOME/Applications" "${path[@]}")

  if [[ -n "${XDG_DATA_DIRS:-}" ]]; then
    export XDG_DATA_DIRS="$HOME/Applications:$XDG_DATA_DIRS"
  else
    export XDG_DATA_DIRS="$HOME/Applications"
  fi
fi

# Added by swiftly
if [[ -f "/home/onur/.local/share/swiftly/env.sh" ]]; then
  . "/home/onur/.local/share/swiftly/env.sh"
fi