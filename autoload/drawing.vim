scriptencoding utf-8

" enable
let s:enabled = get(g:, 'visual_whitespace_enabled', v:true)

" milliseconds between each timer call
let s:refresh_interval = get(g:, 'visual_whitespace_refresh_interval', 100)

" whether to force a redraw on a highlight change (probably needed)
let s:force_redraw = get(g:, 'visual_whitespace_force_redraw', v:true)

" pattern to match spaces
let s:space_pattern = get(g:, 'visual_whitespace_space_pattern', '\%V \%V')

" conceal char for spaces
let s:space_char = get(g:, 'visual_whitespace_space_char', '·')

" pattern to match tabs
let s:tab_pattern = get(g:, 'visual_whitespace_tab_pattern', '\%V\t\%V')

" conceal char for tabs
let s:tab_char = get(g:, 'visual_whitespace_tab_char', '›')

" foreground highlight group for whitespace chars
let s:fg_group = get(g:, 'visual_whitespace_fg_group', 'NonText')

let s:redraw_timer = -1


" public

function! drawing#InitializeVisualWhitespace()
  if s:enabled
    let s:redraw_timer = timer_start(
          \   s:refresh_interval,
          \   function('s:RedrawVisualWhitespace'),
          \   { 'repeat': -1 }
          \ )
  endif
endfunction


" private

function! s:RedrawVisualWhitespace(timer)
  if s:IsVisualMode()
    if !s:DoMatchesExist()
      call s:ConfigureConcealSettingsForVisualMode()
      call s:ConfigureConcealMatchesForWhitespace()
      call s:ConfigureVisualWhitespaceHighlight()
      if s:force_redraw | redraw | endif
    endif
  else
    if s:DoMatchesExist()
      call s:RestoreOriginalConcealSettings()
      call s:ClearConcealMatchesForWhitespace()
      call s:RestoreOriginalHighlight()
      if s:force_redraw | redraw | endif
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

function! s:DoMatchesExist()
  return get(b:, 'space_match', -1) != -1
endfunction

function! s:ConfigureConcealSettingsForVisualMode()
  let b:original_concealcursor = &l:concealcursor
  let b:original_conceallevel  = &l:conceallevel
  let &l:concealcursor         .= 'v'
  let &l:conceallevel          = 2
endfunction

function! s:RestoreOriginalConcealSettings()
  let &l:concealcursor = get(b:, 'original_concealcursor', &l:concealcursor)
  let &l:conceallevel  = get(b:, 'original_conceallevel',  &l:conceallevel)
endfunction

function! s:ConfigureConcealMatchesForWhitespace()
  let b:space_match = matchadd(
        \   'Conceal',
        \   s:space_pattern,
        \   -1,
        \   -1,
        \   { 'conceal': s:space_char }
        \ )
  let b:tab_match = matchadd(
        \   'Conceal',
        \   s:tab_pattern,
        \   -1,
        \   -1,
        \   { 'conceal': s:tab_char }
        \ )
endfunction

function! s:ClearConcealMatchesForWhitespace()
  call matchdelete(b:space_match)
  call matchdelete(b:tab_match)
  unlet b:space_match
  unlet b:tab_match
endfunction

function! s:ConfigureVisualWhitespaceHighlight()
  call s:LinkConcealToVisualWhitespaceHighlightGroup()
endfunction

function! s:RestoreOriginalHighlight()
  execute 'silent highlight Conceal ' . get(b:, 'original_conceal_group_details', '')
  execute 'highlight clear VisualWhitespace'
endfunction

" resulting highlight should have the background of the Visual group and
" the other attributes of the chosen foreground highlight group
function! s:LinkConcealToVisualWhitespaceHighlightGroup()
  let l:visual_group_details           = s:GetHighlightGroupDetails('Visual')
  let l:fg_group_details               = s:GetHighlightGroupDetails(s:fg_group)
  let b:original_conceal_group_details = s:GetHighlightGroupDetails('Conceal')

  " create a 'VisualWhitespace' highlight group which is a crude mash of
  " the two
  execute 'highlight VisualWhitespace ' . l:visual_group_details . ' ' . l:fg_group_details
  execute 'highlight! link Conceal VisualWhitespace'
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
