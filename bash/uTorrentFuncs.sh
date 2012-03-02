#!/bin/bash +x
#[ "${DEBUG}" != "1" ] && stty -echo
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/uTorrentFuncs.sh $
#+=========================================================================
#I   Copyright: Copyright (c) 2002-2011, John Keanrney
#I      Author: John Kearney,                  John.Kearney@web.de
#I
#I     License: All rights reserved. This program and the accompanying 
#I              materials are licensed and made available under the 
#I              terms and conditions of the BSD License which 
#I              accompanies this distribution. The full text of the 
#I              license may be found at 
#I              http://opensource.org/licenses/bsd-license.php
#I              
#I              THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "
#I              AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
#I              ANY KIND, EITHER EXPRESS OR IMPLIED.
#I
#I Description: 
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : SOURCES
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 51 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-01-17 13:33:18 +0100 (Tue, 17 Jan 2012) $
#I  ID                   : $Id: uTorrentFuncs.sh 51 2012-01-17 12:33:18Z dethrophes $
#I
#+=========================================================================
#</KHeader>
if [ -z "${__uTorrentFuncs_SH__:-}" ]; then
	__uTorrentFuncs_SH__=1


	[ -z "${ScriptDir:-}"	] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

	#########################################################################
	# Source Files
	#########################################################################
	[ -z "${__GenFuncs_sh__:-}" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	#SourceCoreFiles_ "move.sh" "uTorrentFuncs.sh" "JobQueue.sh" "FixSymLinks.sh"

	#########################################################################
	# Procedures
	#########################################################################
	function StringifyUTorrentState {
		local States=""
		if [ 0 ]; then
			((${1} & 1))		&&	  States="Started ${States}"
			((${1} & 2))		&&		States="checking ${States}"
			((${1} & 4))		&&		States="start-after-check ${States}"
			((${1} & 8))		&&		States="checked ${States}"
			((${1} & 16))		&&		States="error ${States}"
			((${1} & 32))		&&		States="paused ${States}"
			((${1} & 64))		&&		States="auto ${States}"
			((${1} & 128))	&&		States="loaded ${States}"
		else
			case "${1}" in
				1) States="error" ;;
				2) States="checked" ;;
				3) States="paused" ;;
				4) States="super seeding" ;;
				5) States="seeding" ;;
				6) States="downloading" ;;
				7) States="super seeding (forced)" ;;
				8) States="seeding (forced)" ;;
				9) States="downloading (forced)" ;;
				10) States="seeding" ;;
				11) States="finished" ;;
				12) States="queued" ;;
				13) States="stopped" ;;
			esac
		fi
		ReturnString "${States}"
	}
	function TestUTorrentState {
		local -i States=0
		if [ 0 ]; then
			case "${2}" in
				started)						(( ${1} & 1 ))		&& States=1 ;;
				checking)						(( ${1} & 2 ))		&& States=1 ;;
				start-after-check)	(( ${1} & 4 ))		&& States=1 ;;
				checked)						(( ${1} & 8 ))		&& States=1 ;;
				error)							(( ${1} & 16 ))		&& States=1 ;;
				paused)							(( ${1} & 32 ))		&& States=1 ;;
				auto)								(( ${1} & 64 ))		&& States=1 ;;
				loaded)							(( ${1} & 128 ))	&& States=1 ;;
			esac
		else
			case "${2}" in
				'error')									(( ${1} =  1 ))		&& States=1 ;;
				'checked')								(( ${1} =  2 ))		&& States=1 ;;
				'paused')									(( ${1} =  3 ))		&& States=1 ;;
				'super seeding')					(( ${1} =  4 ))		&& States=1 ;;
				'seeding')								(( ${1} =  5 ))		&& States=1 ;;
				'downloading')						(( ${1} =  6 ))		&& States=1 ;;
				'super seeding (forced)')	(( ${1} =  7 ))		&& States=1 ;;
				'seeding (forced)')				(( ${1} =  8 ))		&& States=1 ;;
				'downloading (forced)')		(( ${1} =  9 ))		&& States=1 ;;
				'seeding')								(( ${1} = 10 ))		&& States=1 ;;
				'finished')								(( ${1} = 11 ))		&& States=1 ;;
				'queued')									(( ${1} = 12 ))		&& States=1 ;;
				'stopped')								(( ${1} = 13 ))		&& States=1 ;;

			esac
		fi
		ReturnString ${States}
	}
	function urlencode {
		#echo -n "${1}" | perl -MURL::Escape -ne 'print url_escape($_)'
		echo "${1}" | perl -MCGI -ne 'print CGI::escape($_)'
	}

	function GetTorrentValue {
		#"${PythonDir}/utorrentctl.py" --dump ${2} | grep "${1}" | sed 's/\s*\w\+\s*=\s*//'

		local Val="$("${PythonDir}/utorrentctl.py" --dump ${2} | grep "${1}")"
		echo "${Val#*= }"
	}
	function SetTorrentValue {
		sRunProg "${PythonDir}/utorrentctl.py" --set-props "${2}.${1}=${3}"
	}
	function GetRssValue {
		#"${PythonDir}/utorrentctl.py" --dump ${2} | grep "${1}" | sed 's/\s*\w\+\s*=\s*//'

		local Val="$("${PythonDir}/utorrentctl.py" --rss-dump ${2} | grep "${1}")"
		echo "${Val#*= }"
	}
	function SetRssValue {
		sRunProg "${PythonDir}/utorrentctl.py" --rss-set-props "${2}.${1}=${3}"
	}

	function GetRssFilterValue {
		#"${PythonDir}/utorrentctl.py" --dump ${2} | grep "${1}" | sed 's/\s*\w\+\s*=\s*//'

		local Val="$("${PythonDir}/utorrentctl.py" --rssfilter-dump ${2} | grep "${1}")"
		echo "${Val#*= }"
	}
	function SetRssFilterValue {
		sRunProg "${PythonDir}/utorrentctl.py" --rssfilter-set-props "${2}.${1}=${3}" || return $?
	}

	function GetTorrentLabel {
		GetTorrentValue label "${@}"  || return $?
	}
	function SetTorrentLabel {
		SetTorrentValue label "${@}"  || return $?
	}
	function ListTorrentFiles {
		"${PythonDir}/utorrentctl.py" --info ${1} | grep -P "${1}.\d" || return $?
	}
	function MaskTorrentFiles {
		ListTorrentFiles  "${1}" | grep -iP "${2}" || return $?
	}
	function GetMaskedTorrentFilesIds {
		MaskTorrentFiles  "${1}" "${2}" | awk '{print $1}' || return $?
	}
	function SetMaskedTorrentFilesPrio {
		local -a FList=( $(MaskTorrentFiles  "${1}" "${2}" | awk '{print $1"='"$3"'"}') )
		if [ ${#FList[@]} -gt 0 ]; then
			sRunProg "${PythonDir}/utorrentctl.py" --prio "${FList[@]}" || return $?
		fi
	}
	function RemoveTorrent {
		 sRunProg "${PythonDir}/utorrentctl.py" --remove --torrent "${@}" || return $?
	}

	function ListTorrents {
		 "${PythonDir}/utorrentctl.py" --list "${@}" || return $?
	}
	function StartTorrent {
		 sRunProg "${PythonDir}/utorrentctl.py" --start "${@}" || return $?
	}
	function StopTorrent {
		 sRunProg "${PythonDir}/utorrentctl.py" --stop "${@}" || return $?
	}
	function RecheckTorrent {
		 sRunProg "${PythonDir}/utorrentctl.py" --recheck "${@}" || return $?
	}

	function ListRssFeeds {
		"${PythonDir}/utorrentctl.py" --rss-list  | grep http | sed -r 's/\|.*$//'  | sed -r 's/\s+([0-9]+)\s+on\s+/\1;/' || return $? 
	}
	function AddRssEztv {
		local MString="$(urlencode "${1}" | sed -e 's/%20/+/g' )"
		"${PythonDir}/utorrentctl.py" --rss-add "${1}|http://www.ezrss.it/search/index.php?show_name=${MString}&quality=HDTV&quality_exact=true&mode=rss" | grep "Feed id" | awk '{print $4}' || return $?
	}
	function AddRssIsohunt {
		local MString="$(urlencode "${1}" | sed -e 's/%20/+/g' )"
		"${PythonDir}/utorrentctl.py" --rss-add "${1}|http://www.ezrss.it/search/index.php?show_name=${MString}&date=&quality=&release_group=&mode=rss" | grep "Feed id" | awk '{print $4}' || return $?
	}
	function AddRssFilter {
		"${PythonDir}/utorrentctl.py" --rssfilter-add "${1}" | grep "Filter id" | awk '{print $4}' || return $?
	}
	function AddHLRss {
		local FeedId="$(${1} "${2}")"
		echo FeedId=${FeedId}
		if [ -n "${FeedId}" ]; then
			local FilterId="$(AddRssFilter "${FeedId}")"
			echo FilterId=${FilterId}
			if [ -n "${FilterId}" ]; then
				"${PythonDir}/utorrentctl.py" --rssfilter-set-props "${FilterId}.name=${2}" "${FilterId}.label=${2}" "${FilterId}.filter=*" || return $?
			fi
		fi
	}

	function AddHLRssEztv {
		AddHLRss AddRssEztv "${1}" 
	}
	function AddHLRssIsohunt {
		AddHLRss AddRssIsohunt "${1}" 
	}

	uTorrentFuncsRevision=$(CleanRevision '$Revision: 51 $')
	push_element	ScriptsLoaded "uTorrentFuncs.sh;${uTorrentFuncsRevision}"
	if [ "${SBaseName2}" = "uTorrentFuncs.sh" ]; then 
		ScriptRevision="${uTorrentFuncsRevision}"

		function InstallDependencies {
			InstallPackages "${@}"  
		}

		# 
		#########################################################################
		# Usage
		#########################################################################
		function Usage {
			ConsoleStdout "."
			ConsoleStdout "+=============================================================================="
			ConsoleStdout "I  ${SBaseName2} ................................................... ${ScriptRevision}"
			ConsoleStdout "+=============================================================================="
			ConsoleStdout "I " 
			UsageCommon
			ConsoleStdout "I                                                                                "
			ConsoleStdout "I                                                                                "
			sNormalExit 0
		}

		#########################################################################
		# Argument Processing
		#########################################################################
		push_element SupportedCLIOptions $(ListFunctionsAsArgs "${0}")
		function MainOptionArg {
			local ArrayName="${1}"
			shift
			eval ${ArrayName}=\(\)
			while [ $# -gt 0 ] ; do
				case "${1}" in
					--*)
						FuncName="${1:2}"
						if [ "$(type -t "${FuncName}")" = "function" ]; then
							shift
							"${FuncName}" "${@}"
							exit 
						else
							sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
						fi
						;;
					-*)
						sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
						;;
					*)
						push_element "${ArrayName}" "${1}"
						;;
				esac
				shift
			done
		}
		CommonOptionArg ArgFiles "${@}"
		MainOptionArg ArgFiles "${ArgFiles[@]}"

		#########################################################################
		# MAIN PROGRAM
		#########################################################################


		sNormalExit 0
	fi
fi
