let s:suite = testini#suite()

function s:suite.before.all() abort
    let s:counters = { 'a' : 1, 'b' : 0, 'c' : 0 }
endfunction

function s:suite.after.all() abort
    call assert_equal({ 'a' : 1, 'b' : 3, 'c' : 3 }, s:counters)
endfunction

function s:suite.before.each() abort
    let s:counters.b += 1
endfunction

function s:suite.after.each() abort
    let s:counters.c += 1
endfunction

" Executed in alphabetical order: one, three, two
function s:suite.test.one() abort
    call assert_equal({ 'a' : 1, 'b' : 1, 'c' : 0 }, s:counters)
endfunction

function s:suite.test.two() abort
    call assert_equal({ 'a' : 1, 'b' : 3, 'c' : 2 }, s:counters)
endfunction

function s:suite.test.three() abort
    call assert_equal({ 'a' : 1, 'b' : 2, 'c' : 1 }, s:counters)
endfunction

