#!/usr/bin/env bash
# uninstall.sh -- reverse install.sh.
#
# Removes only the symlinks we created (those pointing back into this repo),
# restores any <file>.predotfiles.bak we moved aside, and leaves the repo clone
# itself untouched.  The optional LSP layer is managed separately: 'lsp off'.
set -eu

# --- locate this repo, resolving symlinks ------------------------------------
src="${BASH_SOURCE[0]:-$0}"
while [ -h "$src" ]; do
  d="$(cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd)"
  src="$(readlink "$src")"
  case "$src" in /*) ;; *) src="$d/$src" ;; esac
done
REPO="$(cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd)"
MANIFEST="$HOME/.dotfiles-manifest"

if [ ! -r "$MANIFEST" ]; then
  echo "uninstall: no manifest at $MANIFEST -- nothing recorded to remove." >&2
  exit 1
fi

echo "dotfiles: uninstalling (per $MANIFEST)"
while IFS= read -r dest; do
  [ -n "$dest" ] || continue
  if [ -L "$dest" ]; then
    target="$(readlink "$dest")"
    case "$target" in
      "$REPO"/*) rm -f "$dest"; echo "  unlink   $dest" ;;
      *)         echo "  skip     $dest (not ours: -> $target)" ;;
    esac
  fi
  if [ -e "$dest.predotfiles.bak" ]; then
    mv "$dest.predotfiles.bak" "$dest"
    echo "  restore  $dest"
  fi
done < "$MANIFEST"

rm -f "$MANIFEST"
echo
echo "Done.  Repo left intact at $REPO."
if [ -d "$HOME/.vim/pack/lsp" ]; then
  echo "Note: the optional LSP layer is still installed -- run 'lsp off' to remove it."
fi
