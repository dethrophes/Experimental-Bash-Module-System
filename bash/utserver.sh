#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/utserver.sh $
#+=========================================================================
#I   Copyright: Copyright (c) 2002-2009, Kontron Embedded Modules GmbH
#I      Author: John Kearney,                  John.Kearney@kontron.com
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
#I Description:  -- utserver wrapper
#I
#+------------------------------------------------------------------------=
#I
#I  File Name            : utserver.sh
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: utserver.sh 53 2012-02-17 13:29:00Z dethrophes $
#I
#+=========================================================================
#</KHeader>

#########################################################################
# Source Files
#########################################################################
if [ -z "${__GenFuncs_sh__:-}" ]; then
	[ -z "${ScriptDir:-}"	] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
	if [ -f "${ScriptDir}/GenFuncs.sh" ]; then
		source "${ScriptDir}/GenFuncs.sh"
	else
		echo "# "
		echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
		echo "# "
		exit 7
	fi
fi
#SourceCoreFiles_ "ScriptWrappers.sh"
#SourceFiles_ "${ScriptDir}/DiskFuncs.sh"

if [ -z "${__utserver_sh__:-}" ]; then
	declare -gr __utserver_sh__=1



	#########################################################################
	# Procedures
	#########################################################################

	function Set_utserver_Flags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			case "${1}" in
				-logfile)
					sTestEnoughArgs $# 1 "${1} $(gettext "Requires Arg ") "
					shift
				  #SetLogFileName "&1"
					[ -z "${1}" ] || exec &>>"${1}"
					;;
				-pidfile)
					sTestEnoughArgs $# 1 "${1} $(gettext "Requires Arg ") "
					shift
					DiagnoseWriteAccess pidfile "${1}"
					echo $$  > "${1}"
					;;
				-usage)
					"${utserver}" "${1}"
					exit
					;;
				-daemon)
					BeDaemon=1
					;;
				-configfile)
					sTestEnoughArgs $# 1 "${1} $(gettext "Requires Arg ") "
					push_element "${ArrayName}" "${1}"
					shift
					DiagnoseReadAccess configfile "${1}"
					push_element "${ArrayName}" "${1}"
					;;
				-settingspath)
					sTestEnoughArgs $# 1 "${1} $(gettext "Requires Arg ") "
					push_element "${ArrayName}" "${1}"
					shift
					DiagnoseWriteAccessFolder settingspath "${1}"
					push_element "${ArrayName}" "${1}"
					;;
				-*)
					sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
					;;
				--Usage)
					if [ $PCnt -eq 0 ]; then
						ConsoleStdoutN ""
						#ConsoleStdout "I    -h --help                                                                   "
						#ConsoleStdout "I             $(gettext "Display This message")                                  "
					fi
					break
					;;
				--SupportedOptions)
					[ ${PCnt} -eq 0 ] && ConsoleStdoutN ""
					break
					;;
				*)
					break
					;;
			esac
			let PCnt+=1
			shift
		done
		return ${PCnt}
	}

	#########################################################################
	# Required Packages
	#########################################################################
	#push_element RequiredDebianPackages	<Package Name> ...
	#push_element RequiredRpmPackages			<Package Name> ...
	#push_element RequiredGentooPackages	<Package Name> ...
	#push_element RequiredSolarisPackages	<Package Name> ...
	#push_element RequiredFreeBsdPackages	<Package Name> ...
	#push_element RequiredSusePackages		<Package Name> ...

	declare -gr utserverRevision=$(CleanRevision '$Revision: 53 $')
	declare -gr utserverDescription="$(gettext "Please Enter a program description here") "
	push_element	ScriptsLoaded "GenFuncs.sh;${utserverRevision};${utserverDescription}"
	if [ "${SBaseName2}" = "utserver.sh" ]; then 
		declare -gr ScriptRevision="${utserverRevision}"

		#########################################################################
		# Usage
		#########################################################################
		function Usage {
			ConsoleStdout "."
			ConsoleStdout "+=============================================================================="
			ConsoleStdout "I  ${SBaseName2} ................................................... ${ScriptRevision}"
			ConsoleStdout "+=============================================================================="
			ConsoleStdout "I " 
			ConsoleStdout "I  $(gettext "Description"):                                                     "
			ConsoleStdout "I    $(gettext "Please Enter a program description here")                        "
			ConsoleStdout "I                                                                                "
			ConsoleStdout "I  $(gettext "Usage"):                                                           "
			UsageCommon
			ConsoleStdout "I                                                                                "
			ConsoleStdout "I                                                                                "
			sNormalExit 0
		}

		SetLogFileName "&1"
		declare -g BeDaemon=0
		declare -gr utserver="/opt/utorrent/server/bin/utserver"

		sLogOut "${0}" "$@"

		#########################################################################
		# Argument Processing
		#########################################################################
		push_element ModulesArgHandlers Set_utserver_Flags 
		MainOptionArg ArgFiles "${@}"

		#########################################################################
		# MAIN PROGRAM
		#########################################################################
		declare -g SPID
		function KillutserverFunction {
			[ -n "${SPID:-}" ] && KillProcess 0 ${SPID}
		}
		push_element CleanupFunctions "KillutserverFunction"

		function lRunProg {
			echo "${*}"
			"${@}" &
      SPID=$! 
			wait
		}
		function RunUtServer {
			while true ; do
				lRunProg "${utserver}" "${ArgFiles[@]}"
				sleep 9s
			done
		}

		if [ ${BeDaemon} -eq 1 ]; then
			RunUtServer &
		else
			RunUtServer 
		fi
		sNormalExit 0
	fi
fi

