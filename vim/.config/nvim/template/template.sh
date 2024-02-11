#!/usr/bin/env bash

# File: ${filename}.sh
# Author: ${author}
# Purpose:
# Created: ${date}

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

# VARIABLES    {{{1

msg="Loading libraries"
echo -ne "\\033[1;37;41m${msg}\\033[0m"
# shellcheck disable=SC1091
source "@libexec_dir@/libdncommon-bash/liball" # supplies functions
dnEraseText "${msg}"
# provided by libdncommon-bash: dn_self,dn_divider[_top|_bottom]
# shellcheck disable=SC2154
system_conf="@pkgconf_dir@/${dn_self}rc"
local_conf="${HOME}/.${dn_self}rc"
usage="Usage:"
# shellcheck disable=SC2034
param_pad="$(dnRightPad "$(dnStrLen "${usage} ${dn_self}")")"
parameters=" [-v] [-d]" # **
#parameters="${parameters}\n${param_pad}"
#parameters="${parameters} ..."
# required tools findable on system path
required_system_tools=(
	getopt
)
# required tools specified by full path
required_local_tools=()
unset param_pad msg
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
	# these tools are specified by absolute path
	for tool in "${required_local_tools[@]}"; do
		[[ -x "$tool" ]] || missing+=("$tool")
	done
	if [[ ${#missing[@]} -ne 0 ]]; then
		local msg
		msg="Can't run without: $(joinBy ', ' "${missing[@]}")"
		echo "$dn_self: $msg" >/dev/stderr
		# cannot use 'log' function here:
		# - options have not yet been processed
		logger --priority "user.err" --tag "$dn_self" "$msg"
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
${dn_self}: <BRIEF>

<LONG>

${usage} ${dn_self} ${parameters}
       ${dn_self} -h

Options: -x OPT  =
         -v      = print input lines as they are read
                   (equivalent to 'set -o verbose')
         -d      = print input lines after command expansion
                   (equivalent to 'set -o xtrace')
_USAGE
}
# processConfigFiles([global_fp[, local_fp]])    {{{1
#   intent: process configuration files
#   params: global_fp - global config filepath (optional)
#           local_fp  - local config filepath (optional)
#   prints: nil
#   return: nil
#   notes:  set variables [  ]
processConfigFiles() {
	# set variables
	local conf name val
	local system_conf
	system_conf="$(dnNormalisePath "${1}")"
	local local_conf
	local_conf="$(dnNormalisePath "${2}")"
	# process config files
	for conf in "${system_conf}" "${local_conf}"; do
		if [ -r "${conf}" ]; then
			while read -r name val; do
				if [ -n "${val}" ]; then
					# remove enclosing quotes if present
					val="$(dnStripEnclosingQuotes "${val}")"
					# load vars depending on name
					case ${name} in
					'key') key="${val}" ;;
					'key') key="${val}" ;;
					'key') key="${val}" ;;
					esac
				fi
			done <"${conf}"
		fi
	done
	unset system_conf local_conf msg
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
			--options hvdx: \
			--long xoption:,help,verbose,debug \
			--name "${BASH_SOURCE[0]}" \
			-- "${@}"
	)"; then
		# getopt displays errors
		exit 1
	fi
	eval set -- "${OPTIONS}"
	while true; do
		case "${1}" in
		-x | --xoption)
			varx="${2}"
			shift 2
			;;
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
	ARGS=("${@}") # remaining arguments
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

# process configuration files    {{{1
msg="Reading configuration files"
echo -ne "$(dnRedReverseText "${msg}")"
processConfigFiles "${system_conf}" "${local_conf}"
dnEraseText "${msg}"
unset system_conf local_conf msg

# process command line options    {{{1
processOptions "${@}" # leaves ${ARGS[@]} holding positional arguments

# check arguments    {{{1
# Check that argument supplied
#[ $# -eq 0 ] && dnFailScript "No wibble supplied"
# Check value of option-set variable
#case ${var} in
#    val ) var2="val2";;
#    *   ) dnFailScript "'${val}' is an inappropriate wibble";;
#esac
# Check for option-set variable
#[ -z "${var}" ] && dnFailScript "You did not specify a wibble"

# informational message    {{{1
dnInfo "${dn_self} is running..."
# }}}1

# vim:foldmethod=marker:
