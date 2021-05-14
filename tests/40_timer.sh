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
    sudo install -Dm0644 "$PROJECT_HOME/timer/pass-close@.service" /usr/lib/systemd/system/pass-close@.service
    sudo install -Dm0755 "$PROJECT_HOME/close.bash" /usr/lib/password-store/extensions/close.bash
    sudo install -Dm0755 "$PROJECT_HOME/tomb.bash" /usr/lib/password-store/extensions/tomb.bash
    sudo systemctl daemon-reload

    test_export timer
    test_expect_success 'Testing timer: password store creation' '
        _pass tomb $KEY1 --timer=10s --verbose --unsafe --force &&
        [[ -e $PASSWORD_STORE_DIR/.timer ]] &&
        [[ "$(cat $PASSWORD_STORE_DIR/.timer)" == "10s" ]] &&
        systemctl is-active pass-close@$testname.timer &&
        systemctl status pass-close@$testname.timer
        '

    test_export .password  # Using already generated tomb
    test_expect_success 'Testing timer: password store opening with given time' '
        _pass open --timer=10s --verbose --force &&
        [[ "$(cat $PASSWORD_STORE_DIR/.timer)" == "10s" ]] &&
        systemctl is-active pass-close@$testname.timer &&
        systemctl status pass-close@$testname.timer
        '

    test_waitfor .password
    test_expect_success 'Testing timer: consistant timer' '
        _pass open --verbose --force &&
       [[ "$(cat $PASSWORD_STORE_DIR/.timer)" == "10s" ]] &&
        systemctl is-active pass-close@$testname.timer &&
        systemctl status pass-close@$testname.timer
        '

    test_waitfor timer
    test_export timer  # Using already generated tomb
    test_expect_success 'Testing timer: with wrong time value' '
        _pass open --timer=nan --verbose --force &&
        test_must_fail systemctl is-active pass-close@$testname.timer
        '
fi

test_done
