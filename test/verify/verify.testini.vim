let s:suite = testini#suite()

function s:suite.test.verify_args() abort
    call assert_equal(1, 0, 'Non-terminating assert')
    call testini#verify(assert_equal(1, 1, 'Pass'))
    call assert_equal(1, 0, 'Another non-terminating assert')
    call testini#verify(assert_equal(1, 0, 'Fail'))
    call assert_equal(1, 0, "Won't be reached")
endfunction

function s:suite.test.verify_mix() abort
    call testini#verify(assert_equal(1, 1, 'Pass'), assert_equal(1, 0, 'Fail'))
    call assert_equal(1, 0, "Won't be reached")
endfunction

function s:suite.test.verify_empty() abort
    call assert_equal(1, 0, 'Non-terminating assert')
    call testini#verify()
    call assert_equal(1, 0, "Won't be reached")
endfunction

