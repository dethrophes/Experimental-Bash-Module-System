#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               JK Script Tools
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/vt52Funcs.sh $
#+=========================================================================
#I   Copyright: Copyright (c) 2002-2012, dethrophes@web.de
#I      Author: John Kearney,                  dethrophes@web.de
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
#I  File Name            : vt52Funcs.sh
#I  File Location        : scripts/bash
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: vt52Funcs.sh 53 2012-02-17 13:29:00Z dethrophes $
#I
#+=========================================================================
#</KHeader>

#########################################################################
# Source Files
#########################################################################
if [ -z "${__GenFuncs_sh__:-}" ]; then
	[ -z "${ScriptDir:-}"	] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"
	if [ -f "${ScriptDir}/GenFuncs.sh" ]; then
		source "${ScriptDir}/GenFuncs.sh" || exit
	else
		echo "# "
		echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
		echo "# "
		exit 7
	fi
fi
#SourceCoreFiles_ "DiskFuncs.sh"
#SourceFiles_ "${ScriptDir}/DiskFuncs.sh"

if [ -z "${__vt52Funcs_sh__:-}" ]; then
	__vt52Funcs_sh__=1
	#########################################################################
	# Module Shared Procedures
	#########################################################################

	#	VT52 Mode
	#	Parameters for cursor movement are at the end of the ESC Y escape sequence. Each ordinate is encoded in a single
	#	character as value+32. For example, ! is 1. The screen coordinate system is 0-based.
	declare -gr vt52_CursorUp=$'\eA'		# Cursor up.
	declare -gr vt52_CursorDown=$'\eB'	# Cursor down.
	declare -gr vt52_CursorRight=$'\eC'	# Cursor right.
	declare -gr vt52_CursorLeft=$'\eD'	# Cursor left.
	declare -gr vt52_EnterGM=$'\eF'			# Enter graphics mode.
	declare -gr vt52_ExitGM=$'\eG'			# Exit graphics mode.
	declare -gr vt52_MoveHome=$'\eH'		# Move the cursor to the home position.
	declare -gr vt52_ReverseLF=$'\eI'		# Reverse line feed.
	declare -gr vt52_EraseC2ES=$'\eJ'		# Erase from the cursor to the end of the screen.
	declare -gr vt52_EraseC2EL=$'\eK'		# Erase from the cursor to the end of the line.
	# Ps Ps Move the cursor to given row and column.
	function	vt52_cup {	echo -n "${ESC}Y${1?Missing Ps};${2?Missing Ps}${ST}";	}
	declare -gr vt52_Identify=$'\eZ'		# Identify
																			#	® ESC / Z (‘‘I am a VT52.’’)
	declare -gr vt52_Enter_akm=$'\e='		# Enter alternate keypad mode.
	declare -gr vt52_Exit_akm=$'\e>'		# Exit alternate keypad mode.
	declare -gr vt52_ExitVT52mode=$'\e<' # Exit VT52 mode (Enter VT100 mode).

	

	#########################################################################
	# Procedures
	#########################################################################

	#########################################################################
	# Module Argument Handling
	#########################################################################
	function Set_vt52Funcs_Flags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			case "${1}" in
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

	vt52FuncsRevision=$(CleanRevision '$Revision: 53 $')
	vt52FuncsDescription=''
	push_element	ScriptsLoaded "vt52Funcs.sh;${vt52FuncsRevision};${vt52FuncsDescription}"
fi
if [ -n "${__GenFuncs_sh_Loaded_-}" -a "${SBaseName2}" = "template.sh" ]; then 
	ScriptRevision="${templateRevision}"

	#########################################################################
	# Procedures
	#########################################################################

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
	sLogOut "${0}" "${@}"


	#########################################################################
	# Argument Processing
	#########################################################################
	push_element ModulesArgHandlers SupportCallingFileFuncs "Set_vt52Funcs_Flags" "Set_vt52Funcs_exec_Flags"
	#push_element SupportedCLIOptions 
	function Set_vt52Funcs_exec_Flags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			case "${1}" in
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
	#MainOptionArg ArgFiles "${@}"
	MainOptionArg "" "${@}"


	#########################################################################
	# MAIN PROGRAM
	#########################################################################

	echo "###############################################"
	echo "# ${SBaseName2} $(gettext "Test Module")"
	echo "###############################################"

	sNormalExit 0
fi

