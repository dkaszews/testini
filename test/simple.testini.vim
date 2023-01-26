let s:suite = testini#suite()

function s:suite.before.each() abort
    enew!
    file! _simple_test
    call setline(1, [ 'aaa', 'bbb', 'ccc' ])
endfunction

function s:suite.test.buffer_editing() abort
    call assert_equal(3, line('$'))
    call assert_equal('bab', getline(2))
endfunction

function s:suite.after.each() abort
    bdelete! _simple_test
endfunction

