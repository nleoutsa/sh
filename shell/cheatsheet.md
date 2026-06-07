# Cheatsheet  (`cheat` to browse,  `cheat <term>` to filter,  `\?` inside Vim)

Each line is one tip.  Search by keyword: `cheat resize`, `cheat tag`, `cheat split`.

## Vim :: windows & splits
:split / :sp        horizontal split (same file)
:vsplit / :vs       vertical split (same file)
:split / :sp <file> split and open <file>
Ctrl-w s            split horizontally
Ctrl-w v            split vertically
Ctrl-w h/j/k/l      move to window left/down/up/right
Ctrl-w w            cycle to next window
Ctrl-w q            close current window
Ctrl-w o            close all OTHER windows (only)
Ctrl-w =            make all windows equal size
Ctrl-w +            grow window height by 1   (Ctrl-w 10+ for 10)
Ctrl-w -            shrink window height by 1
Ctrl-w >            widen window             (Ctrl-w 10> for 10)
Ctrl-w <            narrow window
Ctrl-w _            maximize height
Ctrl-w |            maximize width
:resize / :res 20   set current window height to 20 rows
:vertical resize / :vert res 80   set current window width to 80 columns
Ctrl-w r            rotate windows
Ctrl-w T            move current window to its own new tab

## Vim :: open file under cursor
gf                  open file whose name is under the cursor
gF                  open file under cursor, jump to line number after it
Ctrl-w f            open file under cursor in a new split
Ctrl-w gf           open file under cursor in a new tab
:set path+=**       (already set) make gf / :find search recursively

## Vim :: fuzzy navigation (no plugins)
:find / :fin <name><Tab>   fuzzy-open a file by name (recursive via path+=**)
:buffer / :b <name><Tab>   jump to an open buffer by partial name
:ls / :buffers      list open buffers          (mapped to \b)
Ctrl-^              switch to the previous (alternate) buffer
:edit / :e <file>   edit a file
gd                  go to local definition of word under cursor
*                   search for word under cursor (next)

## Vim :: tags / code introspection (ctags)
:MakeTags           (re)build a tags file for the project   (custom command)
Ctrl-]              jump to definition under cursor
g]                  list all matching tags (pick one)
Ctrl-t              jump back up the tag stack
:tnext / :tn        next matching tag        (:tprev / :tp = previous)
:tjump / :tj <name> jump to tag, prompt if several match

## Vim :: completion (insert mode, Ctrl-x family)
Ctrl-x Ctrl-o       omni completion (language aware)
Ctrl-n / Ctrl-p     next / prev keyword from buffers + tags
Ctrl-x Ctrl-f       file-path completion
Ctrl-x Ctrl-l       whole-line completion
Ctrl-x Ctrl-]       tag completion
Ctrl-x Ctrl-n       keyword completion (current file only)

## Vim :: file tree (netrw)
\e                  toggle the left-hand file tree   (custom map: :Lexplore)
Enter               open file / expand dir (in netrw)
-                   go up a directory (in netrw)
%                   create a new file (in netrw)
d                   create a new directory (in netrw)
D                   delete file/dir under cursor (in netrw)

## Vim :: buffers, marks, folds, misc
:bnext / :bn        next buffer              (:bprev / :bp = previous)
:bdelete / :bd      delete (close) current buffer
ma                  set mark 'a' at cursor
`a                  jump to mark 'a' (exact spot);  'a jumps to its line
``                  jump back to position before the last jump
zf / zo / zc        create / open / close a fold
za                  toggle fold
zR / zM             open all / close all folds
.                   repeat the last change
q<letter>           record a macro into register <letter>;  q to stop
@<letter>           play the macro;  @@ replays the last one
\<Space>            clear search highlight (custom map)
\?                  open this cheatsheet in Vim (custom map; :Cheat [term])
:nohlsearch / :noh  clear search highlight

## Zsh / Bash :: vi line-editing mode
Esc                 leave insert mode -> NORMAL (vi command) mode
i / a / A / I       enter insert mode (before/after cursor, end/start of line)
0 / $               jump to start / end of line (NORMAL mode)
w / b / e           word motions (NORMAL mode)
dw / dd / cw        delete word / kill line / change word
v                   enter visual-mode (NORMAL mode)
vv                  edit the current command line in $EDITOR (NORMAL mode)
/text  then n       search history backward, n for next match (NORMAL mode)
k / j               previous / next history (NORMAL mode)
Ctrl-a / Ctrl-e     start / end of line          (restored in insert mode)
Ctrl-r              reverse-search history       (restored in insert mode)
Ctrl-p / Ctrl-n     previous / next history      (restored in insert mode)
Ctrl-w              delete previous word
Ctrl-u              delete to start of line
Up / Down           search history by the prefix already typed

## Shell :: git aliases (oh-my-zsh style)
gst                 git status
gss                 git status -s
ga                  git add
gaa                 git add --all
gc                  git commit -v
gca                 git commit -v -a
gcmsg               git commit -m
gco                 git checkout
gcb                 git checkout -b
gb                  git branch
gba                 git branch --all
gd                  git diff
gdca                git diff --cached
gf                  git fetch
gfa                 git fetch --all --prune
gl                  git PULL  (not log!)
gp                  git push
gpf                 git push --force-with-lease
ggp                 git push origin <current-branch>
gpsup               git push --set-upstream origin <current-branch>
glo                 git log --oneline --decorate
glog                git log --oneline --decorate --graph
gm                  git merge
grb                 git rebase
gr                  git remote
gsta                git stash push
gstp                git stash pop
gcl                 git clone

## Shell :: navigation & jobs
cd -                go to the previous directory
take <dir>          mkdir -p <dir> and cd into it
d                   list recent directories (auto-pushd stack)
1 .. 9              jump to the Nth directory in that stack
pushd / popd        directory stack
Ctrl-l              clear the screen
Ctrl-z              suspend the foreground job;  fg to resume,  bg to background
jobs                list background jobs
!!                  the previous command (e.g. `sudo !!`)
!$                  last argument of the previous command

## tmux (if installed)
tmux new -s name    start a named session
tmux a -t name      attach to a session
Ctrl-b d            detach from session
Ctrl-b "            split pane horizontally
Ctrl-b %            split pane vertically
Ctrl-b o            cycle panes
Ctrl-b arrow        move between panes
Ctrl-b c            new window
Ctrl-b n / p        next / previous window
Ctrl-b [            scroll/copy mode (q to quit)

## This dotfiles repo
install.sh          symlink configs into $HOME (backs up existing files)
uninstall.sh        remove the symlinks, restore backups
lsp on | off        add / remove the optional Vim LSP layer (single command)
lsp status          show whether the LSP layer is installed
fzf-layer on | off  add / remove a self-contained fzf install (single command)
cheat <term>        you're looking at it
