#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[ "${DEBUG:-0}" != "1" ] || set -o xtrace
#<KHeader>
#+=========================================================================
#I  Project Name: Scripts
#+=========================================================================
#I   Copyright: Copyright (c) 2004-2012, John Kearney
#I      Author: John Kearney,                  dethrophes@web.de
#I
#I     License: All rights reserved. This program and the accompanying 
#I              materials are licensed and made available under the 
#I              terms and conditions of the BSD License which 
#I              accompanies this distribution. The full text of the 
#I              license may be found at 
#I              http://opensource.org/licenses/bsd-license.php
#I              
#I              THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN '
#I              AS IS' BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
#I              ANY KIND, EITHER EXPRESS OR IMPLIED.
#I
#I Description: 
#I              File Name            : LogFuncs.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : LogFuncs.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>

#########################################################################
# Source Files
#########################################################################
if [ -z "${__GenFuncs_sh__:-}" ]; then
	[ -n "${ScriptDir:-}"	] || ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
	if [ -f "${ScriptDir}/GenFuncs.sh" ]; then
		source "${ScriptDir}/GenFuncs.sh"
	else
		echo "# " >&2
		echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
		echo "# " >&2
		exit 7
	fi
fi

if [ -z "${__LogFuncs_sh__-}" ]; then
	__LogFuncs_sh__=1

	#
	# Copy All the File Pointers
	#
	exec 3<&0
	exec 4>&1
	exec 5>&2
	if [ -z "${ConsoleInterface-}" ]; then  
		if [ -t 3 -a -t 4 ]; then 
			ConsoleInterface=1
		else
			ConsoleInterface=0
		fi
	fi

	if [ -t 4 ]; then
		WRN_OUT_COL=${FG_Brown}
		DBG_OUT_COL=${FG_Cyan}
		LOG_OUT_COL=${FG_DarkGray}
		CMD_OUT_COL=${FG_White}
		STDOUT_CLR=${NO_COLOUR}
	else
		WRN_OUT_COL=
		DBG_OUT_COL=
		LOG_OUT_COL=
		CMD_OUT_COL=
		STDOUT_CLR=
	fi

	if [ -t 5 ]; then
		ERR_OUT_COL=${FG_Red}
		ERROUT_CLR=${NO_COLOUR}
	else
		ERR_OUT_COL=
		ERROUT_CLR=
	fi

	function TruncateFile {
			if [ "$(stat -c%s "${1}")" -gt "${2}" ]; then
				local T="$(mktemp -p "${HOME}")"
				tail -c "${2}" "${1}" > "${T}" && mv -f "${T}" "${1}" || rm -f "${T}"
			fi
	}

	function CmdlineEscape { 
		printf "%q " "${@}"
	}
	function SingleQuote { 
		local LName="'\\''"
		while [ $# -gt 0 ]; do
			echo -n "'${1//"'"/${LName}}' " 
			shift
		done
	}
	function DoubleQuote { 
		local EList CChar
		while [ $# -gt 0 ]; do
			EList="${1}"
			for CChar in '!' '!' '"' ;do
				EList="${EList//${CChar}/\\${CChar}}"
			done
			echo -n "\"${EList}\" " 
			shift
		done
	}
	function CreateSQuotedArgList {
		SingleQuote "${@}"
	}
	function CreateDQuotedArgList {
		DoubleQuote "${@}"
	}
	function CreateDQuotedArgListMinimal {
		while [ $# -gt 0 ]; do
      case "${1}" in 
        *[[:cntrl:]]*) printf "%q " "${1}";;
        *[![:alnum:]_.-]*) DoubleQuote "${1}";;
        *)echo -n "${1} ";; 
      esac
      shift
    done
	}
	function CreateEscapedArgList {
		CreateDQuotedArgList "${@}"
	}
	function CreateEscapedArgList3 {
	  CmdlineEscape "${@}"
	}
	function FormatLogMsgPreambleNew {
		local MType="${1}"
		local FName="${FUNCNAME[$((${2} + 2))]}"
		local FLine="${BASH_LINENO[$((${2} + 1))]}"
		local FFile="$(basename "${BASH_SOURCE[$((${2} + 2))]}")"
		[ -n "${FName}" ] || FName="${SBaseName}"
		printf "${MType}: $(date) : %-5d : %-20.20s(%-4d) : %-15.15s : " $$ "${FFile}" ${FLine} "${FName}"
	}
	function FormatLogMsgNew {
		FormatLogMsgPreambleNew "${1}" "$(( ${2} +1 ))" 
		CreateEscapedArgList "${@:3}" 
	}
	function FormatLogMsgPreambleShort {
		local MType="${1}"
		local FName="${FUNCNAME[${2}+2]}"
		local FLine="${BASH_LINENO[${2}+1]}"
		local FFile="$(basename "${BASH_SOURCE[${2}+2]}")"
		[ -n "${FName}" ] || FName="${SBaseName}"
		printf "${MType}: %-5d : %s(%d):%s" $$ "${FFile}" ${FLine} "${FName}"
	}
	function FormatLogMsgRevNew {
		printf "%-50s #" "$(CreateDQuotedArgListMinimal "${@:3}")"
		FormatLogMsgPreambleNew "${1}" "$((${2}+1))" 
	}

	function cDebugOut {
		if [ -t 6 ]; then
			ConsoleStdout  "${STDOUT_CLR}#${DBG_OUT_COL}$(FormatLogMsgNew D "${@}")${STDOUT_CLR}" >&6
		else
			echo  "#$(FormatLogMsgNew D "${@}")" >&6
		fi
	}
	function cErrorOut {
		local COffset=${1}  # argument 1: last line of error occurence
		while shift && [ $# -gt 0 ]; do
			if [ -t 6 ]; then
				ConsoleErrout "${ERROUT_CLR}#${ERR_OUT_COL}$(FormatLogMsgNew E ${COffset} "${1}")${ERROUT_CLR}" 
			else
				ConsoleErrout "${ERROUT_CLR}#${ERR_OUT_COL}$(gettext "Error"): ${1}${ERROUT_CLR}" 
 				echo  "#$(FormatLogMsgNew E ${COffset} "${1}")" >&6
			fi
		done
		return  0
	}

	function PrintFunctionStack {
		local -i COffset=$(( ${1} +1 ))  # argument 1: last line of error occurence
		local	-i ElementCnt=$((${#BASH_SOURCE[@]} - 1 ))
		while [ ${ElementCnt} -ge ${COffset} ]; do
			let ElementCnt=${ElementCnt}-1
			cDebugOut $((${ElementCnt} +1 )) "[${ElementCnt}]${BASH_SOURCE[${ElementCnt}]}(${BASH_LINENO[${ElementCnt}]}):${FUNCNAME[${ElementCnt}]}"
		done
	}
	function ErrorOut {
		local -i COffset=$(( ${1} +1 ))  # argument 1: last line of error occurrence
		local EMsg="$(PrintArray "${@:2}")"
		[ -t 6 ] || PrintFunctionStack ${COffset}
		cErrorOut ${COffset} "${@:2}"

		if [ ${ConsoleInterface} -eq 0 ]; then
			notify_msg "$(FormatLogMsgPreambleShort E $((${COffset} - 1)) ) " "${EMsg}" 
		fi
	}          

	function WarningOut {
		if [ -t 6 ]; then
			ConsoleStdout  "${STDOUT_CLR}#${WRN_OUT_COL}$(FormatLogMsgNew W "${@}")${STDOUT_CLR}" >&6
		else
			echo  "#$(FormatLogMsgNew W "${@}")" >&6
		fi
	}
	function DebugOut {
		local COffset=$(( ${1} +1 ))  # argument 1: last line of error occurence
		[ -t 6 ] || PrintFunctionStack ${COffset}
		cDebugOut ${COffset} "${@:2}"

	}
	function LogOut {
		if [ -t 6 ]; then
			ConsoleStdout  "${STDOUT_CLR}#${LOG_OUT_COL}$(FormatLogMsgNew L "${@}")${STDOUT_CLR}" >&6
		else
			echo  "#$(FormatLogMsgNew L "${@}")" >&6
		fi
	}
	function CmdOut {
		if [ -t 6 ]; then
			printf "${CMD_OUT_COL}%-50s " "$(CreateDQuotedArgListMinimal "${@:2}")" >&6
			ConsoleStdout "${STDOUT_CLR}#${DBG_OUT_COL}$(FormatLogMsgPreambleNew C "${@}")${STDOUT_CLR}" >&6
		else
			echo  "$(FormatLogMsgRevNew C "${@}")" >&6
		fi
	}

	push_element RequiredDebianPackages		libnotify-bin
	push_element RequiredRpmPackages			libnotify
	push_element RequiredGentooPackages		x11-libs/libtinynotify-cli
	push_element RequiredSolarisPackages	libtinynotify-cli
	push_element RequiredFreeBsdPackages	libtinynotify-cli
	push_element RequiredSusePackages			libtinynotify-cli
	function notify_msg {
		#-i gtk-dialog-info 
		notify-send -t $((1000+300*$(echo -n ${2} | wc -w))) -u low "${1}" "${2}" || true
	}

	function sLogOut {
		LogOut 1 "${@}" 
	}
	function sDebugOut {
		DebugOut 1 "${@}" 
	}
	function scErrorOut {
		cErrorOut 1 "${@}" 
	}
	function sWarningOut {
		WarningOut 1 "${@}" 
	}
	function sErrorOut {
		ErrorOut 1 "${@}" 
	}
	function sRunProg {
		RunProg 1 "${@}"  || return $?
	}
	function sRunProgRoot {
		RunProgRoot 1 "${@}" || return $?
	}
	function sNormalExit {
		NormalExit 1 "${@}"
	}
	function sError_Exit {
		Error_Exit 1 "${@}"
	}
	function sTestEnoughArgs {
		TestEnoughArgs 1 "${@}"
	}
	function sNormalExitEx {
		NormalExitEx 1 "${@}"
	}



	function NormalExitEx {
		local ECMD="\"${BASH_COMMAND}\""
		local -i COffset=$(( ${1} +1 ))  # argument 1: last line of error occurence
		local -i LASTERR="${2}"          # argument 2: error code of last command
		local ETYPE="${3}"            # argument 2: error code of last command
		#[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
		for CleanUpFunc in "${CleanupFunctions[@]}"; do
			"${CleanUpFunc}" || true
		done
		if [ -z "${LASTERR}" -o ${LASTERR} -ne 0 ]; then 
			if [ "${ETYPE}" = "NEXIT" ]; then
				ECMD=""
			else
				PrintFunctionStack 1
			fi
			cErrorOut "${COffset}" "${ETYPE} ELEVEL=${LASTERR} ${ECMD}"
		fi
		trap - EXIT
		stty echo
		exit ${LASTERR}
	}
	function Pause {
		local -a OptArgs=""
		[ $# -eq 0 ] || OptArgs=( "-t" "${1}" )
		read -n1 "${OptArgs[@]}" -p "$(gettext "Press any key to continue...")" || true
		echo
	}

	function Error_Exit {
		local -i COffset=$(( ${1} +1 ))  # argument 1: last line of error occurence
		local -i ECODE="${2}"         # argument 2: error code of last command
		local EMSG="${3}"          # argument 2: error code of last command

		set -- "${@:4}"
		ErrorOut "${COffset}" "# ${SBaseName2}"\
													"# $(gettext "error exit") : ${EMSG}" \
													"${@/#/# }" \
													"#"
		[ "${BATCHMODE}" = "1" ] ||	Pause 5
		NormalExitEx "${COffset}" "${ECODE}" NEXIT
	}


	function DiagnoseWriteAccessFolder {
		local Name="${1}"
		local FName="${2}"

		if [ -z "${FName}" ]; then
			sError_Exit 6 "$(gettext  "${Name} Requires Folder name")"
		elif [ ! -w "${FName}" ]; then
			if [ ! -e "${FName}" ]; then
				sError_Exit 6 "$(gettext "${Name} Folder doesn't exist ")" "${FName}"
			elif [ ! -w "${FName}" ]; then
				sError_Exit 6 "$(gettext "No write access to ${Name} Folder ")" "${FName}"
			fi
		fi
	}
	function DiagnoseWriteAccess {
		local Name="${1}"
		local FName="${2}"

		if [ -z "${FName}" ]; then
			sError_Exit 6 "$(gettext  "${Name} Requires Filename")"
		elif [ ! -w "${FName}" ]; then
			local FileFolder="$(dirname "${FName}")"
			if [ -e "${FName}" ]; then
				sError_Exit 6 "$(gettext "No write access to ${Name}")" "${FName}"
			elif [ -n "${FileFolder}" ]; then
				DiagnoseWriteAccessFolder "${Name}" "${FileFolder}"
			fi
		fi
	}
	function DiagnoseReadAccess {
		local Name="${1}"
		local FName="${2}"

		if [ -z "${FName}" ]; then
			sError_Exit 6 "$(gettext  "${Name} Requires Filename")"
		elif [ ! -e "${FName}" ]; then
			sError_Exit 6 "$(gettext  "${Name} File doesn't exist ")" "${FName}"
		elif [ ! -r "${FName}" ]; then
			sError_Exit 6 "$(gettext  "No read access to ${Name}")"  "${FName}"
		fi
	}
	function SetLogFileName {
		if [ "${1}" = "&1" ] || [ -z "${1}" ]; then
			exec 6>&4
			LogFile=
		elif [ "${1}" = "&2" ] ; then
			exec 6>&5
			LogFile=
		else
			LogFile="${1}"
			if [ -z "${LogFile}" ]; then
				DiagnoseWriteAccess "Logfile" "${LogFile}"
				TruncateFile "${LogFile}" 500000
			fi
			exec 6>>"${1}"
		fi
	}

	[ -d "${LogDir}" ] || mkdir "${LogDir}"
	if [ -d "${LogDir}" -a -w "${LogDir}" ] ; then
		SetLogFileName "${LogDir}/${SBaseName2}.log"
	else
		SetLogFileName "&1"
	fi

	function TaceEvent {
		local LASTERR="${1}"          # argument 2: error code of last command
		local ETYPE="${2}"            # argument 2: error code of last command
		PrintFunctionStack 1
		cErrorOut 1 "${ETYPE} ${BASH_SOURCE[0]}(${BASH_LINENO[0]}):${FUNCNAME[1]} ELEVEL=${LASTERR} \"${BASH_COMMAND}\""
	}
	function TaceEvent2 {
		local LASTERR="${1}"          # argument 2: error code of last command
		local ETYPE="${2}"            # argument 2: error code of last command
		echo  "${ETYPE} ${BASH_SOURCE[0]}(${BASH_LINENO[0]}):${FUNCNAME[1]} ELEVEL=${LASTERR} \"${BASH_COMMAND}\""
	}
	function NormalExit {
		local -i COffset=$(( ${1} +1 ))  # argument 1: last line of error occurence
		local -i ECODE="${2}"         # argument 2: error code of last command
		NormalExitEx "${COffset}" "${ECODE}" NEXIT
	}
	function TrapExit {
		NormalExitEx 1 "${@}"
		[[ ${2} =~ EXIT|ERR ]] || kill -${2} ${$}
	}

	trap 'TrapExit  $? SIGHUP ' SIGHUP
	trap 'TrapExit  $? SIGINT ' SIGINT
	trap 'TrapExit  $? SIGTERM' SIGTERM
	trap 'TrapExit  $? SIGQUIT' SIGQUIT
	trap 'TrapExit  $? SIGABRT' SIGABRT
	trap 'TrapExit  $? EXIT   ' EXIT 
	trap 'TaceEvent $? SIGTRAP' SIGTRAP  
	trap 'TaceEvent $? ERR    ' ERR  
	#trap 'TaceEvent2 $? RETURN ' RETURN  
	#trap 'TaceEvent2 $? DEBUG  ' DEBUG  

	#########################################################################
	# Procedures
	#########################################################################
	#push_element RequiredDebianPackages	moreutils
	#push_element RequiredRpmPackages			moreutils
	#push_element RequiredGentooPackages	moreutils
	#push_element RequiredSolarisPackages	moreutils
	#push_element RequiredFreeBsdPackages	moreutils
	#push_element RequiredSusePackages		moreutils

	LogFuncsRevision=$(CleanRevision '$Revision: 64 $')
	push_element	ScriptsLoaded "LogFuncs.sh;${LogFuncsRevision}"
fi
if  [ -n "${__GenFuncs_sh_Loaded_-}" -a "${SBaseName2}" = "LogFuncs.sh" ] ; then 
	ScriptRevision="${LogFuncsRevision}"

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

	SetLogFileName "&1"
	sLogOut "${0}" "${@}"


	#########################################################################
	# Argument Processing
	#########################################################################
	#push_element ModulesArgHandlers  
	#push_element SupportedCLIOptions 
	MainOptionArg "" "${@}"


	#########################################################################
	# MAIN PROGRAM
	#########################################################################

	echo "###############################################"
	echo "# ${SBaseName2} $(gettext "Test Module")"
	echo "###############################################"

	CreateEscapedArgList "Arg 1" "Arg 2" "Arg 3" "Arg 4" "Arg 5"
	ConsoleStdout ""
	
	sRunProg echo "hello"
	sErrorOut echo "hello"
	scErrorOut echo "hello"
	sDebugOut echo "hello"
	cDebugOut 0 echo "hello"
	sLogOut echo "hello"
	sWarningOut echo "hello"

	ls -al /dev/fd/

	trap
	sNormalExit 0
fi

