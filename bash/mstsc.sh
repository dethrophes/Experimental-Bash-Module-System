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
#I Description: Auto Created for SOURCES
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : mstsc.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
if [ -z "${__mstsc_SH__}" ]; then
	__mstsc_SH__=1

	[ -z "${ScriptDir}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
	[ -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	[ -f "${ScriptDir}/DiskFuncs.sh" ] && source "${ScriptDir}/DiskFuncs.sh"
	[ -f "${ScriptDir}/ScriptWrappers.sh" ] && source "${ScriptDir}/ScriptWrappers.sh"

	#########################################################################
	# PROCEDURES
	#########################################################################

	if [ "${SBaseName2}" = "mstsc.sh" ]; then 
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


		#sLogOut "${0}" "$@"

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



		CfgLine=$(cat "${HOME}/.mstscpass" | grep "${ArgFiles[0]}")
		if [ -n "${CfgLine}" ]; then
			Ip=${CfgLine#*:}
			Ip=${Ip%:*}
			IpCfg=${CfgLine##*:}
		else
			Ip="${ArgFiles[0]}"
			IpCfg=
		fi
		echo sRunProg rdesktop -g 1900x1050 -5 $IpCfg -N -z -x m -r sound:remote -r clipboard:CLIPBOARD -k de $Ip "${ArgFiles[@]:1}" &
		#sRunProg rdesktop -g 1900x1050 -5 $IpCfg -N -z -x m -r sound:remote -r clipboard:CLIPBOARD -k de $Ip "${ArgFiles[@]:1}" &
		sNormalExit $?
	fi
fi
