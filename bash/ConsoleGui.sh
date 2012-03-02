#!/bin/bash 
#set -o errexit 
#set -o errtrace 
#set -o nounset 
[[ "${DEBUG:-0}" != "1" ]] || set -o xtrace
#<KHeader>
#+=========================================================================
#I               EApiDK Embedded Application Development Kit
#+=========================================================================
#I  $HeadURL: svn+ssh://dethdeg.dvrdns.org/svn/KScripts2/trunk/bash/ConsoleGui.sh $
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
#I  File Name            : ConsoleGui.sh
#I  File Location        : apps\EApiValidateAPI\WINNT
#I  Last committed       : $Revision: 53 $
#I  Last changed by      : $Author: dethrophes $
#I  Last changed date    : $Date: 2012-02-17 14:29:00 +0100 (Fri, 17 Feb 2012) $
#I  ID                   : $Id: ConsoleGui.sh 53 2012-02-17 13:29:00Z dethrophes $
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
		if [ ${1} -ge ${2} ]; then
			echo ${2}
		else
			echo ${1}
		fi
		return 0
	}
	function MinLimitCheck {
		if [ ${1} -le ${2} ]; then
			echo ${2}
		else
			echo ${1}
		fi
		return 0
	}
	function SetVariable {
			#echo "${1}[${WindowDescIndexes[${2}]}]=\"${3}\""
			eval ${1}[${2}]='"${3}"'
	}
	function AppendVariable {
			#echo "${1}[${WindowDescIndexes[${2}]}]=\"${3}\""
			eval ${1}[${2}]+='"${3}"'
	}
	function AddtoVariable {
			#echo "${1}[${WindowDescIndexes[${2}]}]=\"${3}\""
			eval let ${1}[${2}]+='"${3}"'
	}
	function GetVariable {
			#echo "${1}[${WindowDescIndexes[${2}]}]"  >&2
			eval echo "\"\${${1}[${2}]}\""
	}
	function DeclareReadOnlyIndexes {
		declare -ga ${1}
		local AName=${1}
		while [ $# -gt 0 ]; do 
			eval declare -gir ${1}=$#
			SetVariable ${AName} $# "${1}"
			shift
		done
	}
	DeclareReadOnlyIndexes WindowDescIndexes StartCol StartLine WindowWidth WindowLen \
												 xpos1 xpos2 xposl xposr xstepsize xscrollOffset \
												 yscrollOffset ypos1 ypos2 yposl yposh ystepsize \
												 yscroll xscroll WindowBuffer BufferLines BufferMWidth \
												 WindowName HeaderLen xMargin HLType BufferFile BFileModTime \
												 WindowControlFunc


	DeclareReadOnlyIndexes HLTypes HLLine NoHL 


	function DebugMsg {
		local -i OBufLen=$(GetVariable HeaderWindowBufferDesc ${BufferLines})
		local -i OCurPos=$(GetVariable HeaderWindowBufferDesc ${yposl})
		AppendWindowBuffer HeaderWindowBufferDesc "${1}"$'\n'
		if [ ${OCurPos} -eq ${OBufLen} ]; then
			SetWindowCursorPositionToLastLine HeaderWindowBufferDesc 
			PrintWindow HeaderWindowBufferDesc
		fi
	}
	function CreateDebugPrintVariableString {
		local -r AName=${1} 
		while shift && [ $# -gt 0 ]; do
			echo -n "${AName}[${WindowDescIndexes[${1}]}]=\"$(GetVariable ${AName} ${1})\" "
		done
	}
	function DebugPrintVariable {
		DebugMsg "$(CreateDebugPrintVariableString "${@}")"
	}

	function GetFileModDate {
		stat -c %Y "${1}"
	}
	function InitWindowDesc {
		local TmpBufFile
		SetVariable ${1} ${WindowName}	 "${2}"
		SetWindowrPosition ${1} 0 10 0 10
		SetVariable ${1} ${xstepsize}			5
		SetVariable ${1} ${xscrollOffset}	3
		SetVariable ${1} ${ystepsize}			1
		SetVariable ${1} ${yscrollOffset}	3
		SetVariable ${1} ${yscroll}				1
		SetVariable ${1} ${xscroll}				1
		SetVariable ${1} ${WindowControlFunc}		${6:-}
		SetWindowHeaderLen ${1} "${3}"
		SetWindowCursorPositionToFirstLine ${1}
		SetVariable ${1} ${xMargin}				0
		SetWindowBuffer ${1} $'Header\nDummy\nContent' 
		SetWindowHLMode	${1}  ${4}
		if [ ${5} -gt 0 ]; then
			CreateTempFile TmpBufFile
			SetBufferFileName ${1} "${TmpBufFile}"
			SetVariable ${1} "${BFileModTime}" "$(GetFileModDate "${TmpBufFile}")"
		else
			SetBufferFileName ${1} "" 
		fi
	}
	#	SetWindowBuffer MainWindowBufferDesc "WindowBuffer Content"
	function EchoWindowBuffer {
		GetVariable ${1} ${WindowBuffer}
	}
	function GetSelectedLines {
		GetVariable ${1} ${WindowBuffer}  | awk "NR>=$(GetVariable ${1} ${yposl}) && NR<=$(GetVariable ${1} ${yposh}) "
	}

	function SetWindowBuffer {
		SetVariable ${1} ${WindowBuffer}			"${2}"
		SetVariable ${1} ${BufferLines}  $(MinLimitCheck $(($(GetLinesInString "${2}") - $(GetVariable ${1} ${HeaderLen}) )) 1)
		SetVariable ${1} ${BufferMWidth} $(MinLimitCheck $(GetLongestLineInString "${2}")  1)
	}
	function SetWindowrPosition {
		#cDebugOut 0 "${@}"
		SetVariable ${1} ${StartCol}			"${2}"
		SetVariable ${1} ${WindowWidth}		"${3}"
		SetVariable ${1} ${StartLine}			"${4}"
		SetVariable ${1} ${WindowLen}			"${5}"
	}
	function SetWindowCursorPosition {
		#cDebugOut 0 "${@}"
		SetVariable ${1} ${xpos1}	"${2}"
		SetVariable ${1} ${xpos2}	"${2}"
		SetVariable ${1} ${xposl}	"${2}"
		SetVariable ${1} ${xposr}	"${2}"
		SetVariable ${1} ${ypos1}	"${3}"
		SetVariable ${1} ${ypos2}	"${3}"
		SetVariable ${1} ${yposl}	"${3}"
		SetVariable ${1} ${yposh}	"${3}"
	}
	function SetWindowCursorPositionToFirstLine {
			SetWindowCursorPosition ${1} 1 $(($(GetVariable ${1} ${HeaderLen})+1))
	}
	function SetWindowCursorPositionToLastLine {
			SetWindowCursorPosition ${1} 1 $(GetVariable ${1} ${BufferLines})
	}
	function AppendWindowBuffer {
		local -i MLen=$(GetLongestLineInString "${2}")
		AppendVariable ${1} ${WindowBuffer}			"${2}"
		AddtoVariable ${1} ${BufferLines}  $(($(GetLinesInString "${2}")-1))
		if [ ${MLen} -gt $(GetVariable ${1} ${BufferMWidth}) ]; then
			SetVariable ${1} ${BufferMWidth} ${MLen}
		fi
	}
	function SetWindowHeaderLen {
			SetVariable ${1} ${HeaderLen} "${2}"
	}
	function GetBufferFileName {
			GetVariable ${1} ${BufferFile}
	}
	function RunControlFunc {
		$(GetVariable ${1} ${WindowControlFunc}) ${1}
	}
	function SetBufferFileName {
			SetVariable ${1} ${BufferFile} "${2}"
	}
	function SetWindowHLMode {
			SetVariable ${1} ${HLType} "${2}"
	}
	function ListVariables_dbg {
		while [ $# -gt 0 ]; do
			cDebugOut 1 "${1}=${!1}"
			shift
		done
	} 
	#CalculateScrollPos ${WindowDesc} ${ypos1} ${yscroll} ${WindowLen} ${BufferLines} ${yscrollOffset}
	function CalculateScrollPos {
		#cDebugOut 1 "${@}"
		local -i cPos=$(GetVariable ${1} ${2})
		local -i wPos=$(GetVariable ${1} ${3})
		local -i wLen=$(GetVariable ${1} ${4})
		local -i BufferLen=$(GetVariable ${1} ${5})
		local -i scroll_offset=$(GetVariable ${1} ${6})

		#ListVariables_dbg  cPos wPos wLen  BufferLen scroll_offset 
		if [ ${cPos} -gt $(( ${wPos} + ${wLen} -${scroll_offset} )) ]; then
			wPos=$(MaxLimitCheck $(( ${cPos} - ${wLen} + ${scroll_offset}  ))  $(( ${BufferLen} -${wLen} )))
			[ ${wPos} -lt 1 ] && wPos=1
		elif [ ${cPos} -lt $(( ${wPos} +${scroll_offset} )) ]; then
			wPos="$(DecCnt ${cPos} ${scroll_offset} $((1)) )"
		fi
		#ListVariables_dbg  cPos wPos wLen  BufferLen scroll_offset 
		SetVariable ${1} ${3} ${wPos}
	}
	#OrderLinePos ${WindowDesc} ${ypos1} ${ypos2} ${yposl} ${yposh}
	function OrderLinePos {
		local -ir pos1=$(GetVariable ${1} ${2}) 
		local -ir pos2=$(GetVariable ${1} ${3}) 
		if [ ${pos1} -le ${pos2} ]; then
			SetVariable ${1} ${4} ${pos1}
			SetVariable ${1} ${5} ${pos2}
		else
			SetVariable ${1} ${4} ${pos2}
			SetVariable ${1} ${5} ${pos1}
		fi
	}

	# PrintWindow WindowDesc
	function PrintWindow {
		local -ri WindowWidthC=$(GetVariable ${1} ${WindowWidth})
		local -ri StartColC=$(GetVariable ${1} ${StartCol})
		local -ri WindowLenC=$(GetVariable ${1} ${WindowLen})
		[ ${WindowWidthC} -eq 0 -o ${WindowLenC} -eq 0 ] && return 0
		function PrintLine {
			tput cup ${Line} ${StartColC}
			printf "${3:-}%-${WindowWidthC}s${NO_COLOUR}" "${2}"
			let Line+=1
		}
		#
		# Nuffer Specific Variable
		#
		local -i Line=$(GetVariable ${1} ${StartLine})
		CalculateScrollPos ${1} ${ypos1} ${yscroll} ${WindowLen} ${BufferLines}	 ${yscrollOffset}
		CalculateScrollPos ${1} ${xpos1} ${xscroll} ${WindowWidth}  ${BufferMWidth} ${xscrollOffset}
		#
		# Nuffer Specific Variable
		#
		local -ri SelectStart=$(GetVariable ${1} ${yposl})
		local -ri SelectStop=$(GetVariable ${1} ${yposh})
		local -ri FDispCol=$(GetVariable ${1} ${xscroll}) 
		local -ri FDispLine=$(GetVariable ${1} ${yscroll}) 
		local -ri LDispCol=${FDispCol}+${WindowWidthC}
		local -ri LDispLine=${FDispLine}+${WindowLenC}
		local -ri HeaderLenC=$(GetVariable ${1} ${HeaderLen})
		local -ri HLType_lcl=$(GetVariable ${1} ${HLType})
		#cDebugOut 0 "${1} FDispCol=${FDispCol}  LDispCol=${LDispCol} SelectStart=${SelectStart} " 
		#cDebugOut 0 "${1} FDispLine=${FDispLine} LDispLine=${LDispLine} SelectStop=${SelectStop} " 
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

		#cDebugOut 0 "${1} CBufOffst=${CBufOffst} LDispLine=${LDispLine} SelectStop=${SelectStop} " 
			while [ ${LDispLine} -gt ${CBufOffst} ] && read CLine; do 
				let CBufOffst+=1
				[ ${FDispLine} -lt ${CBufOffst} ] || continue
				#cDebugOut 0 "${1} CBufOffst=${CBufOffst} LDispLine=${LDispLine} SelectStop=${SelectStop} " 
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
		#cDebugOut 0 "${1} CBufOffst=${CBufOffst} LDispLine=${LDispLine} SelectStop=${SelectStop} " 
			while [ ${LDispLine} -gt ${CBufOffst} ] ; do 
				let CBufOffst+=1 
				PrintLine ${1} ""
			done || true  ;
		}
	}
	#DecCnt val StepSize Limit 
	function IncCnt {
		MaxLimitCheck $(( ${1}+${2} ))  ${3}
	}
	#DecCnt val StepSize Limit 
	function DecCnt {
		MinLimitCheck $(( ${1}-${2} ))  ${3}
	}
	#IncPos WindowDesc ${xpos1} 1 ${BufferLines} 
	function IncPos {
		local Val=$(MaxLimitCheck $(( $(GetVariable ${1} ${2})+$(GetVariable ${1} ${3}) ))  $(($(GetVariable ${1} ${4})+1)))
		local VName
		SetVariable ${1} ${2} ${Val}
		for VName in "${@:5}"; do
			SetVariable ${1} ${VName} ${Val}
		done
	}
	#DecPos WindowDesc ${xpos1} 1 ${BufferLines} 
	function DecPos {
		local Val=$(MinLimitCheck $(( $(GetVariable ${1} ${2})-$(GetVariable ${1} ${3}) ))  $(($(GetVariable ${1} ${4})+1)))
		local VName
		SetVariable ${1} ${2} ${Val}
		for VName in "${@:5}"; do
			SetVariable ${1} ${VName} ${Val}
		done
	}
declare -gi FullRefresh=1
declare -gi TabIndex=0
  function WrapInc {
		local -i val=${1}+1
		if [ ${val} -eq ${2} ]; then
			ReturnString 0
		else
			ReturnString ${val}
		fi
	}
  function WrapDec {
		if [ ${1} -eq 0 ]; then
			ReturnString $((${2} - 1 ))
		else
			ReturnString $((${1}-1))
		fi
	}
		function CmnWindowFunctions {
			case "${key}" in
				home)				SetWindowCursorPositionToFirstLine ${1}  ;;
				pageUp)			DecPos ${1} ${ypos1} ${WindowLen}		${HeaderLen}		${ypos2} ${yposl} ${yposh} ;;
				up)					DecPos ${1} ${ypos1} ${ystepsize}		${HeaderLen}		${ypos2} ${yposl} ${yposh} ;;
				shift-up)		DecPos ${1} ${ypos1} ${ystepsize}		${HeaderLen}						 
										OrderLinePos ${1} ${ypos1} ${ypos2} ${yposl} ${yposh}
					;;

				end)				SetWindowCursorPositionToLastLine ${1}  ;;
				pageDown)		IncPos ${1} ${ypos1} ${WindowLen}		${BufferLines}	${ypos2} ${yposl} ${yposh} ;;
				down)				IncPos ${1} ${ypos1} ${ystepsize}		${BufferLines}	${ypos2} ${yposl} ${yposh} ;;
				shift-down)	IncPos ${1} ${ypos1} ${ystepsize}		${BufferLines}
										OrderLinePos ${1} ${ypos1} ${ypos2} ${yposl} ${yposh}
					;;

				left)				DecPos ${1} ${xpos1} ${xstepsize}		${xMargin}			${xpos2} ${xposl} ${xposr} ;;
				ctrl-left)	DecPos ${1} ${xpos1} ${WindowWidth}	${xMargin}			${xpos2} ${xposl} ${xposr} ;;

				right)			IncPos ${1} ${xpos1} ${xstepsize}		${BufferMWidth} ${xpos2} ${xposl} ${xposr} ;;
				ctrl-right)	IncPos ${1} ${xpos1} ${WindowWidth}	${BufferMWidth} ${xpos2} ${xposl} ${xposr} ;;

				f5|ctrl-r)	FullRefresh=1 ;;
				Horizontal-Tab)				TabIndex=$(WrapInc ${TabIndex}  ${#TabWindowIndex[@]}) ;;
				shift-Horizontal-Tab)	TabIndex=$(WrapDec ${TabIndex}  ${#TabWindowIndex[@]}) ;;


				End-of-Text|q) clear; break ;;
			esac
			#OrderLinePos ${1} ${xpos1} ${xpos2} ${xposl} ${xposr}
			#DebugPrintVariable ${1} ${yposl} ${yposh} ${BufferLines}
		}
	function ToggleDisplayWindow {
		if [ ${!1} -eq 0 ]; then
			eval ${1}=${2}
		else
			eval ${1}=0
		fi
		FullRefresh=1
	}
	function uTorrent_I {
		local utctrl="${PythonDir}/utorrentctl.py"
		local  DCmd
		#local  SDCmd="${utctrl} --list"
		#local  SDCmd="ps -alx"
		local  SDCmd="cd $(pwd) && ls -aZl --group-directories-first --si --dereference --ignore-backups --dired  | grep -v '\s\.\w'" #"
		 
		local  EPID
		local -i ActiveReload=0
		CreateTempFile DCmd

		typeset -ga TabWindowIndex
		TabIndex=0

		declare -ga HeaderWindowBufferDesc
		declare -ga BrowserWindowBufferDesc
		declare -ga MainWindowBufferDesc
		declare -ga CmdWindowBufferDesc
		InitWindowDesc	HeaderWindowBufferDesc	"HeaderWindow"	0	${NoHL}		0 GenericWindowControl
		InitWindowDesc	BrowserWindowBufferDesc	"BrowserWindow" 0	${NoHL}   0 GenericWindowControl
		InitWindowDesc	MainWindowBufferDesc		"MainWindow"		1	${HLLine} 1 BrowseFiles
		InitWindowDesc	CmdWindowBufferDesc			"CmdWindow"			0	${NoHL}   0 CmdWindowControl
		push_element TabWindowIndex MainWindowBufferDesc HeaderWindowBufferDesc BrowserWindowBufferDesc CmdWindowBufferDesc
		local -r MainWindowBufFile="$(GetBufferFileName	MainWindowBufferDesc)"
		#local -r CmdWindowBufFile="$(GetBufferFileName	CmdWindowBufferDesc)"
		#exec 2>${CmdWindowBufFile}
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
			SetWindowrPosition HeaderWindowBufferDesc											 0	${ConsoleCols}														0 ${AHeaderWindowHeight} 
			SetWindowrPosition BrowserWindowBufferDesc										 0	${ABrowserWindowWidth}	${AHeaderWindowHeight} ${MainWindowHeight} 
			SetWindowrPosition MainWindowBufferDesc			${ABrowserWindowWidth} ${MainWindowWidth}		${AHeaderWindowHeight} ${MainWindowHeight} 
			SetWindowrPosition CmdWindowBufferDesc												 0	${ConsoleCols}				$((${MainWindowHeight}+${AHeaderWindowHeight}))   ${ACmdWindowHeight} 
			return 0
		}
		trap "ScreenRefresh;cls" SIGWINCH

		function LoadCmd {
			SDCmd="$(< "${DCmd}")"
		}
		function IssueCmd {
			if [ ${ActiveReload:-0} -eq 1 ]; then
				DebugMsg "${*:2}"
				echo "${@:2}"  >"${DCmd}" 
				kill -s USR2 ${EPID}
			else
				SDCmd="${*:2}"
				COLUMNS=500 SetWindowBuffer ${1} "$(eval ${SDCmd} )"
				SetWindowCursorPositionToFirstLine ${1} 
				PrintWindow ${1}
			fi
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
			tput cup 0 0 
		}
		function ReloadBuffer {
			if [ ${ActiveReload:-0} -eq 1 ]; then
				SetWindowBuffer MainWindowBufferDesc "$(< "${MainWindowBufFile}")"
			else
				COLUMNS=500 SetWindowBuffer MainWindowBufferDesc "$(eval ${SDCmd} )"
			fi
			PrintWindow MainWindowBufferDesc
		}
		function MainWindow {
			IFS=$'\n' local -a CurrentTorrents=($(GetSelectedLines "${@}" | awk '{ print $3 }' ))
			[ ${#CurrentTorrents[*]} -gt 0 ] && echo "Sel=( ${CurrentTorrents[*]} )"
			key="$(ReadKey)"
			case "${key}" in
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

		function BrowseFiles {
			ActiveReload=0
			 IFS=$'\n' local -a CurrentFiles=( "$(GetSelectedLines "${@}" |sed -r 's/^.{58}\s*\S*\s*//' )" )
			#[ ${#CurrentFiles[*]} -gt 0 ] && DebugMsg "Sel=( $(CreateEscapedArgList "${CurrentFiles[@]}") )"
			#DebugMsg "$(pwd)"
			key="$(ReadKey)"
			
			case ${#CurrentFiles[*]} in 
				0) 
					case "${key}" in
						d) ToggleDisplayWindow AHeaderWindowHeight	${HeaderWindowHeight} ;;
						c) ToggleDisplayWindow ACmdWindowHeight			${CmdWindowHeight}		;;
						b) ToggleDisplayWindow ABrowserWindowWidth	${BrowserWindowWidth} ;;
						*) CmnWindowFunctions "${@}"  ;;
					esac
					;;
				*)
					case "${key}" in
						d) ToggleDisplayWindow AHeaderWindowHeight ${HeaderWindowHeight} ;;
						c) ToggleDisplayWindow ACmdWindowHeight			${CmdWindowHeight}		;;
						b) ToggleDisplayWindow ABrowserWindowWidth	${BrowserWindowWidth} ;;
						Backspace) 
							cd ".."
							IssueCmd ${1} "cd '"$(pwd)"' && ls  -aZl --group-directories-first --si --dereference --ignore-backups --dired | grep -v '\s\.\w'" #--color=always"
							;;
						Carriage-return|Enter|Line-feed|' ') 
							#DebugMsg "$(pwd)"
							if [ -d "${CurrentFiles[0]}" ]; then
								cd "${CurrentFiles[0]}"
								IssueCmd ${1} "cd '"$(pwd)"' && ls  -aZl --group-directories-first --si --dereference --ignore-backups --dired | grep -v '\s\.\w'" #--color=always"
								#ReloadBuffer 
							fi
							;;

						*) CmnWindowFunctions "${@}"  ;;
					esac
					;;
			esac
			return 0
		}
		function TorentWindow {
			IFS=$'\n' local -a CurrentFiles=($(GetSelectedLines "${@}" | awk '{ print $1 }' ))
			key="$(ReadKey)"
			case "${key}" in
				Escape|q) 
					IssueCmd ${1} "${utctrl}" --list 
					;;
				*) CmnWindowFunctions "${@}" || return $? ;;
			esac
		}
		function PutCursor {
			local -i col=$(GetVariable ${1} ${xpos1})-$(GetVariable ${1} ${xscroll})+$(GetVariable ${1} ${StartCol})
			local -i line=$(GetVariable ${1} ${ypos1})-$(GetVariable ${1} ${yscroll})+$(GetVariable ${1} ${StartLine})
			tput cup ${line} ${col}
		}
		function CmdWindowControl {
			PutCursor ${1}
			read -e 2>&1
			Content="${REPLY}"
			AppendWindowBuffer ${1} "${REPLY}"
			SetWindowCursorPositionToLastLine
			#key="$(ReadKey)"
			#case "${key}" in
			#	*) CmnWindowFunctions "${@}" || return $? ;;
			#esac
		}
		function GenericWindowControl {
			key="$(ReadKey)"
			case "${key}" in
				*) CmnWindowFunctions "${@}" || return $? ;;
			esac
		}

		#trap ReloadBuffer USR2
		#while true; do
		#	trap LoadCmd USR2
		#	COLUMNS=500 echo "$(eval ${SDCmd})" >"${MainWindowBufFile}" 2>/dev/null
		#	kill -s USR2 $$ 2>/dev/null || exit 0
		#	sleep 1
		#done &
		#EPID=$!
		local Key
		#clear
		SetWindowBuffer CmdWindowBufferDesc ">"
		IssueCmd MainWindowBufferDesc "ls  -aZl --group-directories-first --si --dereference --ignore-backups --dired | grep -v '\s\.\w'" #--color=always"
		FullRefresh=1
		while true; do
			#SetWindowBuffer CmdWindowBufferDesc "$(< "${CmdWindowBufFile}")"
			ScreenRefresh
			RunControlFunc ${TabWindowIndex[${TabIndex}]} || break
			#DebugMsg "key=${key} TabIndex=${TabIndex} ${TabWindowIndex[${TabIndex}]}"
		done
		#kill ${EPID}
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

	ConsoleGuiRevision=$(CleanRevision '$Revision: 53 $')
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

