# pass-tomb completion file for zsh

PASSWORD_STORE_EXTENSION_SUBCOMMANDS+=(
	"tomb:Manage your password store in a Tomb"
	"open:Open a password tomb"
	"close:Close a password tomb"
)

_pass_complete_entries_with_tombs() {
	local tombs="$(findmnt -rvo SOURCE | grep tomb | cut -d '.' -f 2)"
	_values -C 'tombs' "$tombs"
}

__password_store_extension_complete_tomb() {
	_arguments : \
		"-p[gpg-id will only be applied to this subfolder]" \
		"--path[gpg-id will only be applied to this subfolder]" \
		"-n[do not initialise the password store]" \
		"--no-init[do not initialise the password store]" \
		"-t[close the store after a given time]" \
		"--timer[close the store after a given time]" \
		"-f[force operation (i.e. even if swap is active)]" \
		"--force[force operation (i.e. even if swap is active)]" \
		"-q[be quiet]" \
		"--quiet[be quiet]" \
		"-v[be verbose]" \
		"--verbose[be verbose]" \
		"-d[print Tomb debug messages]" \
		"--debug[print Tomb debug messages]" \
		"--unsafe[speed up tomb creation (for testing only)]" \
		"-V[show version information]" \
		"--version[show version information]" \
		"-h[print help message]" \
		"--help[print help message]"

	_pass_complete_keys
}

__password_store_extension_complete_open() {
	_arguments : \
		"-t[close the store after a given time]" \
		"--timer[close the store after a given time]" \
		"-f[force operation (i.e. even if swap is active)]" \
		"--force[force operation (i.e. even if swap is active)]" \
		"-q[be quiet]" \
		"--quiet[be quiet]" \
		"-v[be verbose]" \
		"--verbose[be verbose]" \
		"-d[print Tomb debug messages]" \
		"--debug[print Tomb debug messages]" \
		"-V[show version information]" \
		"--version[show version information]" \
		"-h[print help message]" \
		"--help[print help message]"

	_pass_complete_entries_with_subdirs
}

__password_store_extension_complete_close() {
	_arguments : \
		"-q[be quiet]" \
		"--quiet[be quiet]" \
		"-v[be verbose]" \
		"--verbose[be verbose]" \
		"-d[print Tomb debug messages]" \
		"--debug[print Tomb debug messages]" \
		"-V[show version information]" \
		"--version[show version information]" \
		"-h[print help message]" \
		"--help[print help message]"

	_pass_complete_entries_with_tombs
}
