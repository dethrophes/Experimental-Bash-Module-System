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
#I              File Name            : TesterFuncs.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : TesterFuncs.sh
#I  File Location        : Experimental-Bash-Module-System/bash
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
#SourceCoreFiles_ "DiskFuncs.sh"
#SourceFiles_ "${ScriptDir}/DiskFuncs.sh"

if [ -z "${__TesterFuncs_sh__:-}" ]; then
	__TesterFuncs_sh__=1

	

	#########################################################################
	# Procedures
	#########################################################################
	function AddTestCase {
		push_element ${1} "$(EncodeArgs "${@:2}")"
	}
	declare -ga MTestCases
	function AddTestCase2 {
		push_element MTestCases "$(EncodeArgs "${@:2}")"
	}
	function escapeCtrlCharsString2 {
		local LC_CTYPE=C
		local -i idx=${#1}
		local nString= tval
		for (( idx=0; $idx<${#1}; idx++ )) ; do 
			case "${1:${idx}:1}" in
				$'"')				nString+='"\""';;
				$'\\')				nString+='\\';;
				#$';')					nString+='\;';;
				#$' ')					nString+='\ ';;
				[^[:cntrl:]])	nString+="${1:${idx}:1}";;
				$'\e')				nString+='\e';;
				$'\a')				nString+='\a';;
				$'\n')				nString+='\n';;
				$'\b')				nString+='\b';;
				$'\v')				nString+='\v';;
				$'\t')				nString+='\t';;
				$'\r')				nString+='\r';;
				*)	
					printf -v tval   '\\x%02x' "'${1:${idx}:1}"
					nString+="${tval}"
					;;
			esac
		done
		echo -n \$\'"${nString}"\'
	}



	function test_FuncType_return_only {
		local _FUNCNAME="${1}"
		local -i _FUNCDEPTH=2
		local _RETURN
		function FWrapper {
      _RETURN=""
			"${_FUNCNAME}" "${@}"
			return $?
		}
		test_FuncType_RETURN FWrapper "${@:2}"
	}
 	function test_FuncType_echo {
		local _FUNCNAME="${1}"
		local -i _FUNCDEPTH=2
		local _RETURN
		function FWrapper {
			_RETURN="$("${_FUNCNAME}" "${@}" )"
			return $?
		}
		test_FuncType_RETURN FWrapper "${@:2}"
	}
 	function test_FuncType_RETURN {
		local _FUNCNAME="${_FUNCNAME:-${1}}"
		local -i _FUNCDEPTH="${_FUNCDEPTH:-1}"

		local -r FuncName="${1}"
		local -i ECnt
		local -a CTest
		local -i ErrorCnt=0
		local -i TestCnt=$#
		local -a _RETURN

		while shift && [ $# -gt 0 ]; do
			local Error=0
			DecodedArgs CTest "${1}"
			#echo "${CTest[@]}"
			local -i ExpectedRValue="${CTest[0]}"
			local -a FuncArgs=("${CTest[@]:2:${CTest[1]}}")
			local -a Expected_RETURN=("${CTest[@]:2+${CTest[1]}}")
			echo -n "$(CmdOut ${_FUNCDEPTH} "${_FUNCNAME}" "${FuncArgs[@]}" 6>&1)"
			local RValue=0
			time "${FuncName}" "${FuncArgs[@]}" || RValue=$?
			if [[ -n "${CTest[0]}" && ${ExpectedRValue} -ne ${RValue} ]]; then
				ErrorOut ${_FUNCDEPTH} "$(CreateEscapedArgList3 "${_FUNCNAME}" "${FuncArgs[@]}")" \
							"		Error Wrong Return Value" \
							"		[ ${ExpectedRValue} -ne ${RValue} ]"
				Error+=1
			fi
			ECnt=0
			for CTArg in "${Expected_RETURN[@]}"; do
				if [[ "${CTArg}" != "${_RETURN[${ECnt}]:-}" ]]; then
					ErrorOut ${_FUNCDEPTH} "$(CreateEscapedArgList3 "${_FUNCNAME}" "${FuncArgs[@]}")" \
							"		Error Wrong Return Value _RETURN[${ECnt}]" \
							"		[ $(CreateEscapedArgList3 "${CTArg}") != $(CreateEscapedArgList3 "${_RETURN[${ECnt}]:-}") ]" 
					Error+=1
				fi
				ECnt+=1
			done
			if [[ ${#Expected_RETURN[@]} -lt ${#_RETURN[@]} ]]; then
				ErrorOut ${_FUNCDEPTH} "$(CreateEscapedArgList3 "${_FUNCNAME}" "${FuncArgs[@]}")" \
						"		Too many return elements Got ${#_RETURN[@]} expected ${ECnt}"
				Error+=1
			fi

			[[ ${Error} -eq 0 ]] || ErrorCnt+=1
			shift
		done
		DebugOut ${_FUNCDEPTH} "${_FUNCNAME} Test Cases=${TestCnt}  Fail=${ErrorCnt}"
		return ${ErrorCnt}
	}
  function time_test_func {
    local TIMEFORMAT=$'%3lR' 
    local IterrationCnt=1000

    printf " # %-4d x { %-60s } took " "${IterrationCnt}" "$(CreateDQuotedArgListMinimal "${@}")"
    (time for (( i=0 ; i <${IterrationCnt}; i++ )); do  "${@}" >/dev/null || true ; done  )  
  }

	#########################################################################
	# Module Argument Handling
	#########################################################################
	function Set_TesterFuncs_Flags {
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

	TesterFuncsRevision=$(CleanRevision '$Revision: 64 $')
	TesterFuncsDescription=''
	push_element	ScriptsLoaded "TesterFuncs.sh;${TesterFuncsRevision};${TesterFuncsDescription}"
fi
if [ -n "${__GenFuncs_sh_Loaded_-}" -a "${SBaseName2}" = "TesterFuncs.sh" ]; then 
  ScriptRevision="${TesterFuncsRevision}"

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
  push_element ModulesArgHandlers "Set_TesterFuncs_Flags" "Set_TesterFuncs_exec_Flags"
  #push_element SupportedCLIOptions 
  function Set_TesterFuncs_exec_Flags {
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

