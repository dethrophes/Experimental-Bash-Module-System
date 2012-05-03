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
#I              File Name            : fsck.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : fsck.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
if [ -z "${__fsck_sh__:-}" ]; then
	__fsck_sh__=1

	
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
	SourceCoreFiles_ "DiskFuncs.sh"
	#SourceFiles_ "${ScriptDir}/DiskFuncs.sh"

	#########################################################################
	# Procedures
	#########################################################################

	function Set_fsck_Flags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			case "${1}" in
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


	function fsck_disk {
		while [ $# -gt 0 ] ; do
			time if [ -b "${1}" ]; then
				RunProgRoot 1 umount "${1}" || return $?
				RunProgRoot 1 fsck -p "${1}" || return $?
				RunProgRoot 1 mount "${1}" || return $?
			fi
			shift
		done
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

	fsckRevision=$(CleanRevision '$Revision: 64 $')
	fsckDescription=' -- Wrapper for fsck'
	push_element	ScriptsLoaded "fsck.sh;${fsckRevision};${fsckDescription}"
	if [ "${SBaseName2}" = "fsck.sh" ]; then 
		ScriptRevision="${fsckRevision}"

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
		#push_element ModulesArgHandlers "Set_fsck_Flags" "Set_fsck_exec_Flags"
		#push_element SupportedCLIOptions 
		function Set_fsck_exec_Flags {
			local -i PCnt=0
			while [ $# -gt 0 ] ; do
				case "${1}" in
					--SupportedOptions)
						[ ${PCnt} -eq 0 ] && ConsoleStdoutN ""
						break
						;;
					-*)
							sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
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
		MainOptionArg ArgFiles "${@}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		echo "###############################################"
		echo "# ${SBaseName2} $(gettext "Test Module")"
		echo "###############################################"
		
		fsck_disk "${ArgFiles[@]}"

		sNormalExit 0
	fi
fi

