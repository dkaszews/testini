let s:suite = testini#suite()

function s:suite.test.two_plus_two_is_four() abort
    call assert_equal(4, 2 + 2)
endfunction

function s:suite.test.two_plus_two_is_five() abort
    call assert_equal(5, 2 + 2)
endfunction

