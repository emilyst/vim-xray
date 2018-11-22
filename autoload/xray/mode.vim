scriptencoding utf-8

function! xray#mode#IsVisualOrSelectMode() abort
  let l:mode = mode(1)
  if l:mode ==? 'v' || l:mode ==? '' || l:mode ==? 's' || l:mode ==? ''
    return v:true
  else
    return v:false
  endif
endfunction
