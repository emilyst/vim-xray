scriptencoding utf-8

function! xray#drawing#DrawXray(timer) abort
  if xray#settings#GetEnable()
        \ && !xray#settings#ShouldIgnoreFiletype()
        \ && xray#highlight#CanSetHighlight()
    if xray#mode#IsVisualMode()
      if !xray#list#AreXrayListOptionsConfigured()
            \ && !xray#highlight#AreXrayHighlightsConfigured()
        try
          call xray#highlight#SaveOriginalHighlights()
          call xray#list#SaveOriginalListOptions()
          call xray#highlight#ConfigureVisualHighlights()
          call xray#list#ConfigureListOptionsForVisualMode()
        catch
          if xray#settings#GetVerbose()
            echom 'Caught exception "' . v:exception . '" from ' . v:throwpoint
          endif

          call xray#highlight#RestoreOriginalHighlights()
          call xray#list#RestoreOriginalListOptions()
          if xray#settings#GetForceRedraw() | redraw | endif
        endtry
        if xray#settings#GetForceRedraw() | redraw | endif
      endif
    else
      if xray#list#AreXrayListOptionsConfigured()
            \ && xray#highlight#AreXrayHighlightsConfigured()
        call xray#highlight#RestoreOriginalHighlights()
        call xray#list#RestoreOriginalListOptions()
        if xray#settings#GetForceRedraw() | redraw | endif
      endif
    endif
  endif
endfunction
