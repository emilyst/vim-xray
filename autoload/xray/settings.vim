scriptencoding utf-8


" public

function! xray#settings#GetEnable()
  return get(g:, 'xray_enable', v:true)
endfunction

function! xray#settings#GetForceRedraw()
  return get(g:, 'xray_force_redraw', v:true)
endfunction

function! xray#settings#GetAllowedFiletypes()
  return get(g:, 'xray_allowed_filetypes', [])
endfunction

function! xray#settings#GetIgnoredFiletypes()
  return get(g:, 'xray_ignored_filetypes', ['qf', 'nerdtree', 'tagbar'])
endfunction

function! xray#settings#GetRefreshInterval()
  return get(g:, 'xray_refresh_interval', 100)
endfunction

function! xray#settings#GetSpaceChar()
  return get(g:, 'xray_space_char', '·')
endfunction

function! xray#settings#GetTabChars()
  return get(g:, 'xray_tab_chars', '› ')
endfunction

function! xray#settings#GetEolChar()
  return get(g:, 'xray_eol_char', '¶')
endfunction

function! xray#settings#GetTrailChar()
  return get(g:, 'xray_trail_char', '·')
endfunction
