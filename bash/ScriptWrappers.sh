#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I  Project Name: Kontron Secure Bios
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/ScriptWrappers.sh $
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
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: ScriptWrappers.sh 53 2012-02-17 13:29:00Z dethrophes $
#I
#+=========================================================================
#</KHeader>
if [ -z "${__SCRIPTWRAPPERS_SH__:-}" ]; then
	__SCRIPTWRAPPERS_SH__=1

	[ -z "${ScriptDir:-}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

	[ -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"
	#[ -f "${ScriptDir}/DiskFuncs.sh" ] && source "${ScriptDir}/DiskFuncs.sh"
	#[ -f "${ScriptDir}/ScriptWrappers.sh" ] && source "${ScriptDir}/ScriptWrappers.sh"

	#########################################################################
	# PROCEDURES
	#########################################################################
	function RecreateLinks {
		RunProg 1 "$(GetFileName "CreateMasterList.sh")" $(InterfaceType) --LogFile "$LogFile"  >/dev/null
	}
	function CreateStorageFolder {
		RunProg 1 "$(GetFileName "CreateStorageFolder.sh")" $(InterfaceType) --LogFile "$LogFile" --CreateMissingFolder "$@" >/dev/null
	}
	function Move {
		RunProg 1 "$(GetFileName "move.sh")" $(InterfaceType) --LogFile "$LogFile" --SSYM "$@" >/dev/null
	}
	function SortFiles {
		RunProg 1 "$(GetFileName "SortFiles.sh")" $(InterfaceType) --LogFile "$LogFile" "$@" >/dev/null
	}
	function OpenCurrent {
		RunProg 1 "$(GetFileName "oc.sh")" $(InterfaceType) --LogFile "$LogFile" "$@" >/dev/null
	}
	function OpenBrandNewConsole {
		RunProg 1 "$(GetFileName "obnc.sh")" $(InterfaceType) --LogFile "$LogFile" "$@" >/dev/null
	}

	if [ "${SBaseName2}" = "ScriptWrappers.sh" ]; then 
		ScriptRevision=$(CleanRevision '$Revision: 53 $')

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

		sLogOut "${0}" "${@}"

		#########################################################################
		# Argument Processing
		#########################################################################
		MainOptionArg ""  "${@}"

		#########################################################################
		# MAIN PROGRAM
		#########################################################################


		sNormalExit $?
	fi
fi
