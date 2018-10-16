scriptencoding utf-8

" require 7.4.1154 for v:true, v:false, etc.
" require nocompatible, syntax, conceal, autocmd, timers
if &compatible
      \ || v:version < 704
      \ || (v:version == 704 && !has('patch1154'))
      \ || !has('syntax')
      \ || !has('autocmd')
      \ || !has('timers')
      \ || exists('g:loaded_xray')
  finish
endif

let g:loaded_xray = v:true

if !exists('#InitializeXray')
  augroup InitializeXray
    autocmd!
    autocmd VimEnter * call xray#control#StartXray()
  augroup END
endif
