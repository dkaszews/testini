function s:Echo(messages, on_empty)
    if a:messages == []
        echo a:on_empty
        return
    endif
    for l:message in a:messages
        echom l:message
    endfor
endfunction

command! Testini call s:Echo(testini#run(), 'All tests passed!')
command! TestiniCi call testini#run_ci()
command! TestiniLog call s:Echo(testini#get_log(), '')

let g:testini_autoload = expand('<sfile>:p:h:h')
if stridx(&runtimepath, g:testini_autoload) < 0
    execute 'set runtimepath+=' .. g:testini_autoload .. '/'
endif

