#!/usr/bin/env bash

# File: update-pandoc-filters.sh
# Author: David Nebauer (david at nebauer dot org)
# Purpose: update local pandoc filters
# Created: 2025-08-10

# TODO:
# * refactor into functions using name references ('local -n') for arrays
# * load variables from config file (?generic dncommon library function)
# * alter libdncommon-bash warn|error functions to use coloured text

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
source "/usr/libexec/libdncommon-bash/liball" # supplies functions
dnEraseText "${msg}"
# provided by libdncommon-bash: dn_self,dn_divider[_top|_bottom]
# shellcheck disable=SC2154
usage="Usage:"
# shellcheck disable=SC2034
parameters=" [-v] [-d]"
# required tools findable on system path
required_system_tools=(
	getopt
	curl
	diff
)
# useful paths
stow_target_dir="$HOME"
stow_install_image_path='.local/share/pandoc/filters'
stow_target_install_image_path="${stow_target_dir}/${stow_install_image_path}"
stow_dir="$HOME/.config/dotfiles"
stow_package_dir="$stow_dir/pandoc"
stow_package_install_image_path="${stow_package_dir}/${stow_install_image_path}"
local_filter_dir="${stow_package_install_image_path}"
# useful remotely managed filter urls
remotely_managed_filter_urls=(
	'https://raw.githubusercontent.com/pandoc-ext/abstract-section/refs/heads/main/_extensions/abstract-section/abstract-section.lua'
	'https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/author-info-blocks/author-info-blocks.lua'
	'https://raw.githubusercontent.com/pandoc-ext/diagram/refs/heads/main/_extensions/diagram/diagram.lua'
	'https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/doi2cite/doi2cite.lua'
	'https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/first-line-indent/first-line-indent.lua'
	'https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/include-code-files/include-code-files.lua'
	'https://raw.githubusercontent.com/pandoc-ext/include-files/refs/heads/main/include-files.lua'
	'https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/latex-hyphen/latex-hyphen.lua'
	'https://raw.githubusercontent.com/pandoc-ext/list-table/refs/heads/main/_extensions/list-table/list-table.lua'
	'https://raw.githubusercontent.com/pandoc-ext/multibib/refs/heads/main/_extensions/multibib/multibib.lua'
	'https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/not-in-format/not-in-format.lua'
	'https://raw.githubusercontent.com/pandoc-ext/pagebreak/refs/heads/main/pagebreak.lua'
	'https://raw.githubusercontent.com/pandoc-ext/pretty-urls/refs/heads/main/_extensions/pretty-urls/pretty-urls.lua'
	'https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/scholarly-metadata/scholarly-metadata.lua'
	'https://raw.githubusercontent.com/pandoc-ext/section-bibliographies/refs/heads/main/_extensions/section-bibliographies/section-bibliographies.lua'
	'https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/short-captions/short-captions.lua'
	'https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/spellcheck/spellcheck.lua'
	'https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/table-short-captions/table-short-captions.lua'
	'https://raw.githubusercontent.com/pandoc/lua-filters/refs/heads/master/wordcount/wordcount.lua'
)
self_managed_filters=(
	'heading2bold.py'
	'keyboard-font.lua'
	'line-break-between-paras.lua'
	'paginatesects.py'
	'text-colour.lua'
)
# track additions and removals
added_filters=()
removed_filters=()
unset msg
unset stow_target_dir
unset stow_install_image_path
unset stow_package_dir
unset stow_package_install_image_path
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
	if [[ ${#missing[@]} -ne 0 ]]; then
		local msg
		msg="Can't run without: $(joinBy ', ' "${missing[@]}")"
		echo "$dn_self: $msg" >/dev/stderr
		# cannot use 'log' function here:
		# - options have not yet been processed
		logger --priority "user.err" --tag "$dn_self" "$msg"
		exit 1
	fi
	unset required_system_tools
}
# displayUsage()    {{{1
#   intent: display usage information
#   params: nil
#   prints: nil
#   return: nil
displayUsage() {
	cat <<_USAGE
${dn_self}: update local pandoc filters

Some of the local pandoc filters are sourced from remote online repositories
while others are self-managed.

The script performs the following tasks:

* Download current versions of remote filters and:

    * for any filters where there is no local version, seek user permission
      to install the downloaded version

    * for filters where there is a local version, compare the downloaded
      version to the local versions and, where they differ, seek user
      permission to overwrite the local version

* Warn user if any of the self-managed filters are not present

* Notify user of any local filters that are not in the canonical filter list.

${usage} ${dn_self} ${parameters}
       ${dn_self} -h

Options: -x OPT  =
         -v      = print input lines as they are read
                   (equivalent to 'set -o verbose')
         -d      = print input lines after command expansion
                   (equivalent to 'set -o xtrace')
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
			--options hdx: \
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
	#ARGS=("${@}") # remaining arguments
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

# process command line options    {{{1
processOptions "${@}" # leaves ${ARGS[@]} holding positional arguments

# informational message    {{{1
dnInfo "${dn_self} is running..."

# need internet access
dnInfon 'checking for internet access... '
if dnCheckInternet "${dn_ping_urls[@]}"; then
	echo 'ok'
else
	echo 'failed'
	dnEndScriptStderr 1 'Unable to access internet'
fi

# check for filter dir
dnInfon 'checking for filter directory... '
if dnDirValid "${local_filter_dir}"; then
	echo 'ok'
else
	echo 'failed'
	dnEndScriptStderr 1 "Can't find filter dir: ${local_filter_dir}"
fi

# assemble lists of remote and required filters
remotely_managed_filters=()
for url in "${remotely_managed_filter_urls[@]}"; do
	filter="$(dnExtractFilename "${url}")"
	remotely_managed_filters+=("${filter}")
done
required_filters=("${self_managed_filters[@]}" "${remotely_managed_filters[@]}")
unset filter

# get list of current filters
dnInfon 'getting list of local filters... '
if cmd_output="$(dir -1 "${local_filter_dir}" 2>&1)"; then
	echo 'ok'
	mapfile -t local_filters <<<"${cmd_output}"
else
	echo 'failed'
	dnEndScriptStderr 1 "${cmd_output}"
fi
unset cmd_output

# check whether any self-managed filters are missing
dnInfon 'check that all self-managed filters are present... '
missing_self_managed_filters=()
for filter in "${self_managed_filters[@]}"; do
	if ! dnElementInArray "${filter}" "${local_filters[@]}"; then
		missing_self_managed_filters+=("${filter}")
	fi
done
if ((${#missing_self_managed_filters[@]} == 0)); then
	echo 'ok'
else
	echo 'failed'
	dnWarn 'not all self-managed filters are present - missing:'
	for filter in "${missing_self_managed_filters[@]}"; do
		dnWarn "- ${filter}"
	done
	if dnConfirm 'Abort?'; then
		dnEndScript 1 'aborting at user request'
	fi
fi
unset filter missing_self_managed_filters

# download current versions of remotely managed filters
# • do download in single gulp
dnInfo 'Downloading current versions of remotely managed filters...'
dnInfo "${dn_divider_top}"
tmp_dir="$(dnTempDir)"
dnTempTrap "${tmp_dir}"
curl --output-dir "${tmp_dir}" --remote-name-all "${remotely_managed_filter_urls[@]}" || true
dnInfo "${dn_divider_bottom}"
# • get list of downloaded filters
if cmd_output="$(dir -1 "${tmp_dir}" 2>&1)"; then
	echo 'ok'
	mapfile -t downloaded_remotely_managed_filters <<<"${cmd_output}"
else
	echo 'failed'
	dnEndScriptStderr 1 "${cmd_output}"
fi
# • check all files downloaded successfully
missing_downloaded_filters=()
for filter in "${remotely_managed_filters[@]}"; do
	if ! dnElementInArray "${filter}" "${downloaded_remotely_managed_filters[@]}"; then
		missing_downloaded_filters+=("${filter}")
	fi
done
if ((${#missing_downloaded_filters[@]} != 0)); then
	dnWarn 'not all remotely-managed filters downloaded - missing:'
	for filter in "${missing_downloaded_filters[@]}"; do
		dnWarn "- ${filter}"
	done
	if dnConfirm 'Abort?'; then
		dnEndScript 1 'aborting at user request'
	fi
fi
unset cmd_output
unset downloaded_remotely_managed_filters
unset filter missing_downloaded_filters

# check whether any remotely-managed filters are missing
dnInfon 'check that all remotely-managed filters are present... '
missing_remotely_managed_filters=()
for filter in "${remotely_managed_filters[@]}"; do
	if ! dnElementInArray "${filter}" "${local_filters[@]}"; then
		missing_remotely_managed_filters+=("${filter}")
	fi
done
if ((${#missing_remotely_managed_filters[@]} == 0)); then
	echo 'ok'
else
	echo 'failed'
	dnWarn 'not all remotely-managed filters are present - missing:'
	for filter in "${missing_remotely_managed_filters[@]}"; do
		dnWarn "- ${filter}"
	done
	if dnConfirm 'Install them?'; then
		all_installed_ok=${dn_true}
		for filter in "${missing_remotely_managed_filters[@]}"; do
			existing_filter="${local_filter_dir}/${filter}"
			downloaded_filter="${tmp_dir}/${filter}"
			cp "${downloaded_filter}" "${existing_filter}" || true
			if diff "${existing_filter}" "${downloaded_filter}" &>/dev/null; then
				added_filters+=("${filter}")
			else
				all_installed_ok=${dn_false}
				dnErrorStderr "unable to install filter '${filter}'"
			fi
		done
		if ((all_installed_ok == dn_false)); then
			dnEndScript ${dn_false}
		fi
	fi
fi
unset all_installed_ok
unset downloaded_filter
unset existing_filter
unset filter
unset missing_remotely_managed_filters

# check for extra local filters
dnInfon 'checking for extraneous local filters... '
extra_local_filters=()
for filter in "${local_filters[@]}"; do
	if ! dnElementInArray "${filter}" "${required_filters[@]}"; then
		extra_local_filters+=("${filter}")
	fi
done
if ((${#extra_local_filters[@]} == 0)); then
	echo 'ok'
else
	echo 'failed'
	dnWarn 'extraneous local filter(s) are present:'
	for filter in "${extra_local_filters[@]}"; do
		dnWarn "- ${filter}"
	done
	if dnConfirm 'Delete them?'; then
		all_deleted_ok=${dn_true}
		for filter in "${extra_local_filters[@]}"; do
			filter_path="${local_filter_dir}/${filter}"
			rm "${filter_path}" || true
			if ! [ -f "${filter_path}" ]; then
				removed_filters+=("${filter}")
			else
				all_deleted_ok=${dn_false}
				dnErrorStderr "unable to delete filter '${filter}'"
			fi
		done
		if ((all_deleted_ok == dn_false)); then
			dnEndScript ${dn_false}
		fi
	fi
fi
unset all_deleted_ok
unset extra_local_filters
unset filter
unset filter_path
unset local_filters
unset required_filters

# check whether any remotely managed filters are changed
dnInfon 'checking whether any remotely-managed filters have changed... '
updatable_remotely_managed_filters=()
for filter in "${remotely_managed_filters[@]}"; do
	existing_filter="${local_filter_dir}/${filter}"
	downloaded_filter="${tmp_dir}/${filter}"
	if ! diff "${existing_filter}" "${downloaded_filter}" &>/dev/null; then
		updatable_remotely_managed_filters+=("${filter}")
	fi
done
echo 'done'
unset downloaded_filter
unset existing_filter
unset filter
unset remotely_managed_filters

# update filters if newer versions available
all_updated_ok=${dn_true}
if ((${#updatable_remotely_managed_filters[@]} == 0)); then
	dnInfo 'all remotely managed filters are up-to-date'
else
	dnInfo 'remotely-managed filter(s) with newer versions:'
	for filter in "${updatable_remotely_managed_filters[@]}"; do
		dnInfo "- ${filter}"
	done
	if dnConfirm 'Update?'; then
		for filter in "${updatable_remotely_managed_filters[@]}"; do
			existing_filter="${local_filter_dir}/${filter}"
			downloaded_filter="${tmp_dir}/${filter}"
			cp "${downloaded_filter}" "${existing_filter}" || true
			if ! diff "${existing_filter}" "${downloaded_filter}" &>/dev/null; then
				all_updated_ok=${dn_false}
				dnErrorStderr "unable to update filter '${filter}'"
			fi
		done
	fi
fi
unset downloaded_filter
unset existing_filter
unset filter
unset local_filter_dir
unset updatable_remotely_managed_filters

# clean up
#rm -fr "${tmp_dir}" || true
#dnTempKill "${tmp_dir}"
#unset tmp_dir

# warn user if filters added or removed
if ((${#added_filters[@]} != 0)); then
	dnWarn 'Filter files added'
	dnWarn "Consider re-stowing the 'pandoc' package from the stow directory:"
	dnWarn "${stow_dir}"
fi
if ((${#removed_filters[@]} != 0)); then
	dnWarn 'Filter files removed'
	dnWarn 'Consider pruning broken symlinks from the stow target installation directory:'
	dnWarn "${stow_target_install_image_path}"
fi
unset stow_dir
unset stow_target_install_image_path

# exit
dnEndScript ${all_updated_ok}

# }}}1

# vim:foldmethod=marker:
