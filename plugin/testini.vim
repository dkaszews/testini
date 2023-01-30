command! Testini echo testini#run()
command! TestiniCi call testini#run_ci()

let g:testini_autoload = expand('<sfile>:p:h:h')
if stridx(&runtimepath, g:testini_autoload) < 0
    execute 'set runtimepath+=' .. g:testini_autoload .. '/'
endif

