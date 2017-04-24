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

export test_description="Testing pass tomb, pass open and pass close."

source ./setup.sh
test_cleanup

export PASSWORD_STORE_DIR="$SHARNESS_TRASH_DIRECTORY/password-store"
export PASSWORD_STORE_TOMB_FILE="$SHARNESS_TRASH_DIRECTORY/password.tomb"
export PASSWORD_STORE_TOMB_KEY="$SHARNESS_TRASH_DIRECTORY/password.tomb.key"
test_expect_success 'Password tomb creation & populate' '
    _pass tomb "$KEY1" --verbose --unsafe &&
    test_pass_populate &&
    _pass close
    '

test_expect_success 'Password tomb open & close' '
    _pass open &&
    _pass close
    '

export PASSWORD_STORE_DIR="$SHARNESS_TRASH_DIRECTORY/noinit-store"
export PASSWORD_STORE_TOMB_FILE="$SHARNESS_TRASH_DIRECTORY/noinit.tomb"
export PASSWORD_STORE_TOMB_KEY="$SHARNESS_TRASH_DIRECTORY/noinit.tomb.key"
test_expect_success 'Testing password store creation without store initialisation' '
    _pass tomb "$KEY1" --no-init --verbose --unsafe &&
    _pass init "$KEY2" &&
    test_pass_populate &&
    _pass close
    '

export PASSWORD_STORE_DIR="$SHARNESS_TRASH_DIRECTORY/shared-store"
export PASSWORD_STORE_TOMB_FILE="$SHARNESS_TRASH_DIRECTORY/shared.tomb"
export PASSWORD_STORE_TOMB_KEY="$SHARNESS_TRASH_DIRECTORY/shared.tomb.key"
test_expect_success 'Testing a shared password tomb' '
    _pass tomb "$KEY1" "$KEY2" "$KEY3" --verbose --unsafe &&
    test_pass_populate &&
    _pass close
    '

export PASSWORD_STORE_DIR="$SHARNESS_TRASH_DIRECTORY/subfolder-store"
export PASSWORD_STORE_TOMB_FILE="$SHARNESS_TRASH_DIRECTORY/subfolder.tomb"
export PASSWORD_STORE_TOMB_KEY="$SHARNESS_TRASH_DIRECTORY/subfolder.tomb.key"
test_expect_success 'Testing password tomb in subfolder' '
    path="perso"
    _pass tomb "$KEY1" --path="$path" --verbose --unsafe &&
    test_pass_populate "$path" &&
    _pass close &&
    _pass open "$path" &&
    _pass close
    '

test_done
