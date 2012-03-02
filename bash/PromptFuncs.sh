#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/PromptFuncs.sh $
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
#I Description: 
#I
#+------------------------------------------------------------------------=
#I
#I  File Name            : PromptFuncs.sh
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: PromptFuncs.sh 53 2012-02-17 13:29:00Z dethrophes $
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
#SourceCoreFiles_ "oc.sh" 

if [ -z "${__PromptFuncs_sh__:-}" ]; then
	__PromptFuncs_sh__=1

	function ReceiveCmd {
		local Reply=""
		while IFS= read -srN1 -t 1 ; do 
			 [ "${REPLY}" != "${1}" ] || break
			 Reply+="${REPLY}" 
		done
		REPLY="${Reply}" 
	}
	function ReceiveCmd2 {
		local Reply=""
		while IFS= read -srN1 -t 1 ; do 
			 Reply+="${REPLY}" 
			 ! [[ "${Reply}" =~ "${1}$" ]] || break
		done
		REPLY="${Reply%${1}}" 
	}
	function GetCurPos {
		echo -n "${CSI}6n" ; ReceiveCmd R
		IFS=';' eval 'REPLY=( ${REPLY:2} )'
	}

	SourceCoreFiles_ StrFuncs.sh
	SourceCoreFiles_ ReadKeyFuncs.sh




	function cls {
			printf "${CLS:=`clear`}"
	}

	function printatw	{
			[ $# -lt 4 ] && return 1
			printf "${CSI}%d;%dH%.*b" "${1//[!0-9]}" "${2//[!0-9]}" "${3//[!0-9]}" "${*:4}"
	}
	function printat	{
			[ $# -lt 2 ] && return 1
			printf "${CSI}%d;%dH%b" "${1//[!0-9]}" "${2//[!0-9]}" "${*:3}"
	}



	function AdjustMousePos {
		local -i _INDEX
		ord_eascii _INDEX "${2}"
		eval ${1}'=$(( ${_INDEX}-32))'
	}

	function printCtrlCharsString_echo {
		local LC_CTYPE=C
		local -i idx=${#1}
		echo -n "$'"
		for (( idx=0; $idx<${#1}; idx++ )) ; do 
			printf '\\x%02x' "'${1:${idx}:1}"
		done
		echo -n "'"
	}
	function escapeCtrlCharsString_echo {
	  function TakeBigger {
			if [ ${!1} -lt ${2} ]; then
				eval ${1}'="${2}"'
			fi
		}
		local LC_CTYPE=C
		local LC_COLLATE=C
		local -i idx=${#1} Quote=0
		local nString= val=
		for (( idx=0; $idx<${#1}; idx++ )) ; do 
			case "${1:${idx}:1}" in
				[]\ \!\"\#\$\&\'\(\)\*\;\<\>\?\[\\\^\`\{\|\}])			nString+="${1:${idx}:1}"; TakeBigger Quote 1;;
				[$'\x20'-$'\x7e'])	nString+="${1:${idx}:1}";;
				$'\e')				nString+='\e'; TakeBigger Quote 2;;
				$'\a')				nString+='\a'; TakeBigger Quote 2;;
				$'\n')				nString+='\n'; TakeBigger Quote 2;;
				$'\b')				nString+='\b'; TakeBigger Quote 2;;
				$'\v')				nString+='\v'; TakeBigger Quote 2;;
				$'\t')				nString+='\t'; TakeBigger Quote 2;;
				$'\r')				nString+='\r'; TakeBigger Quote 2;;
				*)						
					printf -v val '\\x%02x' "'${1:${idx}:1}"
					nString+="${val}"
					TakeBigger Quote 2
					;;
			esac
		done
		case ${Quote} in
			0) echo -n "${nString}";;
			1) 
				for CChar in \] \  \! \" \# \$ \& \' \( \) \* \; \< \> \? \[ \\ \^ \` \{ \| \} ;do
					nString="${nString//${CChar}/\\${CChar}}"
				done
				echo -n "$'${nString}'"
				;;
			2) DoubleQuote "${nString}";;
			3) SingleQuote "${nString}";;
			3) echo -n "$'${nString}'";;
		esac
		
	}





	function GetElementIndex {
		OptIndx=0
		local TestStr="${1}"
		local TestType="${2}"
		shift
		while shift && [ $# -gt 0 ]; do
			eval '! [[ ${TestStr} '"${TestType}"' ${1} ]] || break'
			let OptIndx+=1
		done
		return ${OptIndx} 
	}
  # PromptYN_gui <Default Value> <Prompt> <Description> <KeySeq>
	function PromptGeneric {
			local -a UInput
			local -i OptIndx_d=${1:-0}
			local -i OptIndx=${OptIndx_d}
			[ -z "${3}" ] || ConsoleStdout "${3}"
			ConsoleStdoutN "${2}" ;
			shift 3
			while true ; do
				if ReadKey ; then
					case "${UInput[0]:-}" in
						LF) # Just use the default
							ConsoleStdout ""
							if [ ${OptIndx} -lt $# ]; then
								return ${OptIndx_d} 
							else
								return $#
							fi
							;;
						*)
							GetElementIndex "${UInput[0]:-}" "=~" "${@}" 
							if [ ${OptIndx} -lt $# ]; then
								ConsoleStdout "${UInput[0]:-}"
								return ${OptIndx} 
							fi
						;;
				esac
				fi
			done
			ConsoleStdout ""
			return $#
	}

	function select2 {
		function PrintSelectPrompt {
			if [ "${1}" = "0" ]; then
				printat ${XPosM} 1 "${NO_COLOUR}                      "$'\r'"> "
			else
				printat ${XPosM} 1 "${NO_COLOUR}                      "$'\r'"> ${1}" 
			fi
		}
		function PrintLine {
			if [ 0 -ne ${1} ]; then
				printat $((${1}+${XPosL})) 1 "${1}) ${2}${3:0:$((${COLUMNS}-3))}"
			fi
		}
		local RVarName="${1}" && shift
		local -i CCnt=1 RVal=0 PVal=${!RVarName}+1
		local -i XPosM XPosL
		local REPLY
		local CArg
		for CArg in "${@}"; do
			printf "%.*s\n" ${COLUMNS:=$(tput cols)} "${CCnt}) ${CArg}"
			CCnt+=1
		done  >&2 
		GetCurPos 
		XPosL="${REPLY[0]}-${CCnt}"
		XPosM="${REPLY[0]}"

		local -a UInput
		trap 'echo -n "${mouse_off}" ; exit' EXIT SIGINT
		local mouse_on="$(vt100_DECSET ${mouse_type[4]})" 
		while true; do
			if [ ${PVal} -ne ${RVal} ]; then
				if [ ${PVal} -ge 0 -a ${PVal} -lt ${CCnt}  ]; then
					PrintLine "${RVal}" "${NO_COLOUR}"		  "${@:${RVal}:1}"
					PrintLine "${PVal}" "${ATTRIB_Inverse}" "${@:${PVal}:1}"
					echo -en "${NO_COLOUR}"
					RVal=${PVal}
				fi
			fi
			PrintSelectPrompt  ${RVal}
			if ReadKey  ; then
				case "${UInput[0]:-}" in
					*up) PVal=${RVal}-1;;
					*down) PVal=${RVal}+1;;
					DEL) PVal=${RVal}/10 ;;
					[0-9]) PVal=${RVal}*10+${UInput[0]} ;;
					*Mouse-M)
						PVal=${UInput[2]}-${XPosL}
						;;
					*MB1-P)
						if [ ${XPosM} -gt ${UInput[2]} -a ${XPosL} -lt ${UInput[2]} ]; then
							RVal=${UInput[2]}-${XPosL}
							PrintSelectPrompt  ${RVal}
						  break
						fi
						;;
					LF) break ;;
					ESC|q|Q) RVal=0 ; break ;;
				esac
			fi
		done    >&2 
		echo "" >&2
		echo -n "${mouse_off}"
		[ ${RVal} -eq 0 ] && RVal=${CCnt} || RVal+=-1
		eval ${RVarName}'=${RVal:-}'
	}

	function select3 {
		function PrintSelectPrompt {
			local Selected
			JoinArrayToCsv Selected "${Sel[@]}"
			if [ "${1}" = "0" ]; then
				printat ${XPosM} 1 "${NO_COLOUR}                      "$'\r'"> ${Selected}"
			else
				Selected=${Selected/${1};}
				Selected=${Selected/;${1}}
				[ "${Selected}" != "${1}" ] || Selected=${Selected/${1}}
				printat ${XPosM} 1 "${NO_COLOUR}                      "$'\r'"> ${Selected:+${Selected};}${1}" 
			fi
		}
		function PrintLine {
			if [ 0 -ne ${1} ]; then
				printat $((${1}+${XPosL})) 1 "[${2:- }] ${1}) ${3}${4:0:$((${COLUMNS}-3))}"
			fi
		}
		function ToggleState {
			[ "${RVal}" != "0" ] || return 0
			if [ -n "${Sel[${RVal}]:-}" ]; then
				unset Sel[${RVal}]
			else
				Sel[${RVal}]=${RVal}
			fi
		}
		local -ai Sel
		local RVarName="${1}" && shift
		local -i CCnt=1 RVal=0 PVal=1
		local -i XPosM XPosL
		local REPLY
		local CArg
		local -a Sel
		for CArg in $(echo "${!RVarName//;/ }"); do
			Sel[${CArg}+1]=${CArg}+1
		done         
		for CArg in "${@}"; do
			local scratch="${Sel[${CCnt}]:+X}"
			printf "%.*s\n" ${COLUMNS:=$(tput cols)} "[${scratch:- }] ${CCnt}) ${CArg}"
			CCnt+=1
		done  >&2 
		GetCurPos 
		XPosL="${REPLY[0]}-${CCnt}"
		XPosM="${REPLY[0]}"

		local -a UInput
		trap 'echo -n "${mouse_off}" ; exit' EXIT SIGINT TERM
		local mouse_on="$(vt100_DECSET ${mouse_type[4]})" 
		while true; do
			#if [ ${PVal} -ne ${RVal} ]; then
				if [ ${PVal} -ge 0 -a ${PVal} -lt ${CCnt}  ]; then
					PrintLine "${RVal}" "${Sel[${RVal}]:+X}" "${NO_COLOUR}"		  "${@:${RVal}:1}"
					PrintLine "${PVal}" "${Sel[${PVal}]:+X}" "${ATTRIB_Inverse}" "${@:${PVal}:1}"
					echo -en "${NO_COLOUR}"
					RVal=${PVal}
				fi
			#fi
			PrintSelectPrompt  ${RVal}
			if ReadKey  ; then
				case "${UInput[0]:-}" in
					' ') ToggleState ;;
					';') 
						ToggleState
						PVal=0
						;;
					*up) PVal=${RVal}-1;;
					*down) PVal=${RVal}+1;;
					DEL) 
						if [ "${RVal}" != "0" ]; then
							PVal=${RVal}/10 
						else
							local LSet="${Sel[*]}"
							unset Sel[${LSet##*;}]
							PrintLine "${LSet##*;}" "${Sel[${RVal}]:+X}" "${NO_COLOUR}"		  "${@:${LSet##*;}:1}"
						fi
						;;
					[0-9]) PVal=${RVal}*10+${UInput[0]} ;;
					*Mouse-M)
						PVal=${UInput[2]}-${XPosL}
						;;
					*MB1-P)
						if [ ${XPosM} -gt ${UInput[2]} -a ${XPosL} -lt ${UInput[2]} ]; then
							PVal=RVal=${UInput[2]}-${XPosL}
							ToggleState  ${RVal}
						fi
						;;
					LF) break ;;
					ESC|q|Q) RVal=0 ; break ;;
				esac
			fi
		done    >&2 
		echo "" >&2
		[ ${RVal} -eq 0 ] && RVal=${CCnt} || RVal+=-1
 		if [ ${#Sel[@]} -gt 0 ]; then
			eval ${RVarName}'=( "${Sel[@]}" )'
			return 0
		else
			eval ${RVarName}'=( )'
			return 1
		fi
	}  
	# PromptGeneric2_txt <Default Value> <Title> <Description> <Array Values>  
	function PromptGeneric2_txt {
			local OptIndx="${1}"
			echo "${2}"
			echo "${3}"
		  select2 OptIndx "${@:4}"
			return ${OptIndx}
	}
	# PromptSelectMultiple_txt <Default Value> <Title> <Description> <Array Values>  
	function PromptSelectMultiple_txt {
			OptIndx="${1}"
			echo "${2}"
			echo "${3}"
		  select3  OptIndx "${@:4}"
		[ ${#OptIndx[@]} -gt 0 ] || return
	}
	function PrintFormatText {
		local CLine
		echo "${2}" | while read -rd $'\n' CLine; do
			printf "${1:-%s}" "${CLine}"
		done
	}
  # PromptUserEdit_txt <Default Value> <Title> <Description>
	function PromptUserEdit_txt {
		local TmpFile="$(mktemp)"
		{
			echo "## All Lines Starting with # ignored"
			echo "##================================================================="
			PrintFormatText "## %s\n" "${2}"
			echo "##================================================================="
			PrintFormatText "## %s\n" "${3}"
			echo "##-----------------------------------------------------------------"
			PrintFormatText "#%s\n" "${1}"
		}  >"${TmpFile}"
		local ModTime="$(GetFileModTime "${TmpFile}")"
		eval ${EDITOR} '"${TmpFile}"  2>/dev/null '
		if [ ${ModTime} -eq $(GetFileModTime "${TmpFile}") ]; then 
			if PromptYN 1 "$(gettext "Retry ")" "$(gettext "File unmodified") \"${TmpFile}\"" >&2 <&3 ; then
				eval ${EDITOR} '"${TmpFile}"  2>/dev/null '
			fi
		fi
		grep -v '^#' "${TmpFile}"  2>/dev/null && rm -f "${TmpFile}"
	}
  # PromptSelectMultiple_gui <Default Value> <Title> <Description>
	function PromptSelectMultiple_gui {
		#sDebugOut "${@}"
		local -i WindowHeight=$((120-17+($#-3)*25+$(GetLinesInString "${3}")*17))
		local -i WindowWidth=60+$(GetLongestLineInString "${*/#/$'\n'}")*8
		SplitCsvToArray OptIndx "$(eval zenity '--width="${WindowWidth}" --height="${WindowHeight}" --list --checklist ' \
			'--multiple --separator=";" --title="${2}" --text="${3}" --hide-column=2 --column "" --column "" ' \
			'--column "$(gettext "options")" ' $(ListOptions2 "${1:-0}" "${@:4}") )"
		[ ${#OptIndx[@]} -gt 0 ] || return
	}
  # PromptUserEdit_gui <Default Value> <Title> <Description>
	function PromptUserEdit_gui {
		local -i WindowHeight=120-17+$(GetLinesInString "${1}")*25+$(GetLinesInString "${3}")*17
		local -i WindowWidth=$(GetLongestLineInString "${1}${NewLine}${2}${NewLine}${3}")*7
		eval zenity '--width="${WindowWidth}" --height="${WindowHeight}" --list ' \
			'--multiple --separator="${NewLine}" ' \
			'--title="${2}" --text="${3}" '  \
			'--editable --column "$(gettext "options")" ' $(PrintFormatText "%q " "${1}")  2>/dev/null


	}
	function ListOptions2 {
		local COpt
		local -i OptIndx=0
		for COpt in "${@:2}" ; do 
			if [[ \;${1}\; =~ \;${OptIndx}\; ]]; then
				echo -n " True "
			else
				echo -n " False "
			fi
			echo -n " ${OptIndx} "
			CreateSQuotedArgList "${COpt}"
			OptIndx+=1
		done
	}
	function PromptInfoText_gui {
		zenity --text-info --filename=<(echo "${*}")
	}
	function PromptGeneric3_gui {
		#sDebugOut "${@}"
		local -i WindowHeight=$((120-17+($#-3)*25+$(GetLinesInString "${3}")*17))
		local -i WindowWidth=60+$(GetLongestLineInString "${*/#/$'\n'}")*8
		local OptIndx="$(eval zenity '--width="${WindowWidth}" --height="${WindowHeight}" --list --radiolist' \
			'--title="${2}" --text="${3}" --hide-column=2 --column "" --column "" ' \
			'--column "$(gettext "options")"' $(ListOptions2 "${1:-0}" "${@:4}") )"
    shift 4
		return ${OptIndx:-$#}
	}


  # PromptYN_txt <Default Value> <Title> <Description>  
	function PromptYN_txt {
		local -a Options=( y n )
		PromptGeneric "${1}"  "${2} [Yes/No] [${Options[${1}]:-y}] :" "${3}" "^(y|Y)$" "^(n|N|ESC)$"  || return $?
	}
  # PromptYN_gui <Default Value> <Title> <Description>  
	function PromptYN_gui {
		zenity --question --title="${2}" "--text=${3}" || return $?
	}
  # PromptYesNoAll_txt <Default Value> <Title> <Description>  
	function PromptYesNoAll_txt {
		local -a Options=( y a s n )
		PromptGeneric "${1}"  "${2} [Yes/No/All yes/Skip all] [${Options[${1}]:-n}] :" "${3}" "^(y|Y)$" "^(a|A)$" "^(s|S)$" "^(n|N|ESC)$"   || return $?
	}
  # PromptYesNoAll_gui <Default Value> <Title> <Description>  
	function PromptYesNoAll_gui {
		PromptGeneric3_gui "${@:1:3}" "$(gettext "yes")" "$(gettext "all")" "$(gettext "none")" "$(gettext "no")"   || return $?
	}            

  # PromptYesNoAllAlt <Title> <Description Array>
	function PromptYN_Alt {
		PromptYN 0 "${@:1:2}" "$(PrintArray "${@:3}")"
	}
  # PromptYN <Default Value> <Title> <Description>
	function PromptYN {
		if [ ${ConsoleInterface} -eq 1 ];then 
			PromptYN_txt "${@}"   || return $?
		else
			PromptYN_gui "${@}"  || return $?
		fi
	}
  # PromptYesNoAllAlt <Default Value> <Title> <Description Array>
	function PromptYesNoAll_Alt {
		PromptYesNoAll "${@:1:2}" "$(PrintArray "${@:3}")"
	}
  # PromptYesNoAll <Default Value> <Title> <Description>
	function PromptYesNoAll {
		if [ "${1}" = "1" ] || [ "${1}" = "2" ]; then
			return ${1}
		fi
		if [ ${ConsoleInterface} -eq 1 ];then 
			PromptYesNoAll_txt "${@}"  || return $?
		else
			PromptYesNoAll_gui "${@}"   || return $?
		fi
	}
  # PromptSelectElement <Default Value> <Title> <Description> <Array Values>  
	function PromptSelectElement {
		if [ ${ConsoleInterface} -eq 1 ];then 
			PromptGeneric2_txt "${@}"   || return $? 
		else
			PromptGeneric3_gui "${@}"   || return $? 
		fi
	}
  # PromptSelectMultiple <Default Value> <Title> <Description> <Array Values>  
	function PromptSelectMultiple {
		local OptIndx
		REPLY=( )
		if [ ${ConsoleInterface} -eq 1 ];then 
			PromptSelectMultiple_txt "${@}"   || return $? 
		else
			PromptSelectMultiple_gui "${@}"   || return $? 
		fi
		REPLY=( "${OptIndx[@]}" )
	}
  # PromptUserEdit <Default Value> <Title> <Description>
	function PromptUserEdit {
		if [ ${ConsoleInterface} -eq 1 ];then 
			PromptUserEdit_txt "${@}"   || return $? 
		else
			PromptUserEdit_gui "${@}"   || return $? 
		fi
	}



	#########################################################################
	# Module Argument Handling
	#########################################################################
	function Set_PromptFuncs_Flags {
		local -i PCnt=0
		while [ $# -gt 0 ] ; do
			case "${1}" in
				--Usage)
					if [ $PCnt -eq 0 ]; then
						ConsoleStdout "I       --HandleKey                                                             "
						ConsoleStdout "I       --ReadKey                                                               "
						ConsoleStdout "I       --DecCnt                                                                "
					fi
					break
					;;
				--SupportedOptions)
					[ ${PCnt} -eq 0 ] && ConsoleStdoutN "--HandleKey --ReadKey --DecCnt "
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

	PromptFuncsRevision=$(CleanRevision '$Revision: 53 $')
	PromptFuncsDescription="$(gettext "Please Enter a program description here") "
	push_element	ScriptsLoaded "PromptFuncs.sh;${PromptFuncsRevision};${PromptFuncsDescription}"
fi
if [ "${__GenFuncs_sh_Loaded_:-}" = "1" -a "${SBaseName2}" = "PromptFuncs.sh" ]; then 
	ScriptRevision="${PromptFuncsRevision}"

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
	push_element ModulesArgHandlers SupportCallingFileFuncs Set_PromptFuncs_Flags 
	#push_element SupportedCLIOptions 
	MainOptionArg "" "${@}"


	#########################################################################
	# MAIN PROGRAM
	#########################################################################

	echo "###############################################"
	echo "# ${SBaseName2} $(gettext "Test Module")"
	echo "###############################################"

	TestArray=( 
		"Option 1!"
		"Option 2!"
		"Option 3!"
		"Option 4!"
		"Option 5!"
	)
	PromptYN 0 "Title" $'Text Body\n Cnt'  || echo TestArray=$? 
	PromptYesNoAll 3 "Title" $'Text Body\n Cnt'  || echo TestArray=$? 
	PromptYesNoAll_Alt 3 "Title" "Text Body" "Cnt"  || echo TestArray=$? 
	PromptSelectElement 2  "Title" $'Text Body\n Cnt' "${TestArray[@]}" || echo TestArray=$? 
	PromptUserEdit $'Test Text \n Line2'  "Title" $'Text Body\n Cnt' "${TestArray[@]}"  || echo TestArray=$?  
	PromptSelectMultiple "2;3;4"  "Title" $'Text Body\n Cnt' "${TestArray[@]}" || echo TestArray=$? 


	SourceCoreFiles_ "TesterFuncs.sh"
	test_FuncType_echo vt100_EncodeStrings_hexadecimal "$(EncodeArgs 0 3 dfdgdfg dfgdf 1234567890 "64666467646667;6466676466;31323334353637383930")"

	test_FuncType_RETURN vt100_DecodeStrings_hexadecimal  "$(EncodeArgs 0 1 "64666467646667;6466676466;31323334353637383930" dfdgdfg dfgdf 1234567890 )"\
																													"$(EncodeArgs 1 1 "64666467646667;6466676466;3132333435363738393" dfdgdfg dfgdf 123456789 )" \
																													"$(EncodeArgs 1 1 "6466646764666;6466676466;3132333435363738393" dfdgdf  )" \
																													"$(EncodeArgs 1 1 "64666467646663;6466676466;3132333435363738393" dfdgdfc dfgdf 123456789 )"
	test_FuncType_echo vt100_DECUDK		"$(EncodeArgs 0 3 0 1 17 "${DCS}0;1|17${ST}" )" \
																		"$(EncodeArgs 0 4 0 1 17 12 "${DCS}0;1|17;12${ST}")"

	test_FuncType_echo vt100_DECRQSS    "$(EncodeArgs 0 1 DECSCA	"${DCS}\$q“q${ST}" )" \
																			"$(EncodeArgs 0 1 DECSCL	"${DCS}\$q“p${ST}" )" \
																			"$(EncodeArgs 0 1 DECSTBM "${DCS}\$qr${ST}" )"  \
																			"$(EncodeArgs 0 1 SGR			"${DCS}\$qm${ST}" )"  \
																			"$(EncodeArgs 1 1 SGR1		"" )"  
																		#DecodedArgs DDD "$(EncodeArgs 1 SGR1		"" )" 
																		#echo 	"DDD=$(CreateSQuotedArgList "${DDD[@]}" )" 

	test_FuncType_echo vt100_ReqTermcapStr	"$(EncodeArgs 0 1 reasr1	"${DCS}+q726561737231${ST}" )" \ 
																					"$(EncodeArgs 0 2 41241 21rsfsd	"${DCS}+q3431323431;32317273667364${ST}" )" 



	sNormalExit 0
fi

