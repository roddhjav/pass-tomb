#!/usr/bin/env bash
# shellcheck disable=SC2016,SC1091

export test_description="pass-tomb with timer."
cd tests
source ./commons


# Ensure the tomb is closed before to continue
test_waitfor() {
    while systemctl is-active "pass-close@$1.timer"; do
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

    test_waitfor timer
    test_expect_success 'Testing timer: with wrong time value' '
        _pass open --timer=nan --verbose &&
        test_must_fail systemctl is-active pass-close@timer.timer
        '
fi

test_done
