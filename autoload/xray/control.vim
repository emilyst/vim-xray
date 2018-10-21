scriptencoding utf-8

let s:redraw_timer = -1

function! xray#control#IsTimerStarted() abort
  return s:redraw_timer != -1
endfunction

function! xray#control#ToggleXray() abort
  if xray#control#IsTimerStarted()
    call xray#control#StopXray()
  else
    call xray#control#StartXray()
  endif
endfunction

function! xray#control#StartXray() abort
  if xray#settings#GetEnable()
    let s:redraw_timer =
          \ timer_start(
          \   xray#settings#GetRefreshInterval(),
          \   function('xray#drawing#DrawXray'),
          \   { 'repeat': -1 }
          \ )
  endif
endfunction

function! xray#control#StopXray() abort
  if xray#settings#GetEnable()
    call timer_stop(s:redraw_timer)
    let s:redraw_timer = -1
  endif
endfunction

if has('user_commands')
  command! -nargs=0 XrayToggle call xray#control#ToggleXray()
endif
