scriptencoding utf-8


" public

function! xray#settings#GetEnableSetting()
  return get(g:, 'xray_enable',           v:true)
endfunction

function! xray#settings#GetFgGroupSetting()
  return get(g:, 'xray_fg_group',         'SpecialKey')
endfunction

function! xray#settings#GetForceRedrawSetting()
  return get(g:, 'xray_force_redraw',     v:true)
endfunction

function! xray#settings#GetRefreshIntervalSetting()
  return get(g:, 'xray_refresh_interval', 100)
endfunction

" TODO: default to listchars:space
function! xray#settings#GetSpaceCharSetting()
  return get(g:, 'xray_space_char',       '·')
endfunction

function! xray#settings#GetSpacePatternSetting()
  return get(g:, 'xray_space_pattern',    ' ')
endfunction
