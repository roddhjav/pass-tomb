#compdef pass-close
#description Close a password tomb

_pass-close() {
	_arguments : \
		{-h,--help}'[display help information]' \
		{-V,--version}'[display version information]' \
		{-q,--quiet}'[be quiet]' \
		{-v,--verbose}'[be verbose]' \
		{-d,--debug}'[print Tomb debug messages]'

	_pass_complete_entries_with_tombs
}

_pass_complete_entries_with_tombs() {
	local tombs="$(findmnt -rvo SOURCE | grep tomb | cut -d '.' -f 2)"
	_values -C 'tombs' "$tombs"
}

_pass-close "$@"
