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

# shellcheck disable=SC2181

readonly TOMB="${PASSWORD_STORE_TOMB:-tomb}"
readonly TOMB_FILE="${PASSWORD_STORE_TOMB_FILE:-$HOME/.password}"
readonly TOMB_KEY="${PASSWORD_STORE_TOMB_KEY:-$HOME/.password.key}"
readonly TOMB_SIZE="${PASSWORD_STORE_TOMB_SIZE:-10}"

readonly _UID="$(id -u "$USER")"
readonly _GID="$(id -g "$USER")"

#
# Common colors and functions
#
readonly green='\e[0;32m'
readonly yellow='\e[0;33m'
readonly magenta='\e[0;35m'
readonly Bold='\e[1m'
readonly Bred='\e[1;31m'
readonly Bgreen='\e[1;32m'
readonly Byellow='\e[1;33m'
readonly Bblue='\e[1;34m'
readonly Bmagenta='\e[1;35m'
readonly reset='\e[0m'
_message() { [ "$QUIET" = 0 ] && echo -e " ${Bold} . ${reset} ${*}" >&2; }
_warning() { [ "$QUIET" = 0 ] && echo -e " ${Byellow} w ${reset} ${yellow}${*}${reset}" >&2; }
_success() { [ "$QUIET" = 0 ] && echo -e " ${Bgreen}(*)${reset} ${green}${*}${reset}" >&2; }
_error() { echo -e " ${Bred}[x]${reset} ${Bold}Error :${reset} ${*}" >&2; }
_die() { _error "${@}" && exit 1; }
_verbose() { [ "$VERBOSE" = 0 ] || echo -e " ${Bmagenta} . ${reset} ${magenta}pass${reset} ${*}" >&2; }
_verbose_tomb() { [ "$VERBOSE" = 0 ] || echo -e " ${Bmagenta} . ${reset} ${*}" >&2; }

# Check program dependencies
#
# pass tomb depends on tomb
_ensure_dependencies() {
	command -v "$TOMB" &> /dev/null || _die "Tomb is not present."
}

# $@ is the list of all the recipient used to encrypt a tomb key
is_valid_recipients() {
	typeset -a recipients
	recipients=($@)

	# All the keys ID must be valid (the public keys must be present in the database)
	for gpg_id in "${recipients[@]}"; do
		gpg --list-keys "$gpg_id" &> /dev/null
		if [[ $? != 0 ]]; then
			_warning "${gpg_id} is not a valid key ID."
			return 1
		fi
	done

	# At least one private key must be present
	for gpg_id in "${recipients[@]}"; do
		gpg --list-secret-keys "$gpg_id" &> /dev/null
		if [[ $? = 0 ]]; then
			return 0
		fi
	done
	return 1
}

_tomb() {
	local ii ret
	local cmd="$1"; shift
	"$TOMB" "$cmd" "$@" "$DEBUG" &> "$TMP"
	ret=$?
	while read -r ii; do
		_verbose_tomb "$ii"
	done <"$TMP"
	[[ $ret == 0 ]] || _die "Unable to ${cmd} the password tomb."
}

# Provide a random filename in shared memory
_tmp_create() {
	local tfile
	tmpdir	# Defines $SECURE_TMPDIR
	tfile="$(mktemp -u "$SECURE_TMPDIR/XXXXXXXXXXXXXXXXXXXX")" # Temporary file

	umask 066
	[[ $? == 0 ]] || _die "Fatal error setting permission umask for temporary files."
	[[ -r "$tfile" ]] && _die "Someone is messing up with us trying to hijack temporary files.";

	touch "$tfile"
	[[ $? == 0 ]] || _die "Fatal error creating temporary file: ${tfile}."

	TMP="$tfile"
	return 0
}

# Set ownership when mounting a tomb
# $1: Tomb path
_set_ownership() {
	local path="$1"
	_verbose "Setting user permissions on ${path}"
	sudo chown -R "${_UID}:${_GID}" "${path}" || _die "Unable to set ownership permission on ${path}."
	sudo chmod 0711 "${path}" || _die "Unable to set permissions on ${path}."
}

