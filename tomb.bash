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

TOMB="${PASSWORD_STORE_TOMB:-tomb}"
TOMB_FILE="${PASSWORD_STORE_TOMB_FILE:-$HOME/password}"
TOMB_KEY="${PASSWORD_STORE_TOMB_KEY:-$HOME/password.key}"
TOMB_SIZE="${PASSWORD_STORE_TOMB_SIZE:-10}"
TOMB_COMMANDS=(	"dig" "forge" "lock" "open" "index" "search" "list" "close"
				"slam" "resize" "passwd" "setkey" "engrave" "bury" "exhume")

typeset -a TMPFILES
TMPFILES=()

#
# Color Code
#
bold=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
reset=$(tput sgr0)

#
# Commons tools and functions
#
_title() { echo "${bold}${blue}::${reset} ${bold}${*}${reset}"; }
_msg() { echo " ${*}"; }
_alert() { echo " ${bold}${yellow}(*)${reset} ${*}"; }
_warn() { echo " ${bold}${yellow}[W]${reset}${bold} Warning :${reset} ${*}"; }
_success() { echo " ${bold}${green}(*) ${*}${reset}"; }
_error() { echo " ${bold}${red}[*]${reset}${bold} Error :${reset} ${*}"; }
_die() { _error "${@}" && exit 1; }
_verbose() { _alert "${@}"; }

# Check program dependencies
#
# pass tomb depends on tomb>2.3
_ensure_dependencies() {
    command -v $TOMB 1>/dev/null 2>/dev/null || _die "tomb is not present"
}

