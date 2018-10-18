scriptencoding utf-8

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

function! xray#highlight#ConfigureVisualHighlights() abort
  let b:special_key_details = xray#highlight#GetHighlightGroupDetails('SpecialKey')
  let b:non_text_details    = xray#highlight#GetHighlightGroupDetails('NonText')

  let l:normal_termbg_color  = synIDattr(hlID('Normal'), 'bg', 'term')
  let l:normal_ctermbg_color = synIDattr(hlID('Normal'), 'bg', 'cterm')
  let l:normal_guibg_color   = synIDattr(hlID('Normal'), 'bg', 'gui')

  let l:visual_highlight = ''
  if !empty(l:normal_termbg_color)
    let l:visual_highlight .= ' term=bold' .
          \ ' termbg=' . l:normal_termbg_color .
          \ ' termfg=' . l:normal_termbg_color
  endif
  if !empty(l:normal_ctermbg_color)
    let l:visual_highlight .= ' cterm=bold' .
          \ ' ctermbg=' . l:normal_ctermbg_color .
          \ ' ctermfg=' . l:normal_ctermbg_color
  endif
  if !empty(l:normal_guibg_color)
    let l:visual_highlight .= ' gui=bold' .
          \ ' guibg=' . l:normal_guibg_color .
          \ ' guifg=' . l:normal_guibg_color
  endif

  execute 'silent highlight SpecialKey ' . l:visual_highlight
  execute 'silent highlight NonText    ' . l:visual_highlight
endfunction

function! xray#highlight#RestoreOriginalHighlights() abort
  execute 'silent highlight SpecialKey ' .
        \ get(b:, 'special_key_details', xray#highlight#GetHighlightGroupDetails('SpecialKey'))
  execute 'silent highlight NonText    ' .
        \ get(b:, 'non_text_details',    xray#highlight#GetHighlightGroupDetails('NonText'))

  unlet b:special_key_details
  unlet b:non_text_details
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
  return matchlist(l:highlight_output, '\<xxx\>\s\+\(.*\)')[1]
endfunction

