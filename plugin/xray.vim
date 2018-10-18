scriptencoding utf-8

" require 7.4.1154 for v:true, v:false, etc.
" require nocompatible, visual, syntax, autocmd, timers
if &compatible
      \ || !has('patch-7.4.1154')
      \ || !has('visual')
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
