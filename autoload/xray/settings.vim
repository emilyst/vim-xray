scriptencoding utf-8


" public

function! xray#settings#GetEnableSetting()
  return get(g:, 'xray_enable',           v:true)
endfunction

function! xray#settings#GetForceRedrawSetting()
  return get(g:, 'xray_force_redraw',     v:true)
endfunction

function! xray#settings#GetRefreshIntervalSetting()
  return get(g:, 'xray_refresh_interval', 100)
endfunction

" TODO: default to listchars:space
function! xray#settings#GetSpaceSetting()
  return get(g:, 'xray_space_char',       '·')
endfunction

function! xray#settings#GetTabSetting()
  return get(g:, 'xray_tab_char',         '› ')
endfunction

function! xray#settings#GetEolSetting()
  return get(g:, 'xray_eol_char',         '¶')
endfunction

function! xray#settings#GetTrailSetting()
  return get(g:, 'xray_trail_char',       '·')
endfunction
