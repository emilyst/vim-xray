scriptencoding utf-8

" require 7.4.1154 for v:true, v:false, etc.
" require nocompatible, syntax, conceal, autocmd, timers
if &compatible
      \ || v:version < 704
      \ || (v:version == 704 && !has('patch1154'))
      \ || !has('syntax')
      \ || !has('conceal')
      \ || !has('autocmd')
      \ || !has('timers')
      \ || exists('g:loaded_visual_whitespace')
  finish
endif

let g:loaded_visual_whitespace = v:true

if !exists('#InitializeVisualWhitespace')
  augroup InitializeVisualWhitespace
    autocmd!
    autocmd VimEnter * call drawing#InitializeVisualWhitespace()
  augroup END
endif
