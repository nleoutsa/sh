"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Optional LSP layer for the builtin-first vimrc.
"
" Sourced from ~/.vimrc only when ~/.vim/lsp.vim exists, which `bin/lsp on`
" creates.  `bin/lsp off` deletes it and the plugins, returning Vim to its
" plugin-free base.  Stack: vim-lsp + asyncomplete (+ vim-lsp-settings, which
" auto-installs language servers via :LspInstallServer).
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Bail out gracefully if the plugins aren't actually on the runtimepath yet.
if empty(globpath(&packpath, 'pack/lsp/start/vim-lsp'))
  finish
endif

" --- asyncomplete --------------------------------------------------------------
let g:asyncomplete_auto_popup = 1
" Feed asyncomplete's popup through Vim's normal completion UI.
let g:asyncomplete_popup_delay = 100

" --- vim-lsp diagnostics & UI --------------------------------------------------
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1          " show diagnostic for line in cmdline
let g:lsp_diagnostics_virtual_text_enabled = 0 " keep the buffer uncluttered
let g:lsp_document_highlight_enabled = 0
let g:lsp_fold_enabled = 0

" --- buffer-local keymaps, set only when a server actually attaches -----------
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete           " <C-x><C-o> -> LSP completion
  setlocal signcolumn=yes
  " Navigation / introspection (leader-prefixed, so nothing builtin is shadowed;
  " gd/K are remapped buffer-locally only where a server is attached).
  nnoremap <buffer> gd        <plug>(lsp-definition)
  nnoremap <buffer> gr        <plug>(lsp-references)
  nnoremap <buffer> gi        <plug>(lsp-implementation)
  nnoremap <buffer> gy        <plug>(lsp-type-definition)
  nnoremap <buffer> K         <plug>(lsp-hover)
  nnoremap <buffer> <leader>rn <plug>(lsp-rename)
  nnoremap <buffer> <leader>a  <plug>(lsp-code-action)
  nnoremap <buffer> [g        <plug>(lsp-previous-diagnostic)
  nnoremap <buffer> ]g        <plug>(lsp-next-diagnostic)
  nnoremap <buffer> <leader>f  <plug>(lsp-document-format)
endfunction

augroup lspSetup
  autocmd!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
