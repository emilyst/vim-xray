scriptencoding utf-8

function! xray#drawing#DrawXray(timer) abort
  if xray#settings#GetEnable()
        \ && !xray#settings#ShouldIgnoreFiletype()
        \ && xray#highlight#CanSetHighlight()
    if xray#mode#IsVisualMode()
      if !xray#list#AreXrayListOptionsConfigured()
        try
          call xray#highlight#SaveOriginalHighlights()
          call xray#list#SaveOriginalListOptions()
          call xray#highlight#ConfigureVisualHighlights()
          call xray#list#ConfigureListOptionsForVisualMode()
        catch
          call xray#highlight#RestoreOriginalHighlights()
          call xray#list#RestoreOriginalListOptions()
          if xray#settings#GetForceRedraw() | redraw | endif
        endtry
        if xray#settings#GetForceRedraw() | redraw | endif
      endif
    else
      if xray#list#AreXrayListOptionsConfigured()
        call xray#highlight#RestoreOriginalHighlights()
        call xray#list#RestoreOriginalListOptions()
        if xray#settings#GetForceRedraw() | redraw | endif
      endif
    endif
  endif
endfunction
