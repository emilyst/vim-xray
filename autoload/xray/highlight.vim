scriptencoding utf-8

" Store 'SpecialKey' and 'NonText' highlight groups so that we can set
" them later to their original values.
function! xray#highlight#SaveOriginalHighlights() abort
  if !exists('g:xray_original_special_key_details')
    let g:xray_original_special_key_details = xray#highlight#GetHighlightGroupDetails('SpecialKey')
  endif

  if !exists('g:xray_original_non_text_details')
    let g:xray_original_non_text_details = xray#highlight#GetHighlightGroupDetails('NonText')
  endif
endfunction

" Restore 'SpecialKey' and 'NonText' highlight groups to their original
" values. Requires that we first clear the modified values we set, or we
" may end up with a combination instead of the exact original.
function! xray#highlight#RestoreOriginalHighlights() abort
  execute 'silent highlight clear SpecialKey'
  execute 'silent highlight clear NonText'

  execute 'silent highlight SpecialKey ' . g:xray_original_special_key_details
  execute 'silent highlight NonText '    . g:xray_original_non_text_details
endfunction

" Determine if we're using the original or modified versions of the
" 'SpecialKey' and 'NonText' highlight groups.
function! xray#highlight#AreXrayHighlightsConfigured() abort
  let l:original_special_key_details = get(
        \   g:,
        \   'xray_original_special_key_details',
        \   xray#highlight#GetHighlightGroupDetails('SpecialKey')
        \ )
  let l:current_special_key_details = xray#highlight#GetHighlightGroupDetails('SpecialKey')
  if l:original_special_key_details != l:current_special_key_details
    return v:true
  endif

  let l:original_non_text_details = get(
        \   g:,
        \   'xray_original_non_text_details',
        \   xray#highlight#GetHighlightGroupDetails('NonText')
        \ )
  let l:current_non_text_details = xray#highlight#GetHighlightGroupDetails('NonText')
  if l:original_non_text_details != l:current_non_text_details
    return v:true
  endif

  return v:false
endfunction

" Extract a highlight group's details for saving and restoring.
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

" Switch out the foreground _and_ background for the 'SpecialKey' and
" 'NonText' highlight groups to match the background for the 'Normal'
" group. That means these characters (usually 'listchars') won't be
" visible unless selected.
"
" At the time this is called, my use of the "bg" keyword triggers Vim to
" look at the background used for the 'Normal' highlight group, if it
" can find it; thereafter, it always uses the same color, even if the
" colorscheme changes. (See `:help E419` or `:help E420`.)
"
" Occasionally, Vim even seems to get this wrong (xterm, urxvt).
"
" If 'Normal' has no background set (such as for the default
" colorscheme), Vim basically has no idea how to find out what the
" background is, and there's no way this will succeed. So before this
" gets called, we checked that 'Normal' has some background set.
function! xray#highlight#ConfigureVisualHighlights() abort
  if xray#highlight#IsGuiOrTrueColorTerm()
    let l:visual_highlight = 'gui=bold guibg=bg guifg=bg'
  elseif xray#highlight#IsSupportedColorTerm()
    let l:visual_highlight = 'cterm=bold ctermbg=bg ctermfg=bg'
  endif

  execute 'silent highlight SpecialKey ' . l:visual_highlight
  execute 'silent highlight NonText    ' . l:visual_highlight
endfunction

" Determine if a *supported* color term is in use. If so, this implies
" that the 'cterm' highlight arguments may be used.
"
" This is a lot of guessing, but I try to err on the safe side. This is
" probably error-prone. Assumes this won't change during a Vim session.
function! xray#highlight#IsSupportedColorTerm() abort
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

" Determine if a GUI or true-color terminal is in use. If so, this
" implies that the 'gui' highlight arguments may be used. Assumes this
" won't change during a Vim session.
function! xray#highlight#IsGuiOrTrueColorTerm() abort
  if exists('g:xray_use_gui')
    return g:xray_use_gui
  endif

  let g:xray_use_gui = v:false

  if has('gui_running')
    let g:xray_use_gui = v:true
  else
    " check both that the terminal supports truecolor mode _and_ that
    " Vim supports it _and_ that the user has chosen to use it
    if exists('$COLORTERM')
          \ && $COLORTERM ==? 'truecolor'
          \ && has('termguicolors')
          \ && &l:termguicolors
      let g:xray_use_gui = v:true
    endif
  endif

  return g:xray_use_gui
endfunction

" Determine if 'Normal' has any background highlight set for the current
" type of Vim session. If not, Vim can't determine what the background
" color of the Vim screen is.
"
" Assume this can't change during a Vim session. (It can, but if it
" does, we can't really recover gracefully regardless: see `:help E419`
" or `:help E420`.)
function! xray#highlight#CanSetHighlight() abort
  if exists('g:xray_can_set_highlight')
    return g:xray_can_set_highlight
  endif

  let g:xray_can_set_highlight = v:false
  let l:normal_backgrounds = xray#highlight#GetBackgroundsForHighlightGroup('Normal')

  if xray#highlight#IsGuiOrTrueColorTerm() && l:normal_backgrounds.guibg != ''
    let g:xray_can_set_highlight = v:true
  elseif xray#highlight#IsSupportedColorTerm() && l:normal_backgrounds.ctermbg != ''
    let g:xray_can_set_highlight = v:true
  endif

  return g:xray_can_set_highlight
endfunction

" Get a Dictionary of the background highlights for each kind of
" background in a highlight group; if the mode is not set, an empty
" string will be set.
"
" Assume this can't change during a Vim session. (It can, but if it
" does, we can't really recover gracefully regardless: see `:help E419`
" or `:help E420`.)
function! xray#highlight#GetBackgroundsForHighlightGroup(group) abort
  if exists('g:xray_background_highlights')
    return g:xray_background_highlights
  endif

  let g:xray_background_highlights =
        \ {
        \   'termbg':  synIDattr(hlID(a:group), 'bg', 'term'),
        \   'ctermbg': synIDattr(hlID(a:group), 'bg', 'cterm'),
        \   'guibg':   synIDattr(hlID(a:group), 'bg', 'gui')
        \ }

  return g:xray_background_highlights
endfunction
