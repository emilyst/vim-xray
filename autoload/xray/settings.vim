scriptencoding utf-8


" public

function! xray#settings#GetEnable() abort
  return get(g:, 'xray_enable', v:true)
endfunction

function! xray#settings#GetForceRedraw() abort
  return get(g:, 'xray_force_redraw', v:true)
endfunction

function! xray#settings#GetAllowedFiletypes() abort
  return get(g:, 'xray_allowed_filetypes', [])
endfunction

function! xray#settings#GetIgnoredFiletypes() abort
  return get(g:, 'xray_ignored_filetypes', ['qf', 'nerdtree', 'tagbar'])
endfunction

function! xray#settings#GetRefreshInterval() abort
  return get(g:, 'xray_refresh_interval', 100)
endfunction

function! xray#settings#GetSpaceChar() abort
  return get(g:, 'xray_space_char', '·')
endfunction

function! xray#settings#GetTabChars() abort
  return get(g:, 'xray_tab_chars', '› ')
endfunction

function! xray#settings#GetEolChar() abort
  return get(g:, 'xray_eol_char', '¶')
endfunction

function! xray#settings#GetTrailChar() abort
  return get(g:, 'xray_trail_char', '·')
endfunction

function! xray#settings#GetVerbose() abort
  return get(g:, 'xray_verbose', v:false)
endfunction

" if allowed filetypes are populated, it overrides the ignore list and
" means this plugin only works for those specifically allowed filetypes
function! xray#settings#ShouldIgnoreFiletype() abort
  if len(xray#settings#GetAllowedFiletypes()) > 0
    if count(xray#settings#GetAllowedFiletypes(), &l:filetype) > 0
      return v:false
    else
      return v:true
    endif
  else
    if count(xray#settings#GetIgnoredFiletypes(), &l:filetype) > 0
      return v:true
    else
      return v:false
    endif
  endif
endfunction
