scriptencoding utf-8

" public

let s:redraw_timer = -1

function! xray#init#InitializeXray()
  if xray#settings#GetEnableSetting()
    let s:redraw_timer = timer_start(
          \   xray#settings#GetRefreshIntervalSetting(),
          \   function('s:RedrawXray'),
          \   { 'repeat': -1 }
          \ )
  endif
endfunction


" private

" main method, called every interval
function! s:RedrawXray(timer)
  if s:IsVisualMode()
    if !s:AreWhitespaceHighlightPatternsConfigured()
      call s:ConfigureWhitespaceHighlightPatterns()
      call s:ConfigureConcealOptionsForVisualMode()
      call s:ConfigureXrayHighlight()
      if xray#settings#GetForceRedrawSetting() | redraw | endif
    endif
  else
    if s:AreWhitespaceHighlightPatternsConfigured()
      call s:ClearWhitespaceHighlightPatterns()
      call s:RestoreOriginalConcealOptions()
      call s:RestoreOriginalHighlight()
      if xray#settings#GetForceRedrawSetting() | redraw | endif
    endif
  endif
endfunction

function! s:IsVisualMode()
  if mode(1) =~ 'v'
    return v:true
  else
    return v:false
  endif
endfunction

function! s:AreWhitespaceHighlightPatternsConfigured()
  if len(get(b:, 'highlight_pattern_matches', [])) > 0
    return v:true
  else
    return v:false
  endif
endfunction

function! s:ConfigureWhitespaceHighlightPatterns()
  let b:highlight_pattern_matches = get(b:, 'highlight_pattern_matches', [])

  call add(b:highlight_pattern_matches, matchadd(
        \   'Conceal',
        \   xray#settings#GetSpacePatternSetting(),
        \   -1,
        \   -1,
        \   { 'conceal': xray#settings#GetSpaceCharSetting() }
        \ ))
  call add(b:highlight_pattern_matches, matchadd(
        \   'Conceal',
        \   xray#settings#GetTabPatternSetting(),
        \   -1,
        \   -1,
        \   { 'conceal': xray#settings#GetTabCharSetting() }
        \ ))
endfunction

function! s:ClearWhitespaceHighlightPatterns()
  let b:highlight_pattern_matches = get(b:, 'highlight_pattern_matches', [])
  for id in b:highlight_pattern_matches
    call matchdelete(id)
  endfor
  let b:highlight_pattern_matches = []
endfunction

function! s:ConfigureConcealOptionsForVisualMode()
  let b:original_concealcursor = &l:concealcursor
  let b:original_conceallevel  = &l:conceallevel
  let &l:concealcursor         .= 'v'
  let &l:conceallevel          = 2
endfunction

function! s:RestoreOriginalConcealOptions()
  let &l:concealcursor = get(b:, 'original_concealcursor', &l:concealcursor)
  let &l:conceallevel  = get(b:, 'original_conceallevel',  &l:conceallevel)
endfunction

function! s:ConfigureXrayHighlight()
  call s:LinkConcealToXrayHighlightGroup()
endfunction

function! s:RestoreOriginalHighlight()
  execute 'silent highlight Conceal ' . get(b:, 'original_conceal_details', '')
  execute 'highlight clear Xray'
endfunction

" resulting highlight should have the background of the Visual group and
" the other attributes of the chosen foreground highlight group
function! s:LinkConcealToXrayHighlightGroup()
  let l:visual_details           = s:GetHighlightGroupDetails('Visual')
  let l:fg_details               = s:GetHighlightGroupDetails(xray#settings#GetFgGroupSetting())
  let b:original_conceal_details = s:GetHighlightGroupDetails('Conceal')

  " create a 'Xray' highlight group which is a crude mash of the two
  execute 'highlight Xray ' . l:visual_details . ' ' . l:fg_details
  execute 'highlight! link Conceal Xray'
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
