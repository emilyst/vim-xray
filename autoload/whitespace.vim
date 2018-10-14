scriptencoding utf-8

let s:enable           = get(g:, 'visual_whitespace_enable',           v:true)
let s:fg_group         = get(g:, 'visual_whitespace_fg_group',         'NonText')
let s:force_redraw     = get(g:, 'visual_whitespace_force_redraw',     v:true)
let s:refresh_interval = get(g:, 'visual_whitespace_refresh_interval', 100)
let s:space_char       = get(g:, 'visual_whitespace_space_char',       '·')
let s:space_pattern    = get(g:, 'visual_whitespace_space_pattern',    '\%V \%V')
let s:tab_char         = get(g:, 'visual_whitespace_tab_char',         '›')
let s:tab_pattern      = get(g:, 'visual_whitespace_tab_pattern',      '\v%V\t\zs%V')


" public

let s:redraw_timer = -1

function! whitespace#InitializeVisualWhitespace()
  if s:enable
    let s:redraw_timer = timer_start(
          \   s:refresh_interval,
          \   function('s:RedrawVisualWhitespace'),
          \   { 'repeat': -1 }
          \ )
  endif
endfunction


" private

" main method, called every interval
function! s:RedrawVisualWhitespace(timer)
  if s:IsVisualMode()
    if !s:AreWhitespaceHighlightPatternsConfigured()
      call s:ConfigureWhitespaceHighlightPatterns()
      call s:ConfigureConcealOptionsForVisualMode()
      call s:ConfigureVisualWhitespaceHighlight()
      if s:force_redraw | redraw | endif
    endif
  else
    if s:AreWhitespaceHighlightPatternsConfigured()
      call s:ClearWhitespaceHighlightPatterns()
      call s:RestoreOriginalConcealOptions()
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
        \   s:space_pattern,
        \   -1,
        \   -1,
        \   { 'conceal': s:space_char }
        \ ))
  call add(b:highlight_pattern_matches, matchadd(
        \   'Conceal',
        \   s:tab_pattern,
        \   -1,
        \   -1,
        \   { 'conceal': s:tab_char }
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
