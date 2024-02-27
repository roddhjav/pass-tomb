#compdef pass-open
#description Open a password tomb

_pass-open () {
	_arguments : \
		{-h,--help}'[display help information]' \
		{-V,--version}'[display version information]' \
		{-t,--timer}'[close the store after a given time]' \
		{-f,--force}'[force operation (i.e. even if swap is active)]' \
		{-q,--quiet}'[be quiet]' \
		{-v,--verbose}'[be verbose]' \
		{-d,--debug}'[print Tomb debug messages]'

	_pass_complete_entries_with_dirs
}

_pass_complete_entries_with_dirs () {
	_pass_complete_entries_helper -type d
}

_pass-open "$@"
