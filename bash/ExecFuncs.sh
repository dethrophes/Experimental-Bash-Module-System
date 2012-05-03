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
#I              File Name            : ExecFuncs.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : ExecFuncs.sh
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
		echo "# "
		echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
		echo "# "
		exit 7
	fi
fi

if [ -z "${__ExecFuncs_sh__:-}" ]; then
	__ExecFuncs_sh__=1

	function RunProg {
		local -i ReturnValue=0
		local -i COffset=$(( ${1} +1 ))
		shift 1
		CmdOut "${COffset}" "${@}"
		if [ -f "${LogFile}" ]; then
			"${@}" &>>"${LogFile}" || ReturnValue=$?
		else
			"${@}" || ReturnValue=$?
		fi
		[ ${ReturnValue} -eq 0 ] || ErrorOut "${COffset}" \
									"$(CreateEscapedArgList "${@}")" \
									"$(gettext "Returned non Zero (${ReturnValue})")"
		return ${ReturnValue}
	}
	function RunProgRoot {
		RunProg "$(( ${1} +1 ))" "$(GetSudo)" "${@:2}" || return $?
	}	

	CoProcessList=()
	function AddCoProcessId {
		if [ -z "${CleanupFunctions[0]:-}" ]; then 
			push_element CleanupFunctions KillAllCoProcess
		fi
		push_element CoProcessList ${1}
	}
	function RemoveCoProcessId {
		CoProcessList=( ${CoProcessList[*]/#${1}$/} )
	}
	function KillCoProcess {
		RemoveCoProcessId ${1}
		kill ${1}
	}
	function KillAllCoProcess {
		[ ${#CoProcessList[*]} -eq 0 ] || kill ${CoProcessList[*]}
	}


	#########################################################################
	# Procedures
	#########################################################################
	#push_element RequiredDebianPackages moreutils
	#push_element RequiredRpmPackages moreutils
	#push_element RequiredGentooPackages moreutils

	ExecFuncsRevision=$(CleanRevision '$Revision: 64 $')
	push_element	ScriptsLoaded "ExecFuncs.sh;${ExecFuncsRevision}"
	if [ "${SBaseName2}" = "ExecFuncs.sh" ]; then 
		ScriptRevision="${ExecFuncsRevision}"


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

		sNormalExit 0
	fi
fi

