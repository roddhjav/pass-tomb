#!/usr/bin/env bash
# Tomb manager - Password Store Extension (https://www.passwordstore.org/)
# Copyright (C) 2017 Alexandre PUJOL <alexandre@pujol.io>.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# shellcheck disable=SC2016,SC1091

export test_description="pass-tomb, test suite."

source ./setup.sh
test_cleanup

test_export "password"
test_expect_success 'Password tomb creation & populate' '
    _pass tomb "$KEY1" --verbose --unsafe &&
    test_pass_populate &&
    _pass close
    '

test_expect_success 'Password tomb open & close' '
    _pass open &&
    _pass close
    '

test_export "noinit"
test_expect_success 'Testing password store creation without store initialisation' '
    _pass tomb "$KEY1" --no-init --verbose --unsafe &&
    pass init "$KEY2" &&
    test_pass_populate &&
    _pass close
    '

test_export "shared"
test_expect_success 'Testing a shared password tomb' '
    _pass tomb "$KEY1" "$KEY2" "$KEY3" --verbose --unsafe &&
    test_pass_populate &&
    _pass close
    '

test_export "subfolder"
test_expect_success 'Testing password tomb in subfolder' '
    path="perso"
    _pass tomb "$KEY1" --path="$path" --verbose --unsafe &&
    test_pass_populate "$path" &&
    _pass close &&
    _pass open "$path" &&
    _pass close
    '

test_expect_success 'Testing help message' '
	_pass tomb --help &&
    _pass tomb --version
	'

test_done
