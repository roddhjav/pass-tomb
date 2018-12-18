#!/usr/bin/env bash
# shellcheck disable=SC2016,SC1091

export test_description="pass-tomb with timer."
cd tests
source ./commons

_tomb_unmounted() {
    local name="$1"
    test -z "$(mount -l | grep "/dev/mapper/tomb.$name")"
    return $?
}

# Ensure the tomb is closed before to continue
_waitfor() {
    local name="$1"
    while ! _tomb_unmounted "$name"; do
        sleep 5
    done
}

if test_have_prereq SYSTEMD; then
    # Install the pass-close service
    sudo install -m 0644 "$PROJECT_HOME/timer/pass-close@.service" \
        /etc/systemd/system/pass-close@.service

    test_export timer
    test_expect_success 'Testing timer: password store creation' '
        _pass tomb $KEY1 --timer=10s --verbose --unsafe &&
        [[ -e $PASSWORD_STORE_DIR/.timer ]] &&
        [[ "$(cat $PASSWORD_STORE_DIR/.timer)" == "10s" ]] &&
        systemctl is-active pass-close@timer.timer &&
        systemctl status pass-close@timer.timer
        '

    test_export password  # Using already generated tomb
    test_expect_success 'Testing timer: password store opening with given time' '
        _pass open --timer=10s --verbose &&
        [[ "$(cat $PASSWORD_STORE_DIR/.timer)" == "10s" ]] &&
        systemctl is-active pass-close@password.timer &&
        systemctl status pass-close@password.timer
        '

    _waitfor timer
    test_export timer  # Using already generated tomb
    test_expect_success 'Testing timer: password store re-opening' '
        _pass open --verbose &&
        systemctl is-active pass-close@timer.timer &&
        systemctl status pass-close@timer.timer
        '

    _waitfor timer
    test_expect_success 'Testing timer: with wrong time value' '
        _pass open --timer=nan --verbose &&
        test_must_fail systemctl is-active pass-close@timer.timer
        '
fi

test_done
