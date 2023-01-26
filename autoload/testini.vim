" TODO: patterns
" TODO: timers
" TODO: params
" TODO: fence
" TODO: log

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

function! s:source() abort
    let s:suites = {}
    for l:file in glob('**/*.testini.vim', 0, 1)
        let s:suite_name = fnamemodify(l:file, ':t:r:r')
        execute 'source ' .. l:file
        let s:suite_name = ''
    endfor
    return s:suites
endfunction

function s:run_part(suite, middle, part) abort
    let v:errors = []
    try
        if has_key(s:suites[a:suite][a:middle], a:part)
            call call(s:suites[a:suite][a:middle][a:part], [])
        endif
    catch 'testini.ignore'
        return
    catch
        let l:exception = v:throwpoint .. ': thrown ' .. v:exception
        call extend(v:errors, [ l:exception ])
    endtry
    call extend(s:errors, v:errors)
endfunction

function! s:decode_callstacks() abort
    if s:errors == []
        return
    endif

    let l:fun_map = {}
    for l:suite in keys(s:suites)
        for l:middle in keys(s:suites[l:suite])
            for l:part in keys(s:suites[l:suite][l:middle])
                let l:name = join([l:suite, l:middle, l:part], '.')
                let l:fun = string(s:suites[l:suite][l:middle][l:part])
                let l:code = substitute(l:fun, '\v\D*(\d+)\D.*', '\1', '')
                let l:fun_map[l:code] = l:name
            endfor
        endfor
    endfor

    for l:i in range(len(s:errors))
        let [ l:callstack, l:message ] = split(s:errors[l:i], ':\zs')
        for [ l:code, l:name ] in items(l:fun_map)
            let l:pat = '\v(\.\.| )' .. l:code .. '(\.\.| )'
            let l:sub = '\1' .. l:name .. '\1'
            let l:callstack = substitute(l:callstack, l:pat, l:sub, 'g')
        endfor
        let s:errors[l:i] = join([ l:callstack, l:message ], '')
    endfor
endfunction

function! testini#run() abort
    " Keep errors in the script variable so they can be accessed by timeout
    let s:errors = []
    call s:source()
    for l:suite in keys(s:suites)
        call s:run_part(l:suite, 'before', 'suite')
        for l:test in keys(s:suites[l:suite].test)
            call s:run_part(l:suite, 'before', 'each')
            call s:run_part(l:suite, 'test', l:test)
            call s:run_part(l:suite, 'after', 'each')
        endfor
        call s:run_part(l:suite, 'after', 'suite')
    endfor
    call s:decode_callstacks()
    return s:errors
endfunction

function! testini#run_ci() abort
    if testini#run() != []
        call writefile(s:errors, 'testini.log')
        cquit! 1
    endif
    quit!
endfunction

