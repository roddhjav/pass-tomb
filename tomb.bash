#!/usr/bin/env bash
# Tomb manager - Password Store Extension (https://www.passwordstore.org/)
# Copyright (C) 2017-2021 Alexandre PUJOL <alexandre@pujol.io>.
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

# shellcheck disable=SC2181,SC2024

readonly TOMB="${PASSWORD_STORE_TOMB:-tomb}"
readonly TOMB_FILE="${PASSWORD_STORE_TOMB_FILE:-$HOME/.password.tomb}"
readonly TOMB_KEY="${PASSWORD_STORE_TOMB_KEY:-$HOME/.password.tomb.key}"
readonly TOMB_SIZE="${PASSWORD_STORE_TOMB_SIZE:-30}"

readonly VERSION="1.3.1"

#
# Common colors and functions
#
readonly green='\e[0;32m' yellow='\e[0;33m' magenta='\e[0;35m'
readonly Bred='\e[1;31m' Bgreen='\e[1;32m' Byellow='\e[1;33m'
readonly Bmagenta='\e[1;35m' Bold='\e[1m' reset='\e[0m'
_message() { [ "$QUIET" = 0 ] && printf '  %b.%b  %s\n' "$Bold" "$reset" "$*" >&2; }
_warning() { [ "$QUIET" = 0 ] && printf '  %bw%b  %b%s%b\n' "$Byellow" "$reset" "$yellow" "$*" "$reset" >&2; }
_success() { [ "$QUIET" = 0 ] && printf ' %b(*)%b %b%s%b\n' "$Bgreen" "$reset" "$green" "$*" "$reset" >&2; }
_verbose() { [ "$VERBOSE" = 0 ] || printf '  %b.%b  %bpass%b %s\n' "$Bmagenta" "$reset" "$magenta" "$reset" "$*" >&2; }
_verbose_tomb() { [ "$VERBOSE" = 0 ] || printf '  %b.%b  %s\n' "$Bmagenta" "$reset" "$*" >&2; }
_error() { printf ' %b[x]%b %bError:%b %s\n' "$Bred" "$reset" "$Bold" "$reset" "$*" >&2; }
_die() { _error "$*" && exit 1; }
_in() { [[ $1 =~ (^|[[:space:]])$2($|[[:space:]]) ]] && return 0 || return 1; }

# Check program dependencies
#
# pass tomb depends on tomb
_ensure_dependencies() {
	command -v "$TOMB" &> /dev/null || _die "Tomb is not present."
}

# Get the trust level of a GPG public key.
_get_publictrust() {
	local gpg_id="$1"
	gpg --with-colons --batch --list-keys "$gpg_id" 2> /dev/null \
		| awk 'BEGIN { FS=":" } /^pub/ { print $2; exit}'
}

# $@ is the list of all the recipient used to encrypt a tomb key
is_valid_recipients() {
	typeset -a recipients
	IFS=" " read -r -a recipients <<< "$@"
	trusted='m f u w s'

	# All the keys ID must be valid (the public keys must be present in the database)
	for gpg_id in "${recipients[@]}"; do
		trust="$(_get_publictrust "$gpg_id")"
		if [[ $? != 0 ]]; then
			_warning "${gpg_id} is not a valid key ID."
			return 1
		elif ! _in "$trusted" "$trust"; then
			_warning "The key ${gpg_id} is not trusted enough"
			return 1
		fi
	done

	# At least one private key must be present
	for gpg_id in "${recipients[@]}"; do
		gpg --with-colons --batch --list-secret-keys "$gpg_id" &> /dev/null
		if [[ $? = 0 ]]; then
			return 0
		fi
	done
	return 1
}

_tomb() {
	local ii ret
	local cmd="$1"; shift
	"$TOMB" "$cmd" "$@" "$FORCE" "$DEBUG" &> "$TMP"
	ret=$?
	while read -r ii; do
		_verbose_tomb "$ii"
	done <"$TMP"
	[[ $ret == 0 ]] || _die "Unable to $cmd the password tomb."
}

# Systemd timer to close the passwod store.
# $1: Delay before to run the pass-close service
# $2: Path in the password store to save the delay (may be empty)
# return 0 on success, 1 otherwise
_timer() {
	local ret ii _tomb_name delay="$1" path="$2"
	_tmp_create
	_tomb_name="${TOMB_FILE##*/}"
	_tomb_name="${_tomb_name%.tomb}"
	sudo systemd-run --system --on-active="$delay" \
	                 --description="pass-close timer" \
	                 --unit="pass-close@$_tomb_name.service" \
	                 &> "$TMP"
	ret=$?
	while read -r ii; do
		_verbose "$ii"
	done <"$TMP"
	if [[ $ret == 0 ]]; then
		echo "$delay" > "$PREFIX/$path/.timer"
		_verbose "Timer successfully created"
		echo 0
	else
		_warning "Unable to set the timer to close the password tomb in $delay."
		echo 1
	fi
	return $ret
}

