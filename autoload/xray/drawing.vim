scriptencoding utf-8

function! xray#drawing#RedrawXray(timer)
  if xray#settings#GetEnable() && !xray#settings#ShouldIgnoreFiletype()
    if xray#mode#IsVisualMode()
      if !xray#highlight#AreWhitespaceHighlightPatternsConfigured()
        call xray#highlight#ConfigureVisualHighlights()
        call xray#list#ConfigureListOptionsForVisualMode()
        if xray#settings#GetForceRedraw() | redraw | endif
      endif
    else
      if xray#highlight#AreWhitespaceHighlightPatternsConfigured()
        call xray#highlight#RestoreOriginalHighlights()
        call xray#list#RestoreOriginalListOptions()
        if xray#settings#GetForceRedraw() | redraw | endif
      endif
    endif
  endif
endfunction
