#!/bin/bash 
#set -o errexit 
#set -o functrace 
set -o errtrace 
set -o nounset 
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
#I Description: Auto Created for SOURCES
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : GenFuncs.sh
#I  File Location        : Experimental-Bash-Module-System/bash
#I
#+=========================================================================
#</KHeader>
if [ -z "${__GenFuncs_sh__:-}" ]; then
	__GenFuncs_sh__=1

	export IFS=$' \t\n'
	function TestReadPath {
		if [ -z "${!1:-}" ]; then
			#echo "$(gettext "Empty Path Variable") \"${1:-}\""
			return 1
		elif [ ! -d "${!1}" ]; then
			echo "$(gettext "Folder Doesn't exist") \"${1}\"=\"${!1}\""
			return 1
		elif [ ! -r "${!1}" ]; then
			echo "$(gettext "No read access to Folder") \"${1}\"=\"${!1}\""
			return 1
		fi
		#echo "	${1}=\"${!1}\""
		return 0
	}
	function TestWritePath {
		TestReadPath "${1}" || return $?
		if [ ! -w "${!1}" ]; then
			echo "$(gettext "No write access to Folder") \"${1}\"=\"${!1}\""
			return 1
		fi
		#echo "	${1}=\"${!1}\""
		return 0
	}
	function SetVariable {
		local TestFunc="${1}"
		local VarName="${2}"
		shift 2
		"${TestFunc}" "${VarName}" && return 0

		while [ $# -gt 0 ]; do
			eval ${VarName}=\"\${1}\"
			if "${TestFunc}" "${VarName}" ; then
				#echo "$(gettext "Using") ${VarName}=\"${!VarName}\""
				export "${VarName}"
				return 0
			else
				echo "$(gettext "Ignoring invalid value for") ${VarName}=\"${!VarName}\""
			fi
			shift
		done
		unset "${VarName}"
		echo "$(gettext "Error can't set variable") ${VarName}" >&2 
		exit 19
	}
	function CleanDir {
		[ -d "${1}" ] && echo "$(cd "${1}";		pwd)"
	}
	

	SetVariable TestWritePath "HOME"			"$(getent passwd $(whoami) | awk 'BEGIN { FS = ":" } ; {print $6}')"
	SetVariable TestReadPath	"ScriptDir"	"$(CleanDir "$(dirname "${0}")"		  )"													
	SetVariable TestReadPath	"PythonDir"	"$(CleanDir "${ScriptDir[0]:-}/../python")"	"$(CleanDir "${ScriptDir[1]:-}/../python")"		
	SetVariable TestReadPath	"PerlDir"		"$(CleanDir "${ScriptDir[0]:-}/../perl"  )"	"$(CleanDir "${ScriptDir[1]:-}/../python")"		
	SetVariable TestWritePath "LogDir"		"$(CleanDir "${ScriptDir[0]:-}/../Logs"  )"  "$(CleanDir "${HOME}/scripts/Logs"  )" 								
	[ -z "${TERM:-}" ]					&& export TERM=xterm																										
	[ -z "${BATCHMODE:-}" ]			&& export BATCHMODE=0																									

	[ -z "${CTTY:-}" ]					&& CTTY="$(tty)"
	SetVariable TestWritePath 	"TMP" "$(CleanDir /tmp)"
	[ -z "${TmpFile:-}" ]				&& TmpFile[0]="$(mktemp)"
	[ -z "${TIMEFORMAT:-}" ]		&& TIMEFORMAT=$'%3lR'


	export TEXTDOMAINDIR="${ScriptDir}/locale"
	export TEXTDOMAIN=script

	SBaseName2="$(basename "${0}")"
	SBaseName="$(basename "${SBaseName2}" .sh)"

	declare -ga ModulesArgHandlers
	declare -ga SupportedCLIOptions
	declare -ga ScriptsLoaded
	declare -ga ArgFiles

	declare -ga RequiredDebianPackages
	declare -ga RequiredRpmPackages
	declare -ga RequiredGentooPackages
	declare -ga RequiredSolarisPackages
	declare -ga RequiredFreeBsdPackages
	declare -ga RequiredSusePackages

	declare -ga CleanupFunctions

	function ReturnString {
		echo "${@}"
	}
	function CleanRevision {
		ReturnString "${1}" | awk '{print $2}'
	}
 	function CleanRevision_new {
		local -a RVer=(${2})
		set_variable "${1}" "${RVer[1]}"
		readonly "${1}"
		#printf -v "${1}" "%s" "${RVer[1]}"
	}
 	function Error_Exit {
		# Function Gets overriden later in LogFuncs.sh
		local CLine
		for CLine in "${@:3}"; do 
			echo "${CLine}" >&2
		done
		exit ${2}
	}
 	function SourceFiles_ {
		local CSourceFile
		local SIFS="${IFS}"
		local FileInclusionProtection
		for CSourceFile in "${@}"; do
			FileInclusionProtection="__$(basename "${CSourceFile}" .sh)_sh__"
			if [ -z "${!FileInclusionProtection:-}" ]; then
				if [ -f "${CSourceFile}"	]; then
					if [ -r "${CSourceFile}"	]; then
						source "${CSourceFile}"
						#time source "${CSourceFile}"
						#printf "$(gettext "Sourcing %-50s ")\n" "${CSourceFile}"  
						if [ "${SIFS}" != "${IFS}"	]; then
							Error_Exit 1 7 "$(gettext "Sourced file modified IFS")" "${CSourceFile}"
						fi
					else
						Error_Exit 1 7 "$(gettext "Source file not readable")" "${CSourceFile}"
					fi
				else
					Error_Exit 1 7 "$(gettext "Can't find Source file")" "${CSourceFile}"
				fi
			fi
		done
	}
 	function SourceCoreFiles_ {
		local CSPath
		local Found=0
		while [ $# -gt 0 ]; do
			for CSPAth in "${ScriptDir[@]}"; do 
				if [ -f "${CSPAth}/${1}" ]; then 
					SourceFiles_ "${CSPAth}/${1}"
					Found=1
					break
				fi
			done
			if [ "${Found}" = "0" ]; then
				Error_Exit 1 7 "$(gettext "Can't find Core Source file")" "${1}"
			fi
			Found=0
			shift
		done
	}

	SourceCoreFiles_  "ArrayFuncs.sh"  "ConsoleFuncs.sh" "LogFuncs.sh"    

	HumanReadable=0


	function have {
		PATH="${PATH}:/sbin:/usr/sbin:/usr/local/sbin" type "${1}" &>/dev/null
	}

	#push_element RequiredDebianPackages	
	push_element RequiredRpmPackages			beesu
	#push_element RequiredGentooPackages		
	#push_element RequiredSolarisPackages	
	#push_element RequiredFreeBsdPackages
	#push_element RequiredSusePackages	

	for CProg in gksudo beesu kdesudo ktsuss gksu kdesu ; do
		if have "${CProg}"  ; then
			GSUDO="${CProg}"
			break
		fi
	done

  function GetSudo {
		if [ ${ConsoleInterface} -eq 1 ]; then
			echo "sudo"
		else
			[ -z " ${GSUDO:-}" ] && sError_Exit 8 "$(gettext "No su gui present")"
			echo "${GSUDO}"
		fi
	}

	DIFS="${Space}${Tab}${NewLine}"
	CsvIFS=";${NewLine}"
	function JoinArrayToCsv {
		IFS="${CsvIFS}" eval ${1}'=${*:2}'
	}
	function SplitCsvToArray {
		IFS="${CsvIFS}" eval ${1}=\(\${2}\)
	}
	Spacer=$'\v'
	function EncodeArgs {
		IFS=${Spacer} eval 'echo "${*}"'
	}
	function DecodedArgs {
		#printf "%q\n" "${2}"  
		IFS="${Spacer}" eval "${1}"'=( .${2}. )'
		#IFS="${Spacer}" read -ra "${1}" <<< ".${2}."
		#eval echo '"${'"${1}"'[@]}"'
		eval ${1}'[0]="${'${1}'[0]:1}"'
		eval ${1}'[${#'${1}'[@]}-1]="${'${1}'[${#'${1}'[@]}-1]]%.}"'
	}

	function ReturnStringPart {
		echo -n "${@}"
	}
	function send {
		info="$( eval ${@} 2>&1 )"
		notify_msg "${*}" "${info}" || return $?
	}

	SourceCoreFiles_ "ExecFuncs.sh"

	function InterfaceType {
		if [ ${ConsoleInterface} -eq 1 ]; then
			ReturnString --console || return $?
		else
			ReturnString --gui || return $?
		fi
	}
	function ReturnEcho {
		local -i val="${1}" || exit $?
		ReturnString "${val}"
		return ${val}
	}
	#########################################################################
	# PROCEDURES
	#########################################################################
	function PrintArray {
		#IFS=$'\n' eval echo '"${*}"'
		printf "%s\n" "${*}"
	}

	function float_eval {
    local stat=0
    local result=0.0
    if [[ $# -gt 0 ]]; then
        result=$(echo "scale=${1}; ${*:2}" | bc -q 2>/dev/null)
        stat=$?
        if [[ $stat -eq 0  &&  -z "$result" ]]; then stat=1; fi
    fi
    echo $result
    return $stat
	}

	SourceCoreFiles_ "PromptFuncs.sh" "ProgressFuncs.sh" "FilterFuncs.sh" "CoreFuncs.sh"





	function GrabELevel {
		if [ ${!1} -lt ${2} ]; then 
			eval ${1}'="${2}"'
		fi
	}

	function ReadCfgFile {
		grep -vP "^\s*#.*" "${1}"
	}
  function LoadCfgFile {
		if [ -f "${2}" ]; then
			IFS="$NewLine" eval ${1}'=( $(ReadCfgFile "${2}") )'
		fi
	}

	function GetFileAccessTime {
		[ -f "${1}" ] && stat -c%X "${1}"
	}
	function GetFileChangeTime {
		[ -f "${1}" ] && stat -c%Z "${1}"
	}
	function GetFileModTime {
		[ -f "${1}" ] && stat -c%Y "${1}"
	}
	function GetFileSize {
		[ -f "${1}" ] && stat -c%s "${1}"
	}

	function GetLineCnt {
		wc -l "${1}" | awk '{ print $1 }'
	}
	function nop {
		# Dummy command
	  echo -n ""
	}

	function GetFileTextType {   
		local FileType
		if [ -d "${1}" ]; then
			FileType="$(gettext "Directory")"
		elif [ -f "${1}" ]; then
			FileType="$(gettext "File")"
		elif [ -h "${1}" ]; then
			FileType="$(gettext "Link")"
		elif [ -S "${1}" ]; then
			FileType="$(gettext "socket")"
		elif [ -p "${1}" ]; then
			FileType="$(gettext "Pipe")"
		elif [ -b "${1}" ]; then
			FileType="$(gettext "Block Device")"
		elif [ -c "${1}" ]; then
			FileType="$(gettext "Character Device")"
		elif [ -e "${1}" ]; then
			FileType="$(gettext "Unsupported file type")"
		else
			FileType="$(gettext "SrcFile Doesn't exist")"
		fi
		ReturnString "${FileType}"
	}

	SourceCoreFiles_ "LockFuncs.sh" "TempFuncs.sh" "PathFuncs.sh" "PkgFuncs.sh"
	SourceCoreFiles_ "TestFuncs.sh" "SizeFuncs.sh"

	#########################################################################
	# Error_Exit
	#########################################################################

	#push_element RequiredDebianPackages	moreutils
	#push_element RequiredRpmPackages     moreutils
	#push_element RequiredGentooPackages  moreutils
	#push_element RequiredSolarisPackages moreutils
	#push_element RequiredFreeBsdPackages moreutils
	#push_element RequiredSusePackages    moreutils



	function UsageCommon {
		for LCargHandler in "${ModulesArgHandlers[@]}"; do
			"${LCargHandler}" --Usage || true
		done
	}

	function SetGenFuncsFlags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			case "${1}" in
				'-h'|'/h'|'/?'|'-?'|'--help')
					Usage
					exit 0
					;;
				--Usage)
					if [ $PCnt -eq 0 ]; then
						ConsoleStdout "I    -h --help                                                                   "
						ConsoleStdout "I             $(gettext "Display This message")                                  "
						ConsoleStdout "I       --version                                                                "
						ConsoleStdout "I             $(gettext "Display current scripts version")                       "
						ConsoleStdout "I       --SupportedOptions                                                       "
						ConsoleStdout "I             $(gettext "List supported command line arguments")                 "
						ConsoleStdout "I    -y	--Yes                                                                   "
						ConsoleStdout "I             $(gettext "Answer not to questions")                               "
						ConsoleStdout "I    -n	--No                                                                    "
						ConsoleStdout "I             $(gettext "Answer yes to questions")                               "
						ConsoleStdout "I      	--console                                                               "
						ConsoleStdout "I             $(gettext "Use Console User Interface")                            "
						ConsoleStdout "I      	--gui                                                                   "
						ConsoleStdout "I             $(gettext "Use Gui User Interface")                                "
						ConsoleStdout "I      	--InstallDependencies                                                   "
						ConsoleStdout "I             $(gettext "Install scripts dependencies")                          "
						ConsoleStdout "I      	--LogFile <FileName>                                                    "
						ConsoleStdout "I             $(gettext "Specify Log File")                                      "
					fi
					break
					;;
				--version)
					ConsoleStdout ${ScriptRevision}
					exit 0
					;;
				--SupportedOptions)
					[ $PCnt -eq 0 ] && ConsoleStdoutN "${SupportedCLIOptions[*]}"
					break
					;;
				-n|-N)
					BatchMode=2
					;;
				-y|-Y)
					BatchMode=1
					;;
				--HumanReadable)
					HumanReadable=1
					;;
				--console)
					ConsoleInterface=1
					;;
				--gui)
					ConsoleInterface=0
					;;
				'--InstallDependencies')
					InstallDependencies
					;;
				'--LogFile')
					sTestEnoughArgs $# 1 "${1} $(gettext "Requires Arg ")"
					shift && let PCnt+=1
					SetLogFileName "${1}"
					;;
				'--Version')
					local CScript 
					local -a CElements
					for CScript in "${ScriptsLoaded[@]}" ; do
						SplitCsvToArray CElements "${CScript}"
						printf "%s(%s)\n" "${CElements[@]}"
					done
					exit 0
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
	push_element ModulesArgHandlers  SetGenFuncsFlags 
	function CommonOptionArg {
		local ArrayName="${1}"
		local -i ElCnt
		shift
		eval ${ArrayName}'=()'
		while [ $# -gt 0 ] ; do
			ElCnt=$#
			for LCargHandler in "${ModulesArgHandlers[@]}"; do
				"${LCargHandler}" "${@}" || { shift $? ; break ; }
			done
			[ ${ElCnt} -ne $# ] && continue
			case "${1}" in
				--SupportedOptions|--Usage)
					ConsoleStdout
					exit 0
					;;
				*)
					push_element "${ArrayName}" "${1}"
					;;
			esac
			shift
		done
	}
	function ListFunctionsAsArgs {
		cat "${1}" | awk '/^[[:space:]]+function/ {printf "--%s ", $2}'
	}
	BatchMode=0
	push_element SupportedCLIOptions "-h" "--help" "-y" "-n" "--No" "--Yes" "--gui" "--console" "--LogFile" "--InstallDependencies" "--version" "--HumanReadable"

	function MainOptionArg {
		local ArrayName="${1}"
		local -i ElCnt
		shift
		[ -n "${ArrayName}" ] && eval ${ArrayName}=\(\)
		while [ $# -gt 0 ] ; do
			ElCnt=$#
			for LCargHandler in "${ModulesArgHandlers[@]}"; do
				#echo "${LCargHandler}" "${@}"
				"${LCargHandler}" "${@}" || { shift $? ; break ; }
			done
			[ ${ElCnt} -ne $# ] && continue
			case "${1}" in
				--SupportedOptions|--Usage)
					ConsoleStdout
					exit 0
					;;
				*)
					if [ -n "${ArrayName}" ]; then
						push_element "${ArrayName}" "${1}"
					else
						sError_Exit 4 "$(gettext "Unsupported option") \"${1}\" "
					fi
					;;
			esac
			shift
		done
	}
	function SupportCallingFileFuncs {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			case "${1}" in
				--Usage)
					if [ $PCnt -eq 0 ]; then
						for CFuncName in $(ListFunctionsAsArgs "${0}"); do 
							printf "I     %-2s %-20s  %s\n" "" "${CFuncName}"  "<Funtion Args>"
							printf "I     %-2s %-10s  %s\n" "" ""  "$(declare -F "${CFuncName:2}" )"
						done
					fi
					break
					;;
				--SupportedOptions)
					[ ${PCnt} -eq 0 ] && ConsoleStdoutN "$(ListFunctionsAsArgs "${0}")"
					break
					;;
				--*)                                               
						FuncName="${1:2}"                               
						if [ "$(type -t "${FuncName}")" = "function" ]; then        
							"${FuncName}" "${@:2}"                        
							exit                                       
						else                                        
							break
						fi                                         
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



	readonly __GenFuncs_sh_Loaded_=1

	#readonly GenFuncsRevision=$(CleanRevision '$Revision: 64 $')
	CleanRevision_new GenFuncsRevision '$Revision: 64 $'
	readonly GenFuncsDescription="$(gettext "Please Enter a program description here") "
	push_element	ScriptsLoaded "GenFuncs.sh;${GenFuncsRevision};${GenFuncsDescription}"
	if [ "${SBaseName2}" = "GenFuncs.sh" ]; then 
		readonly ScriptRevision="${GenFuncsRevision}"


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
		push_element ModulesArgHandlers SupportCallingFileFuncs SetGenFuncsTestFlags 
		push_element SupportedCLIOptions --MakeSizeHumanReadable --GetSizeRecursive 
		function SetGenFuncsTestFlags {
			local -i PCnt=0
			while [ $# -gt 0 ] ; do
				case "${1}" in
					--Usage)
						if [ $PCnt -eq 0 ]; then
							ConsoleStdout "I    --MakeSizeHumanReadable                                                     "
							ConsoleStdout "I    --GetSizeRecursive																													"
							#ConsoleStdout "I             $(gettext "Display This message")                                  "
						fi
						break
						;;
					--SupportedOptions)
						[ ${PCnt} -eq 0 ] && ConsoleStdoutN ""
						break
						;;
          --MakeSizeHumanReadable) 
              sTestEnoughArgs $# 1 "${1} $(gettext "Requires Arg ")"  
              shift               
              MakeSizeHumanReadable "${1}"                           
              exit 0                                                
              ;;                                                   
            --GetSizeRecursive)                                          
              sTestEnoughArgs $# 1 "${1} $(gettext "Requires Arg ")"
              shift                                                
              PrintSize "$(GetSizeRecursive "${1}")"              
              exit 0                                             
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

		MainOptionArg		"" "${@}"


		#########################################################################
		# MAIN PROGRAM
		#########################################################################
		ConsoleStdout "###############################################"
		ConsoleStdout "# ${SBaseName2} $(gettext "Test Module")"
		ConsoleStdout "###############################################"


		send wc --help

		sNormalExit 0
	fi
fi
