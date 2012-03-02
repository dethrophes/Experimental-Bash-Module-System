#!/bin/bash
#if [ "$DEBUG" != "1" ]; then stty -echo; fi
#<KHeader>
#+=========================================================================
#I  Project Name: Kontron Secure Bios
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/init.modt005.sh $
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
#I Description: Auto Created for SOURCES
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : template.sh
#I  File Location        : bash
#I  Last committed       : $Revision: 51 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-01-17 13:33:18 +0100 (Tue, 17 Jan 2012) $
#I  ID                   : $Id: init.modt005.sh 51 2012-01-17 12:33:18Z dethrophes $
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
		ScriptRevision=$(CleanRevision '$Revision: 51 $')

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
