# ~/.bashrc -- portable bash config (symlinked from the dotfiles repo).
# Interactive-only settings live here; .bash_profile sources this for login shells.

# Bail out if not running interactively.
case $- in
  *i*) ;;
  *) return ;;
esac

# --- locate the dotfiles repo through the symlink -----------------------------
# macOS readlink has no -f, so resolve symlinks manually.
_src="${BASH_SOURCE[0]}"
while [ -h "$_src" ]; do
  _dir="$(cd -P "$(dirname "$_src")" >/dev/null 2>&1 && pwd)"
  _src="$(readlink "$_src")"
  case "$_src" in /*) ;; *) _src="$_dir/$_src" ;; esac
done
_dir="$(cd -P "$(dirname "$_src")" >/dev/null 2>&1 && pwd)"
DOTFILES="$(cd "$_dir/.." >/dev/null 2>&1 && pwd)"
export DOTFILES
unset _src _dir

# --- shared exports + aliases -------------------------------------------------
[ -r "${DOTFILES}/shell/common.sh" ]  && . "${DOTFILES}/shell/common.sh"
[ -r "${DOTFILES}/shell/aliases.sh" ] && . "${DOTFILES}/shell/aliases.sh"

# --- history ------------------------------------------------------------------
HISTFILE="${HOME}/.bash_history"
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth          # ignore dupes and leading-space commands
shopt -s histappend             # append instead of overwriting on exit
shopt -s checkwinsize           # keep $LINES/$COLUMNS correct after resize
# Capture the last command's exit status (before anything else resets $?), then
# flush each command to history immediately (handy across many shells/SSH).
PROMPT_COMMAND="_ec=\$?; history -a; ${PROMPT_COMMAND}"

# --- vi mode ------------------------------------------------------------------
# Readline editing mode + the emacs-key restorations live in ~/.inputrc so they
# also apply to other readline programs.  Turn on shell vi mode here:
set -o vi

# --- completion ---------------------------------------------------------------
# Load bash-completion if available (path varies by platform).
if ! shopt -oq posix; then
  for f in /usr/share/bash-completion/bash_completion \
           /etc/bash_completion \
           /opt/homebrew/etc/profile.d/bash_completion.sh \
           /usr/local/etc/profile.d/bash_completion.sh; do
    [ -r "$f" ] && { . "$f"; break; }
  done
  unset f
fi

# --- prompt -------------------------------------------------------------------
# Git segment, following common git-prompt conventions:
#   green  = clean working tree
#   yellow = has changes, with ASCII markers:  + staged   * unstaged   ? untracked
# Emits readline-safe non-printing markers (\001..\002) so width stays correct.
_git_prompt() {
  local branch st marks='' c0 c1
  branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) \
    || branch=$(git rev-parse --short HEAD 2>/dev/null) || return 0
  st=$(git status --porcelain 2>/dev/null)
  printf '%s\n' "$st" | grep -q '^[MADRCU]' && marks+='+'   # staged (index) changes
  printf '%s\n' "$st" | grep -q '^.[MD]'    && marks+='*'   # unstaged worktree changes
  printf '%s\n' "$st" | grep -q '^??'       && marks+='?'   # untracked files
  if [ -n "$marks" ]; then c0='\001\033[33m\002'; else c0='\001\033[32m\002'; fi
  c1='\001\033[0m\002'
  printf ' %b(%s%s)%b' "$c0" "$branch" "$marks" "$c1"
}
# Red [N] when the last command failed (uses the $? captured in PROMPT_COMMAND).
_exit_code() {
  [ "${_ec:-0}" -ne 0 ] && printf ' \001\033[31m\002[%s]\001\033[0m\002' "$_ec"
}

# Path segment palette — swap the uncommented line to change theme:
_path_colors=(63 69 99 105 111 117 153)    # Periwinkle Dusk
#_path_colors=(132 168 174 211 217 218 225) # Warm Rose
_path_prompt() {
  local nc=${#_path_colors[@]} dim='\001\033[38;5;244m\002' rst='\001\033[0m\002'
  local p="${PWD/#$HOME/\~}" prefix=''
  if [[ $p == '~' ]]; then printf '%b~%b' "$dim" "$rst"; return; fi
  if   [[ $p == '~/'* ]]; then prefix='~'; p="${p:2}"
  elif [[ $p ==  '/'* ]]; then prefix='';  p="${p:1}"
  fi
  [[ -n $prefix ]] && printf '%b%s' "$dim" "$prefix"
  IFS='/' read -ra _pp <<< "$p"
  local i=0
  for part in "${_pp[@]}"; do
    [[ -z $part ]] && continue
    printf '%b/%b%s' "$dim" "\001\033[38;5;${_path_colors[$((i % nc))]}m\002" "$part"
    (( i++ ))
  done
  printf '%b' "$rst"
}

# Context color for user@host (computed once -- doesn't change within a session):
#   pastel purple (256-color 183) local non-root; magenta root; red SSH
#   (+[client-ip]); yellow [docker]
_ctx_color='38;5;183' _ctx_prefix=''
if [ -n "$SSH_CONNECTION" ]; then
  _ctx_color='31'
  _ctx_prefix="\[\e[33m\][${SSH_CONNECTION%% *}]\[\e[0m\] "
elif [ -e /.dockerenv ]; then
  _ctx_prefix='\[\e[33m\][docker]\[\e[0m\] '
elif [ -r /etc/debian_chroot ]; then
  _ctx_prefix="\[\e[33m\][chroot]\[\e[0m\] "
fi
[ "$(id -u)" = 0 ] && _ctx_color='35'

# Show user@host (\u@\h) only when remote (SSH); skip it on local sessions.
# To always show it, comment out the guard below and uncomment the line after.
_host_seg=''
[ -n "$SSH_CONNECTION" ] && _host_seg="\[\e[${_ctx_color}m\]\u@\h\[\e[0m\]:"
# _host_seg="\[\e[${_ctx_color}m\]\u@\h\[\e[0m\]:"

# cwd (per-segment color via _path_prompt); git segment; red [N] on failure;
# \$ -> '#' as root else plain '$'.
PS1="${_ctx_prefix}${_host_seg}"'$(_path_prompt)$(_git_prompt)$(_exit_code) \$ '

# --- fzf integration (only when the opt-in layer is installed) ----------------
# Adds fzf to PATH plus Ctrl-R / Ctrl-T / Alt-C widgets and completion.
# Installed/removed with `fzf-layer on` / `fzf-layer off`.
[ -f "${HOME}/.fzf.bash" ] && . "${HOME}/.fzf.bash"

# --- machine-local overrides (never committed) --------------------------------
[ -r "${HOME}/.bashrc.local" ] && . "${HOME}/.bashrc.local"
