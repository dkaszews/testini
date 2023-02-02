let s:suite = testini#suite()

function s:suite.test.ignored_after_assert_will_fail() abort
    call assert_equal(1, 0)
    call testini#ignore()
endfunction

