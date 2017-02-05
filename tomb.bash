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

cmd_tomb_help() {
	cat <<-_EOF
	Usage:
	    $PROGRAM tomb gpg-id...
	    	Create and initialise a new password tomb.
	    	Use gpg-id for encryption of both tomb and passwords
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
	
	return 0
}

cmd_close() {
	TOMB_NAME=${TOMB_FILE##*/}
	
	_tmp_create
	_tomb close "$TOMB_NAME"
	
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


cmd_tomb() {

	_ensure_dependencies  # Check dependencies are present or bail out
	check_sneaky_paths "$1"
	
	if [[ "$1" == "help" ]]; then
		cmd_tomb_help
	else
		cmd_tomb_create "$1"
	fi

    return $?
}

[[ "$COMMAND" == "tomb" ]] && cmd_tomb "$@"
