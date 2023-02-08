#!/usr/bin/env bash

# While Testini is designed to need no runner scripts, it is better to write
# a simple one for Testini itself. Otherwise, there is a risk that some fatal
# bug such as `return []` at top of `testini#run` might cause a failure that
# is not detectable inside the framework itself. Plus, want negative cases.

VIM=${1:-vim}
NEOVIM=$($VIM --version | grep -cm1 'NVIM')
HEADLESS=$([[ $NEOVIM -ne 0 ]] && echo '--headless' || echo '--not-a-term')
SCRIPT_ROOT=$(cd "$(dirname "$0")"; pwd -P)
TESTINI_ROOT="${SCRIPT_ROOT}/.."
TESTINI_VIM="${TESTINI_ROOT}/plugin/testini.vim"

get_expected_exitcode() {
    file=$(ls -1 ?.expected)
    echo ${file//[^[0-9]/}
}

total_failed=0
pushd $SCRIPT_ROOT > /dev/null
for dir in */; do
    echo -e "Running tests from ${dir}"
    pushd $dir > /dev/null

    $VIM $HEADLESS -u $TESTINI_VIM -c TestiniCi
    exitcode=$?
    expected_exitcode=$(get_expected_exitcode)

    failed=0
    [[ $exitcode -ne $expected_exitcode ]] && failed=1 \
        && echo "Expected exitcode: ${expected_exitcode}, actual: ${exitcode}"
    diff -u ?.expected 'testini.log' || failed=1
    (( total_failed += $failed ))

    popd > /dev/null
done
popd > /dev/null

echo -e "\n${total_failed} tests failed"
[[ $total_failed -eq 0 ]] && exit 0 || exit 1

