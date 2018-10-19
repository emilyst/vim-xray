scriptencoding utf-8

" this seems fragile, I'm gonna not use this
function! xray#highlight#AreWhitespaceHighlightPatternsConfigured() abort
  if get(b:, 'special_key_details', xray#highlight#GetHighlightGroupDetails('SpecialKey'))
        \ !=? xray#highlight#GetHighlightGroupDetails('SpecialKey')
    return v:true
  endif

  if get(b:, 'non_text_details', xray#highlight#GetHighlightGroupDetails('NonText'))
        \ !=? xray#highlight#GetHighlightGroupDetails('NonText')
    return v:true
  endif

  return v:false
endfunction

function! xray#highlight#SaveOriginalHighlights() abort
  let b:special_key_details = xray#highlight#GetHighlightGroupDetails('SpecialKey')
  let b:non_text_details    = xray#highlight#GetHighlightGroupDetails('NonText')
endfunction

function! xray#highlight#RestoreOriginalHighlights() abort
  execute 'silent highlight SpecialKey '
        \ .  get(b:, 'special_key_details', xray#highlight#GetHighlightGroupDetails('SpecialKey'))
  execute 'silent highlight NonText    '
        \ .  get(b:, 'non_text_details',    xray#highlight#GetHighlightGroupDetails('NonText'))

  unlet b:special_key_details
  unlet b:non_text_details
endfunction

" At the time this is called, my use of the "bg" keyword triggers Vim to
" look at the background used for the 'Normal' highlight group, if it
" can find it; thereafter, it always uses the same color, even if the
" colorscheme changes.
"
" Occasionally, Vim even seems to get this wrong (xterm, urxvt).
"
" Finally, if 'Normal' has no background set (such as for the default
" colorscheme), we basically have no idea how to find out what the
" background is, and there's no way we can succeed, so there is logic in
" place to preclude us getting here in that case.
function! xray#highlight#ConfigureVisualHighlights() abort
  if xray#highlight#IsGuiOrTrueColorTerm()
    let l:visual_highlight = 'gui=bold guibg=bg guifg=bg'
  elseif xray#highlight#IsColorTerm()
    let l:visual_highlight = 'cterm=bold ctermbg=bg ctermfg=bg'
  endif

  execute 'silent highlight SpecialKey ' . l:visual_highlight
  execute 'silent highlight NonText    ' . l:visual_highlight
endfunction

function! xray#highlight#GetHighlightGroupDetails(group) abort
  redir => l:highlight_output
  execute 'silent highlight ' . a:group
  redir END

  " recurse to find actual highlight group if needed
  while l:highlight_output =~ 'links to'
    let l:index        = stridx(l:highlight_output, 'links to') + len('links to')
    let l:linked_group = strpart(l:highlight_output, l:index + 1)

    redir => l:highlight_output
    execute 'silent highlight ' . l:linked_group
    redir END
  endwhile

  " extract highlight group details
  return substitute(matchlist(l:highlight_output, '\<xxx\>\s\+\(.*\)')[1], '\n', ' ', 'g')
endfunction

" implies cterm highlight args are used
function! xray#highlight#IsSupportedColorTerm() abort
  " very unlikely to change during a Vim session
  if exists('g:xray_use_cterm')
    return g:xray_use_cterm
  endif

  let g:xray_use_cterm = v:false

  if has('terminfo')
    if &term =~ 'gui'
      let g:xray_use_cterm = v:false
    elseif (&term =~ '\(xterm\|color\)') && exists('&t_Co') && &t_Co >= 8
      let g:xray_use_cterm = v:true
    endif
  endif

  return g:xray_use_cterm
endfunction

" implies gui highlight args are used
function! xray#highlight#IsGuiOrTrueColorTerm() abort
  " very unlikely to change during a Vim session
  if exists('g:xray_use_gui')
    return g:xray_use_gui
  endif

  let g:xray_use_gui = v:false

  if has('gui_running')
    let g:xray_use_gui = v:true
  else
    " check both that the terminal supports it _and_ that Vim supports it
    " _and_ that the user has configured it
    if exists('$COLORTERM')
          \ && $COLORTERM ==? 'truecolor'
          \ && has('termguicolors')
          \ && &l:termguicolors
      let g:xray_use_gui = v:true
    endif
  endif

  return g:xray_use_gui
endfunction

function! xray#highlight#CanSetHighlight()
  " can change during a Vim session, but if it does, we're broken anyway
  " (see `:help E419` and `:help E420`)
  if exists('g:xray_can_set_highlight')
    return g:xray_can_set_highlight
  endif

  let g:xray_can_set_highlight = v:false

  let l:empty_bg = { 'termbg': '', 'ctermbg': '', 'guibg': '' }
  if xray#highlight#GetBackgroundsForHighlightGroup('Normal') != l:empty_bg
    let g:xray_can_set_highlight = v:true
  endif

  return g:xray_can_set_highlight
endfunction

" get a Dictionary of the background for each mode of background in the
" highlight group; if the mode is not set, an empty string will be set
function! xray#highlight#GetBackgroundsForHighlightGroup(group) abort
  return
        \ {
        \   'termbg':  synIDattr(hlID(a:group), 'bg', 'term'),
        \   'ctermbg': synIDattr(hlID(a:group), 'bg', 'cterm'),
        \   'guibg':   synIDattr(hlID(a:group), 'bg', 'gui')
        \ }
endfunction

