scriptencoding utf-8


" public

let s:redraw_timer = -1

function! xray#init#IsTimerStarted()
  return s:redraw_timer != -1
endfunction

function! xray#init#StartXray()
  if xray#settings#GetEnable()
    let s:redraw_timer =
          \ timer_start(
          \   xray#settings#GetRefreshInterval(),
          \   function('s:RedrawXray'),
          \   { 'repeat': -1 }
          \ )
  endif
endfunction

function! xray#init#StopXray()
  if xray#settings#GetEnable()
    call timer_stop(s:redraw_timer)
    let s:redraw_timer = -1
  endif
endfunction

function! xray#init#ToggleXray()
  if xray#init#IsTimerStarted()
    call xray#init#StopXray()
  else
    call xray#init#StartXray()
  endif
endfunction

command! -nargs=0 XrayToggle call xray#init#ToggleXray()


" private

" main method, called every interval
function! s:RedrawXray(timer)
  if xray#settings#GetEnable() && !s:ShouldIgnoreFiletype()
    if s:IsVisualMode()
      if !s:AreWhitespaceHighlightPatternsConfigured()
        call s:ConfigureVisualHighlights()
        call s:ConfigureListOptionsForVisualMode()
        if xray#settings#GetForceRedraw() | redraw | endif
      endif
    else
      if s:AreWhitespaceHighlightPatternsConfigured()
        call s:RestoreOriginalHighlights()
        call s:RestoreOriginalListOptions()
        if xray#settings#GetForceRedraw() | redraw | endif
      endif
    endif
  endif
endfunction

" if allowed filetypes are populated, it overrides the ignore list and
" means this plugin only works for those specifically allowed filetypes
function! s:ShouldIgnoreFiletype()
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

function! s:IsVisualMode()
  let l:mode = mode(1)
  if l:mode ==? 'v' || l:mode ==? ''
    return v:true
  else
    return v:false
  endif
endfunction

function! s:AreWhitespaceHighlightPatternsConfigured()
  if get(b:, 'special_key_details', s:GetHighlightGroupDetails('SpecialKey'))
        \ !=? s:GetHighlightGroupDetails('SpecialKey')
    return v:true
  endif

  if get(b:, 'non_text_details', s:GetHighlightGroupDetails('NonText'))
        \ !=? s:GetHighlightGroupDetails('NonText')
    return v:true
  endif

  return v:false
endfunction

function! s:ConfigureListOptionsForVisualMode()
  let b:original_list      = &l:list
  let b:original_listchars = split(&l:listchars, ',')

  setlocal list

  " this setting is, tragically, only global, so setting this here will
  " affect all windows, but hopefully if we do the highlighting first,
  " we won't reveal the listchars in those windows; using 'setlocal'
  " anyways because it degrades to 'set' and because someday maybe it
  " will acquire a local ability
  setlocal listchars=

  if !empty(xray#settings#GetSpaceChar())
    execute "setlocal listchars+=space:" . escape((xray#settings#GetSpaceChar()), ' ')
  endif

  if !empty(xray#settings#GetTabChars())
    execute "setlocal listchars+=tab:" . escape((xray#settings#GetTabChars()), ' ')
  endif

  if !empty(xray#settings#GetEolChar())
    execute "setlocal listchars+=eol:" . escape((xray#settings#GetEolChar()), ' ')
  endif

  if !empty(xray#settings#GetTrailChar())
    execute "setlocal listchars+=trail:" . escape((xray#settings#GetTrailChar()), ' ')
  endif
endfunction

function! s:RestoreOriginalListOptions()
  if get(b:, 'original_list', &l:list)
    setlocal list
  else
    setlocal nolist
  endif

  setlocal listchars=
  execute 'setlocal listchars=' .
        \ escape(join(get(b:, 'original_listchars', split(&l:listchars, ',')), ','), ' ')
endfunction

function! s:ConfigureVisualHighlights()
  let b:special_key_details = s:GetHighlightGroupDetails('SpecialKey')
  let b:non_text_details    = s:GetHighlightGroupDetails('NonText')

  let l:colors = []
  for arg in split(s:GetHighlightGroupDetails('Normal'))
    if arg =~ 'bg'
      call add(l:colors, arg)
      call add(l:colors, substitute(arg, 'bg', 'fg', ''))
    endif
  endfor

  execute 'silent highlight SpecialKey term=bold gui=bold ' . join(l:colors, ' ')
  execute 'silent highlight NonText    term=bold gui=bold ' . join(l:colors, ' ')
endfunction

function! s:RestoreOriginalHighlights()
  execute 'silent highlight SpecialKey ' .
        \ get(b:, 'special_key_details', s:GetHighlightGroupDetails('SpecialKey'))
  execute 'silent highlight NonText    ' .
        \ get(b:, 'non_text_details',    s:GetHighlightGroupDetails('NonText'))

  unlet b:special_key_details
  unlet b:non_text_details
endfunction

function! s:GetHighlightGroupDetails(group)
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
