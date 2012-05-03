#!/bin/bash +x
#if [ "${DEBUG}" != "1" ]; then stty -echo; fi
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
#I Description: -- Text File Editor Wrapper
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : EditTxtFile.sh
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
SourceCoreFiles_ "DiskFuncs.sh" "ScriptWrappers.sh"

if [ -z "${__EditTxtFile_SH__:-}" ]; then
	__EditTxtFile_SH__=1


	TextEditor=""
	SupportedEditors=(gvim gedit uex)


	#########################################################################
	# PROCEDURES
	#########################################################################
	function FindTextEditor {
		[ -n "${TextEditor}" ] || TextEditor="$(which gvim					)";
		[ -n "${TextEditor}" ] || TextEditor="$(which gedit					)";
		[ -n "${TextEditor}" ] || TextEditor="$(which uex						)";
		[ -n "${TextEditor}" ]
	}



	#########################################################################
	# Open TextEditor
	#########################################################################
	function Edit {
		function OptionalArg {
			if [ ! -z "${1}" ]; then
				ReturnString "${2}${1}${3}"
			fi
		}
		LFNAME="${1}"
		pushd "$(dirname "${LFNAME}")" &>/dev/null
		case "$(basename "${TextEditor}")" in
			gvim)
				sRunProg "${TextEditor}"  "${LFNAME}" "+normal ${2}G${3}|" &>/dev/null &
				;;
			gedit)
				sRunProg "${TextEditor}"  "${LFNAME}" $(OptionalArg "${2}" "+" ":${3}") &>/dev/null &
				;;
			uex)
				sRunProg "${TextEditor}"  "${LFNAME}" $(OptionalArg "${2}" "--lc" ":${3}") &>/dev/null &
				;;
			*)
				sRunProg "${TextEditor}" "${LFNAME}"  &>/dev/null &
				;;
		esac
		popd  &>/dev/null
	}

	function Set_EditTxtFile_Flags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			#echo "2 ${1}"
			case "${1}" in
				--Usage)
					if [ $PCnt -eq 0 ]; then
						ConsoleStdout "I       --lc                                                                     "
						ConsoleStdout "I             $(gettext "Specify Line Column")                                   "
						ConsoleStdout "I    ${SupportedEditors[*]}                                                      "
						ConsoleStdout "I             $(gettext "Supported Editor Options")                              "
					fi
					break
					;;
				--SupportedOptions)
					[ ${PCnt} -eq 0 ] && ConsoleStdoutN "-lc ${SupportedEditors[*]}"
					break
					;;
				-lc[0-9]*)
					LineCol="${1/#-lc/}"
					LineNum="${LineCol%:*}"
					LineCol="${LineCol#*:}"
					;;
				+[0-9]*)
					LineNum="${1:1}"
					;;
				-*)
						sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
					;;
				*)
					for COPT in ${SupportedEditors[@]}; do
						if [ "${1}" == "${COPT}" ]; then
							TextEditor=${1}
							let PCnt+=1
							shift
							break 2
						fi
					done
					break
					;;
			esac
			let PCnt+=1
			shift
		done
		return ${PCnt}
	}


	readonly EditTxtFileRevision=$(CleanRevision '$Revision: 64 $')
	readonly EditTxtFileDescription="$(gettext "Please Enter a program description here") "
	push_element	ScriptsLoaded "EditTxtFile.sh;${EditTxtFileRevision};${EditTxtFileDescription}"
	if [ "${SBaseName2}" = "EditTxtFile.sh" ]; then 
		readonly ScriptRevision="${EditTxtFileRevision}"


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

		declare -gi LineNum=0
		declare -gi LineCol=0
		#########################################################################
		# Argument Processing
		#########################################################################
		push_element ModulesArgHandlers  Set_EditTxtFile_Flags Set_EditTxtFile_exec_Flags
		#push_element SupportedCLIOptions 
		function Set_EditTxtFile_exec_Flags {
			local -i PCnt=0
			while [ $# -gt 0 ] ; do
				case "${1}" in
				--Usage|--SupportedOptions)
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
		MainOptionArg ArgFiles  "${@}"
		#########################################################################
		# MAIN PROGRAM
		#########################################################################
		FindTextEditor

		Edit "${ArgFiles[0]}" "${LineNum}" "${LineCol}"

		sNormalExit $?
	fi
fi