_basename() { # From https://github.com/chilicuil/learn
    [ -z "${1}" ] && return 1 || _basename__name="${1%%/}"
    [ -z "${2}" ] || _basename__suffix="${2}"
    case "${_basename__name}" in
        /*|*/*) _basename__name="$(expr "${_basename__name}" : '.*/\([^/]*\)')" ;;
    esac

    if [ -n "${_basename__suffix}" ] && [ "${#_basename__name}" -gt "${#2}" ]; then
        if [ X"$(printf "%s" "${_basename__name}" | cut -c"$((${#_basename__name} - ${#_basename__suffix} + 1))"-"${#_basename__name}")" \
           = X"$(printf "%s" "${_basename__suffix}")" ]; then
            _basename__name="$(printf "%s" "${_basename__name}" | cut -c1-"$((${#_basename__name} - ${#_basename__suffix}))")"
        fi
    fi

    printf "%s" "${_basename__name}"
}

in_array() {
	local needle=$1; shift
	local item
	for item in "${@}"; do
		[[ ${item} == ${needle} ]] && return 0
	done
	return 1
}

# $@ is the list of all the recipient used to encrypt a tomb key
is_valid_recipients() {
    typeset -a recipients
    local tmp
    recipients=($@)   # 
    
	# All the keys ID must be valid (the public keys must be present in the database)
    for gpg_id in ${recipients[@]}; do
        tmp=$(gpg --list-keys "$gpg_id")
        [[ $? != 0 ]] && {
            _warn "$gpg_id is not a valid key ID."
            return 1
        }
    done

	# At least one private key must be present
    for gpg_id in $recipients; do
        tmp=$(gpg --list-secret-keys "$gpg_id")
        [[ $? = 0 ]] && { 
            return 0
        }
    done

	return 1
}

_tomb() {
	local cmd="$1"; shift
	"$TOMB" -D "$cmd" "$@" 2> "$TMP"
	[[ $? == 0 ]] || {
		_die "Unable to $cmd the password tomb"
	}
}

# Provide a random filename in shared memory
_tmp_create() {
	TMPPREFIX=/tmp
	
    tfile="${TMPPREFIX}/$RANDOM$RANDOM$RANDOM$RANDOM"   # Temporary file
    umask 066
    [[ $? == 0 ]] || {
        _die "Fatal error setting the permission umask for temporary files"; }

    [[ -r "$tfile" ]] && {
        _die "Someone is messing up with us trying to hijack temporary files."; }

    touch "$tfile"
    [[ $? == 0 ]] || {
        _die "Fatal error creating a temporary file: $tfile"; }

    TMP="$tfile"
    TMPFILES+=("$tfile")

    return 0
}

cmd_tomb_help() {
	cat <<-_EOF
	Usage:
	    $PROGRAM tomb gpg-id...
	    	Create and initialise a new password tomb.
	    	Use gpg-id for encryption of both tomb and passwords
	    $PROGRAM tomb <tomb_cmd> [ARG]
	    	Wrapper to execute a tomb command for password tomb management.
	    	If a required arguments is not present, this functions will detect
	    	it and add the default value in pass-tomb as arguments.
	    $PROGRAM tomb help
	    	Print this help
	    $PROGRAM open
	    	Open a password tomb
	    $PROGRAM close
	    	Close a password tomb

	More information may be found in the pass-tomb(1) man page.
	_EOF
}

cmd_open() {

	# Sanity checks
	check_sneaky_paths "$TOMB_FILE"
	check_sneaky_paths "$TOMB_KEY"
	[[ -e "$TOMB_FILE" ]] || _die "There is no password tomb to open."
	[[ -e "$TOMB_KEY" ]] || _die "There is no password tomb key."
	
	_tmp_create
	_tomb open "$TOMB_FILE" -k "$TOMB_KEY" -f -r "dummy-gpgid" "$PREFIX"
	sudo chown -R $USER:$USER "$PREFIX" || _die "Unable to set the permission on $PREFIX"
	while read ii; do
		_verbose "$ii"
	done <$TMP
	
	return 0
}

cmd_close() {
	TOMB_NAME=$(_basename "$TOMB_FILE")
	
	_tmp_create
	_tomb close "$TOMB_NAME"
	while read ii; do
		_verbose "$ii"
	done <$TMP
	
	return 0
}

cmd_tomb_create() {
	TOMB_RECIPIENTS=($@)
	PASSWORD_STORE_SIGNING_KEY=${TOMB_RECIPIENTS[0]}
	
	# Sanity checks
	check_sneaky_paths "$TOMB_FILE"
	check_sneaky_paths "$TOMB_KEY"
	{ is_valid_recipients $TOMB_RECIPIENTS ;} || { _die "You set an invalid GPG ID." ;}
	[[ -e "$TOMB_KEY" ]] && _die "The tomb key $TOMB_KEY already exists. I won't overwrite it."
	[[ -e "$TOMB_FILE" ]] && _die "The password tomb $TOMB_FILE already exists. I won't overwrite it."
	[[ "$TOMB_SIZE" -lt 10 ]] && _die "A password tomb cannot be smaller than 10 mebibytes."
	
	# Create the password tomb
	_tmp_create
	_tomb dig "$TOMB_FILE" -s "$TOMB_SIZE"
	_tomb forge "$TOMB_KEY" -r "$TOMB_RECIPIENTS"
	_tomb lock "$TOMB_FILE" -k "$TOMB_KEY" -r "$TOMB_RECIPIENTS"
	_tomb open "$TOMB_FILE" -k "$TOMB_KEY" -r "$TOMB_RECIPIENTS" "$PREFIX"
	sudo chown -R $USER:$USER "$PREFIX" || _die "Unable to set the permission on $PREFIX"
	while read ii; do
		_verbose "$ii"
	done <$TMP
}


tomb_cmd() {
	
	return 0
}

cmd_tomb() {

	_ensure_dependencies  # Check dependencies are present or bail out
	check_sneaky_paths "$1"
	
	if in_array "$1" ${TOMB_COMMANDS[@]}; then
		tomb_cmd "$@"
	elif [[ "$1" == "help" ]]; then
		cmd_tomb_help
	else
		cmd_tomb_create "$1"
	fi

    return $?
}

[[ "$COMMAND" == "tomb" ]] && cmd_tomb "$@"