cmd_tomb_verion() {
	cat <<-_EOF
	$PROGRAM tomb - A pass extension allowing you to put and manage your
	            password store in a tomb.

	Version: 0.1
	_EOF
}

cmd_tomb_usage() {
	cmd_tomb_verion
	echo
	cat <<-_EOF
	Usage:
	    $PROGRAM tomb [--path=subfolder,-p subfolder] gpg-id...
	        Create and initialise a new password tomb
	        Use gpg-id for encryption of both tomb and passwords
	    $PROGRAM open
	        Open a password tomb
	    $PROGRAM close
	        Close a password tomb

	Options:
	    -n, --no-init  Do not initialise the password store
		-t, --timer    Close the store after a given time (default: 1 hour)
	    -q, --quiet    Be quiet
	    -v, --verbose  Print tomb message
	    -d, --debug    Print tomb debug message
	        --unsafe   Speed up tomb creation (for testing only)
	    -V, --version  Show version information.
	    -h, --help	   Print this help message and exit.

	More information may be found in the pass-tomb(1) man page.
	_EOF
}

# Open a password tomb
cmd_open() {
	local path="$1"; shift;
	_verbose "Opening the password tomb $TOMB_FILE using the key $TOMB_KEY"

	# Sanity checks
	check_sneaky_paths "$path"
	check_sneaky_paths "$TOMB_FILE"
	check_sneaky_paths "$TOMB_KEY"
	[[ -e "$TOMB_FILE" ]] || _die "There is no password tomb to open."
	[[ -e "$TOMB_KEY" ]] || _die "There is no password tomb key."

	# Open the passwod tomb
	_tmp_create
	_tomb open "$TOMB_FILE" -k "$TOMB_KEY" -g "${PREFIX}/${path}"
	_set_ownership "${PREFIX}/${path}"

	_success "Your password tomb has been opened in ${PREFIX}/."
	_message "You can now use pass as usual."
	_message "When finished, close the password tomb using 'pass close'."
	return 0
}

