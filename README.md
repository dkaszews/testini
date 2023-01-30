# Testini[!](https://youtu.be/3BDfA0DSqn8)

Lightweight unit testing framework for vimscript/viml.
Designed to make testing vim plugins as quick, pleasant and hassle-free as possible, encourage [test-driven development](https://en.wikipedia.org/wiki/Test-driven_development) and modular, testable design with useful APIs.

## Features

* Test vimscript plugins in pure vimscript, with [as little as 4 lines of code](#usage)
* Run as CI as a oneliner, [no runner script needed](#as-continous-integration)
* Suites with setup/teardown
* Terminating and non-terminating assertions
* Callstack for failed assertions and thrown exceptions
* _Enumerate tests and run those matching pattern (roadmap)_
* _Parametric tests (roadmap)_
* _Test time and timeout (roadmap)_

## Usage

Create a file with extension `mytest.tesitni.vim` with following content:

```viml
let s:suite = testini#suite()
function s:suite.test.two_plus_two_is_four() abort
    call assert_equal(4, 2 + 2)
endfunction
```

Save the file and run `Testini` command.
You should see an empty array as a result, which means no tests have failed.

If you change the `assert_equal(4, 2 + 2)` to `assert_equal(5, 2 + 2)`, resave and rerun, you will see instead output like:

```viml
['mytest.test.two_plus_two_is_four[1]: Expected 5 but got 4']
```

### Instalation

With [`vim-plug`](https://github.com/junegunn/vim-plug) add to your .vimrc:

```viml
call plug#begin()
Plug 'dkaszews/testini'
call plug#end()
```

### As [continous integration](https://en.wikipedia.org/wiki/Continuous_integration)

Above instructions are useful for adding Testini to your existing workspace.
For CI however, it is more desirable to start from clean slate to make results repeatable.
By design, Testini does not provide a runner script, instead all you need to do is run the following:

```bash
vim -u path_to_testini/plugin/testini.vim -c TestiniCi
```

The `-u` option treats loads Testini at startup while at the same time preventing loading of the default `.vimrc`.
[`TestiniCi`](#) is roughly equivalent to the regular `Testini` command, but it writes results to file `testini.log` quits vim with exit code indicating a success or failure which the CI environment can pick up.

To add Testini itself to your CI workspace, simply clone it.
If you clone it inside your own plugin, it is recommended to do it in a dot-hidden directory so that Testini's own tests are not picked up be the glob:

```bash
[[ -d .testini ]] || https://github.com/dkaszews/testini .testini
```

To load your own plugin or additional dependencies, you can place those commands in the script scope of one of your tests, or a separate file such as `init.testini.vim`, as it will be sourced before all tests are run, even if it does not call `testini#suite()` itself.

## Test structure

All tests are defined by first registering a suite with a call to `testini#suite()`, then adding function to the object returned.
The name of the suite is the same as the name of the file, without extension.
Suite names are required to be unique.

### `suite` object

#### `suite.test.{testname}`

Defines a test `{testname}` in suite.
The test is considered failed if it throws an exception or adds to `v:errors`.

#### `suite.before.each`

Defines a function to be run before each test in the suite.
A failure (exception or adding to `v:errors`) aborts run of the test.

#### `suite.after.each`

Defines a function to be run after each test in the suite.
A failure (exception or adding to `v:errors`) is treated as a failure in the last run test, so can be used for common assertions.

#### `suite.before.all`

Defines a function to be run once in the suite, before any tests.
A failure (exception or adding to `v:errors`) aborts run of the suite.

#### `suite.after.all`

Defines a function to be run once in the suite, after all tests.
A failure (exception or adding to `v:errors`) is reported separately.

### Free functions

For assertions, you can use builtin functions like `assert_equal`, or define your own which adds to `v:errors` directly or indirectly.
For more details, see `:help assert-functions`.

#### `testini#ignore([ {message} ])`

Terminates current test with optional message.
The test's status is the same as at time of call, so recommended to place it as the first instruction, so that ignored tests are not failed.
This is equivalent to calling `return` inside the test function, but can also be used inside helper functions deeper in the callstack.

#### `testini#verify([ {assertion}, [ {assertion}, ...] ])`

Vim's builtin functions like `assert_equal` are non-terminating, meaning a failure does not stop running the test.
This is similar to [`gtest EXPECT_*`](http://google.github.io/googletest/primer.html#assertions) and is useful to perform multiple independent checks and get more information in case of failure.
For terminating assertions, when a failure makes the reminder of the test pointless, `testini#verify()` is provided.

If called with results of assertion functions, it terminates test if any of those assertions have failed (returned 1). Otherwise, it terminates test if any of prior assertions have failed:

```viml
call assert_something_else()
let l:values = get_values()
" Terminate if we don't have at least 3 values, ignores previous assert
call testini#verify(assert_true(len(l:values) >= 3, 'len(l:values): ' .. len(l:values)))
call foo(l:values[:2])
for l:value in l:values
    " Non-terminating independent assert of each value
    call assert_equal(10, l:value)
endfor
" Terminate if any prior assertions have failed
call testini#verify()
...
```

## Commands and functions

#### `Testini` `testini#run()`

Runs all tests, returns array of failed assertions and thrown exceptions, or empty array if all tests have passed.

#### `TestiniCi` `testini#run_ci()`

Same as above, but writes result to `testini.log`, then exits vim with exit code `0` if all tests have passed, or `1` if any of them have failed.

## FAQ

#### Why not use one of existing vim testing frameworks?

Most vim plugins either roll their own over-specialized testing frameworks, or, much worse, don't have any tests at all.
Existing general-purpose frameworks are overcomplicated, with thousands of lines of implementation and bloated runner scripts which may or may not work in all environment.
Moreover, frameworks such as [`Vader`](https://github.com/junegunn/vader.vim) focus on functional testing by emulating user input and checking contents of whole buffers.

![](https://imgs.xkcd.com/comics/standards.png)

Also, [XKCD 927](https://xkcd.com/927/).

