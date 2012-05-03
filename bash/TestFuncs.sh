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
#I              File Name            : TestFuncs.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : TestFuncs.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>

[ -z "${ScriptDir:-}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

[ -z "${__GenFuncs_sh__:-}" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"

if [ -z "${__TestFuncs_sh__:-}" ]; then
	__TestFuncs_sh__=1

	#########################################################################
	# Procedures
	#########################################################################
 	function TestEnoughArgs {
		local COffset=$(( ${1} +1 ))  # argument 1: last line of error occurence
		local ArgsLeft="${2}"      # argument 2: error code of last command
		local ArgsReq="${3}"       # argument 2: error code of last command
		local EMSG="${4}"          # argument 2: error code of last command
		[ ${ArgsLeft} -gt ${ArgsReq} ] || Error_Exit "${COffset}" 8 "${EMSG}"
	}
	function TestFolder {
		while [ $# -gt 0 ]; do
			if [ -d "${1}" ]; then 
				return 0
			elif [ -e "${1}" ]; then
				sErrorOut "$(gettext "Expected Folder got $(GetFileTextType "${1}")")" "${1}"
				return 1
			else 
				sErrorOut "$(gettext "Doesn't Exist")" "${1}"
				return 2
			fi
			shift
		done
	}

	function TestStrPerlRegEx {
		echo "${1}" | grep -iP "${2}" >/dev/null 2>&1
	}

	function TestEmptyArg {
		[ -z "${1}" ] && sErrorOut "$(gettext "Arg error missing") ${2}" && return 5
		return 0
	}

	#push_element RequiredDebianPackages moreutils
	#push_element RequiredRpmPackages moreutils
	#push_element RequiredGentooPackages moreutils

	TestFuncsRevision=$(CleanRevision '$Revision: 64 $')
	push_element	ScriptsLoaded "TestFuncs.sh;${TestFuncsRevision}"
	if [ "${SBaseName2}" = "TestFuncs.sh" ]; then 
		ScriptRevision="${TestFuncsRevision}"

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

		sNormalExit 0
	fi
fi

