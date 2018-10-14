scriptencoding utf-8


" public

function! xray#settings#GetEnableSetting()
  return get(g:, 'xray_enable',           v:true)
endfunction

function! xray#settings#GetFgGroupSetting()
  return get(g:, 'xray_fg_group',         'NonText')
endfunction

function! xray#settings#GetForceRedrawSetting()
  return get(g:, 'xray_force_redraw',     v:true)
endfunction

function! xray#settings#GetRefreshIntervalSetting()
  return get(g:, 'xray_refresh_interval', 100)
endfunction

function! xray#settings#GetSpaceCharSetting()
  return get(g:, 'xray_space_char',       '·')
endfunction

function! xray#settings#GetSpacePatternSetting()
  return get(g:, 'xray_space_pattern',    '\%V \%V')
endfunction

function! xray#settings#GetTabCharSetting()
  return get(g:, 'xray_tab_char',         '›')
endfunction

function! xray#settings#GetTabPatternSetting()
  return get(g:, 'xray_tab_pattern',      '\v%V\t\zs%V')
endfunction
