scriptencoding utf-8

function! xray#highlight#AreWhitespaceHighlightPatternsConfigured()
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

function! xray#highlight#ConfigureVisualHighlights()
  let b:special_key_details = xray#highlight#GetHighlightGroupDetails('SpecialKey')
  let b:non_text_details    = xray#highlight#GetHighlightGroupDetails('NonText')

  let l:colors = []
  for arg in split(xray#highlight#GetHighlightGroupDetails('Normal'))
    if arg =~ 'bg'
      call add(l:colors, arg)
      call add(l:colors, substitute(arg, 'bg', 'fg', ''))
    endif
  endfor

  execute 'silent highlight SpecialKey term=bold gui=bold ' . join(l:colors, ' ')
  execute 'silent highlight NonText    term=bold gui=bold ' . join(l:colors, ' ')
endfunction

function! xray#highlight#RestoreOriginalHighlights()
  execute 'silent highlight SpecialKey ' .
        \ get(b:, 'special_key_details', xray#highlight#GetHighlightGroupDetails('SpecialKey'))
  execute 'silent highlight NonText    ' .
        \ get(b:, 'non_text_details',    xray#highlight#GetHighlightGroupDetails('NonText'))

  unlet b:special_key_details
  unlet b:non_text_details
endfunction

function! xray#highlight#GetHighlightGroupDetails(group)
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

