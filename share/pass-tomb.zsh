#compdef pass-tomb
#description Manage your password store in a Tomb

_pass-tomb() {
	_arguments : \
		{-h,--help}'[display help information]' \
		{-V,--version}'[display version information]' \
		{-p,--path}'[gpg-id will only be applied to this subfolder]:dirs:_pass_complete_entries_with_dirs' \
		{-n,--no-init}'[do not initialise the password store]' \
		{-t,--timer}'[close the store after a given time]' \
		{-f,--force}'[force operation (i.e. even if swap is active)]' \
		{-q,--quiet}'[be quiet]' \
		{-v,--verbose}'[be verbose]' \
		{-d,--debug}'[print Tomb debug messages]' \
		'--unsafe[speed up tomb creation (for testing only)]'

	_pass_complete_keys
}

_pass_complete_entries_with_dirs () {
	_pass_complete_entries_helper -type d
}

_pass-tomb "$@"
