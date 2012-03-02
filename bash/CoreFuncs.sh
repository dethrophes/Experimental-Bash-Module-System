#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/CoreFuncs.sh $
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
#I Description: 
#I
#+------------------------------------------------------------------------=
#I
#I  File Name            : CoreFuncs.sh
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: CoreFuncs.sh 53 2012-02-17 13:29:00Z dethrophes $
#I
#+=========================================================================
#</KHeader>

[ -z "${ScriptDir:-}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

[ -z "${__GenFuncs_sh__:-}" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"

if [ -z "${__CoreFuncs_sh__:-}" ]; then
	__CoreFuncs_sh__=1
	function SimpleMkdir {
		local CFile
		for CFile in "${@}"; do 
			if [ ! -e "${CFile}" ]; then 
				sRunProg mkdir -p "${CFile}"
			elif [ -f "${CFile}" ]; then
				sErrorOut "$(gettext "File with the same name exists")" \
																					 "$(gettext "exists :") \"${CFile}\""

				return 6
			fi
		done
	}
	function SimpleRmdir {
		local CFile
		for CFile in "${@}"; do 
			if [ -d "${CFile}" ]; then 
				sRunProg rmdir "${CFile}"
			elif [ -f "${CFile}" ]; then
				sErrorOut "$(gettext "This is a File Not a Folder")" \
																					 "$(gettext "skipping Delete :") \"${CFile}\""
				return 6
			fi
		done
	}
	function SimpleRmdirRecursive {
		local CFile
		for CFile in "${@}"; do 
			if [ -d "${CFile}" ]; then 
				sRunProg rm -R --interactive=never "${CFile}"
			elif [ -f "${CFile}" ]; then
				sErrorOut "$(gettext "This is a File Not a Folder")" \
																					 "$(gettext "skipping Delete :") \"${CFile}\""
				return 6
			fi
		done
	}
	function SimpleDelFile {
		local CFile
		for CFile in "${@}"; do 
			if [ -f "${CFile}" -o -h "${CFile}" ]; then 
				sRunProg rm --interactive=never "${CFile}"
			elif [ -d "${CFile}" ]; then
				sErrorOut "$(gettext "This is a folder Not a File")" \
																					 "$(gettext "skipping Delete :") \"${CFile}\""
				return 6
			fi
		done
	}

	#########################################################################
	# Procedures
	#########################################################################
	#push_element RequiredDebianPackages moreutils
	#push_element RequiredRpmPackages moreutils
	#push_element RequiredGentooPackages moreutils

	CoreFuncsRevision=$(CleanRevision '$Revision: 53 $')
	push_element	ScriptsLoaded "CoreFuncs.sh;${CoreFuncsRevision}"
	if [ "${SBaseName2}" = "CoreFuncs.sh" ]; then 
		ScriptRevision="${CoreFuncsRevision}"

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

