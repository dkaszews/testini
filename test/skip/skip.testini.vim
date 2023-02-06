let s:suite = testini#suite()

function s:suite.test.skipped_wont_fail() abort
    call testini#skip()
    call assert_equal(1, 0)
endfunction

