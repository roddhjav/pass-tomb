#!/usr/bin/env bash
# shellcheck disable=SC2016,SC1091

export test_description="pass-tomb in subfolder."
cd tests
source ./commons

test_export "subfolder"
test_expect_success 'Testing password tomb in subfolder' '
    path=perso &&
    _pass tomb $KEY1 --path=$path --verbose --unsafe &&
    _pass_populate $path &&
    _pass close &&
    _pass open $path &&
    _pass close
    '

test_done