# Close a password tomb
cmd_close() {
	local _tomb_name _tomb_file="$1"
	[[ -z "$_tomb_file" ]] && _tomb_file="$TOMB_FILE"
	_verbose "Closing the password tomb $_tomb_file"

	# Sanity checks
	check_sneaky_paths "$_tomb_file"
	[[ -e "$_tomb_file" ]] || _die "There is no password tomb to close."
	_tomb_name=${_tomb_file##*/}
	_tomb_name=${_tomb_name%.*}
	[[ -z "$_tomb_name" ]] && _die "There is no password tomb."

	_tmp_create
	_tomb close "$_tomb_name"

	_success "Your password tomb has been closed."
	_message "Your passwords remain present in ${_tomb_file}."
	return 0
}

# Create a new password tomb and initialise the password repository.
# $1: path subfolder
# $@: gpg-ids
cmd_tomb() {
	local path="$1"; shift;
	typeset -a RECIPIENTS
	[[ -z "$*" ]] && _die "$PROGRAM $COMMAND [--path=subfolder,-p subfolder] gpg-id..."
	RECIPIENTS=($@)
	_verbose "Creating a password tomb with the GPG key(s): ${RECIPIENTS[*]}"

	# Sanity checks
	check_sneaky_paths "$path"
	check_sneaky_paths "$TOMB_FILE"
	check_sneaky_paths "$TOMB_KEY"
	if ! is_valid_recipients "${RECIPIENTS[@]}"; then
		_die "You set an invalid GPG ID."
	elif [[ -e "$TOMB_KEY" ]]; then
		_die "The tomb key ${TOMB_KEY} already exists. I won't overwrite it."
	elif [[ -e "$TOMB_FILE" ]]; then
		_die "The password tomb ${TOMB_FILE} already exists. I won't overwrite it."
	elif [[ "$TOMB_SIZE" -lt 10 ]]; then
		_die "A password tomb cannot be smaller than 10 MB."
	fi
	if [[ $UNSAFE -ne 0 ]]; then
		_warning "Using unsafe mode to speed up tomb generation."
		_warning "Only use it for testing purposes."
		local unsafe=(--unsafe --use-urandom)
	fi

	# Sharing support
	local recipients_arg tmp_arg
	if [ "${#RECIPIENTS[@]}" -gt 1 ]; then
		tmp_arg="${RECIPIENTS[*]}"
		recipients_arg=${tmp_arg// /,}
	else
		recipients_arg="${RECIPIENTS[0]}"
	fi

	# Create the password tomb
	_tmp_create
	_tomb dig "$TOMB_FILE" -s "$TOMB_SIZE"
	_tomb forge "$TOMB_KEY" -gr "$recipients_arg" "${unsafe[@]}"
	_tomb lock "$TOMB_FILE" -k "$TOMB_KEY" -gr "$recipients_arg"
	_tomb open "$TOMB_FILE" -k "$TOMB_KEY" -gr "$recipients_arg" "${PREFIX}/${path}"
	_set_ownership "${PREFIX}/${path}"

	# Use the same recipients to initialise the password store
	local ret path_cmd=()
	if [[ $NOINIT -eq 0 ]]; then
		[[ -z "$path" ]] || path_cmd=("--path=${path}")
		ret="$(cmd_init "${RECIPIENTS[@]}" "${path_cmd[@]}")"
		if [[ ! -e "${PREFIX}/${path}/.gpg-id" ]]; then
			_warning "$ret"
			_die "Unable to initialise the password store."
		fi
	fi

	# Initialise the timer
	local timer=false
	if [[ ! -z "$TIMER" ]]; then
		echo "$TIMER" > "${PREFIX}/${path}/.timer"
		_timer "$TIMER"
		[[ $? == 0 ]] && timer=true
	fi

	# Success!
	_success "Your password tomb has been created and opened in ${PREFIX}."
	[[ -z "$ret" ]] || _success "$ret"
	_message "Your tomb is: ${TOMB_FILE}"
	_message "Your tomb key is: ${TOMB_KEY}"
	if [[ -z "$ret" ]]; then
		_message "You need to initialise the store with 'pass init gpg-id...'."
	else
		_message "You can now use pass as usual."
	fi
	if [[ $timer == "true" ]]; then
		_message "This password store will be closed in $TIMER"
	else
		_message "When finished, close the password tomb using 'pass close'."
	fi
	return 0
}

# Check dependencies are present or bail out
_ensure_dependencies

# Global options
UNSAFE=0
VERBOSE=0
QUIET=0
DEBUG=""
NOINIT=0
TIMER=""

# Getopt options
small_arg="vdhVp:qny"
long_arg="verbose,debug,help,version,path:,unsafe,quiet,no-init,timer::"
opts="$($GETOPT -o $small_arg -l $long_arg -n "$PROGRAM $COMMAND" -- "$@")"
err=$?
eval set -- "$opts"
while true; do case $1 in
	-q|--quiet) QUIET=1; VERBOSE=0; DEBUG=""; shift ;;
	-v|--verbose) VERBOSE=1; shift ;;
	-d|--debug) DEBUG="-D"; VERBOSE=1; shift ;;
	-h|--help) shift; cmd_tomb_usage; exit 0 ;;
	-V|--version) shift; cmd_tomb_verion; exit 0 ;;
	-p|--path) id_path="$2"; shift 2 ;;
	-t|--timer) TIMER="$2"; shift 2 ;;
	-n|--no-init) NOINIT=1; shift ;;
	--unsafe) UNSAFE=1; shift ;;
	--) shift; break ;;
esac done

[[ $err -ne 0 ]] && cmd_tomb_usage && exit 1
[[ "$COMMAND" == "tomb" ]] && cmd_tomb "$id_path" "$@"
