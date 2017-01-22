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

cmd_tomb_help() {
	cat <<-_EOF

	More information may be found in the pass-tomb(1) man page.
	_EOF
}

cmd_open() {

	return 0
}

cmd_close() {
	
	return 0
}

cmd_tomb_create() {
	return 0
}


tomb_cmd() {
	
	return 0
}

cmd_tomb() {


    return 0
}

[[ "$COMMAND" == "tomb" ]] && cmd_tomb "$@"
