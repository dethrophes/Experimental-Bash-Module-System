#!/bin/bash
#if [ "$DEBUG" != "1" ]; then stty -echo; fi
#<KHeader>
#+=========================================================================
#I  Project Name: Kontron Secure Bios
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/uTorrent.sh $
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
#I  ID                   : $Id: uTorrent.sh 51 2012-01-17 12:33:18Z dethrophes $
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
SourceCoreFiles_ "ScriptWrappers.sh"
#SourceFiles_ "${ScriptDir}/DiskFuncs.sh"

if [ -z "${__uTorrent_SH__}" ]; then
	declare -gr __uTorrent_SH__=1

	#########################################################################
	# PROCEDURES
	#########################################################################

	if [ "${SBaseName2}" = "uTorrent.sh" ]; then 
		declare -gr ScriptRevision=$(CleanRevision '$Revision: 51 $')

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
		MainOptionArg ""  "${ArgFiles[@]}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################
		uTorrent2=~/.wine/dosdevices/c\:/Program\ Files/uTorrent/uTorrent_2.2.1.exe
		uTorrent3=~/.wine/dosdevices/c\:/Program\ Files/uTorrent/utorrent_3.0.exe
		uTorrent3=~/.wine/dosdevices/c\:/Program\ Files/uTorrent/utorrent-3.1-latest.exe
		uTorrent=~/.wine/dosdevices/c\:/Program\ Files/uTorrent/uTorrent.exe

		cp "$uTorrent2" "$uTorrent" 
		sRunProg wine "$uTorrent" /NOINSTALL /BRINGTOFRONT &

		sNormalExit $?
	fi
fi


