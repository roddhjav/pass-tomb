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

#
# Commons color and functions
#
green='\e[0;32m'
yellow='\e[0;33m'
bold='\e[1m'
Bred='\e[1;31m'
Bgreen='\e[1;32m'
Byellow='\e[1;33m'
Bblue='\e[1;34m'
reset='\e[0m'
_title() { echo -e "${Bblue}::${reset} ${bold}${*}${reset}"; }
_message() { echo -e " ${bold} . ${reset} ${*}"; }
_alert() { echo -e " ${Byellow}(*)${reset} ${*}"; }
_warning() { echo -e " ${Byellow}[W]${reset} ${yellow}${*}${reset}"; }
_success() { echo -e " ${Bgreen}(*)${reset} ${green}${*}${reset}"; }
_error() { echo -e " ${Bred}[*]${reset}${bold} Error :${reset} ${*}"; }
_die() { _error "${@}" && exit 1; }
_verbose() { _alert "${@}"; }

# Check program dependencies
#
# pass tomb depends on tomb>2.3
_ensure_dependencies() {
    command -v "$TOMB" 1>/dev/null 2>/dev/null || _die "tomb is not present"
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
	"$TOMB" "$cmd" "$@" "$DEBUG" &> "$TMP"
	ret=$?
	while read ii; do
		_verbose "$ii"
	done <$TMP
	[[ $ret == 0 ]] || _die "Unable to $cmd the password tomb"
}

# Provide a random filename in shared memory
_tmp_create() {
	tmpdir	# Defines $SECURE_TMPDIR
	tfile="$(mktemp -u "$SECURE_TMPDIR/XXXXXXXXXXXXXXXXXXXX")" # Temporary file
	
	umask 066
	[[ $? == 0 ]] || {
		_die "Fatal error setting the permission umask for temporary files"; }

	[[ -r "$tfile" ]] && {
		_die "Someone is messing up with us trying to hijack temporary files."; }

	touch "$tfile"
	[[ $? == 0 ]] || {
		_die "Fatal error creating a temporary file: $tfile"; }

	TMP="$tfile"
	return 0
}

cmd_tomb_verion() {
	cat <<-_EOF
	$PROGRAM tomb - A pass extension allowing you to put and manage your
	            password repository in a tomb.
	
	Vesion: 0.1
	_EOF
}

cmd_tomb_usage() {
	cmd_tomb_verion
	echo
	cat <<-_EOF
	Usage:
	    $PROGRAM tomb [--path=subfolder,-p subfolder] gpg-id...
	        Create and initialise a new password tomb.
	        Use gpg-id for encryption of both tomb and passwords
	    $PROGRAM open
	        Open a password tomb
	    $PROGRAM close
	        Close a password tomb
	
	Options:
	    -v, --verbose  Print tomb message
	    -d, --debug    Print tomb debug message
	        --unsafe   Speed up tomb creation (for test only)
	    -V, --version  Show version information.
	    -h, --help	   Print this help message and exit.
	
	More information may be found in the pass-tomb(1) man page.
	_EOF
}

# Open a password tomb
cmd_open() {
	# Sanity checks
	check_sneaky_paths "$TOMB_FILE"
	check_sneaky_paths "$TOMB_KEY"
	[[ -e "$TOMB_FILE" ]] || _die "There is no password tomb to open."
	[[ -e "$TOMB_KEY" ]] || _die "There is no password tomb key."
	
	_tmp_create
	_tomb open "$TOMB_FILE" -k "$TOMB_KEY" -f -r "dummy-gpgid" "$PREFIX"
	sudo chown -R "$USER:$USER" "$PREFIX" || _die "Unable to set the permission on $PREFIX"
	return 0
}

# Close a password tomb
cmd_close() {
	# Sanity checks
	check_sneaky_paths "$TOMB_FILE"
	[[ -e "$TOMB_FILE" ]] || _die "There is no password tomb to close."
	TOMB_NAME=${TOMB_FILE##*/}
	[[ -z "$TOMB_NAME" ]] && _die "There no password tomb."
	
	_tmp_create
	_tomb close "$TOMB_NAME"
	return 0
}

cmd_tomb() {
	local path="$1"; shift;
	[[ -z "$@" ]] && _die "$PROGRAM $COMMAND [--path=subfolder,-p subfolder] gpg-id..."
	RECIPIENTS=($@)
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
	
	# Use the same recipients to initialise the password store
	echo "${TOMB_RECIPIENTS/,/\n}" > "$PREFIX/.gpg-id"
	
	# Sign the .gpg-id file
	if [[ ! -z "$PASSWORD_STORE_SIGNING_KEY" ]]; then
	    _tmp_create
    	tmpres=$TMP
		gpg --batch --detach-sign --default-key "$PASSWORD_STORE_SIGNING_KEY" \
			--no-mdc-warning --no-options --status-fd 2 --no-permission-warning \
			--no-tty --output "$PREFIX/.gpg-id.sig" "$PREFIX/.gpg-id" 2> "$tmpres"
	    ret=1
		while read ii; do
			_verbose "$ii"
			[[ "$ii" =~ "SIG_CREATED" ]] && ret=0;
		done <$tmpres
    	[[ $ret == 0 ]] || {
			_die "Unable to sign $PREFIX/.gpg-id with $PASSWORD_STORE_SIGNING_KEY"
		}
	fi
	
	_success "Your password tomb as been created and openned in $PREFIX."
	_success "You can now use pass normaly"
	_success "When finish, close the password tomb using 'pass close'"
}

# Check dependencies are present or bail out
_ensure_dependencies

# Global options
UNSAFE=0
VERBOSE=0
DEBUG=""
opts="$($GETOPT -o vdhVp: -l verbose,debug,help,version,path:,unsafe -n "$PROGRAM $COMMAND" -- "$@")"
err=$?
eval set -- "$opts"
while true; do case $1 in
	-v|--verbose) VERBOSE=1; shift ;;
	-d|--debug) DEBUG="-D"; VERBOSE=1; shift ;;
	-h|--help) shift; cmd_tomb_usage; exit 0 ;;
	-V|--version) shift; cmd_tomb_verion; exit 0 ;;
	-p|--path) id_path="$2"; shift 2 ;;
	--unsafe) UNSAFE=1; shift ;;
	--) shift; break ;;
esac done

[[ $err -ne 0 ]] && cmd_tomb_usage && exit 1
[[ "$COMMAND" == "tomb" ]] && cmd_tomb "$id_path" "$@"
