command! Testini echo join(testini#run(), "\n")
command! TestiniCi call testini#run_ci()
command! TestiniLog echo join(testini#get_log(), "\n")

let g:testini_autoload = expand('<sfile>:p:h:h')
if stridx(&runtimepath, g:testini_autoload) < 0
    execute 'set runtimepath+=' .. g:testini_autoload .. '/'
endif

