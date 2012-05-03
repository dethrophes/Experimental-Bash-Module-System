#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
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
#I Description: 
#I              File Name            : PathFuncs.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : PathFuncs.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>

[ -z "${ScriptDir:-}" ] && ScriptDir="$(cd "$(dirname "${0}")"; pwd)"

[ -z "${__GenFuncs_sh__:-}" -a -f "${ScriptDir}/GenFuncs.sh" ] && source "${ScriptDir}/GenFuncs.sh"

if [ -z "${__PathFuncs_sh__:-}" ]; then
	__PathFuncs_sh__=1

	function realpath {
		readlink -f "${1}" || true
	}

	function SplitFilePath {
		IFS=$'/' eval "${1}"=\( \${2} \)
	}
	function JoinFilePath {
		IFS=$'/' eval echo -n \"\${*}\"
		[ $# -eq 1 -a "${1}" = "" ] && echo -n "/"
	}
	function path_common {
		set -- "${@//\/\///}"		## Replace all '//' with '/'
		local -a Path1
		local -i Cnt=0
		SplitFilePath Path1 "${1}"
		IFS=$'/' eval set -- \${2} 
		for CName in "${Path1[@]}" ; do
			[ "${CName}" != "${1}" ] && break;
			shift && let Cnt+=1
		done
		JoinFilePath "${Path1[@]:0:${Cnt}}"
	}
	declare -ga sResh=( .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. )
	function path_relative {
		#echo "${@}" >&2
		set -- "${@//\/\///}"		## Replace all '//' with '/'
		local -a Path1
		local -i Cnt=0
		SplitFilePath Path1 "${1}"
		IFS=$'/' eval set -- \${2} 
		for CName in "${Path1[@]}" ; do
			#echo "Cnt=$Cnt [ \"${CName}\" != \"${1}\" ]" >&2
			# (( Cnt++ ))
			[ "${CName}" != "${1}" ] && break;
			shift && let Cnt+=1
		done
		#echo "${Path1[*]:${Cnt}}" >&2
		if [ $# -eq 0 ]; then
			JoinFilePath "${Path1[@]:${Cnt}}"
		else 
			JoinFilePath "${sResh[@]:0:$#}" "${Path1[@]:${Cnt}}"
		fi
	}

	function FindExistingPathPart {
		local DirName
		DirName="${1}"
		UDir=""
		while [ ! -d "${DirName}" ] && [ ! -z "${DirName}" ]; do
			UDir="$(basename "${DirName}")"
			DirName="$(dirname "${DirName}")"
		done
		ReturnString "${DirName}"
	}
	function GetFileName {
		local AbsFName
		AbsFName="$(which "${1}")"
		if [ -z "${AbsFName}" ]; then
			AbsFName="${ScriptDir}/${1}"
			[ ! -e "${AbsFName}" ] && return 2
		fi
		ReturnString "${AbsFName}"
		return 0
	}
	
	function CleanFolderNameSub {
		ReturnString "${1}" | sed -r 's#/+\s*$##'
		return $?
	}


	function CleanFolderName {
		if [ -e "${1}" ]; then
			if [ -f "${1}" ]; then 
				ReturnString "$(cd "$(dirname "${1}")"; pwd)"
			else
				ReturnString "$(cd "${1}"; pwd)"
			fi
		else
			CleanFolderNameSub "${1}"
		fi
		return $?
	}



	#########################################################################
	# Procedures
	#########################################################################
	#push_element RequiredDebianPackages moreutils
	#push_element RequiredRpmPackages moreutils
	#push_element RequiredGentooPackages moreutils

	PathFuncsRevision=$(CleanRevision '$Revision: 64 $')
	push_element	ScriptsLoaded "PathFuncs.sh;${PathFuncsRevision}"
	if [ "${SBaseName2}" = "PathFuncs.sh" ]; then 
		ScriptRevision="${PathFuncsRevision}"


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
		#push_element ModulesArgHandlers SetGenFuncsFlags 
		#push_element SupportedCLIOptions 
		MainOptionArg "" "${@}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################

		echo "###############################################"
		echo "# ${SBaseName2} $(gettext "Test Module")"
		echo "###############################################"
		do_test () {
			if test "${@}"; then 
				DebugOut 1 "Pass [ $(CreateEscapedArgList "${@}" ])"
			else 
				ErrorOut 1 "Fail [ $(CreateEscapedArgList "${@}") ]"
				let failed+=1
			fi
		}

		failed=0
		do_test "$(path_common /a/b/c/d /a/b/e/f; echo x)" = /a/bx
		do_test "$(path_common /long/names/foo /long/names/bar; echo x)" = /long/namesx
		do_test "$(path_common / /a/b/c; echo x)" = /x		
		do_test "$(path_common a/b/c/d a/b/e/f ; echo x)" = a/bx
		do_test "$(path_common ./a/b/c/d ./a/b/e/f; echo x)" = ./a/bx
		do_test "$(path_common $'\n/\n/\n' $'\n/\n'; echo x)" = $'\n/\n'x
		do_test "$(path_common --/-- --; echo x)" = '--x'
		do_test "$(path_common '' ''; echo x)" = x
		do_test "$(path_common /foo/bar ''; echo x)" = x
		do_test "$(path_common /foo /fo; echo x)" = /x		## Changed from x
		do_test "$(path_common '--$`\! *@ \a\b\e\E\f\r\t\v\\\"'\'' 
	' '--$`\! *@ \a\b\e\E\f\r\t\v\\\"'\'' 
	'; echo x)" = '--$`\! *@ \a\b\e\E\f\r\t\v\\\"'\'' 
	'x
		do_test "$(path_common /foo/bar //foo//bar//baz; echo x)" = /foo/barx
		do_test "$(path_common foo foo; echo x)" = foox
		do_test "$(path_common /fo /foo; echo x)" = /x      	## Changed from x
		do_test "$(path_common "/fo d/fo" "/fo d/foo"; echo x)" = "/fo dx"


		do_test "$(path_relative "/fff/fo s/fo" "/fff/fo d/foo")" = "../../fo s/fo"
		do_test "$(path_relative "/fo d/fo" "/fo d/foo")" = "../fo"


		if [ $failed -ne 0 ]; then 
			sError_Exit 1 "$failed tests failed"
		fi


		sNormalExit 0
	fi
fi