# Provide a random filename in shared memory
_tmp_create() {
	local tfile
	tmpdir	# Defines $SECURE_TMPDIR
	tfile="$(mktemp -u "$SECURE_TMPDIR/XXXXXXXXXXXXXXXXXXXX")" # Temporary file

	umask 066
	[[ $? == 0 ]] || _die "Fatal error setting permission umask for temporary files."
	[[ -r "$tfile" ]] && _die "Someone is messing up with us trying to hijack temporary files."

	touch "$tfile"
	[[ $? == 0 ]] || _die "Fatal error creating temporary file: $tfile."

	TMP="$tfile"
	return 0
}

# Set ownership when mounting a tomb
# $1: Tomb path
_set_ownership() {
	local _uid _gid path="$1"
	_uid="$(id -u "$USER")"
	_gid="$(id -g "$USER")"
	_verbose "Setting user permissions on $path"
	sudo chown -R "$_uid:$_gid" "$path" || _die "Unable to set ownership permission on $path."
}

cmd_tomb_version() {
	cat <<-_EOF
	$PROGRAM tomb $VERSION - A pass extension that helps to keep the whole tree of
	                password encrypted inside a tomb.
	_EOF
}

cmd_tomb_usage() {
	cmd_tomb_version
	echo
	cat <<-_EOF
	Usage:
	    $PROGRAM tomb [-n] [-t time] [-f] [-p subfolder] gpg-id...
	        Create and initialise a new password tomb
	        Use gpg-id for encryption of both tomb and passwords

	    $PROGRAM open [subfolder] [-t time] [-f]
	        Open a password tomb

	    $PROGRAM close [store]
	        Close a password tomb

	    $PROGRAM timer [store]
	        Show timer status

	Options:
	    -n, --no-init  Do not initialise the password store
	    -t, --timer    Close the store after a given time
	    -p, --path     Create the store for that specific subfolder
	    -f, --force    Force operation (i.e. even if swap is active)
	    -q, --quiet    Be quiet
	    -v, --verbose  Be verbose
	    -d, --debug    Print tomb debug messages
	        --unsafe   Speed up tomb creation (for testing only)
	    -V, --version  Show version information.
	    -h, --help     Print this help message and exit.

	More information may be found in the pass-tomb(1) man page.
	_EOF
}

# Open a password tomb
cmd_open() {
	local path="$1"; shift;

	# Sanity checks
	check_sneaky_paths "$path" "$TOMB_FILE" "$TOMB_KEY"
	[[ -e "$TOMB_FILE" ]] || _die "There is no password tomb to open."
	[[ -e "$TOMB_KEY" ]] || _die "There is no password tomb key."

	# Open the passwod tomb
	_tmp_create
	_verbose "Opening the password tomb $TOMB_FILE using the key $TOMB_KEY"
	_tomb open "$TOMB_FILE" -k "$TOMB_KEY" -g "$PREFIX/$path"
	_set_ownership "$PREFIX/$path"

	# Read, initialise and start the timer
	local timed=1
	if [[ -z "$TIMER" ]]; then
		if [[ -e "$PREFIX/$path/.timer" ]]; then
			TIMER="$(cat "$PREFIX/$path/.timer")"
			[[ -z "$TIMER" ]] || timed="$(_timer "$TIMER" "$path")"
		fi
	else
		timed="$(_timer "$TIMER" "$path")"
	fi

	# Success!
	_success "Your password tomb has been opened in $PREFIX/."
	_message "You can now use pass as usual."
	if [[ $timed == 0 ]]; then
		_message "This password store will be closed in $TIMER"
	else
		_message "When finished, close the password tomb using 'pass close'."
	fi
	return 0
}

# Close a password tomb
cmd_close() {
	local _tomb_name _tomb_file="$1"
	[[ -z "$_tomb_file" ]] && _tomb_file="$TOMB_FILE"

	# Sanity checks
	check_sneaky_paths "$_tomb_file"
	_tomb_name="${_tomb_file##*/}"
	_tomb_name="${_tomb_name%.tomb}"
	[[ -z "$_tomb_name" ]] && _die "There is no password tomb."

	_tmp_create
	_verbose "Closing the password tomb $_tomb_file"
	_tomb close "$_tomb_name"

	_success "Your password tomb has been closed."
	_message "Your passwords remain present in $_tomb_file."
	return 0
}

