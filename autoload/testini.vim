function! testini#suite() abort
    if s:suite_name == ''
        throw 'testini.empty_suite(): do not manually source test scripts'
    elseif has_key(s:suites, s:suite_name)
        throw 'testini.duplicate_suite(' .. s:suite_name .. ')'
    endif

    let s:suites[s:suite_name] = { 'test': {}, 'before': {}, 'after': {} }
    return s:suites[s:suite_name]
endfunction

function! testini#ignore(...) abort
    throw 'testini.ignore(' .. get(a:, 1, '') .. ')'
endfunction

function! testini#verify(...) abort
    let l:errors = a:000 != [] ? filter(copy(a:000), 'v:val') : v:errors
    if l:errors != []
        throw 'suite.verify()'
    endif
endfunction

function! testini#log(message) abort
    call s:log('user', a:message)
endfunction

function! s:source() abort
    let s:suites = {}
    for l:file in glob('**/*.testini.vim', 0, 1)
        let s:suite_name = fnamemodify(l:file, ':t:r:r')
        execute 'source ' .. l:file
        let s:suite_name = ''
    endfor
    return s:suites
endfunction

function! s:exception() abort
    return v:throwpoint .. ': thrown ' .. v:exception
endfunction

function! s:log(level, message) abort
    let l:level = toupper(a:level)
    let l:messages = type(a:message) == v:t_list ? a:message : [ a:message ]
    if l:level == 'FAIL'
        call extend(s:errors, l:messages)
    endif
    call map(l:messages, 'printf("[%s] %s", l:level, v:val)')
    call extend(s:logdata, l:messages)
endfunction

function! s:run_part(suite, middle, part) abort
    if !has_key(s:suites[a:suite][a:middle], a:part)
        return 1
    endif

    let v:errors = []
    try
        call call(s:suites[a:suite][a:middle][a:part], [])
    catch 'testini.ignore'
        " Do nothing
    catch
        call add(v:errors, s:exception())
    endtry
    call s:map_errors(a:suite, a:middle, a:part, v:errors)
    call s:log('FAIL', v:errors)
    return v:errors == []
endfunction

function! s:map_errors(suite, middle, part, errors) abort
    if a:errors == []
        return
    endif

    let l:name = join([a:suite, a:middle, a:part], '.')
    let l:fun = string(s:suites[a:suite][a:middle][a:part])
    let l:code = substitute(l:fun, '\v\D*(\d+)\D.*', '\1', '')

    let l:separator = '\v(^|\.\.| |\[)' 
    for l:i in range(len(a:errors))
        " Split callstack and message to avoid matches in arbitrary text
        " Cannot use `split()` because it has no way of limiting
        let l:pivot = stridx(a:errors[l:i], ':')
        let l:stack = a:errors[l:i][: l:pivot]
        let l:message = a:errors[l:i][l:pivot + 1 :]

        " 'foo[10]..bar line 20' => 'foo[10]..bar[20]' for consistency
        let l:stack = substitute(l:stack, '\v\c,? line (\d)', '[\1]', '')
        let l:stack = substitute(l:stack, '\v\c^.{-}run_part\[\d\]\.\.', '', '')
        let l:pat = l:separator .. l:code .. l:separator
        let l:stack = substitute(l:stack, l:pat,  '\1' .. l:name .. '\2', 'g')
        let a:errors[l:i] = l:stack .. l:message
    endfor
    return a:errors
endfunction

function! s:log_result(result, suite, ...) abort
    let l:string = a:result ? 'Pass' : 'Fail'
    let l:part = a:0 ? printf('%s.test.%s', a:suite, a:1) : a:suite
    call s:log(l:string, printf('%s: %sed', l:part, l:string))
endfunction

function! s:run_test(suite, test) abort
    call s:log('info', printf('%s.test.%s: Running', a:suite, a:test))
    let l:result = s:run_part(a:suite, 'before', 'each')
    if l:result
        let l:result *= s:run_part(a:suite, 'test', a:test)
    endif
    let l:result *= s:run_part(a:suite, 'after', 'each')
    call s:log_result(l:result, a:suite, a:test)
    return l:result
endfunction

function! s:run_suite(suite) abort
    call s:log('info', printf('%s: Running', a:suite))
    let l:result = 1
    if s:run_part(a:suite, 'before', 'all')
        for l:test in sort(keys(s:suites[a:suite].test))
            let l:result *= s:run_test(a:suite, l:test)
        endfor
    endif
    let l:result *= s:run_part(a:suite, 'after', 'all')
    call s:log_result(l:result, a:suite)
endfunction

function! testini#get_log(...) abort
    return s:logdata
endfunction

function! testini#run() abort
    " Keep errors in the script variable so they can be accessed by timeout
    let s:errors = []
    let s:logdata = []
    call s:source()
    for l:suite in keys(s:suites)
        call s:run_suite(l:suite)
    endfor
    return s:errors
endfunction

function! testini#run_ci() abort
    try
        call testini#run()
        call writefile(s:logdata, 'testini.log')
        execute (s:errors == [] ? 'quit!' : 'cquit!')
    catch
        call writefile([ 'INTERNAL ERROR:', s:exception() ], 'testini.log')
        cquit!
    endtry
endfunction

