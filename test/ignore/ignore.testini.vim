let s:suite = testini#suite()

function s:suite.test.ignored_wont_fail() abort
    call testini#ignore()
    call assert_equal(1, 0)
endfunction

