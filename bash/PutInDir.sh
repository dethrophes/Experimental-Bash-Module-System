#!/bin/bash 
set -o nounset 
set -e
[[ ${DEBUG:-0} != 1 ]] || set -o xtrace
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
#I  File Name            : PutInDir.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>

#########################################################################
# Source Files
#########################################################################
if [ -z "${__GenFuncs_sh__:-}" ]; then
	[ -n "${ScriptDir:-}"	] || ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
	if [ -f "${ScriptDir}/GenFuncs.sh" ]; then
		source "${ScriptDir}/GenFuncs.sh" || exit
	elif which GenFuncs.sh &>/dev/null ; then
		ScriptDir[1]="$(dirname "$(which "${ScriptDir}/GenFuncs.sh")")"
		source "$(which "${ScriptDir}/GenFuncs.sh")" || exit
	else
		echo "# "
		echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
		echo "# "
		exit 7
	fi
fi

if [ -z "${__PutInDir_SH__:-}" ]; then
	__PutInDir_SH__=1

	SourceCoreFiles_ "ScriptWrappers.sh"

	#########################################################################
	# PROCEDURES
	#########################################################################
	function PutInFolder {
		local file
		local sfile
		for file in "${@}"; do
			if [ -h "${file}" ]; then
				echo LINK: ${file}
			elif [ -d "${file}" ]; then
				echo DIR : ${file}
			elif [ -f "${file}" ]; then
				sfile="${file%.*}"
				echo FILE: "${file}"; 
				SimpleMkdir "${sfile}"
				if [ -d "${sfile}" ]; then
					sRunProg mv "${file}" "${sfile}"
				else
					sErrorOut "unknown \"${sfile}\""
				fi
			fi
		done
	}

	readonly PutInDirRevision=$(CleanRevision '$Revision: 64 $')
	readonly PutInDirDescription="$(gettext "Please Enter a program description here") "
	push_element	ScriptsLoaded "PutInDir.sh;${PutInDirRevision};${PutInDirDescription}"
	if [ "${SBaseName2}" = "PutInDir.sh" ]; then 
		ScriptRevision="${PutInDirRevision}"

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


		#########################################################################
		# Argument Processing
		#########################################################################
		push_element ModulesArgHandlers SupportCallingFileFuncs 
		#push_element SupportedCLIOptions 
		MainOptionArg "ArgFiles"  "${@}"



		#########################################################################
		# MAIN PROGRAM
		#########################################################################
		for DstFldr in "${ArgFiles[@]}"; do
			PutInFolder "${DstFldr}"/*
		done


		sNormalExit 0
	fi
fi

