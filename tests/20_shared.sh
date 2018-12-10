#!/usr/bin/env bash
# shellcheck disable=SC2016,SC1091

export test_description="pass-tomb with shared keys."
cd tests
source ./commons

test_export "shared"
test_expect_success 'Testing a shared password tomb' '
    _pass tomb $KEY1 $KEY2 $KEY3 --verbose --unsafe &&
    _pass_populate &&
    _pass close
    '

test_done
