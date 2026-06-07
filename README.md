# sh — portable shell & vim dotfiles

Builtin-first configuration for Vim, zsh, and bash, designed to be **set up and
torn down fast** on any unix/linux box or VM you SSH into. No runtime
dependencies in the base layer; full code intelligence is an opt-in you add (and
remove) with a single command.

## Quick start

```sh
git clone <this-repo> ~/sh      # clone anywhere; the config self-locates
cd ~/sh
./install.sh                    # symlinks configs into $HOME, backing up existing ones
exec $SHELL                     # reload your shell
```

Remove it all just as fast:

```sh
~/sh/uninstall.sh               # removes our symlinks, restores backups, repo untouched
```

## What you get

- **Vim** (`home/.vimrc`) — pure builtins, zero plugins:
  - completion via `<C-x><C-o>` (omni), `<C-n>/<C-p>`, `<C-x><C-f>` (files),
    `<C-x><C-l>` (lines)
  - plugin-free fuzzy file open: `:find name<Tab>` (recursive `path+=**`),
    `:b name<Tab>`, `gf`
  - tags-based jumps: `:MakeTags` then `<C-]>` / `g]` / `<C-t>`
  - per-language indentation for JS/TS/Python/C/C++, netrw file tree on `\e`
  - **no builtin keys are clobbered** (see "Key bindings" below)
- **zsh & bash** — vi editing mode with the high-value emacs keys restored in
  insert mode (`^A` `^E` `^R`, plus `^P`/`^N` in zsh), case-insensitive menu
  completion, big shared history. Plus oh-my-zsh-style conveniences:
  - **context-aware prompt**: green `user@host` locally, **red + `[client-ip]`
    over SSH**, magenta as root, `[docker]`/`[chroot]` prefixes; yellow path;
    git segment **green=clean / yellow=dirty** with `+`staged `*`unstaged
    `?`untracked; a red `[N]` when the last command exits nonzero.
  - `take` (mkdir+cd), `auto_pushd` dir stack (`d`, then `1`–`9`),
    `# comments` at the prompt, and a **curated git alias set** (`gst gco gcb
    gaa gcmsg gp gd glo …`). Note: following oh-my-zsh, **`gl` = `git pull`**
    (use `glo`/`glog` for log).
  - `vv` (normal mode) opens the command line in `$EDITOR`; `v` stays visual-mode.
- **`cheat`** — quick command lookup. `cheat` to fuzzy-browse (fzf when
  present, pager otherwise), `cheat <term>` to filter. Same content opens in
  Vim with `\?`.

## Optional LSP layer (code intelligence)

The base Vim is intentionally builtin-only. When you want go-to-definition,
hover, diagnostics, and rename on a machine you'll be on for a while:

```sh
lsp on        # clones vim-lsp + asyncomplete + vim-lsp-settings (pure VimScript)
              # then in Vim: :LspInstallServer  (per language)
lsp status    # what's installed
lsp off       # removes the plugins, config, and downloaded servers — one command
```

Everything the layer touches lives in exactly three paths
(`~/.vim/pack/lsp/`, `~/.vim/lsp.vim`, `~/.local/share/vim-lsp-settings/`), so
`lsp off` is total. Servers are installed per language with `:LspInstallServer`:
C/C++ uses `clangd`, TS/JS uses `typescript-language-server` (needs `node`),
Python uses `pyright` or `pylsp`.

## Key bindings worth knowing

These shell keys are **changed** by vi mode (everything else keeps its emacs
default in insert mode):

| Key | Normal (vi command) mode | Insert mode |
|-----|--------------------------|-------------|
| `Esc` | enter command mode | — |
| `k` / `j` | history prev / next | — |
| `v` | edit command line in `$EDITOR` | — |
| `^A` `^E` `^R` `^P` `^N` | — | restored to emacs behavior |

In Vim, only the unused `\` (leader) prefix and a couple of buffer-local LSP
maps are bound; builtin keys like `gp`, `<C-l>`, `<C-]>`, `<C-w>…` are left
alone. Run `cheat` for the full list.

## Layout

```
install.sh / uninstall.sh   symlink in / out (with backups + a manifest)
bin/lsp                     optional Vim LSP layer: on | off | status
bin/fzf-layer               optional self-contained fzf: on | off | status
bin/cheat                   quick command lookup
home/                       files symlinked into $HOME (.vimrc .zshrc .bashrc …)
shell/                      fragments sourced by both shells + cheatsheet.md
vim/lsp.vim                 the opt-in LSP config (only sourced when installed)
```

Machine-specific tweaks go in `~/.zshrc.local` / `~/.bashrc.local` (sourced if
present, never committed).

## Recommended tools (optional)

The config works with none of these — it detects them and degrades gracefully.
Each adds a nicety; install them where you'll stay a while.

| Tool | Buys you | Without it |
|------|----------|------------|
| `fzf` | fuzzy `cheat`, `Ctrl-R`/`Ctrl-T`/`Alt-C` | `cheat` uses grep + pager; builtin history search |
| `ripgrep` (`rg`) | fast Vim `:grep` | Vim falls back to system `grep` |
| `universal-ctags` | `:MakeTags` + `<C-]>` jumps in base Vim | `:MakeTags` warns; no tag jumps (use `lsp on` for richer nav) |

**fzf** has a clean self-contained install/removal, so it's wrapped:

```sh
fzf-layer on      # clones + builds fzf under ~/.fzf, wires up the shells
fzf-layer off     # removes ~/.fzf and its integration files — one command
```

**ripgrep** and **universal-ctags** are system binaries with no clean
self-contained removal, so they're left to your package manager:

```sh
# macOS
brew install ripgrep universal-ctags
# Debian/Ubuntu
sudo apt install ripgrep universal-ctags
# Fedora
sudo dnf install ripgrep ctags
```

On a machine where you'd rather install nothing, skip them: base Vim still does
fuzzy `:find`/`gf`/buffer navigation, and `lsp on` gives go-to-definition that
exceeds ctags anyway.

## Notes

- Old macOS bash (3.2) is supported; `.inputrc` directives it doesn't understand
  are ignored harmlessly.
