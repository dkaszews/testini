#!/usr/bin/env bash

# While Testini is designed to need no runner scripts, it is better to write
# a simple one for Testini itself. Otherwise, there is a risk that some fatal
# error such as `return []` at top of `testini#run` might cause a failure that
# is not detectable inside the framework itself.

SCRIPT_ROOT=$(realpath $(dirname $0))
TESTINI_ROOT=$(realpath $SCRIPT_ROOT/..)
TESTINI_VIM=$(realpath $TESTINI_ROOT/plugin/testini.vim)

diff_logs () {
    actual=$1
    expected="expected_${actual}"
    diff -u $expected $actual
    diff_failures=$(( $diff_failures + $? ))
}

test_failures=0
pushd $SCRIPT_ROOT > /dev/null
for dir in */; do
    pushd $dir > /dev/null
    echo "Running tests from $(realpath .)"

    rm -f testini.log exitcode.log
    vim -u $TESTINI_VIM -c TestiniCi
    echo $? > exitcode.log
    diff_failures=0
    diff_logs exitcode.log
    diff_logs testini.log
    if [[ $diff_failures -gt 0 ]]; then
        test_failures=$(( $test_failures + 1 ))
    fi

    popd > /dev/null
done
popd > /dev/null

if [[ $test_failures -eq 0 ]]; then
    echo 'All tests passed'
    exit 0
else
    echo "${test_failures} tests failed!"
    exit 1
fi

