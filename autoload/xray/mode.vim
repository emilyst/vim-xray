scriptencoding utf-8

function! xray#mode#IsVisualMode()
  let l:mode = mode(1)
  if l:mode ==? 'v' || l:mode ==? ''
    return v:true
  else
    return v:false
  endif
endfunction
