#!/usr/bin/env bash
# shellcheck disable=SC2016,SC1091

export test_description="pass-tomb without store initialisation."
cd tests
source ./commons

test_export "noinit"
test_expect_success 'Testing password store creation without store initialisation' '
    _pass tomb $KEY1 --no-init --verbose --unsafe &&
    _pass init $KEY2 &&
    _pass_populate &&
    _pass close
    '

test_done
