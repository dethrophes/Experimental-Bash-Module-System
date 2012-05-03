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
#I              File Name            : ConsoleGui.sh
#I
#+-------------------------------------------------------------------------
#I
#I  File Name            : ConsoleGui.sh
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
		ScriptDir[1]="$(dirname "$(which "GenFuncs.sh")")"
		source "$(which "GenFuncs.sh")" || exit
	else
		echo "# "
		echo "# Error Exit : Error Sourcing \"${ScriptDir}/GenFuncs.sh\"" >&2
		echo "# "
		exit 7
	fi
fi
#SourceCoreFiles_ "DiskFuncs.sh"
#SourceFiles_ "${ScriptDir}/DiskFuncs.sh"

if [ -z "${__ConsoleGui_sh__:-}" ]; then
	__ConsoleGui_sh__=1

	
	#########################################################################
	# Procedures
	#########################################################################

	SingleLine="--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	DoubleLine="=================================================================================================================================================================================================================================================="
	function nop {
		echo -n ""
	}
	function MaxLimitCheck {
		if [ ${2:?Missing Variable 1} -ge ${3:?Missing Variable 2} ]; then
			set_variable "${1:?Missing Destination Variable}" "${3}"
		else
			set_variable "${1:?Missing Destination Variable}" "${2}"
		fi
		return 0
	}
	function MinLimitCheck {
		if [ ${2:?Missing Variable 1} -le ${3:?Missing Variable 2} ]; then
			set_variable "${1:?Missing Destination Variable}" "${3}"
		else
			set_variable "${1:?Missing Destination Variable}" "${2}"
		fi
		return 0
	}
	function AppendVariable {
			#echo "${1}[${WindowDescIndexes[${2}]}]=\"${3}\""
			eval "${1}[${2}]"+='"${3}"'
	}
	function AddtoVariable {
			#echo "${1}[${WindowDescIndexes[${2}]}]=\"${3}\""
			eval let "${1}[${2}]"+='"${3}"'
	}
	function DeclareReadOnlyIndexes {
		declare -ga "${1:?Missing Array Name}"
		local AName="${1}" 
		while shift && [ $# -gt 0 ]; do 
			declare -gir "${1}"=$#
			set_array_element "${AName}" $# "${1}"
		done
	}
	DeclareReadOnlyIndexes WindowDescIndexes StartCol StartLine WindowWidth WindowLen \
												 xpos1 xpos2 xposl xposr xstepsize xscrollOffset \
												 yscrollOffset ypos1 ypos2 yposl yposh ystepsize \
												 yscroll xscroll WindowBuffer BufferLines BufferMWidth \
												 WindowName HeaderLen xMargin HLType BufferFile BFileModTime \
												 WindowControlFunc WindowRefreshFunc eWindowLen WindowSelectable


	DeclareReadOnlyIndexes HLTypes HLLine NoHL 


	function DebugWindowOut {
		local WindowDesc="CmdWindowBufferDesc"
		local -i OBufLen
		local -i OCurPos
		get_array_element "OBufLen"			"${WindowDesc}" "${BufferLines}"
		get_array_element "OCurPos"			"${WindowDesc}" "${yposl}"
		AppendWindowBuffer "${WindowDesc}" $'\n'"${2}"
		if [ ${OCurPos} -eq ${OBufLen} ]; then
			SetWindowCursorPositionToLastLine "${WindowDesc}" 
		fi
		PrintWindow "${WindowDesc}"
	}
	function sDebugMsg {
		if false; then
			DebugOut 1 "${@}"
		else
			DebugOut 1 "${@}"
			DebugWindowOut 1 "${@}"
		fi
	}
	function CreateDebugPrintVariableString {
		local -r AName="${1:?Missing WindowDesc}" 
		local Val
		while shift && [ $# -gt 0 ]; do
			echo -n "${AName}[${WindowDescIndexes[${1}]}]="
			get_array_element Val "${AName}" "${1}"
			printf "%q " "${Val}"
		done
	}
	function DebugPrintVariable {
		DebugOut 1 "$(CreateDebugPrintVariableString "${@}")"
	}

	function GetFileModDate {
		stat -c %Y "${1}"
	}
	function InitWindowDesc {
		local TmpBufFile
		set_array_element		"${1:?Missing WindowDesc}" "${WindowName}"	 "${2:?Missing Window Name}"
		set_array_element		"${1}" "${xstepsize}"			5
		set_array_element		"${1}" "${xscrollOffset}"	3
		set_array_element		"${1}" "${ystepsize}"			1
		set_array_element		"${1}" "${yscrollOffset}"	3
		set_array_element		"${1}" "${yscroll}"				1
		set_array_element		"${1}" "${xscroll}"				1
		set_array_element		"${1}" "${WindowControlFunc}"	"${6:-nop}"
		set_array_element		"${1}" "${WindowRefreshFunc}"	"${7:-nop}"
		SetWindowHeaderLen	"${1}" "${3:?Missing Header Length}"
		SetWindowrPosition	"${1}" 0 10 0 10

		SetWindowCursorPositionToFirstLine "${1}"
		set_array_element		"${1}" "${xMargin}"				0
		SetWindowBuffer			"${1}" $'Header\nDummy\nContent' 
		SetWindowHLMode			"${1}" "${4:?Missing Window Highlight Mode}"
		if [ ${5:?Missing Create Tmp File} -gt 0 ]; then
			CreateTempFile TmpBufFile
			SetBufferFileName "${1}" "${TmpBufFile}"
			set_array_element "${1}" "${BFileModTime}" "$(GetFileModDate "${TmpBufFile}")"
		else
			SetBufferFileName "${1}" "" 
		fi
	}
	#	SetWindowBuffer MainWindowBufferDesc "WindowBuffer Content"
	function EchoWindowBuffer {
		get_array_element_echo "${1:?Missing WindowDesc}" "${WindowBuffer}"
	}
	function GetSelectedLines {
		local lpos
		local rpos
		get_array_element lpos ${1:?Missing WindowDesc} ${yposl}
		get_array_element rpos ${1} ${yposh}
		get_array_element_echo ${1} ${WindowBuffer}  | awk "NR>=${lpos} && NR<=${rpos} "
	}

	function SetWindowBuffer {
		local hlen
		local val
		get_array_element hlen ${1:?Missing WindowDesc} ${HeaderLen}
		set_array_element ${1} ${WindowBuffer}			"${2}"
		local LinesInStr
		GetLinesInString LinesInStr "${2}"
		MinLimitCheck "val"  $((${LinesInStr}- ${hlen} ))	0
		set_array_element ${1} ${BufferLines}			"${val}"

		MinLimitCheck "val" $(GetLongestLineInString_echo "${2}")						1
		set_array_element ${1} ${BufferMWidth}			"${val}"
		
		#CreateDebugPrintVariableString "${1}" "${BufferLines}" "${BufferMWidth}"
	}
	function LoadWindowBuffer {
		local WindowBufFile
		GetBufferFileName	WindowBufFile "${1:?Missing WindowDesc}"
		SetWindowBuffer "${1}" "$(< "${WindowBufFile}")"
		set_array_element "${1}" "${BFileModTime}" "$(GetFileModDate "${WindowBufFile}")"
	}
	function SetWindowrPosition {
		local hlen
		#cDebugOut 0 "${@}"
		set_array_element "${1:?Missing WindowDesc}" "${StartCol}"			"${2:?Missing StartCol}"
		set_array_element "${1}" "${WindowWidth}"		"${3:?Missing WindowWidth}"
		set_array_element "${1}" "${StartLine}"			"${4:?Missing StartLine}"
		set_array_element "${1}" "${WindowLen}"			"${5:?Missing WindowLen}"
		get_array_element hlen ${1} ${HeaderLen}
		if [ ${hlen} -eq 0 ]; then
			set_array_element "${1}" "${eWindowLen}"		${5}
		else
			set_array_element "${1}" "${eWindowLen}"		$((${5}-${hlen}-1))
		fi
	}
	function SetWindowCursorPosition {
		#cDebugOut 0 "${@}"
		set_array_element "${1:?Missing WindowDesc}" "${xpos1}"	"${2:?Missing X Pos}"
		set_array_element "${1}" "${xpos2}"	"${2}"
		set_array_element "${1}" "${xposl}"	"${2}"
		set_array_element "${1}" "${xposr}"	"${2}"
		set_array_element "${1}" "${ypos1}"	"${3:?Missing Y Pos}"
		set_array_element "${1}" "${ypos2}"	"${3}"
		set_array_element "${1}" "${yposl}"	"${3}"
		set_array_element "${1}" "${yposh}"	"${3}"
	}
	function SetWindowCursorPositionToFirstLine {
			local hlen
			get_array_element hlen  "${1:?Missing WindowDesc}" "${HeaderLen}"
			SetWindowCursorPosition "${1}" 1 $((${hlen}+1))
	}
	function SetWindowCursorPositionToLastLine {
			local blines
			get_array_element blines  "${1:?Missing WindowDesc}"   "${BufferLines}"
			SetWindowCursorPosition		"${1}" 1 "${blines}"
	}
	function AppendWindowBuffer {
		local -i MLen=$(GetLongestLineInString_echo "${2}")
		AppendVariable "${1:?Missing WindowDesc}" "${WindowBuffer}"	"${2}"
		local bminw
		get_array_element bminw "${1}" "${BufferMWidth}"
		local LinesInStr
		GetLinesInString LinesInStr "${2}"
		#sDebugOut  LinesInStr "${2}"  "${LinesInStr}" 
		AddtoVariable "${1}" "${BufferLines}"  $((${LinesInStr}-1))
		if [ ${MLen} -gt ${bminw} ]; then
			set_array_element "${1}" "${BufferMWidth}" "${MLen}"
		fi
	}
	function SetWindowHeaderLen {
			set_array_element "${1:?Missing WindowDesc}" "${HeaderLen}" "${2:-0}"
	}
	function GetBufferFileName {
		get_array_element "${1:?Missing Destination Variable}"	"${2:?Missing WindowDesc}" "${BufferFile}"
	}
	function RunWindowInitFunc {
		local CFunc
		get_array_element CFunc	"${1:?Missing WindowDesc}" "${WindowRefreshFunc}"
		#sDebugOut "${CFunc}" "${@}"
		"${CFunc}" "${@}"
	}
	function RunControlFunc {
		local CFunc
		get_array_element CFunc	"${1:?Missing WindowDesc}" "${WindowControlFunc}"
		"${CFunc}" "${@}"
	}
	function SetBufferFileName {
			set_array_element "${1:?Missing WindowDesc}" "${BufferFile}" "${2}"
	}
	function SetWindowHLMode {
			set_array_element "${1:?Missing WindowDesc}" "${HLType}" "${2}"
			set_array_element "${1}" "${WindowSelectable}" "${2}"
	}
	function ListVariables_dbg {
		cDebugOut 1 "$(while [ $# -gt 0 ]; do echo -n "${1}=${!1} " ; shift ; done           )"
	} 
	#CalculateWindowBase ${WindowDesc} ${ypos1} ${yscroll} ${WindowLen} ${BufferLines} ${yscrollOffset}
	function CalculateWindowBase {
		#cDebugOut 1 "${@}"
		local -i CurPos
		local -i WindowBase
		local -i windowLen
		local -i scroll_offset
		#CreateDebugPrintVariableString "${@}"
		get_array_element CurPos					"${1:?Missing WindowDesc}"	"${2:?Missing CurPos}"
		get_array_element WindowBase			"${1}"											"${3:?Missing WindowBase}"
		get_array_element windowLen				"${1}"											"${4:?Missing windowLen}"
		get_array_element scroll_offset		"${1}"											"${6:?Missing scroll_offset}"
		let windowLen-="${8:-0}"

		if [ ${CurPos} -gt $(( ${WindowBase} + ${windowLen} - ${scroll_offset}  )) ]; then
			local -i BufferLen
			get_array_element BufferLen	"${1}"	"${5:?Missing BufferLen}"
			MaxLimitCheck WindowBase $(( ${CurPos} - ${windowLen} + ${scroll_offset}  ))  $(( ${BufferLen} -${windowLen} +1 ))
			[ ${WindowBase} -ge ${7:-0} ] || WindowBase=${7:-0}
		elif [ ${CurPos} -lt $(( ${WindowBase} +${scroll_offset} )) ]; then
			MinLimitCheck WindowBase $((${CurPos}-${scroll_offset})) 1
		fi
		#ListVariables_dbg  CurPos WindowBase windowLen  scroll_offset 
		set_array_element "${1}" "${3}" "${WindowBase}"
	}
	#OrderLinePos ${WindowDesc} ${ypos1} ${ypos2} ${yposl} ${yposh}
	function OrderLinePos {
		local -ir pos1
		local -ir pos2
		get_array_element pos1	 "${1:?Missing WindowDesc}" "${2:?Missing ypos1}"
		get_array_element pos2	 "${1}" "${3:?Missing ypos2}"
		if [ ${pos1} -le ${pos2} ]; then
			set_array_element "${1}" "${4:?Missing posl}" "${pos1}"
			set_array_element "${1}" "${5:?Missing posh}" "${pos2}"
		else
			set_array_element "${1}" "${4:?Missing posl}" "${pos2}"
			set_array_element "${1}" "${5:?Missing posh}" "${pos1}"
		fi
	}
	function TestWindowVisible {
		local -i WindowWidthC
		local -i WindowLenC
		get_array_element WindowWidthC	 "${1:?Missing WindowDesc}" "${WindowWidth}"
		get_array_element WindowLenC     "${1}" "${WindowLen}"
		[ ${WindowWidthC} -ne 0 -a ${WindowLenC} -ne 0 ] || return $?
	}
	function TestWindowSelectable {
		local WinSel
		TestWindowVisible "${1:?Missing WindowDesc}" || return $?
		get_array_element WinSel "${1}" "${WindowSelectable}"
		[ ${WinSel} -ne ${NoHL} ] || return $?
	}

	# PrintWindow WindowDesc
	function PrintWindow {
		TestWindowVisible ${1:?Missing WindowDesc} || return 0

		local -i WindowWidthC
		local -i StartColC
		get_array_element WindowWidthC	 "${1}" "${WindowWidth}"
		get_array_element StartColC      "${1}" "${StartCol}"

		function PrintLine {
			tput cup ${Line} ${StartColC}
			printf "${3:-}%-${WindowWidthC}s${NO_COLOUR}" "${2}"
			let Line+=1
		}
		#
		# Buffer Specific Variable
		#
		local -i HeaderLenC
		local -i Line
		local -i LastLine
		local -i WindowLenC

		get_array_element WindowLenC  "${1}" "${WindowLen}"
		get_array_element HeaderLenC	"${1}" "${HeaderLen}"
		get_array_element Line				"${1}" "${StartLine}"
		LastLine=$((${Line}+${WindowLenC}))
		CalculateWindowBase "${1}" "${ypos1}" "${yscroll}" "${eWindowLen}"	"${BufferLines}"	"${yscrollOffset}" "${HeaderLenC}"
		CalculateWindowBase "${1}" "${xpos1}" "${xscroll}" "${WindowWidth}"  "${BufferMWidth}" "${xscrollOffset}" 0 
		#
		# Buffer Specific Variable
		#
		local -i FDispCol
		local -i FDispLine
		local -i LDispCol

		get_array_element FDispCol    "${1}" "${xscroll}" 
		get_array_element FDispLine   "${1}" "${yscroll}" 
		LDispCol=${FDispCol}+${WindowWidthC}
		#cDebugOut 0 "${1} FDispCol=${FDispCol}  LDispCol=${LDispCol}" 
		#cDebugOut 0 "${1} FDispLine=${FDispLine} LastLine=${LastLine}" 
		#
		# Nuffer Specific Variable
		#
		local CLine
		local -i CBufOffst=0
		EchoWindowBuffer ${1} | cut -c ${FDispCol}-${LDispCol} | { 
			while [ ${HeaderLenC} -gt ${CBufOffst} ] && read CLine; do
				let CBufOffst+=1
				PrintLine ${1} "${CLine}"
			done
			if [ ${HeaderLenC} -gt 0 ] ; then
				PrintLine ${1} "${SingleLine:0:${WindowWidthC}}"
			fi

			local -i SelectStart
			local -i SelectStop
			local -i HLType_lcl
			get_array_element SelectStart "${1}" "${yposl}"
			get_array_element SelectStop  "${1}" "${yposh}"
			get_array_element HLType_lcl	"${1}" "${HLType}"
			#cDebugOut 0 "${1} CBufOffst=${CBufOffst} LastLine=${LastLine} Line=${Line} " 
			while [ ${LastLine} -gt ${Line} ] && read CLine; do 
				let CBufOffst+=1
				[ ${FDispLine} -le ${CBufOffst} ] || continue
				#cDebugOut 0 "${1} CBufOffst=${CBufOffst} LastLine=${LastLine} Line=${Line} ${FDispLine} " 
				case ${HLType_lcl} in
					${HLLine})
						if [ ${SelectStart} -le ${CBufOffst} -a ${SelectStop} -ge ${CBufOffst} ]; then
							PrintLine ${1} "${CLine}" "${ATTRIB_Inverse}"
						else
							PrintLine ${1} "${CLine}"
						fi
						;;
					*)
						PrintLine ${1} "${CLine}"
						;;
				esac
			done || true ;
			#cDebugOut 0 "${1} CBufOffst=${CBufOffst} LastLine=${LastLine} SelectStop=${SelectStop} " 
			while [ ${LastLine} -gt ${Line} ] ; do 
				PrintLine ${1} ""
			done || true  ;
		}
	}
	#IncPos WindowDesc ${xpos1} 1 ${BufferLines} 
	function IncPos {
		local Val VName
		local CurValue StepSize MaxValue
		get_array_element CurValue "${1:?Missing WindowDesc}" "${2:?Missing CurValue variable}"
		get_array_element StepSize "${1}" "${3:?Missing StepSize variable}"
		get_array_element MaxValue "${1}" "${4:?Missing MaxValue variable}"
		MaxLimitCheck Val "$(( ${CurValue}+${StepSize} ))"  "$((${MaxValue}))"
		set_array_element ${1} ${2} ${Val}
		for VName in "${@:5}"; do
			set_array_element ${1} ${VName} ${Val}
		done
	}
	#DecPos WindowDesc ${xpos1} 1 ${BufferLines} 
	function DecPos {
		local Val VName
		local CurValue StepSize MinValue
		get_array_element CurValue "${1:?Missing WindowDesc}" "${2}"
		get_array_element StepSize "${1}" "${3:?Missing StepSize variable}"
		get_array_element MinValue "${1}" "${4:?Missing MinValue variable}"
		MinLimitCheck Val "$(( ${CurValue}-${StepSize} ))"  "$((${MinValue}+1))"
		set_array_element "${1}" "${2}" "${Val}"
		for VName in "${@:5}"; do
			set_array_element "${1}" "${VName}" "${Val}"
		done
	}
	FullRefresh=1
	TabWindowIndex=()
	TabIndex=0
  function WrapInc {
		local -i val=${!1}+1
		if [ ${val} -eq ${2} ]; then
			set_variable "${1}" 0
		else
			set_variable "${1}" ${val}
		fi
	}
  function WrapDec {
		if [ ${!1} -eq 0 ]; then
			set_variable "${1}" $((${2} - 1 ))
		else
			set_variable "${1}" $((${!1}-1))
		fi
	}
	function AdvanceTabWindow {
		while ${1} TabIndex  ${#TabWindowIndex[@]} ; do 
			TestWindowSelectable ${TabWindowIndex[${TabIndex}]} && break; 
		done
	}
	function CmnWindowFunctions {
		case "${UInput[0]}" in
			home)				SetWindowCursorPositionToFirstLine ${1}  ;;
			pageUp)			DecPos ${1} ${ypos1} ${eWindowLen}	${HeaderLen}		${ypos2} ${yposl} ${yposh} ;;
			up)					DecPos ${1} ${ypos1} ${ystepsize}		${HeaderLen}		${ypos2} ${yposl} ${yposh} ;;
			S-up)				DecPos ${1} ${ypos1} ${ystepsize}		${HeaderLen}						 
									OrderLinePos ${1} ${ypos1} ${ypos2} ${yposl} ${yposh}
				;;

			end)				SetWindowCursorPositionToLastLine ${1}  ;;
			pageDown)		IncPos ${1} ${ypos1} ${eWindowLen}	${BufferLines}	${ypos2} ${yposl} ${yposh} ;;
			down)				IncPos ${1} ${ypos1} ${ystepsize}		${BufferLines}	${ypos2} ${yposl} ${yposh} ;;
			S-down)			IncPos ${1} ${ypos1} ${ystepsize}		${BufferLines}
									OrderLinePos ${1} ${ypos1} ${ypos2} ${yposl} ${yposh}
				;;

			left)				DecPos ${1} ${xpos1} ${xstepsize}		${xMargin}			${xpos2} ${xposl} ${xposr} ;;
			C-left)			DecPos ${1} ${xpos1} ${WindowWidth}	${xMargin}			${xpos2} ${xposl} ${xposr} ;;

			right)			IncPos ${1} ${xpos1} ${xstepsize}		${BufferMWidth} ${xpos2} ${xposl} ${xposr} ;;
			C-right)		IncPos ${1} ${xpos1} ${WindowWidth}	${BufferMWidth} ${xpos2} ${xposl} ${xposr} ;;

			f5|C-r)			FullRefresh=1 ;;
			HT)					AdvanceTabWindow WrapInc ;;
			S-HT)				AdvanceTabWindow WrapDec ;;


			End-of-Text|q) clear; break ;;
		esac
		#OrderLinePos ${1} ${xpos1} ${xpos2} ${xposl} ${xposr}
		#DebugPrintVariable ${1} ${yposl} ${yposh} ${BufferLines}
	}
	function ToggleDisplayWindow {
		if [ ${!1} -eq 0 ]; then
			set_variable "${1}" "${2}"
		else
			set_variable "${1}" 0
			TestWindowSelectable ${TabWindowIndex[${TabIndex}]} || AdvanceTabWindow WrapInc
		fi
		FullRefresh=1
	}
	function ScreenRefresh {
		local CWindowDesc
		if [ ${FullRefresh} -gt 0 ]; then
			ReSizeWindows
			for CWindowDesc in "${TabWindowIndex[@]}"; do
				PrintWindow ${CWindowDesc}
			done
			FullRefresh=0
		else
			PrintWindow ${TabWindowIndex[${TabIndex}]}
		fi
		tput cup $((${LINES}-3)) 0
	}
	function uTorrent_I {

		declare -ga HeaderWindowBufferDesc
		declare -ga BrowserWindowBufferDesc
		declare -ga MainWindowBufferDesc
		declare -ga CmdWindowBufferDesc
		InitWindowDesc	HeaderWindowBufferDesc	"HeaderWindow"	0	${HLLine}		0 GenericWindowControl
		InitWindowDesc	BrowserWindowBufferDesc	"BrowserWindow" 0	${HLLine}   0 GenericWindowControl
		InitWindowDesc	MainWindowBufferDesc		"MainWindow"		1	${HLLine} 1 BrowseFiles RefreshBrowser
		InitWindowDesc	CmdWindowBufferDesc			"CmdWindow"			0	${NoHL}   0 GenericWindowControl
		push_element TabWindowIndex MainWindowBufferDesc HeaderWindowBufferDesc BrowserWindowBufferDesc CmdWindowBufferDesc

		local -i HeaderWindowHeight=4
		local -i CmdWindowHeight=5
		local -i BrowserWindowWidth=10
		local -i AHeaderWindowHeight=${HeaderWindowHeight}
		local -i ACmdWindowHeight=${CmdWindowHeight}
		local -i ABrowserWindowWidth=${BrowserWindowWidth}
	
		function ReSizeWindows {
			SetColLines 
			local -i MainWindowHeight=${LINES}-${ACmdWindowHeight}-${AHeaderWindowHeight}-1
			local -i MainWindowWidth=${COLUMNS}-${ABrowserWindowWidth}
			SetWindowrPosition HeaderWindowBufferDesc											 0	${COLUMNS}														0 ${AHeaderWindowHeight} 
			SetWindowrPosition BrowserWindowBufferDesc										 0	${ABrowserWindowWidth}	${AHeaderWindowHeight} ${MainWindowHeight} 
			SetWindowrPosition MainWindowBufferDesc			${ABrowserWindowWidth} ${MainWindowWidth}		${AHeaderWindowHeight} ${MainWindowHeight} 
			SetWindowrPosition CmdWindowBufferDesc												 0	${COLUMNS}				$((${MainWindowHeight}+${AHeaderWindowHeight}))   ${ACmdWindowHeight} 
			return 0
		}
		trap "FullRefresh=1;ScreenRefresh" SIGWINCH

		local utctrl="${PythonDir}/utorrentctl.py"
		#local  SDCmd="${utctrl} --list"
		function RefreshTorrents {
			IssueCmd ${1:?Missing WindowDesc} "${utctrl} --list"
		}
		function MainWindow {
			IFS=$'\n' local -a CurrentTorrents=($(GetSelectedLines "${@}" | awk '{ print $3 }' ))
			#[ ${#CurrentTorrents[*]} -gt 0 ] && echo "Sel=( ${CurrentTorrents[*]} )"
			case "${UInput[0]}" in
				Carriage-return|Enter|Line-feed) 
					IssueCmd ${1} "${utctrl}"--info ${CurrentTorrents} 
					;;
				p) "${utctrl}" --pause ${CurrentTorrents[@]} ;;
				r) "${utctrl}" --resume ${CurrentTorrents[@]} ;;
				p) "${utctrl}" --stop ${CurrentTorrents[@]} ;;
				s) "${utctrl}" --start ${CurrentTorrents[@]} ;;
				S) "${utctrl}" --start --force ${CurrentTorrents[@]} ;;
				c) "${utctrl}" --check ${CurrentTorrents[@]} ;;
				C) "${utctrl}" --check --force ${CurrentTorrents[@]} ;;
				*) CmnWindowFunctions "${@}" || return $? ;;
			esac
		}
		function TorentWindow {
			IFS=$'\n' local -a CurrentFiles=($(GetSelectedLines "${@}" | awk '{ print $1 }' ))
			case "${UInput[0]}" in
				ESC|q) 
					IssueCmd ${1} "${utctrl}" --list 
					;;
				*) CmnWindowFunctions "${@}" || return $? ;;
			esac
		}

		function ListFiles {
			cd "${1}" 
			ls  -aZl --group-directories-first --si --dereference --ignore-backups --dired | grep -v '\s\.\w' #--color=always"
		}
		function RefreshBrowser {
			IssueCmd ${1:?Missing WindowDesc} ListFiles "$(pwd)"
		}
		function BrowseFiles {
			local IFS=$'\n'
			local -a CurrentFiles=( "$(GetSelectedLines "${@}" |sed -r 's/^.{53}\s*\S*\s*//' )" )
			IFS=$' \t\n'
			
			case ${#CurrentFiles[*]} in 
				0) 
					case "${UInput[0]}" in
						d) ToggleDisplayWindow AHeaderWindowHeight	${HeaderWindowHeight} ;;
						c) ToggleDisplayWindow ACmdWindowHeight			${CmdWindowHeight}		;;
						b) ToggleDisplayWindow ABrowserWindowWidth	${BrowserWindowWidth} ;;
						*) CmnWindowFunctions "${@}"  ;;
					esac
					;;
				*)
					case "${UInput[0]}" in
						d) ToggleDisplayWindow AHeaderWindowHeight ${HeaderWindowHeight} ;;
						c) ToggleDisplayWindow ACmdWindowHeight			${CmdWindowHeight}		;;
						b) ToggleDisplayWindow ABrowserWindowWidth	${BrowserWindowWidth} ;;
						DEL) 
							cd ".."
							RefreshBrowser "${1}"
							;;
						LF|' ') 
							if [ -d "${CurrentFiles[0]}" ]; then
								sDebugOut "${CurrentFiles[0]}"
								cd "${CurrentFiles[0]}"
								RefreshBrowser "${1}" 
								#ReloadBuffer "${1}"
							fi
							;;

						*) CmnWindowFunctions "${@}"  ;;
					esac
					;;
			esac
			return 0
		}
		function CmdWindowControl {
			case "${UInput[0]}" in
				*) CmnWindowFunctions "${@}" || return $? ;;
			esac
		}
		function GenericWindowControl {
			case "${UInput[0]}" in
				*) CmnWindowFunctions "${@}" || return $? ;;
			esac
		}

		local  SDCmd="ls"
		if false; then
			local DCmd
			local MainWindowBufFile
			GetBufferFileName	MainWindowBufFile MainWindowBufferDesc
			CreateTempFile DCmd

			function LoadCmd {
				sDebugOut "${SDCmd}"
				SDCmd="$(< "${DCmd}")"
			}
			function RunCmd {
				COLUMNS=500 eval "${SDCmd}"  &>"${MainWindowBufFile}"
				kill -s USR2 $$ 2>/dev/null || exit 0
			}
			{
				trap 'LoadCmd;RunCmd' USR2
				while true; do
					RunCmd
					sDebugOut "${SDCmd}"
					sleep 5
				done 
			}&
			local coprocess_PID=$!
			trap 'ReloadBuffer MainWindowBufferDesc' USR2
			function ReloadBuffer {
				LoadWindowBuffer "${1}"
				PrintWindow "${1}"
			}
			function IssueCmd {
				printf "%q " "${@:2}" >"${DCmd}" 
				kill -s USR2 "${coprocess_PID}"
			}
		else
			function IssueCmd {
				SDCmd="$(printf "%q " "${@:2}")"
				SetWindowCursorPositionToFirstLine ${1} 
				local WindowDesc="MainWindowBufferDesc"
				COLUMNS=500 SetWindowBuffer "MainWindowBufferDesc" "$(eval "${SDCmd}" )"
				PrintWindow "MainWindowBufferDesc"
			}
		fi
		local Key
		SetWindowBuffer CmdWindowBufferDesc ">"
		for CurWindowDesc in "${TabWindowIndex[@]}" ; do
			RunWindowInitFunc  "${CurWindowDesc}" || return $?
		done
		FullRefresh=1
		stty -echo # Prevent Artifacts
		while true; do
			ScreenRefresh
			ReadKey
			RunControlFunc "${TabWindowIndex[${TabIndex}]}" || break
			sDebugMsg "UInput[0]=${UInput[0]} TabIndex=${TabIndex} ${TabWindowIndex[${TabIndex}]}"
		done
		stty echo
		[ -z "${coprocess_PID}" ] || kill ${coprocess_PID}
	}

	#########################################################################
	# Module Argument Handling
	#########################################################################

	function Set_ConsoleGui_Flags {
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
				--uTorrent_I)
					"${1:2}"  "${@:2}"
					exit
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

	CleanRevision_new ConsoleGuiRevision '$Revision: 64 $'
	ConsoleGuiDescription=' -- Functions for implementing console gui applications'
	push_element	ScriptsLoaded "ConsoleGui.sh;${ConsoleGuiRevision};${ConsoleGuiDescription}"
	if [ "${SBaseName2}" = "ConsoleGui.sh" ]; then 
		ScriptRevision="${ConsoleGuiRevision}"

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
		push_element ModulesArgHandlers "Set_ConsoleGui_Flags" "Set_ConsoleGui_exec_Flags"
		#push_element SupportedCLIOptions 
		function Set_ConsoleGui_exec_Flags {
			local -i PCnt=0
			while [ $# -gt 0 ] ; do
				case "${1}" in
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
fi

