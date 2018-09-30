#!/usr/bin/env bash
# shellcheck disable=SC2016,SC1091

export test_description="pass-tomb with timer."

source ./setup

_tomb_unmounted() {
    local name="$1"
    test -z "$(mount -l | grep "/dev/mapper/tomb.$name")"
    return $?
}

if test_have_prereq SYSTEMD; then

    test_export "timer"
    test_expect_success 'Testing timer: password store creation' '
        _pass tomb $KEY1 --timer=20s --verbose --unsafe &&
        [[ -e $PASSWORD_STORE_DIR/.timer ]] &&
        [[ "$(cat $PASSWORD_STORE_DIR/.timer)" == "20s" ]]
        '

    test_export "password" # Using already generated tomb
    test_expect_success 'Testing timer: password store opening with given time' '
        _pass open --timer=20s --verbose &&
        [[ "$(cat $PASSWORD_STORE_DIR/.timer)" == "20s" ]]
        '

    test_export "shared" # Using already generated tomb
    test_expect_success 'Testing timer: ensure password store is open long enough' '
        _pass open --timer=20s --verbose &&
        [[ -e $PASSWORD_STORE_DIR/.timer ]] &&
        [[ "$(cat $PASSWORD_STORE_DIR/.timer)" == "20s" ]] &&
        sleep 10s &&
        test_must_fail _tomb_unmounted "shared"
        '

    sleep 30s
    test_expect_success 'Testing timer: ensure all password store are closed' '
        _tomb_unmounted "timer" &&
        _tomb_unmounted "password"
        '

    test_export "timer" # Using already generated tomb
    test_expect_success 'Testing timer: password store opening' '
        _pass open --verbose &&
        sleep 40s &&
        _tomb_unmounted
        '
fi

test_done
