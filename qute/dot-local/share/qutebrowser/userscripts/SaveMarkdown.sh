#!/usr/bin/env bash

# Qutebrowser userscript that converts the current page to markdown and saves
# it to a filepath specified by the user.
#
# Suggested keybinding (for "save markdown"):
# spawn --userscript SaveMarkdown.sh
#     sm

# ERROR HANDLING    {{{1

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
#set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace

# VARIABLES    {{{1

self="$(basename "$0")"
# required tools findable on system path
required_system_tools=(basename cp getopt pandoc mktemp sed zenity)
# download directory
download_dir=${download_dir:-$QUTE_DOWNLOAD_DIR}
download_dir=${download_dir:-$HOME/Downloads}
# filename
file_name="$(basename "$QUTE_URL")"
file_name_md="${file_name%.*}.md"
# default save filepath
default_path="$download_dir/$file_name_md"
# }}}1

# PROCEDURES

# checkPrereqs()    {{{1
#   intent: check for required tools
#   params: nil
#   prints: error message if tool(s) missing
#   return: n/a, aborts scipts on failure
function checkPrereqs() {
	local missing tool
	missing=()
	# these tools can be found on the base system path
	for tool in "${required_system_tools[@]}"; do
		command -v "$tool" &>/dev/null || missing+=("$tool")
	done
	if [[ ${#missing[@]} -ne 0 ]]; then
		local msg
		msg="Can't run without: $(joinBy ', ' "${missing[@]}")"
		echo "$self: $msg" >/dev/stderr
		# cannot use 'log' function here:
		# - options have not yet been processed
		logger --priority "user.err" --tag "$self" "$msg"
		exit 1
	fi
	unset required_system_tools required_local_tools
}
# displayUsage()    {{{1
#   intent: display usage information
#   params: nil
#   prints: nil
#   return: nil
displayUsage() {
	cat <<_USAGE
${self}: Qutebrowser userscript to save page as markdown file

Qutebrowser userscript that converts the current page to
markdown and saves it to a filepath specified by the user.

Not intended to be run from the command line.
_USAGE
}
# processOptions([@options])    {{{1
#   intent: process all command line options
#   params: @options - all command line parameters
#   prints: feedback
#   return: nil
#   note:   after execution variable @ARGS contains
#           remaining command line args (after options removed)
processOptions() {
	# read the command line options
	local OPTIONS
	if ! OPTIONS="$(
		getopt \
			--options hvd \
			--long help,verbose,debug \
			--name "${BASH_SOURCE[0]}" \
			-- "${@}"
	)"; then
		# getopt displays errors
		exit 1
	fi
	eval set -- "${OPTIONS}"
	while true; do
		case "${1}" in
		-h | --help)
			displayUsage
			exit 0
			;;
		-v | --verbose)
			set -o verbose
			shift 1
			;;
		-d | --debug)
			set -o xtrace
			shift 1
			;;
		--)
			shift
			break
			;;
		*) break ;;
		esac
	done
}
# joinBy($delim, @items)    {{{1
#   intent: join all items using delimiter
#   params: delim - delimiter
#           items - items to be joined
#   prints: string containing joined items
#   return: nil
function joinBy() {
	local delimiter first_item
	delimiter="${1:-}"
	shift
	first_item="${1:-}"
	shift
	printf %b%s "$first_item" "${@/#/$delimiter}"
}
# msg($type, $message)    {{{1
#   intent: display message
#   params: type    - messasge type [string, required, must be {info,error}]
#           message - message to display [string, required]
#   prints: nil
#   return: nil
msg() {
	local cmd="$1"
	shift
	local msg="$*"
	echo "message-$cmd '${msg//\'/\\\'}'" >>"$QUTE_FIFO"
}
# info($message)    {{{1
#   intent: display informational message
#   params: message - informational message to display [string, required]
#   prints: nil
#   return: nil
info() {
	msg info "$*"
}
# die($message)    {{{1
#   intent: display error message and exit
#   params: message - error message to display [string, required]
#   prints: nil
#   return: nil
die() {
	msg error "$*"
	# the above error message already informs the user about the failure;
	# no additional "userscript exited with status 1" is needed.
	exit 0
}
# }}}1

# MAIN

# check for required tools    {{{1
checkPrereqs

# get download file path    {{{1
# - zenity automatically confirms overwriting with user
#   if save file already exists
md_path="$(
	zenity \
		--title 'Save as...' \
		--file-selection \
		--save \
		--filename="$default_path" \
		--file-filter="*.md"
)" || true
[ -n "$md_path" ] || die 'No download file path set'

# convert html file to temporary markdown file    {{{1
temp_file="$(mktemp --tmpdir qutebrowser_XXXXXXXX.md)"
trap '[[ -f "$temp_file" ]] && rm -rf "$temp_file"' EXIT
pandoc --from=html --to=markdown --output="$temp_file" "$QUTE_URL" || true
[ -f "$temp_file" ] || die 'Unable to generate markdown output file'
[ -s "$temp_file" ] || die 'Markdown output file is empty'

# copy temp file to output file location    {{{1
if [[ -f "$md_path" ]]; then
	rm "$md_path" || true
	[[ -f "${md_path}" ]] && die "Unable to overwrite existing file ${md_path}"
fi
cp "$temp_file" "$md_path" || true
[[ -f "${md_path}" ]] || die "Unable to save $md_path"

# final feedback    {{{1
# - if here then must have succeeded
info "Saved $md_path"
# }}}1

# vim:foldmethod=marker:
