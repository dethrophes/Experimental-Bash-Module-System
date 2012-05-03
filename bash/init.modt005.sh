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
#I  File Name            : init.modt005.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
if [ -z "${__init_modt005_sh__}" ]; then
	__init_modt005_sh__=1

	[ -z "${ScriptDir:-}"	] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

	#########################################################################
	# Source Files
	#########################################################################
	[ -z "${__GenFuncs_sh__:-}" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	SourceCoreFiles_ "ScriptWrappers.sh"

	#########################################################################
	# SHARED PROCEDURES
	#########################################################################

	if [ "${SBaseName2}" = "init.modt005.sh" ]; then 
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


		#LogOut "$FUNCNAME" "$LINENO" "$0" "$@"

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
		MainOptionArg ArgFiles  "${@}"


#########################################################################
# MAIN PROGRAM
#########################################################################

	case "${HOSTNAME}" in
		modt005)
			OpenBrandNewConsole . --exec ssh 192.168.178.21
			OpenBrandNewConsole . --exec ssh utorrent@192.168.178.21 '${HOME}/scripts/bash/utserver.sh -settingspath /var/opt/utorrent/server/ -configfile /etc/opt/utorrent/server/utserver.conf -logfile ""'
			sleep 15s
			OpenBrandNewConsole . --exec ssh 192.168.178.21 '${HOME}/scripts/bash/oc.sh /mnt/DETH00/media/GenData/Downloads/Finished/'
			OpenBrandNewConsole . --exec ssh 192.168.178.21 
			OpenBrandNewConsole . --exec ssh 192.168.178.51 
			OpenBrandNewConsole . --exec ssh 192.168.178.50 
			OpenBrandNewConsole /mnt/DETH00/home/scripts/bash
			OpenBrandNewConsole .
			OpenBrandNewConsole .
			;;
		DETH00)
			VBoxHeadless --startvm Gentoo_amd64 --vrdeproperty  "TCP/Ports=3390" &
			#VBoxHeadless --startvm Fedora_64 --vrdeproperty  "TCP/Ports=3391" &

			;;
	esac



		sNormalExit $?
	fi
fi
