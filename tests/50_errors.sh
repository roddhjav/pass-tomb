#!/usr/bin/env bash
# shellcheck disable=SC2016,SC1091

export test_description="pass-tomb errors handling."

source ./setup

test_export "invalidkey"
test_expect_success 'Password tomb creation with invalid key' '
    test_must_fail _pass tomb $KEY_INVALID --debug --unsafe
    '

test_expect_success 'Testing wrong tomb parameters' '
    PASSWORD_STORE_TOMB_SIZE=5 test_must_fail _pass tomb $KEY1 --quiet --unsafe &&
    PASSWORD_STORE_TOMB_FILE="$TMP/password.tomb" test_must_fail _pass tomb $KEY1 --quiet --unsafe &&
    PASSWORD_STORE_TOMB_KEY="$TMP/password.key" test_must_fail _pass tomb $KEY1 --quiet --unsafe
    '

test_expect_success 'Testing help messages' '
    _pass tomb --help &&
    _pass tomb --version
    '

test_done
