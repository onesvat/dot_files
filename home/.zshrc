# Shared interactive Zsh config for desktop and htpc.

[[ -o interactive ]] || return 0

if [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]]; then
  fpath=("$GHOSTTY_RESOURCES_DIR/shell-integration/zsh" $fpath)
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

bindkey -e

setopt AUTO_CD
setopt COMPLETE_IN_WORD
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt NO_NOMATCH
setopt PROMPT_SUBST
setopt TRANSIENT_RPROMPT

HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=50000
SAVEHIST=50000

setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

fc -RI

autoload -Uz add-zsh-hook compinit edit-command-line \
  down-line-or-beginning-search up-line-or-beginning-search
zmodload zsh/complist

typeset -g cache_root="${XDG_CACHE_HOME:-$HOME/.cache}"
typeset -g comp_cache="$cache_root/zsh"
typeset -g comp_dump="${ZDOTDIR:-$HOME}/.zcompdump"

command mkdir -p "$comp_cache"

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$comp_cache"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' special-dirs false
zstyle ':completion:*' ignore-parents /media $HOME/docker

if [[ -f "$comp_dump" ]]; then
  compinit -C -d "$comp_dump"
else
  compinit -d "$comp_dump"
fi

case "${TERM:-}" in
  xterm*|rxvt*|screen*|tmux*|vte*)
    if [[ -z "${TITLE_HOOKS_ADDED:-}" ]]; then
      _title_precmd() {
        print -Pn "\e]2;%n@%m: ${PWD/#$HOME/~}\a"
      }

      _title_preexec() {
        print -Pn "\e]2;%n@%m: $1\a"
      }

      add-zsh-hook precmd _title_precmd
      add-zsh-hook preexec _title_preexec
      export TITLE_HOOKS_ADDED=1
    fi
    ;;
esac

export GIT_DISCOVERY_ACROSS_FILESYSTEM=0

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ -f "$ZINIT_HOME/zinit.zsh" ]]; then
  source "$ZINIT_HOME/zinit.zsh"

  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=25
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

  zinit light zsh-users/zsh-completions
  zinit light Aloxaf/fzf-tab
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-history-substring-search
  zinit light zdharma-continuum/fast-syntax-highlighting
  zinit cdreplay -q
fi

if command -v fzf >/dev/null 2>&1 && [[ -t 0 && -t 1 ]]; then
  if fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  else
    [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
    [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
  fi
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

if command -v starship >/dev/null 2>&1 && [[ "${TERM:-}" != "dumb" ]]; then
  eval "$(starship init zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias zz='cd "$(zoxide query -i)"'
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
fi

if [[ -f "$HOME/.openclaw/completions/openclaw.zsh" ]]; then
  source "$HOME/.openclaw/completions/openclaw.zsh"
fi

unalias la ll lt le py python venv dc q s e md 2>/dev/null

if command -v eza >/dev/null 2>&1; then
  _ls_core() {
    local hidden="$1"
    shift
    local perms="--no-permissions"
    local time_style="--time-style=relative"
    local size=""
    local args=()

    for arg in "$@"; do
      case "$arg" in
        -p) perms="" ;;
        -op) perms="--octal-permissions" ;;
        -t) time_style="--time-style=long-iso" ;;
        -s) size="--total-size" ;;
        -A) hidden="-A" ;;
        *) args+=("$arg") ;;
      esac
    done

    eza -l $hidden --icons --git --smart-group --group-directories-first \
      $perms $time_style $size "${args[@]}"
  }

  le() { _ls_core "" "$@"; }
  ll() { _ls_core "-A" "$@"; }
  la() { eza -a --icons --group-directories-first "$@"; }
  lt() {
    local depth=2
    [[ "$1" =~ ^[0-9]+$ ]] && depth="$1" && shift
    eza -l --tree --level="$depth" --icons --git --smart-group "$@"
  }
else
  le() { command ls -lh "$@"; }
  ll() { command ls -lah "$@"; }
  la() { command ls -A "$@"; }
  lt() { command ls -lah "$@"; }
fi

alias py='python3'
alias python='python3'
alias venv='source .venv/bin/activate'
alias dc='docker compose'

if command -v rg >/dev/null 2>&1; then
  alias rga='rg -uu 2>/dev/null'
  alias rgl='rg -uu -l 2>/dev/null'
fi

if command -v aichat >/dev/null 2>&1; then
  alias q='aichat -r cmd'
  alias qe='aichat -e'
fi

if command -v kitten >/dev/null 2>&1; then
  alias s='kitten ssh'
fi

if command -v gnome-text-editor >/dev/null 2>&1; then
  alias e='gnome-text-editor'
fi

if command -v glow >/dev/null 2>&1; then
  alias md='glow -p'
fi

bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

if (( $+widgets[atuin-search] )); then
  bindkey '^R' atuin-search
fi

if (( $+widgets[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^[[OA' history-substring-search-up
  bindkey '^[[OB' history-substring-search-down
elif (( $+widgets[atuin-up-search] )); then
  bindkey '^[[A' atuin-up-search
  bindkey '^[[B' down-line-or-history
  bindkey '^[[OA' atuin-up-search
  bindkey '^[[OB' down-line-or-history
else
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search
  bindkey '^[[A' up-line-or-beginning-search
  bindkey '^[[B' down-line-or-beginning-search
  bindkey '^[[OA' up-line-or-beginning-search
  bindkey '^[[OB' down-line-or-beginning-search
fi

zle -N edit-command-line
_edit_command_line() {
  zle edit-command-line
  zle -I
  zle reset-prompt
  zle redisplay
}
zle -N _edit_command_line
bindkey '^X^E' _edit_command_line
bindkey '^Xe' _edit_command_line

typeset -gaU ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(forward-word)

if command -v aichat >/dev/null 2>&1; then
  _aichat_zsh() {
    if [[ -n "$BUFFER" ]]; then
      local old_buffer="$BUFFER"
      BUFFER="thinking..."
      zle -I
      zle redisplay
      BUFFER="$(aichat -e "$old_buffer")"
      zle end-of-line
    fi
  }

  zle -N _aichat_zsh
  bindkey '\ee' _aichat_zsh
fi

if ! command -v starship >/dev/null 2>&1; then
  PROMPT='%F{cyan}%3~%f %# '
fi

cat() {
  if [[ $# -eq 1 ]]; then
    case "$1" in
      *.md)  command glow -p "$1" ;;
      *.csv) command csvlens "$1" ;;
      *)     command cat "$@" ;;
    esac
  else
    command cat "$@"
  fi
}

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:/home/onur/.lmstudio/bin"

# OpenClaw Completion
#source "/home/onur/.openclaw/completions/openclaw.zsh"

# Rebase current branch onto upstream main and push to fork
git-sync() {
  local branch
  branch=$(git branch --show-current) || return 1

  # Ensure fork remote exists
  if ! git remote get-url fork >/dev/null 2>&1; then
    echo "error: 'fork' remote not found. Add it first:" >&2
    echo "  git remote add fork git@github.com:<you>/<repo>.git" >&2
    return 1
  fi

  echo "⟳ Fetching origin and fork..."
  git fetch origin || return 1
  git fetch fork || return 1

  echo "⟳ Rebasing $branch onto origin/main..."
  git rebase origin/main || return 1

  echo "⟳ Pushing to fork/$branch..."
  git push fork "$branch" --force-with-lease || return 1

  echo "✓ $branch is up to date on fork"
}
