# ~/.zshrc -- portable zsh config (symlinked from the dotfiles repo).

# --- locate the dotfiles repo through the symlink -----------------------------
# ${(%):-%x} expands to this file's path; :A resolves symlinks to an absolute
# path; :h:h walks home/ -> repo root.
DOTFILES="${${(%):-%x}:A:h:h}"
export DOTFILES

# --- shared exports + aliases -------------------------------------------------
[ -r "${DOTFILES}/shell/common.sh" ]  && . "${DOTFILES}/shell/common.sh"
[ -r "${DOTFILES}/shell/aliases.sh" ] && . "${DOTFILES}/shell/aliases.sh"

# --- history ------------------------------------------------------------------
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share history across running shells
setopt HIST_IGNORE_ALL_DUPS   # collapse duplicate commands
setopt HIST_IGNORE_SPACE      # a leading space hides a command from history
setopt HIST_VERIFY            # expand !! etc. onto the line before running
setopt EXTENDED_HISTORY       # record timestamps

# --- completion ---------------------------------------------------------------
autoload -Uz compinit && compinit -i
zstyle ':completion:*' menu select                         # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive
zstyle ':completion:*' list-colors ''                      # colorize matches
zstyle ':completion:*:descriptions' format '%B%d%b'        # group headers
setopt AUTO_MENU COMPLETE_IN_WORD ALWAYS_TO_END

# --- shell options & directory navigation -------------------------------------
setopt AUTO_CD                # `..` / a dir name alone cds into it
setopt AUTO_PUSHD             # every cd pushes onto the dir stack ...
setopt PUSHD_IGNORE_DUPS      # ... without duplicate entries ...
setopt PUSHD_SILENT           # ... and quietly
setopt INTERACTIVE_COMMENTS   # allow `# comments` at the interactive prompt
setopt EXTENDED_GLOB          # richer globbing (^, ~, # operators)
# Directory stack: `d` lists recent dirs; 1-9 jump straight to them.
alias d='dirs -v'
for _i in 1 2 3 4 5 6 7 8 9; do alias "$_i"="cd +$_i"; done; unset _i

# --- vi mode ------------------------------------------------------------------
bindkey -v
export KEYTIMEOUT=1           # ~10ms: make <Esc> feel instant

# Restore the high-value emacs editing keys in INSERT mode (these are lost or
# repurposed by `bindkey -v`).  Normal/command mode stays pure vi.
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M viins '^P' up-line-or-history
bindkey -M viins '^N' down-line-or-history
bindkey -M viins '^?' backward-delete-char     # keep Backspace sane past insert
bindkey -M viins '^H' backward-delete-char      # Ctrl-H also deletes back
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^S' history-incremental-search-forward
# Also allow ^R search from normal mode.
bindkey -M vicmd '^R' history-incremental-search-backward

# `vv` in normal mode opens the line in $EDITOR (matching oh-my-zsh); this leaves
# the plain `v` bound to its default visual-mode.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'vv' edit-command-line

# Change the cursor shape per mode: beam in insert, block in normal (DECSCUSR;
# ignored by terminals that don't support it).
function _vi_cursor {
  case $KEYMAP in
    vicmd)      print -n '\e[2 q' ;;   # steady block
    main|viins) print -n '\e[6 q' ;;   # steady beam
  esac
}

# Show the current vi mode (INSERT vs NORMAL) on the right of the prompt and
# update the cursor shape.
function zle-line-init zle-keymap-select {
  case $KEYMAP in
    vicmd)      RPS1='%F{yellow}-- NORMAL --%f' ;;
    main|viins) RPS1='%F{green}-- INSERT --%f' ;;
  esac
  _vi_cursor
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
# Reset to a beam when each command starts running (so output isn't a block).
function zle-line-finish { print -n '\e[6 q' }
zle -N zle-line-finish

# --- prompt -------------------------------------------------------------------
setopt PROMPT_SUBST

# Git segment, following common git-prompt conventions:
#   green  = clean working tree
#   yellow = has changes, with ASCII markers:  + staged   * unstaged   ? untracked
# Nothing is printed outside a git repo.
_git_prompt() {
  local branch st marks='' color
  branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) \
    || branch=$(git rev-parse --short HEAD 2>/dev/null) || return 0
  st=$(git status --porcelain 2>/dev/null)
  print -r -- "$st" | grep -q '^[MADRCU]' && marks+='+'   # staged (index) changes
  print -r -- "$st" | grep -q '^.[MD]'    && marks+='*'   # unstaged worktree changes
  print -r -- "$st" | grep -q '^??'       && marks+='?'   # untracked files
  if [[ -n $marks ]]; then color='%F{yellow}'; else color='%F{green}'; fi
  print -n -- " ${color}(${branch}${marks})%f"
}

# Context color for user@host (computed once -- doesn't change within a session):
#   183     local non-root (pastel purple, distinct from the green clean-git)
#   magenta root
#   red     SSH session, prefixed with [client-ip]
#   yellow  [docker] / [chroot] prefix
_ctx_color=183; _ctx_prefix=''
if [[ -n $SSH_CONNECTION ]]; then
  _ctx_color=red
  _ctx_prefix="%F{yellow}[${SSH_CONNECTION%% *}]%f "
elif [[ -e /.dockerenv ]]; then
  _ctx_prefix='%F{yellow}[docker]%f '
elif [[ -r /etc/debian_chroot ]]; then
  _ctx_prefix="%F{yellow}[chroot]%f "
fi
[[ $UID == 0 ]] && _ctx_color=magenta

# %n user, %m short hostname, %~ cwd (yellow); the git segment; then a red [N]
# only when the last command failed; %(!.#.$) -> '#' as root else plain '$'.
PROMPT="${_ctx_prefix}%F{${_ctx_color}}%n@%m%f:%F{cyan}%~%f"'$(_git_prompt)%(?.. %F{red}[%?]%f) %(!.#.$) '
unset _ctx_color _ctx_prefix

# --- fzf integration (only when the opt-in layer is installed) ----------------
# Sourced last so fzf's Ctrl-R (fuzzy history) takes over from the builtin one
# when present.  Installed/removed with `fzf-layer on` / `fzf-layer off`.
[ -f "${HOME}/.fzf.zsh" ] && . "${HOME}/.fzf.zsh"

# --- machine-local overrides (never committed) --------------------------------
[ -r "${HOME}/.zshrc.local" ] && . "${HOME}/.zshrc.local"
