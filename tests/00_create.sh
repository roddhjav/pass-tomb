#!/usr/bin/env bash
# shellcheck disable=SC2016,SC1091

export test_description="pass-tomb creation"
cd tests
source ./commons
test_cleanup

test_export "password"
test_expect_success 'Password tomb creation & populate' '
    _pass tomb $KEY1 --verbose --unsafe &&
    _pass_populate &&
    _pass close
    '

test_expect_success 'Password tomb open & close' '
    _pass open &&
    _pass_populate &&
    _pass close
    '

test_expect_success 'Password tomb creation with plain swap' '
    sudo swapon -a &&
    _pass open --force &&
    _pass close &&
    sudo swapoff -a
    '

test_done
