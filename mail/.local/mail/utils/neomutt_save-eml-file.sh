#!/usr/bin/env bash

# USAGE    {{{1

# Intended to be called in neomutt's index or pager menus.
# Expects:
# • email message via stdin (in eml format)
# • download directory as first and only argument
# Output filename template = 'YYYY-MM-DD_email-subject.eml'.
# Can be called by this neomutt macro provided variables
# $my_save_eml and $my_download_dir are set appropriately:
#   macro index,pager X "\
#   <enter-command>set my_wait_key=\$wait_key<enter>\
#   <enter-command>set wait_key<enter>\
#   <pipe-message>\
#   $my_save_eml $my_download_dir<enter>\
#   <enter-command>set wait_key=\$my_wait_key<enter>\
#   <enter-command>unset my_wait_key<enter>\
#   " 'save message to eml file in download dir'

# Credit: https://unix.stackexchange.com/a/310990

# ERROR HANDLING    {{{1

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace
# Do not overwrite file using routine redirection operators
set -o noclobber

# VARIABLES    {{{1

required_system_tools=(cat date echo exit formail head iconv php printf sed tr)
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
		msg="Error: can't run without: $(joinBy ', ' "${missing[@]}")"
		echo "$msg"
		exit 1
	fi
	unset required_system_tools
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
# }}}1

# MAIN

# check for required tools    {{{1
checkPrereqs

# get download directory    {{{1
# • sed = strip trailing slashes
dirpath="$(sed --expression='s,/*$,,' <<<"$1")"
if ! [[ -d "$dirpath" ]]; then
	echo "Error: unable to locate download directory: $dirpath"
	exit 1
fi

# get email content    {{{1
message="$(cat)"
if [[ -z "$message" ]]; then
	echo 'Error: no email content provided'
	exit 1
fi

# extract date part of file name    {{{1
# • formail options:
#   -c = concatenate multi-line header fields
#   -x = extract header field
#   -z = trim leading/trailing whitespace from extracted header field
mail_date="$(formail -c -z -x 'Date' <<<"$message")"
formatted_date="$(date --date="$mail_date" --iso-8601='date')"

# extract subject part of file name    {{{1
# • transformations:
#   php = fix MIME encoded-word syntax
#         (see https://en.wikipedia.org/wiki/MIME#Encoded-Word
#          and https://unix.stackexchange.com/a/564513)
#   iconv = convert from utf-8 to ascii encoding
#   tr = convert uppercase to lowercase
#   tr = convert non-alphanum chars to spaces
#   tr = remove single and double quotation marks
#   tr = convert spaces to dashes
#   tr = remove dash sequences
#   head = truncate at X chars (actually, bytes)
#   sed = remove leading/trailing dashes
subject="$(
	formail -c -z -x 'Subject' <<<"$message" |
		php --run 'echo iconv_mime_decode(stream_get_contents(STDIN),1,"utf-8");' |
		iconv --from-code=UTF-8 --to-code=ASCII//TRANSLIT |
		tr '[:upper:]' '[:lower:]' |
		tr '/()[]{}<>+=_;:,.!?~`@#$%^*' '                          ' |
		tr --delete "'\"" |
		tr ' ' '-' |
		tr --squeeze-repeats '-' |
		head --bytes=40 |
		sed --expression='s/^-*//' | sed --expression='s/-*$//'
)"

# construct filepath    {{{1
if [[ -z "$formatted_date" ]]; then
	echo 'Error: unable to extract date from email'
	exit 1
fi
basename="$formatted_date"
if [[ -z "$subject" ]]; then
	echo 'Warning: no subject found'
else
	basename+="_$subject"
fi
fp="$dirpath/$basename.eml"

# save eml file    {{{1
if printf "%s" "$message" >"$fp"; then
	echo "Saved to: $fp"
else
	echo "Error: unable to save to: $fp"
fi
# }}}1

# vim:foldmethod=marker:
