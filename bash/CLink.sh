#!/bin/bash
#if [ "$DEBUG" != "1" ]; then stty -echo; fi
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
#I Description: -- Fix Sym Links
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : CLink.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
if [ -z "${__CLink_SH__}" ]; then
	__CLink_SH__=1

	[ -z "${ScriptDir:-}"	] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

	#########################################################################
	# Source Files
	#########################################################################
	[ -z "${__GenFuncs_sh__:-}" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	SourceCoreFiles_ "ScriptWrappers.sh"

	#########################################################################
	# PROCEDURES
	#########################################################################
	function FunctionMapGlobal {
		local FNAME
		local FPath1
		local FPath2
		FNAME=${1}
		FPath1="$(echo "${FNAME}" | sed -r "s/^\/(\w+)(\/.*)/\1/")"
		FPath2="$(echo "${FNAME}" | sed -r "s/^\/\w+\/(\w+)//")"
		case "${FPath1}" in
			#mnt)
			#	FNAME=${FNAME}
			#	;;
			home)  [ -e "/mnt/${HOSTNAME}/home/${FPath2}" ] && FNAME="/mnt/${HOSTNAME}/home/${FPath2}" ;;
			media) [ -e "/mnt/${HOSTNAME}${FNAME}" ] && FNAME="/mnt/${HOSTNAME}${FNAME}" ;;
			#*)
			#	FNAME=$FNAME
			#	;;
		esac
		ReturnString "${FNAME}"
	}


	if [ "${SBaseName2}" = "CLink.sh" ]; then 
		ScriptRevision=$(CleanRevision '$Revision: 64 $')

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

		sLogOut "${0}" "$@"

		#########################################################################
		# Argument Processing
		#########################################################################
		function MainOptionArg {
			local ArrayName="${1}"
			shift
			eval ${ArrayName}=\(\)
			while [ $# -gt 0 ] ; do
				case "${1}" in
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
		MainOptionArg ArgFiles  "${ArgFiles[@]}"

		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		for CurFile in "${ArgFiles[@]}"; do
			CurFile="$(FunctionMapGlobal "$CurFile")"
			sRunProg ln -s "$CurFile" "$(basename "$CurFile")"
		done

		sNormalExit $?
	fi
fi
