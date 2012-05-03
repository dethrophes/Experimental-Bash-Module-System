#!/bin/bash +x
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
#I  File Name            : open_real_path.sh
#I  File Location        : Experimental-Bash-Module-System/bash
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


	readonly open_real_pathFileRevision=$(CleanRevision '$Revision: 64 $')
	readonly open_real_pathFileDescription="$(gettext "Please Enter a program description here") "
	push_element	ScriptsLoaded "open_real_path.sh;${open_real_pathFileRevision};${open_real_pathFileDescription}"
	if [ "${SBaseName2}" = "open_real_path.sh" ]; then 
		readonly ScriptRevision=${open_real_pathFileRevision}

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
