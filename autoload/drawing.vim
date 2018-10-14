scriptencoding utf-8

" enable
let s:visual_whitespace_enabled =
      \ get(g:, 'visual_whitespace_enabled', v:true)

" milliseconds between each timer call
let s:visual_whitespace_refresh_interval =
      \ get(g:, 'visual_whitespace_refresh_interval', 100)

" pattern to match spaces
let s:visual_whitespace_space_pattern =
      \ get(g:, 'visual_whitespace_space_pattern', '\%V \%V')

" conceal char for spaces
let s:visual_whitespace_space_char =
      \ get(g:, 'visual_whitespace_space_char', '·')

" pattern to match tabs
let s:visual_whitespace_tab_pattern =
      \ get(g:, 'visual_whitespace_tab_pattern', '\%V\t\%V')

" conceal char for tabs
let s:visual_whitespace_tab_char =
      \ get(g:, 'visual_whitespace_space_char', '›')


" public

function! drawing#InitializeVisualWhitespace()
  if s:visual_whitespace_enabled
    call timer_start(
          \   s:visual_whitespace_refresh_interval,
          \   function('s:RedrawVisualWhitespace'),
          \   { 'repeat': -1 }
          \ )
  endif
endfunction

function! s:RedrawVisualWhitespace(timer)
  if s:IsVisualMode()
    if !s:DoMatchesExist()
      call s:SetConcealSettingsForVisualMode()
      call s:ConfigureConcealMatchesForWhitespace()
      call s:LinkConcealToVisualNonText()
      redraw
    endif
  else
    if s:DoMatchesExist()
      call s:RestoreConcealSettingsToOriginals()
      call s:ClearConcealMatchesForWhitespace()
      call s:UnlinkConcealFromVisualNonText()
      redraw
    endif
  endif
endfunction


" private

function! s:IsVisualMode()
  if mode(1) =~ 'v'
    return v:true
  else
    return v:false
  endif
endfunction

function! s:DoMatchesExist()
  return get(b:, 'space_match', -1) != -1
endfunction

function! s:SetConcealSettingsForVisualMode()
  let b:original_concealcursor = &l:concealcursor
  let b:original_conceallevel  = &l:conceallevel
  let &l:concealcursor         .= 'v'
  let &l:conceallevel          = 2
endfunction

function! s:RestoreConcealSettingsToOriginals()
  let &l:concealcursor = get(b:, 'original_concealcursor', &l:concealcursor)
  let &l:conceallevel  = get(b:, 'original_conceallevel',  &l:conceallevel)
endfunction

function! s:ConfigureConcealMatchesForWhitespace()
  let b:space_match = matchadd(
        \   'Conceal',
        \   s:visual_whitespace_space_pattern,
        \   10,
        \   -1,
        \   { 'conceal': s:visual_whitespace_space_char }
        \ )
  let b:tab_match = matchadd(
        \   'Conceal',
        \   s:visual_whitespace_tab_pattern,
        \   10,
        \   -1,
        \   { 'conceal': s:visual_whitespace_tab_char }
        \ )
endfunction

function! s:ClearConcealMatchesForWhitespace()
  call matchdelete(b:space_match)
  call matchdelete(b:tab_match)
  unlet b:space_match
  unlet b:tab_match
endfunction

function! s:UnlinkConcealFromVisualNonText()
  execute 'highlight! link Conceal NONE'
  execute 'highlight clear VisualNonText'
endfunction

function! s:LinkConcealToVisualNonText()
  let l:visual_group_details  = s:GetHighlightGroupDetails('Visual')
  let l:nontext_group_details = s:GetHighlightGroupDetails('NonText')

  " create a 'VisualNonText' (just a crude mash of the two)
  execute 'highlight VisualNonText ' . l:visual_group_details . ' ' . l:nontext_group_details
  execute 'highlight! link Conceal VisualNonText'
endfunction

" resulting highlight should have the background of the Visual group and
" the other attributes of the NonText group
function! s:GetHighlightGroupDetails(group)
  redir => l:highlight_output
  execute 'silent highlight ' . a:group
  redir END

  " recurse to find actual highlight group if needed
  while l:highlight_output =~ 'links to'
    let l:index        = stridx(l:highlight_output, 'links to') + len('links to')
    let l:linked_group = strpart(l:highlight_output, l:index + 1)

    redir => l:highlight_output
    execute 'highlight ' . l:linked_group
    redir END
  endwhile

  " extract highlight group details
  return matchlist(l:highlight_output, '\<xxx\>\s\+\(.*\)')[1]
endfunction
