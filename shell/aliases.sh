# shell/aliases.sh -- portable aliases for both zsh and bash.  POSIX sh only.

# --- ls: colorized + a detailed default listing (-l -h -A -F) -----------------
# GNU coreutils uses --color; BSD/macOS uses -G.  The actual colors come from
# $LS_COLORS / $LSCOLORS (set in common.sh).  `command ls` in l/la bypasses the
# ls alias so its flags don't stack on top of -lhAF.
if ls --color=auto >/dev/null 2>&1; then _ls_color='--color=auto'; else _ls_color='-G'; fi
alias ls="ls $_ls_color -lhAF"          # long, human sizes, almost-all (-A), classify (/ * @)
alias ll='ls'                            # ll == ls (muscle memory)
alias la="command ls $_ls_color -lhA"    # long + almost-all, without the classify suffixes
alias l="command ls $_ls_color"          # plain colorized listing
unset _ls_color

# --- grep colors --------------------------------------------------------------
if grep --color=auto -q . </dev/null 2>/dev/null; then
  alias grep='grep --color=auto'
  alias egrep='egrep --color=auto'
  alias fgrep='fgrep --color=auto'
fi

# --- navigation ---------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# --- git shortcuts (curated subset of oh-my-zsh's git plugin) -----------------
# NOTE: these follow oh-my-zsh conventions so muscle memory carries over.
#       In particular `gl` = git PULL (not log); use `glo`/`glog` for log.
git_current_branch() { git symbolic-ref --quiet --short HEAD 2>/dev/null \
  || git rev-parse --short HEAD 2>/dev/null; }

alias gst='git status'
alias gss='git status -s'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcmsg='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch --all'
alias gd='git diff'
alias gdca='git diff --cached'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gl='git pull'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias ggp='git push origin "$(git_current_branch)"'
alias gpsup='git push --set-upstream origin "$(git_current_branch)"'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias gm='git merge'
alias grb='git rebase'
alias gr='git remote'
alias gsta='git stash push'
alias gstp='git stash pop'
alias gcl='git clone'

# --- misc ---------------------------------------------------------------------
alias vi='vim'
alias e='${EDITOR:-vim}'
