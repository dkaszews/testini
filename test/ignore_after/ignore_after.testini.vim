let s:suite = testini#suite()

function s:suite.test.ignored_after_will_fail() abort
    call assert_true(0)
    call testini#ignore()
endfunction

