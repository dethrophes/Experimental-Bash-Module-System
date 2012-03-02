#!/bin/bash +x
#if [ "$DEBUG" != "1" ]; then stty -echo; fi
#<KHeader>
#+=========================================================================
#I  Project Name: Kontron Secure Bios
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/open_real_path.sh $
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
#I  ID                   : $Id: open_real_path.sh 51 2012-01-17 12:33:18Z dethrophes $
#I
#+=========================================================================
#</KHeader>
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
SourceCoreFiles_ "oc.sh" 

if [ -z "${__open_real_path_SH__:-}" ]; then
	__open_real_path_SH__=1

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
			#	FNAME=$FNAME
			#	;;
			home)  [ -e "/mnt/${HOSTNAME}/home/${FPath2}" ] && FNAME="/mnt/${HOSTNAME}/home/${FPath2}" ;;
			media) [ -e "/mnt/${HOSTNAME}${FNAME}" ] && FNAME="/mnt/${HOSTNAME}${FNAME}" ;;
			#*)
			#	FNAME=$FNAME
			#	;;
		esac
		ReturnString "${FNAME}"
	}


	declare -gr open_real_pathFileRevision=$(CleanRevision '$Revision: 51 $')
	declare -gr open_real_pathFileDescription="$(gettext "Please Enter a program description here") "
	push_element	ScriptsLoaded "open_real_path.sh;${open_real_pathFileRevision};${open_real_pathFileDescription}"
	if [ "${SBaseName2}" = "open_real_path.sh" ]; then 
		declare -gr ScriptRevision=${open_real_pathFileRevision}

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
		push_element ModulesArgHandlers  Set_oc_Flags 
		#push_element SupportedCLIOptions 
		
		MainOptionArg ArgFiles "${@}"

		#########################################################################
		# MAIN PROGRAM
		#########################################################################
		FindBrowser
		
		if [ -z "${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS:-}" ]; then
			[ -n "${ArgFiles[0]}" ] || exit 2
			FNAME="${ArgFiles[0]}"
		else
			FNAME="${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS}"
			#exec 1>/tmp/$ScriptName.log 2>&1
		fi

		FNAME="$(realpath "$FNAME")"
		FNAME="$(FunctionMapGlobal "$FNAME")"

		Browse "$FNAME" 


		sNormalExit $?
	fi
fi
