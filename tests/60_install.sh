#!/usr/bin/env bash
# shellcheck disable=SC2016,SC1091

export test_description="pass-tomb installation."
cd tests
source ./commons

if test_have_prereq TRAVIS; then
    test_expect_success 'Testing install.' '
        sudo make --directory=$PROJECT_HOME install
        '

    export PASSWORD_STORE_ENABLE_EXTENSIONS=''
    export PASSWORD_STORE_EXTENSIONS_DIR=''
    test_export password  # Using already generated tomb
    test_expect_success 'Testing installated extension.' '
        _pass open &&
        _pass close
        '

    test_expect_success 'Testing uninstall.' '
        sudo make --directory=$PROJECT_HOME uninstall
        '
fi

test_done