# Show timer status
cmd_timer() {
	local _tomb_name _tomb_file="$1"
	[[ -z "$_tomb_file" ]] && _tomb_file="$TOMB_FILE"

	# Sanity checks
	check_sneaky_paths "$_tomb_file"
	_tomb_name="${_tomb_file##*/}"
	_tomb_name="${_tomb_name%.tomb}"
	[[ -z "$_tomb_name" ]] && _die "There is no password tomb."

	if systemctl is-active "pass-close@$_tomb_name.timer" &> /dev/null; then
		systemctl status "pass-close@$_tomb_name.timer"
	else
		_warning "There is no active timer for $_tomb_file."
		sudo systemctl status "pass-close@$_tomb_name.service"
	fi

	return 0
}

# Create a new password tomb and initialise the password repository.
# $1: path subfolder
# $@: gpg-ids
cmd_tomb() {
	local path="$1"; shift;
	typeset -a RECIPIENTS
	[[ -z "$*" ]] && _die "$PROGRAM $COMMAND [-n] [-t time] [-p subfolder] gpg-id..."
	IFS=" " read -r -a RECIPIENTS <<< "$@"

	# Sanity checks
	check_sneaky_paths "$path" "$TOMB_FILE" "$TOMB_KEY"
	if ! is_valid_recipients "${RECIPIENTS[@]}"; then
		_die "You set an invalid GPG ID."
	elif [[ -e "$TOMB_KEY" ]]; then
		_die "The tomb key $TOMB_KEY already exists. I won't overwrite it."
	elif [[ -e "$TOMB_FILE" ]]; then
		_die "The password tomb $TOMB_FILE already exists. I won't overwrite it."
	elif [[ "$TOMB_SIZE" -lt 30 ]]; then
		_die "A password tomb cannot be smaller than 30 MB."
	fi
	if [[ $UNSAFE -ne 0 ]]; then
		_warning "Using unsafe mode to speed up tomb generation."
		_warning "Only use it for testing purposes."
		local unsafe=(--unsafe)
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
	_verbose "Creating a password tomb with the GPG key(s): ${RECIPIENTS[*]}"
	_tomb dig "$TOMB_FILE" -s "$TOMB_SIZE"
	_tomb forge "$TOMB_KEY" -gr "$recipients_arg" "${unsafe[@]}"
	_tomb lock "$TOMB_FILE" -k "$TOMB_KEY" -gr "$recipients_arg"
	_tomb open "$TOMB_FILE" -k "$TOMB_KEY" -gr "$recipients_arg" "$PREFIX/$path"
	_set_ownership "$PREFIX/$path"

	# Use the same recipients to initialise the password store
	local ret path_cmd=()
	if [[ $NOINIT -eq 0 ]]; then
		[[ -z "$path" ]] || path_cmd=("--path=${path}")
		ret="$(cmd_init "${RECIPIENTS[@]}" "${path_cmd[@]}")"
		if [[ ! -e "$PREFIX/$path/.gpg-id" ]]; then
			_warning "$ret"
			_die "Unable to initialise the password store."
		fi
	fi

	# Initialise the timer
	local timed=1
	[[ -z "$TIMER" ]] || timed="$(_timer "$TIMER" "$path")"

	# Success!
	_success "Your password tomb has been created and opened in $PREFIX."
	[[ -z "$ret" ]] || _success "$ret"
	_message "Your tomb is: $TOMB_FILE"
	_message "Your tomb key is: $TOMB_KEY"
	if [[ -z "$ret" ]]; then
		_message "You need to initialise the store with 'pass init gpg-id...'."
	else
		_message "You can now use pass as usual."
	fi
	if [[ $timed == 0 ]]; then
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
FORCE=""
DEBUG=""
NOINIT=0
TIMER=""

# Getopt options
small_arg="vdhVp:qnt:f"
long_arg="verbose,debug,help,version,path:,unsafe,quiet,no-init,timer:,force"
opts="$($GETOPT -o $small_arg -l $long_arg -n "$PROGRAM $COMMAND" -- "$@")"
err=$?
eval set -- "$opts"
while true; do case $1 in
	-q|--quiet) QUIET=1; VERBOSE=0; DEBUG=""; shift ;;
	-v|--verbose) VERBOSE=1; shift ;;
	-d|--debug) DEBUG="-D"; VERBOSE=1; shift ;;
	-f|--force) FORCE="--force"; shift ;;
	-h|--help) shift; cmd_tomb_usage; exit 0 ;;
	-V|--version) shift; cmd_tomb_version; exit 0 ;;
	-p|--path) id_path="$2"; shift 2 ;;
	-t|--timer) TIMER="$2"; shift 2 ;;
	-n|--no-init) NOINIT=1; shift ;;
	--unsafe) UNSAFE=1; shift ;;
	--) shift; break ;;
esac done

[[ -z "$TIMER" ]] || command -v systemd-run &> /dev/null || _die "systemd-run is not present."
[[ $err -ne 0 ]] && cmd_tomb_usage && exit 1
[[ "$COMMAND" == "tomb" ]] && cmd_tomb "$id_path" "$@"
