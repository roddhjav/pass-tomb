# pass-tomb completion file for bash

PASSWORD_STORE_EXTENSION_COMMANDS+=(tomb open close)

_pass_complete_tombs() {
	local tombs="$(findmnt -rvo SOURCE | grep tomb | cut -d '.' -f 2)"
	COMPREPLY+=($(compgen -W "${tombs}" -- ${cur}))
}

__password_store_extension_complete_tomb() {
	local lastarg="${COMP_WORDS[$COMP_CWORD-1]}"
	if [[ $lastarg == "-p" || $lastarg == "--path" ]]; then
		_pass_complete_folders
		compopt -o nospace
	else
		COMPREPLY+=($(compgen -W "-h --help -n --no-init -t --timer -p --path -f --force -q --quiet -v --verbose -d --debug -V --version" -- ${cur}))
		_pass_complete_keys
    fi
}

__password_store_extension_complete_open() {
	COMPREPLY+=($(compgen -W "-h --help -t --timer -f --force -v --verbose -d --debug -V --version" -- ${cur}))
	_pass_complete_entries
	compopt -o nospace
}

__password_store_extension_complete_close() {
	COMPREPLY+=($(compgen -W "-h --help -v --verbose -d --debug -V --version" -- ${cur}))
	_pass_complete_tombs
	compopt -o nospace
}
