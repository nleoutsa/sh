"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Portable, builtin-first vimrc.  No plugins required.
" An optional LSP layer (see `bin/lsp on`) is sourced at the very bottom only
" when it has been installed.  Nothing here depends on it.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" START $VIMRUNTIME/defaults.vim (sortof)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use Vim settings, rather than Vi settings
" This must be first, because it changes other options as a side effect.
" Avoid side effects when it was already reset.
if &compatible
  set nocompatible
endif

" When the +eval feature is missing, the set command above will be skipped.
" Use a trick to reset compatible only when the +eval feature is missing.
silent! while 0
  set nocompatible
silent! endwhile

" Allow backspacing over everything in insert mode.
set backspace=indent,eol,start

set history=200		" keep 200 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set wildmenu		" display completion matches in a status line

set ttimeout		" time out for key codes
set ttimeoutlen=100	" wait up to 100ms after Esc for special key

" Show @@@ in the last line if it is truncated.
set display=truncate

" Show a few lines of context around the cursor.  Note that this makes the
" text scroll if you mouse-click near the start or end of the window.
set scrolloff=5

" Do incremental searching when it's possible to timeout.
if has('reltime')
  set incsearch
endif

" Do not recognize octal numbers for Ctrl-A and Ctrl-X, most users find it
" confusing.
set nrformats-=octal

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries.
if has('win32')
  set guioptions-=t
endif

" Don't use Q for Ex mode, use it for formatting.  Except for Select mode.
" Revert with ":unmap Q".
map Q gq
sunmap Q

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
" Revert with ":iunmap <C-U>".
inoremap <C-U> <C-G>u<C-U>

" Only do this part when Vim was compiled with the +eval feature.
if 1

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  " Revert with ":filetype off".
  filetype plugin indent on

  " Put these in an autocmd group, so that you can revert them with:
  " ":autocmd! vimStartup"
  augroup vimStartup
    autocmd!

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid, when inside an event handler
    " (happens when dropping a file on gvim), for a commit or rebase message
    " (likely a different one than last time), and when using xxd(1) to filter
    " and edit binary files (it transforms input files back and forth, causing
    " them to have dual nature, so to speak)
    autocmd BufReadPost *
      \ let line = line("'\"")
      \ | if line >= 1 && line <= line("$") && &filetype !~# 'commit'
      \      && index(['xxd', 'gitrebase'], &filetype) == -1
      \ |   execute "normal! g`\""
      \ | endif

  augroup END

  " Quite a few people accidentally type "q:" instead of ":q" and get confused
  " by the command line window.  Give a hint about how to get out.
  " If you don't like this you can put this in your vimrc:
  " ":autocmd! vimHints"
  augroup vimHints
    au!
    autocmd CmdwinEnter *
	  \ echohl Todo |
	  \ echo gettext('You discovered the command-line window! You can close it with ":q".') |
	  \ echohl None
  augroup END

endif

" Switch syntax highlighting on when the terminal has colors or when using the
" GUI (which always has colors).
if &t_Co > 2 || has("gui_running")
  " Revert with ":syntax off".
  syntax on

  " I like highlighting strings inside C comments.
  " Revert with ":unlet c_comment_strings".
  let c_comment_strings=1
endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
" Revert with: ":delcommand DiffOrig".
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If set (default), this may break plugins (but it's backward
  " compatible).
  set nolangremap
endif

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" END $VIMRUNTIME/defaults.vim (sortof)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GENERAL UX
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set number                        " absolute line numbers
set norelativenumber              " no relative numbers (':set rnu' to toggle on)
set hidden                        " switch buffers without saving
set laststatus=2                  " always show the status line
set splitright splitbelow         " new splits open where the eye expects
set signcolumn=auto               " only take the gutter when something needs it
set updatetime=300                " snappier swap/CursorHold (also helps LSP layer)
set noerrorbells novisualbell     " quiet
set mouse=                        " mouse off by default; ':set mouse=a' to enable

" Sensible default indentation; per-language overrides live in the ftplugin
" autocmds below.
set tabstop=4 shiftwidth=4 expandtab smarttab autoindent

" Keep working backups/undo out of the project tree and persistent across runs.
set undolevels=10000              " lower this if a machine is RAM-starved
let s:undodir = expand('~/.vim/undo')
if !isdirectory(s:undodir)
  silent! call mkdir(s:undodir, 'p', 0700)
endif
let &undodir = s:undodir
let &backupdir = s:undodir
let &directory = s:undodir . '//'   " swap files; // = full path in name


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CURSOR SHAPE PER MODE
" The terminal cursor has no distinct colour under many colorschemes, so the
" current mode is invisible.  Signal it with the cursor *shape* instead, via
" the DECSCUSR sequence (CSI Ps SP q) that all modern terminals understand:
"     2 = steady block      -> normal / visual
"     6 = steady bar        -> insert      (t_SI)
"     4 = steady underline  -> replace     (t_SR)
" Use 1/5/3 instead of 2/6/4 for the blinking variants.
" Guarded to terminal Vim (the GUI draws its own cursor) and wrapped in the
" tmux/screen passthrough DCS so a multiplexer doesn't swallow the escape.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if !has('gui_running')
  if exists('$TMUX')
    let &t_SI = "\ePtmux;\e\e[6 q\e\\"
    let &t_SR = "\ePtmux;\e\e[4 q\e\\"
    let &t_EI = "\ePtmux;\e\e[2 q\e\\"
  else
    let &t_SI = "\e[6 q"
    let &t_SR = "\e[4 q"
    let &t_EI = "\e[2 q"
  endif
  " Vim emits t_EI only on a mode *transition*, so force a block at startup
  " (and after :suspend), and restore one on exit so the shell prompt isn't
  " left with a stray bar/underline cursor.
  augroup CursorShape
    autocmd!
    autocmd VimEnter,VimResume * silent execute "!printf '\e[2 q'" | redraw!
    autocmd VimLeave           * silent execute "!printf '\e[2 q'"
  augroup END
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SEARCH
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set ignorecase                    " case-insensitive search ...
set smartcase                     " ... unless the pattern has an uppercase char
" <leader> (\) + space clears the last search highlight.
nnoremap <silent> <leader><Space> :nohlsearch<CR>

" Use ripgrep for :grep when available (builtin :grep, just a faster backend).
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case
  set grepformat=%f:%l:%c:%m
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COMPLETION (all builtin: i_CTRL-X family)
"   <C-x><C-o>  omni (semantic-ish, language aware)
"   <C-n>/<C-p> keyword completion from open buffers/tags
"   <C-x><C-f>  filename completion
"   <C-x><C-l>  whole-line completion
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set completeopt=menuone,noinsert,popup
set infercase                     " adjust case of keyword matches
set pumheight=12                  " cap the completion popup height
set shortmess+=c                  " don't clutter the message line with match counts


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FUZZY-ISH FILE NAVIGATION (no plugins, just 'path' + wildmenu)
"   :find foo<Tab>   fuzzy-open by name (recursive thanks to path+=**)
"   :b foo<Tab>      jump to an open buffer by partial name
"   gf               open the file under the cursor
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set path+=**                      " :find searches recursively from cwd
set wildmode=longest:full,full    " complete longest common, then cycle
if has('patch-8.2.4325') || has('nvim')
  set wildoptions=pum             " show wildmenu as a popup when supported
endif
set wildignorecase
set wildignore+=*.o,*.obj,*.pyc,*.class,*.so,*.dylib
set wildignore+=*/node_modules/*,*/.git/*,*/dist/*,*/build/*,*/.venv/*,*/__pycache__/*


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TAGS  (builtin code introspection via ctags)
"   :MakeTags        (re)generate a tags file for the project
"   <C-]>            jump to definition under cursor   (builtin)
"   g]               list all matching tags            (builtin)
"   <C-t>            jump back up the tag stack         (builtin)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Search ./tags first, then walk up toward the filesystem root (the ';').
set tags=./tags;,tags
command! MakeTags call s:MakeTags()
function! s:MakeTags() abort
  if !executable('ctags')
    echohl WarningMsg | echo 'ctags not found on PATH' | echohl None
    return
  endif
  call system('ctags -R --exclude=.git --exclude=node_modules --exclude=dist --exclude=build .')
  echo 'tags written'
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PER-LANGUAGE SETTINGS
" Indentation conventions + an omnifunc fallback so <C-x><C-o> always does
" *something* even without the LSP layer (syntaxcomplete uses the syntax file).
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup ftPrefs
  autocmd!
  " 2-space: web languages
  autocmd FileType javascript,javascriptreact,typescript,typescriptreact,json,html,css,scss,yaml
        \ setlocal tabstop=2 shiftwidth=2 expandtab
  " 4-space: python, C, C++
  autocmd FileType python,c,cpp
        \ setlocal tabstop=4 shiftwidth=4 expandtab
  " Makefiles need real tabs.
  autocmd FileType make setlocal noexpandtab
  " Give every buffer a working omnifunc when nothing else set one.
  autocmd FileType *
        \ if &omnifunc ==# '' |
        \   setlocal omnifunc=syntaxcomplete#Complete |
        \ endif
augroup END


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FILE TREE (netrw, builtin)  ---  \e toggles a left-hand tree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>e :Lexplore<CR>
" let g:netrw_banner = 0          " hide the banner
let g:netrw_liststyle = 3       " tree view
let g:netrw_winsize = 25        " 25% width
" let g:netrw_keepdir = 0         " sync browsing dir with working dir

" Open the Lexplore tree automatically on startup, then return focus to the
" editing window.  Skipped for: diff mode, special buffers (stdin, etc.),
" directory launches (netrw is already showing), and git commit/rebase edits.
function! s:StartTree() abort
  if &diff || !empty(&buftype) || &filetype =~# 'netrw\|commit\|gitrebase'
    return
  endif
  Lexplore
  wincmd p                        " hand focus back to the file you opened
endfunction

augroup AutoLexplore
  autocmd!
  autocmd VimEnter * call s:StartTree()
augroup END


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CONVENIENCE MAPS  (all on the unused <leader>/\ prefix -- no builtins shadowed)
"   \w  write      \b  buffer list      \?  cheatsheet      :Cheat [term]
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>w :write<CR>
nnoremap <leader>b :ls<CR>:b<Space>

" :Cheat [term]  /  \?  -- open the shared cheatsheet (~/.vim/cheatsheet.md).
" When fzf is available it launches the real fuzzy `cheat` picker in a :terminal
" split (same experience as the shell, with a live preview); otherwise it opens
" a scratch buffer, fuzzy-filtered by [term] via matchfuzzy() when one is given.
command! -nargs=? Cheat call s:Cheat(<q-args>)
nnoremap <silent> <leader>? :Cheat<CR>

function! s:Cheat(query) abort
  let l:f = expand('~/.vim/cheatsheet.md')
  if !filereadable(l:f)
    echohl WarningMsg | echo 'cheatsheet not found at ' . l:f | echohl None
    return
  endif
  " Preferred: interactive fuzzy finder via the `cheat` script + fzf, run in a
  " terminal split (vim's :terminal gives fzf the pty it needs).
  if has('terminal') && executable('cheat') && executable('fzf')
    let l:cmd = empty(a:query) ? ['cheat'] : ['cheat', a:query]
    botright split
    " term_finish=close: when fzf exits -- whether you pick a line or press
    " <Esc> to abort -- the job ends and this terminal window closes itself.
    call term_start(l:cmd, #{curwin: v:true, term_finish: 'close'})
    return
  endif
  call s:CheatBuffer(l:f, a:query)
endfunction

" Builtin fallback: scratch buffer, optionally fuzzy-filtered with matchfuzzy().
function! s:CheatBuffer(file, query) abort
  let l:lines = readfile(a:file)
  if !empty(a:query) && exists('*matchfuzzy')
    let l:lines = matchfuzzy(l:lines, a:query)
    if empty(l:lines)
      let l:lines = ['(no matches for "' . a:query . '")']
    endif
  endif
  botright new
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted filetype=markdown
  call setline(1, l:lines)
  call cursor(1, 1)
  setlocal nomodifiable
  " Close the cheatsheet window with either q or <Esc>.
  nnoremap <buffer> <silent> q :close<CR>
  nnoremap <buffer> <silent> <Esc> :close<CR>
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OPT-IN LSP LAYER
" Sourced only when `bin/lsp on` has installed it.  Base config stays
" plugin-free if this file is absent.  `bin/lsp off` removes it again.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if filereadable(expand('~/.vim/lsp.vim'))
  source ~/.vim/lsp.vim
endif
