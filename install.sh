#!/usr/bin/env bash
# install.sh -- symlink the dotfiles into $HOME.
#
# Safe and idempotent: any pre-existing real file is moved aside to
# <file>.predotfiles.bak before its symlink is created, and every link we make
# is recorded in ~/.dotfiles-manifest so uninstall.sh can reverse exactly this.
set -eu

# --- locate this repo, resolving symlinks ------------------------------------
src="${BASH_SOURCE[0]:-$0}"
while [ -h "$src" ]; do
  d="$(cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd)"
  src="$(readlink "$src")"
  case "$src" in /*) ;; *) src="$d/$src" ;; esac
done
REPO="$(cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd)"
HOMESRC="$REPO/home"
MANIFEST="$HOME/.dotfiles-manifest"

echo "dotfiles: installing from $REPO"
: > "$MANIFEST"   # start a fresh manifest

link_one() {
  _src="$1"; _dest="$2"
  mkdir -p "$(dirname "$_dest")"
  if [ -L "$_dest" ]; then
    rm -f "$_dest"                       # replace a stale symlink quietly
  elif [ -e "$_dest" ]; then
    echo "  backup  $_dest -> $(basename "$_dest").predotfiles.bak"
    mv "$_dest" "$_dest.predotfiles.bak"
  fi
  ln -s "$_src" "$_dest"
  echo "$_dest" >> "$MANIFEST"
  echo "  link    $_dest"
}

# --- mirror every file under home/ into $HOME (preserving any subdirs) --------
find "$HOMESRC" -mindepth 1 \( -type f -o -type l \) | while IFS= read -r f; do
  rel="${f#"$HOMESRC"/}"
  link_one "$f" "$HOME/$rel"
done

# --- supporting state ---------------------------------------------------------
mkdir -p "$HOME/.vim/undo"               # used by 'undofile' in .vimrc
# Make the cheatsheet reachable from inside Vim (\?), independent of cwd.
ln -sf "$REPO/shell/cheatsheet.md" "$HOME/.vim/cheatsheet.md"
echo "$HOME/.vim/cheatsheet.md" >> "$MANIFEST"

cat <<EOF

Done.  Open a new shell (or 'exec \$SHELL') to pick up the shell config.
  - shells now use vi mode + completion (see 'cheat' for keys)
  - vim is builtin-only; run 'lsp on' to add the optional LSP layer
  - 'uninstall.sh' reverses everything recorded in $MANIFEST
EOF
