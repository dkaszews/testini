let s:suite = testini#suite()

function! s:suite.before.all()
    call testini#log('In before all')
endfunction

function! s:suite.after.all()
    call testini#log('In after all')
endfunction

function! s:suite.before.each()
    call testini#log('In before each')
endfunction

function! s:suite.after.each()
    call testini#log('In after each')
endfunction

function! s:suite.test.foo()
    call testini#log('In test foo')
endfunction

