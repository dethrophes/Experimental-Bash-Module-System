#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               JK Script Tools
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/template.sh $
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
#I Description: Auto Created for SOURCES
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : template.sh
#I  File Location        : scripts/bash
#I  Last committed       : $Revision: 54 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-26 11:36:27 +0100 (Sun, 26 Feb 2012) $
#I  ID                   : $Id: template.sh 54 2012-02-26 10:36:27Z dethrophes $
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
		ScriptDir[1]="$(dirname "$(which "GenFuncs.sh")")"
		source "$(which "GenFuncs.sh")" || exit
	else
		echo "# "
		echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
		echo "# "
		exit 7
	fi
fi

if [ -z "${__<+FILE NAME ROOT+>_<+FILE SUFFIX+>__:-}" ]; then
	__<+FILE NAME ROOT+>_<+FILE SUFFIX+>__=1

	#SourceCoreFiles_ "DiskFuncs.sh"
	#SourceFiles_ "${ScriptDir}/DiskFuncs.sh"

	#########################################################################
	# Module Shared Procedures
	#########################################################################




	#########################################################################
	# Procedures
	#########################################################################

	#########################################################################
	# Module Argument Handling
	#########################################################################
	#function Set_template_Flags {
	#  local -i PCnt=0
	#  while [ $# -gt 0 ] ; do
	#    case "${1}" in
	#      --Usage)
	#        if [ $PCnt -eq 0 ]; then
	#          ConsoleStdoutN ""
	#          #ConsoleStdout "I    -h --help                                                                   "
	#          #ConsoleStdout "I             $(gettext "Display This message")                                  "
	#        fi
	#        break
	#        ;;
	#      --SupportedOptions)
	#        [ ${PCnt} -eq 0 ] && ConsoleStdoutN ""
	#        break
	#        ;;
	#      *)
	#        break
	#        ;;
	#    esac
	#    let PCnt+=1
	#    shift
	#  done
	#  return ${PCnt}
	#}

	#########################################################################
	# Required Packages
	#########################################################################
	#push_element RequiredDebianPackages	<Package Name> ...
	#push_element RequiredRpmPackages			<Package Name> ...
	#push_element RequiredGentooPackages	<Package Name> ...
	#push_element RequiredSolarisPackages	<Package Name> ...
	#push_element RequiredFreeBsdPackages	<Package Name> ...
	#push_element RequiredSusePackages		<Package Name> ...

	declare -gr templateRevision=$(CleanRevision '$Revision: 54 $')
	declare -gr templateDescription="$(gettext "Please Enter a program description here") "
	push_element	ScriptsLoaded "template.sh;${templateRevision};${templateDescription}"
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
	#push_element ModulesArgHandlers SupportCallingFileFuncs Set_template_Flags Set_template_exec_Flags
	push_element ModulesArgHandlers SupportCallingFileFuncs Set_template_exec_Flags
	#push_element SupportedCLIOptions 
	function Set_template_exec_Flags {
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
	SourceCoreFiles_ "TesterFuncs.sh"
	#declare -i ECnt=0
	#test_FuncType_echo		testFunction \
	#											"$(EncodeArgs <Expected Return Value>  <Arg Cnt>  [arg1 [arg2 [arg3 [...]]]] <Echo Value>)" \
  # 										"$(EncodeArgs <Expected Return Value>  <Arg Cnt>  [arg1 [arg2 [arg3 [...]]]] <Echo Value>)" \
	#											|| ECnt+=${?}
	#test_FuncType_RETURN testFunction \
	#											"$(EncodeArgs <Expected Return Value>  <Arg Cnt>  [arg1 [arg2 [arg3 [...]]]] <rval1 [rval2 [rval3 [...]]]>)"  \
  # 										"$(EncodeArgs <Expected Return Value>  <Arg Cnt>  [arg1 [arg2 [arg3 [...]]]] <rval1 [rval2 [rval3 [...]]]>))" \
	#											|| ECnt+=${?}
	#
	#if [[ ${ECnt} -gt 0 ]]; then
	#  sError_Exit 5 "${ECnt} $(gettext "Tests failed")"
	#else
	#  sDebugOut "$(gettext "All tests passed")"
	#  sNormalExit 0
	#fi

	sNormalExit 0
fi

