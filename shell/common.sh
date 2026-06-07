# shell/common.sh -- shared exports for both zsh and bash.
# Sourced after $DOTFILES is resolved by the calling rc file.  POSIX sh only.

# Homebrew bootstrap: macOS only sources brew's env in login shells (~/.zprofile),
# so non-login interactive shells (tmux, IDE terminals) lose brew tools like fzf.
# Put brew on PATH here if it isn't already, so every interactive shell matches.
# Guarded + portable: checks the standard locations, no-op when brew is absent.
if ! command -v brew >/dev/null 2>&1; then
  for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew \
               /home/linuxbrew/.linuxbrew/bin/brew; do
    if [ -x "$_brew" ]; then
      eval "$("$_brew" shellenv)"
      break
    fi
  done
  unset _brew
fi

# Put this repo's bin/ (cheat, lsp, ...) on PATH, without duplicating it.
case ":${PATH}:" in
  *":${DOTFILES}/bin:"*) ;;
  *) PATH="${DOTFILES}/bin:${PATH}" ;;
esac
export PATH

# Editor: prefer vim everywhere.
export EDITOR=vim
export VISUAL=vim

# Pager: prefer less with sensible flags (-R keeps colors, -F quits if it fits,
# -X leaves the screen contents after quitting); fall back to more if absent.
if command -v less >/dev/null 2>&1; then
  export PAGER=less
  export LESS='-R -F -X'
else
  export PAGER=more
fi

# --- colors for ls and common tools ------------------------------------------
# A readable scheme following the de-facto dircolors conventions.  The default
# directory color is a dim blue that's hard to read on a dark background, so
# directories are bumped to BOLD BLUE (still conventional, but legible);
# symlinks bold cyan, executables bold green, archives red, media magenta.
export CLICOLOR=1   # macOS/BSD: enable colorized ls output
# BSD/macOS ls reads LSCOLORS (11 pairs: dir, symlink, socket, pipe, exec, ...).
# Caps = bold/bright.  Ex=bold blue dir, Gx=bold cyan link, Cx=bold green exec.
export LSCOLORS='ExGxcxdxCxegedabagacad'
# GNU ls reads LS_COLORS.
export LS_COLORS='rs=0:di=1;34:ln=1;36:or=1;31:mi=1;31:pi=33:so=1;35:bd=1;33:cd=1;33:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=1;32:*.tar=1;31:*.tgz=1;31:*.zip=1;31:*.gz=1;31:*.bz2=1;31:*.xz=1;31:*.7z=1;31:*.rar=1;31:*.jpg=1;35:*.jpeg=1;35:*.png=1;35:*.gif=1;35:*.svg=1;35:*.mp4=1;35:*.mkv=1;35:*.mp3=36:*.wav=36:*.pdf=1;31:*.json=33:*.yml=33:*.yaml=33'

# Colorize man pages (via less's termcap hooks) -- a common, builtin-only trick.
LESS_TERMCAP_md=$(printf '\033[1;34m'); export LESS_TERMCAP_md   # bold -> blue (headings)
LESS_TERMCAP_me=$(printf '\033[0m');    export LESS_TERMCAP_me   # end bold/blink
LESS_TERMCAP_us=$(printf '\033[1;32m'); export LESS_TERMCAP_us   # underline -> green (args)
LESS_TERMCAP_ue=$(printf '\033[0m');    export LESS_TERMCAP_ue   # end underline
LESS_TERMCAP_so=$(printf '\033[1;33m'); export LESS_TERMCAP_so   # standout -> yellow (prompt)
LESS_TERMCAP_se=$(printf '\033[0m');    export LESS_TERMCAP_se   # end standout

# Color grep matches by default if the implementation supports it (set via the
# aliases in aliases.sh); GREP_COLORS tweaks the match color.
export GREP_COLORS='ms=1;31'   # matching text -> bold red

# Where the cheatsheet lives, so `cheat` works regardless of cwd.
export DOTFILES_CHEATSHEET="${DOTFILES}/shell/cheatsheet.md"

# take -- mkdir -p then cd into it (a handy oh-my-zsh staple). Works in sh/zsh/bash.
take() {
  mkdir -p -- "$1" && cd -- "$1"
}
