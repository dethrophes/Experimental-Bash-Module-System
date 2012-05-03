#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
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
#I              File Name            : ProgressFuncs.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : ProgressFuncs.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>

[ -z "${ScriptDir:-}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

[ -z "${__GenFuncs_sh__:-}" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"

if [ -z "${__ProgressFuncs_sh__:-}" ]; then
	__ProgressFuncs_sh__=1


	declare	-g ProgressBuffer="${TMP}/$$_${SBaseName}_ProgressBar.pipe"
	declare	-gi ProgressWeight="100"
	
	function SetColLines {
		[ -t 0 -a -t 1 ] || return 0
		local -a ConsoleDimensions=( $( COLUMNS= stty -a | awk  '/columns/ { print $5 $7 }' | tr ';' ' ' 2>/dev/null ) )
		LINES=${ConsoleDimensions[0]}
		COLUMNS=${ConsoleDimensions[1]}
	}
	#SetColLines
	#[ -t 0 -a -t 1 ] && trap "SetColLines" SIGWINCH

	function SendProgressBarCmd {
		if [ -p "${ProgressBuffer}" ]; then 
			ReturnString "${@}"  > "${ProgressBuffer}"
		fi
	}
	function LaunchProgressBar_gui {
		mkfifo "${ProgressBuffer}" || return 3
		local ProgressWeight="${1}"
		local PPer=0 
		trap  '[ -p "${ProgressBuffer}" ] &&	rm "${ProgressBuffer}"; exit' EXIT
		while [ 1 ]; do 
			local Cmd="$(cat "${ProgressBuffer}")" 
			case "${Cmd}" in 
				Exit)
					exit
					;;
				*)
					PPer="$(float_eval 2 "${Cmd}*100/${ProgressWeight}")"
					[ -n "${PPer}" ] && ReturnString "${PPer}"
					;;
			esac
		done | zenity --progress --percentage="0" &
	}
	function UpdateProgressBar_gui {
		SendProgressBarCmd "${1}"
	}
	function CloseProgressBar_gui {
		SendProgressBarCmd "Exit"
	}
	function LaunchProgressBar_txt {
		ProgressWeight="${1}"
	}
	function UpdateProgressBar_txt {
		local PPer="$(float_eval 2 "${1}*100/${ProgressWeight}")"
		local cnt="$(float_eval 0 "(${COLUMNS}-11)*${PPer}/100")"
		printf "\r [%6.2f%%] " ${PPer}
		while  [ ${cnt} -gt 0 ]; do 
			echo -n "|"
			(( cnt -- ))
		done
	}
	function CloseProgressBar_txt {
		echo ""
	}

	function LaunchProgressBar {
		if [ ${ConsoleInterface} -eq 1 ];then 
			LaunchProgressBar_txt "${@}" || return $?
		else
			LaunchProgressBar_gui "${@}" || return $?
		fi
		push_element CleanupFunctions CloseProgressBar
	}
	function UpdateProgressBar {
		if [ ${ConsoleInterface} -eq 1 ];then 
			UpdateProgressBar_txt "${@}" || return $?
		else
			UpdateProgressBar_gui "${@}" || return $?
		fi
	}
	function CloseProgressBar {
		if [ ${ConsoleInterface} -eq 1 ];then 
			CloseProgressBar_txt "${@}" || return $?
		else
			CloseProgressBar_gui "${@}" || return $?
		fi
	}

	#########################################################################
	# Procedures
	#########################################################################
	#push_element RequiredDebianPackages moreutils
	#push_element RequiredRpmPackages moreutils
	#push_element RequiredGentooPackages moreutils

	ProgressFuncsRevision=$(CleanRevision '$Revision: 64 $')
	push_element	ScriptsLoaded "ProgressFuncs.sh;${ProgressFuncsRevision}"
	if [ "${SBaseName2}" = "ProgressFuncs.sh" ]; then 
		ScriptRevision="${ProgressFuncsRevision}"

		function InstallDependencies {
			InstallPackages "${@}"  
		}

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
		#push_element ModulesArgHandlers SetGenFuncsFlags 
		#push_element SupportedCLIOptions 
		MainOptionArg "" "${@}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		echo "###############################################"
		echo "# ${SBaseName2} $(gettext "Test Module")"
		echo "###############################################"
		LaunchProgressBar  800
		for (( cnt=0; cnt<= 800; cnt+=11 )); do
			UpdateProgressBar ${cnt}
			sleep 1s
		done
		CloseProgressBar


		sNormalExit 0
	fi
fi

